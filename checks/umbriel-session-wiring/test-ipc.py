#!/usr/bin/env python3
"""Negative fixtures for the production IPC adapter; no real desktop calls."""

import contextlib
import copy
import importlib.util
import io
import json
import shlex
import sys
from types import SimpleNamespace
import unittest
from unittest import mock

spec = importlib.util.spec_from_file_location("adapter", sys.argv.pop(1))
adapter = importlib.util.module_from_spec(spec)
spec.loader.exec_module(adapter)


def window(identifier, column=0, row=0, app="zen", title="same"):
    return {"id": identifier, "app_id": app, "title": title, "workspace": "main:1",
            "column": column, "row": row, "floating": False}


class Fake:
    def __init__(self, connectors=("eDP-1", "DP-2")):
        self.output_data = [{"name": name, "enabled": True, "focused": index == 0,
                             "active_workspace": "main:1" if index == 0 else "ext:1"}
                            for index, name in enumerate(connectors)]
        self.workspace_data = [{"id": f"ws:{name}", "name": name, "named": True,
                                "index": index + 1, "output": "eDP-1", "focused": index == 0}
                               for index, name in enumerate(adapter.NAMES)]
        for output in self.output_data:
            output["active_workspace"] = self.workspace_data[0]["id"]
        self.window_data = []
        self.focus_id = None
        self.actions = []
        self.after_focus = lambda: None

    def query(self, command):
        if command == "focused-window":
            return next(copy.deepcopy(entry) for entry in self.window_data if entry["id"] == self.focus_id)
        return copy.deepcopy({"outputs": self.output_data, "workspaces": self.workspace_data, "windows": self.window_data}[command])

    def action(self, action, **fields):
        self.actions.append((action, fields))
        if action == "window-focus":
            self.focus_id = fields["window"]
        elif action == "workspace-switch":
            workspace = next(entry for entry in self.workspace_data if entry["name"] == fields["workspace"] and entry["output"] == fields["output"])
            for output in self.output_data:
                output["focused"] = output["name"] == fields["output"]
                if output["focused"]:
                    output["active_workspace"] = workspace["id"]
            self.after_focus()
        elif action == "workspace-move-to-output":
            workspace = next(entry for entry in self.workspace_data if entry["name"] == fields["workspace"] and entry["output"] == fields["output"])
            workspace["output"] = fields["destination"]


class IPCFixtures(unittest.TestCase):
    def test_transport_uses_typed_payload_and_rejects_bad_replies(self):
        payloads = (b'{"ok":null}\n', b'{"err":"stale"}\n', b'[]\n', b'{"ok":1}', b'invalid\n', b'x' * (adapter.MAX_REPLY + 1))
        for index, payload in enumerate(payloads):
            with self.subTest(index=index):
                connection = mock.MagicMock()
                connection.__enter__.return_value = connection
                connection.makefile.return_value = io.BytesIO(payload)
                with mock.patch.dict(adapter.os.environ, {"UMBRIEL_SOCKET": "/fixture/socket"}, clear=True):
                    ipc = adapter.IPC()
                with mock.patch.object(adapter.socket, "socket", return_value=connection):
                    if index == 0:
                        ipc.action("window-focus", window="opaque;$(not-shell)")
                    else:
                        with self.assertRaises((adapter.InvalidState, ValueError)):
                            ipc.action("window-focus", window="opaque;$(not-shell)")
                sent = connection.sendall.call_args.args[0]
                self.assertEqual(json.loads(sent), {"cmd": "action", "action": "window-focus", "window": "opaque;$(not-shell)"})
                connection.connect.assert_called_once_with("/fixture/socket")

    def test_startup_policy_does_not_depend_on_noctalia(self):
        fake = Fake()
        sleep = mock.Mock()
        with mock.patch.object(adapter, "routing_lock", side_effect=contextlib.nullcontext), \
                mock.patch.object(adapter.subprocess, "run", side_effect=AssertionError("shell must not be queried")) as run:
            adapter.startup(fake, "eDP-1", sleep)
        run.assert_not_called()
        sleep.assert_called_once_with(2)
        spawns = [fields["command"] for action, fields in fake.actions if action == "spawn"]
        self.assertEqual(spawns, ["discord", "signal-desktop", "Telegram", "viber", "logseq", "ghostty"])
        self.assertNotIn(("workspace-switch", {"workspace": "main-browser", "output": "eDP-1"}), fake.actions)
        self.assertEqual(fake.actions[-2:], [("workspace-switch", {"workspace": "main-term", "output": "eDP-1"}),
                                            ("spawn", {"command": "ghostty"})])

    def test_startup_readiness_and_terminal_delay_are_outside_lock(self):
        fake = Fake()
        held = False
        waits = []
        original_query, original_action = fake.query, fake.action
        first = True

        def query(command):
            nonlocal first
            if first:
                first = False
                self.assertFalse(held)
                raise OSError("compositor not ready")
            return original_query(command)

        def action(*args, **kwargs):
            self.assertTrue(held)
            return original_action(*args, **kwargs)

        @contextlib.contextmanager
        def lock():
            nonlocal held
            self.assertFalse(held, "startup must not acquire a nested routing lock")
            held = True
            try:
                yield
            finally:
                held = False

        def sleep(seconds):
            self.assertFalse(held)
            waits.append(seconds)
            if seconds == 2:
                # A workspace transfer during the delay must be resolved afresh.
                fake.workspace_data[0]["output"] = "DP-2"

        fake.query, fake.action = query, action
        with mock.patch.object(adapter, "routing_lock", side_effect=lock):
            adapter.startup(fake, "eDP-1", sleep)
        self.assertEqual(waits, [0.2, 2])
        self.assertEqual(fake.actions[-2], ("workspace-switch", {"workspace": "main-term", "output": "DP-2"}))
        self.assertFalse(held)

    def test_startup_readiness_failure_never_locks_or_launches(self):
        for disabled in (False, True):
            with self.subTest(disabled=disabled):
                failed = Fake()
                if disabled:
                    for output in failed.output_data:
                        output["enabled"] = False
                else:
                    failed.query = mock.Mock(side_effect=OSError("fixture unavailable"))
                with mock.patch.object(adapter.time, "monotonic", side_effect=(0, 21)), \
                        mock.patch.object(adapter, "routing_lock") as lock:
                    with self.assertRaisesRegex(adapter.InvalidState, "compositor startup readiness timed out"):
                        adapter.startup(failed, "eDP-1", lambda _seconds: self.fail("slept after deadline"))
                lock.assert_not_called()
                self.assertEqual(failed.actions, [])

    def test_startup_dispatch_has_no_outer_routing_lock(self):
        fake = Fake()
        with mock.patch.object(adapter.sys, "argv", ["adapter", "startup", "--primary", "fixture-output"]), \
                mock.patch.object(adapter, "IPC", return_value=fake), \
                mock.patch.object(adapter, "startup") as startup, \
                mock.patch.object(adapter, "routing_lock", side_effect=AssertionError("outer lock")):
            adapter.main()
        startup.assert_called_once_with(fake, "fixture-output")

    def test_assignment_preflights_all_names(self):
        fake = Fake()
        fake.workspace_data.pop()
        with self.assertRaises(adapter.InvalidState):
            adapter.reconcile(fake)
        self.assertEqual(fake.actions, [])

    def test_laptop_all_names_and_external_policy(self):
        for connectors, destination in ((("eDP-1",), "eDP-1"), (("eDP-1", "DP-2"), "DP-2"),
                                        (("eDP-1", "HDMI-A-1", "DP-2"), "DP-2"), (("DP-2",), "DP-2")):
            with self.subTest(connectors=connectors):
                fake = Fake(connectors)
                adapter.reconcile(fake)
                self.assertEqual({entry["name"] for entry in fake.workspace_data}, set(adapter.NAMES))
                for entry in fake.workspace_data:
                    expected = destination if entry["name"].startswith("ext-") or "eDP-1" not in connectors else "eDP-1"
                    self.assertEqual(entry["output"], expected)

    def test_duplicate_or_missing_name_aborts_without_move(self):
        for missing in (False, True):
            fake = Fake()
            if missing:
                fake.workspace_data = fake.workspace_data[1:]
            else:
                extra = dict(fake.workspace_data[0], id="duplicate")
                fake.workspace_data.append(extra)
            with self.assertRaises(adapter.InvalidState):
                adapter.route(fake, "main-term", move=True)
            self.assertEqual(fake.actions, [])

    def test_current_output_not_id_prefix_used_for_routes(self):
        fake = Fake()
        fake.workspace_data[0]["output"] = "DP-2"
        adapter.route(fake, "main-term", move=True)
        self.assertEqual(fake.actions, [("column-move-to-workspace", {"workspace": "main-term", "output": "DP-2"})])

    def test_smart_spawn_across_outputs_and_laptop_only(self):
        for connectors, external_focus, expected in ((("eDP-1",), False, "main-term"),
                                                     (("eDP-1", "DP-2"), False, "ext-term"),
                                                     (("eDP-1", "DP-2"), True, "main-term")):
            fake = Fake(connectors)
            adapter.reconcile(fake)
            fake.actions.clear()
            if external_focus:
                for entry in fake.output_data:
                    entry["focused"] = entry["name"] == "DP-2"
            adapter.smart_spawn(fake, "terminal")
            self.assertEqual(fake.actions[0][1]["workspace"], expected)
            self.assertEqual(fake.actions[-1], ("spawn", {"command": "ghostty"}))

    def test_topology_change_after_focus_never_spawns(self):
        fake = Fake()
        adapter.reconcile(fake)
        fake.actions.clear()
        fake.after_focus = lambda: fake.output_data.pop()
        with self.assertRaises(adapter.InvalidState):
            adapter.smart_spawn(fake, "browser", browser="zen-twilight")
        self.assertFalse(any(name == "spawn" for name, _ in fake.actions))

    def test_browser_argv_is_quoted_not_evaluated(self):
        fake = Fake(("eDP-1",))
        command = 'zen-twilight "$(touch /not-executed)";echo not-a-command'
        adapter.smart_spawn(fake, "browser", browser=command)
        self.assertEqual(shlex.split(fake.actions[-1][1]["command"]), shlex.split(command))

    def test_selector_opaque_ids_duplicate_titles_and_controls(self):
        fake = Fake()
        fake.window_data = [window("id;$(not-a-command)"), window("second-id", title="same\n\t\u202ebidi\u2028line\u2029paragraph")]
        def choose(argv, **kwargs):
            self.assertEqual(argv[0], "rofi")
            self.assertIn("-no-custom", argv)
            self.assertNotIn("\u202e", kwargs["input"])
            self.assertEqual(len(kwargs["input"].splitlines()), 2)
            return SimpleNamespace(returncode=0, stdout="0\n")
        adapter.select_window(fake, "browser", choose)
        self.assertEqual(fake.actions, [("window-focus", {"window": "id;$(not-a-command)"})])

    def test_selector_cancel_custom_invalid_and_empty_never_act(self):
        for result in (SimpleNamespace(returncode=1, stdout="0\n"),
                       *(SimpleNamespace(returncode=0, stdout=text) for text in ("", "-1\n", "2\n", "01\n", "0;echo\n", "0\n1\n"))):
            fake = Fake()
            fake.window_data = [window("id")]
            adapter.select_window(fake, "browser", lambda *args, **kwargs: result)
            self.assertEqual(fake.actions, [])
        fake = Fake()
        adapter.select_window(fake, "ghostty", lambda *args, **kwargs: self.fail("picker ran without windows"))
        self.assertEqual(fake.actions, [])

    def test_selector_stale_or_changed_app_never_focuses(self):
        for remove in (True, False):
            fake = Fake()
            fake.window_data = [window("id")]
            def choose(*_args, **_kwargs):
                if remove:
                    fake.window_data.clear()
                else:
                    fake.window_data[0]["app_id"] = "unrelated"
                return SimpleNamespace(returncode=0, stdout="0\n")
            adapter.select_window(fake, "browser", choose)
            self.assertEqual(fake.actions, [])

    def test_bad_inventory_rejected(self):
        for data in ({}, [None], [window(1)], [window("id"), window("id")]):
            fake = Fake()
            fake.window_data = data
            with self.assertRaises(adapter.InvalidState):
                adapter.select_window(fake, "browser")
            self.assertEqual(fake.actions, [])

    def test_tab_order_and_edges(self):
        fake = Fake()
        fake.window_data = [window("d", 1, 1), window("a", 0, 0), window("c", 1, 0), window("b", 0, 1)]
        fake.focus_id = "b"
        adapter.traverse(fake, 1)
        self.assertEqual(fake.focus_id, "c")
        adapter.traverse(fake, -1)
        self.assertEqual(fake.focus_id, "b")
        fake.focus_id = "a"
        fake.actions.clear()
        adapter.traverse(fake, -1)
        self.assertEqual(fake.actions, [])
        fake.focus_id = "d"
        adapter.traverse(fake, 1)
        self.assertEqual(fake.actions, [])

    def test_bottom_expel_not_focused_row(self):
        fake = Fake()
        fake.window_data = [window("a", 0, 0), window("b", 0, 1), window("c", 0, 2)]
        fake.focus_id = "a"
        adapter.expel_bottom(fake)
        self.assertEqual(fake.actions, [("window-focus", {"window": "c"}), ("window-consume-or-expel-right", {})])

    def test_floating_and_ambiguous_order_refused(self):
        for ambiguous in (False, True):
            fake = Fake()
            fake.window_data = [window("a")]
            fake.focus_id = "a"
            if ambiguous:
                fake.window_data.append(window("b"))
            else:
                fake.window_data[0]["floating"] = True
            with self.assertRaises(adapter.InvalidState):
                adapter.traverse(fake, 1)
            self.assertEqual(fake.actions, [])

    def test_focus_changes_do_not_change_topology_signature(self):
        fake = Fake()
        before = adapter.topology(fake)
        for entry in fake.output_data:
            entry["focused"] = not entry["focused"]
        self.assertEqual(before, adapter.topology(fake))


if __name__ == "__main__":
    unittest.main(verbosity=2)
