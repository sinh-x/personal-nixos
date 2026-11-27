#!/usr/bin/env python3
"""Power/capture/storage/recording fixtures; every desktop process is fake."""

import os
from pathlib import Path
import subprocess
import sys
import tempfile
from types import SimpleNamespace
import unittest
from unittest import mock

sys.path.insert(0, sys.argv.pop(1))
import capture
import controls
import power
from runtime import Refused, Runtime


class Locker:
    def __init__(self, write_fd, packet=b"\n", exited=None, late_exit=False, crash=False):
        self.held_fd = None
        self.exited = exited
        self.late_exit = late_exit
        self.crash = crash
        self.polls = 0
        self.waited = False
        if packet is None:
            self.held_fd = os.dup(write_fd)
        elif packet:
            os.write(write_fd, packet)

    def poll(self):
        self.polls += 1
        return 1 if self.late_exit and self.polls >= 3 else self.exited

    def wait(self):
        self.waited = True
        if self.held_fd is not None:
            os.close(self.held_fd)
            self.held_fd = None
        return 1 if self.crash else 0

    def kill(self):
        raise AssertionError("must never kill the locker")

    def terminate(self):
        raise AssertionError("must never terminate the locker")


class RecorderProcess:
    def __init__(self, failure=False, inactive=False):
        self.calls = []
        self.values = {"LoadState": "not-found"}
        self.failure = failure
        self.inactive = inactive
        self.selection = "0\n"

    def __call__(self, argv, **kwargs):
        self.calls.append(argv)
        if argv[0] == "systemd-run":
            unit = argv[argv.index("--unit") + 1]
            description = argv[argv.index("--description") + 1]
            self.values = {
                "LoadState": "loaded", "ActiveState": "inactive" if self.inactive else "active",
                "Description": description, "Transient": "yes", "PartOf": "umbriel-session.target",
                "Requisite": "umbriel.service umbriel-session.target", "After": "umbriel.service",
                "KillSignal": "2", "Id": unit,
            }
            if self.failure:
                raise subprocess.CalledProcessError(1, argv)
        elif argv[:3] == ["systemctl", "--user", "show"]:
            return SimpleNamespace(returncode=0, stdout="".join(f"{key}={value}\n" for key, value in self.values.items()))
        elif argv[:3] == ["systemctl", "--user", "stop"]:
            self.values["ActiveState"] = "inactive"
        elif argv[0] == "rofi":
            return SimpleNamespace(returncode=0, stdout=self.selection)
        elif argv[0] == "slurp":
            return SimpleNamespace(returncode=0, stdout="0,0 100x100\n")
        return SimpleNamespace(returncode=0, stdout="")


class Compositor:
    def __init__(self):
        self.entries = [
            {"name": "eDP-1", "enabled": True, "focused": True, "active_workspace": "ws:1",
             "position": {"x": 0, "y": 0}, "logical_size": {"width": 1000, "height": 800}},
            {"name": "DP-2", "enabled": True, "focused": False, "active_workspace": "ws:2",
             "position": {"x": 1000, "y": 0}, "logical_size": {"width": 1000, "height": 800}},
        ]

    def query(self, command):
        assert command == "outputs"
        return self.entries


class ControlFixtures(unittest.TestCase):
    def power_case(self, **options):
        with tempfile.TemporaryDirectory() as root, Runtime(root, "fixture") as runtime:
            made, calls, messages = [], [], []
            def popen(argv, **kwargs):
                self.assertEqual(argv[0], "swaylock")
                self.assertNotIn("--daemonize", argv)
                self.assertNotIn("-f", argv)
                self.assertIn("--config", argv)
                self.assertEqual(argv[argv.index("--config") + 1], "/dev/null")
                fd = int(argv[-1])
                self.assertEqual(kwargs["pass_fds"], (fd,))
                locker = Locker(fd, **options.get("locker", {}))
                made.append(locker)
                return locker
            def run(argv, **kwargs):
                self.assertEqual(argv, ["systemctl", "hibernate"])
                self.assertGreaterEqual(made[0].polls, 3)
                self.assertFalse(made[0].waited)
                with self.assertRaises(Refused):
                    with runtime.lock("power.lock"):
                        self.fail("duplicate power request acquired")
                calls.append(argv)
                return SimpleNamespace(returncode=options.get("denial", 0))
            status = power.guard(options.get("mode", "hibernate"), runtime, popen, run,
                                 notify=messages.append, timeout=0.01)
            self.assertTrue(made[0].waited)
            return status, calls, messages

    def test_hibernate_after_ready_only(self):
        status, calls, messages = self.power_case()
        self.assertEqual(status, 0)
        self.assertEqual(calls, [["systemctl", "hibernate"]])
        self.assertEqual(messages, [])

    def test_lock_only_has_no_power(self):
        status, calls, messages = self.power_case(mode="lock")
        self.assertEqual((status, calls, messages), (0, [], []))

    def test_eof_timeout_junk_exit_and_late_exit_never_dispatch(self):
        for locker in ({"packet": b""}, {"packet": None}, {"packet": b"x"}, {"exited": 1}, {"late_exit": True}):
            with self.subTest(locker=locker):
                status, calls, messages = self.power_case(locker=locker)
                self.assertEqual(status, 1)
                self.assertEqual(calls, [])
                self.assertEqual(len(messages), 1)

    def test_hibernate_denial_retains_locker_without_fallback(self):
        status, calls, messages = self.power_case(denial=1)
        self.assertEqual(status, 1)
        self.assertEqual(calls, [["systemctl", "hibernate"]])
        self.assertEqual(len(messages), 1)

    def test_locker_crash_is_not_success(self):
        status, calls, messages = self.power_case(mode="lock", locker={"crash": True})
        self.assertEqual(status, 1)
        self.assertEqual(calls, [])
        self.assertEqual(len(messages), 1)

    def test_locker_launch_error_never_dispatches_power(self):
        with tempfile.TemporaryDirectory() as root, Runtime(root, "fixture") as runtime:
            with self.assertRaises(OSError):
                power.guard("hibernate", runtime,
                            popen=mock.Mock(side_effect=OSError("fixture missing locker")),
                            run=lambda *_args, **_kwargs: self.fail("power dispatched after launch error"))

    def test_helpers_refuse_other_desktop_before_any_action(self):
        with mock.patch.dict(os.environ, {"XDG_CURRENT_DESKTOP": "niri"}):
            with self.assertRaises(Refused):
                controls.main()
            with self.assertRaises(Refused):
                capture.main()

    def test_duplicate_request_starts_no_locker_or_power(self):
        with tempfile.TemporaryDirectory() as root, Runtime(root, "fixture") as runtime:
            with runtime.lock("power.lock"), self.assertRaises(Refused):
                power.guard("hibernate", runtime,
                            popen=lambda *_args, **_kwargs: self.fail("locker launched on duplicate"),
                            run=lambda *_args, **_kwargs: self.fail("power dispatched on duplicate"))

    def test_notify_does_not_activate_a_legacy_daemon(self):
        calls = []
        power.report("fixture diagnostic", run=lambda argv, **_kwargs: calls.append(argv))
        self.assertEqual(len(calls), 1)
        self.assertIn("--auto-start=no", calls[0])
        self.assertNotIn("notify-send", calls[0])

    def test_secret_metadata_only_and_locked_missing_fail(self):
        for alias, locked, accepted in (
            ('o "/org/freedesktop/secrets/collection/login"', 'b false', True),
            ('o "/org/freedesktop/secrets/collection/login"', 'b true', False),
            ('o "/"', 'b false', False),
            ('invalid', 'b false', False),
        ):
            calls = []
            def run(argv, **_kwargs):
                calls.append(argv)
                self.assertIn("--auto-start=no", argv)
                self.assertNotIn("Unlock", argv)
                self.assertNotIn("GetSecret", argv)
                return SimpleNamespace(stdout=alias if "ReadAlias" in argv else locked)
            if accepted:
                controls.clipboard_ready(run)
                self.assertEqual(len(calls), 2)
            else:
                with self.assertRaises(Refused):
                    controls.clipboard_ready(run)

    def test_volume_cap_mic_default_source_and_brightness_dependency(self):
        for action in ("volume-up", "volume-down", "volume-mute", "mic-mute", "brightness-up", "brightness-down"):
            calls = []
            controls.utility(action, lambda argv, **_kwargs: calls.append(argv))
            if action.startswith("volume-") and action not in ("volume-mute",):
                self.assertIn(["wpctl", "set-volume", "-l", "1.0", controls.SINK, "5%+" if action == "volume-up" else "5%-"], calls)
            if action == "mic-mute":
                self.assertEqual(calls[0], ["wpctl", "set-mute", controls.SOURCE, "toggle"])
            if action.startswith("brightness-"):
                self.assertEqual(calls[0][0], "brightnessctl")
                self.assertFalse(any("light" == item for argv in calls for item in argv))

    def test_capture_targets_and_explicit_flags(self):
        for kind, target in (("region", "screenshot-region"), ("window", "screenshot-window"), ("screen", "screenshot-fullscreen")):
            calls = []
            capture.screenshot(kind, run=lambda argv, **_kwargs: calls.append(argv), directory="/fixture/screenshots")
            self.assertEqual(len(calls), 1)
            self.assertEqual(calls[0][:3], ["noctalia", "msg", target])
            for flag in capture.SCREENSHOT_FLAGS:
                self.assertIn(flag, calls[0])
            for forbidden in ("--save-to-file", "--copy-to-clipboard", "--pipe-to-command", "--copy-on-close"):
                self.assertNotIn(forbidden, calls[0])

    def test_capture_cancel_and_delays(self):
        for selection in ("", "custom\n", "-1\n", "99\n"):
            calls = []
            def cancel(argv, **_kwargs):
                calls.append(argv)
                return SimpleNamespace(returncode=0, stdout=selection)
            capture.screenshot_menu(cancel, sleep=lambda _seconds: self.fail("cancel delayed"))
            self.assertEqual(len(calls), 1)
        for index, delay in ((3, 5), (4, 10)):
            calls, sleeps = [], []
            def selected(argv, **_kwargs):
                calls.append(argv)
                return SimpleNamespace(returncode=0, stdout=f"{index}\n")
            capture.screenshot_menu(selected, sleep=sleeps.append)
            self.assertEqual(sleeps, [delay])
            self.assertEqual(calls[-1][2], "screenshot-fullscreen")

    def test_recording_screen_region_audio_and_graceful_owned_stop(self):
        for region, audio in ((False, False), (True, False), (False, True), (True, True)):
            with tempfile.TemporaryDirectory() as root, Runtime(root, "fixture") as runtime:
                process = RecorderProcess()
                with mock.patch.dict(os.environ, {"NX077_WF_RECORDER": "/fixture/wf-recorder"}):
                    self.assertTrue(capture.start_recording(runtime, Compositor(), region, audio, process, Path(root) / "video"))
                state = runtime.load_recording()
                self.assertIsNotNone(state)
                started = next(argv for argv in process.calls if argv[0] == "systemd-run")
                self.assertIn("/fixture/wf-recorder", started)
                self.assertIn("--property=KillSignal=SIGINT", started)
                self.assertIn("--property=Requisite=umbriel.service umbriel-session.target", started)
                self.assertEqual("--audio" in started, audio)
                self.assertEqual("-g" in started, region)
                self.assertTrue(capture.stop_recording(runtime, process))
                self.assertIsNone(runtime.load_recording())
                stops = [argv for argv in process.calls if argv[:3] == ["systemctl", "--user", "stop"]]
                self.assertEqual(stops, [["systemctl", "--user", "stop", state["unit"]]])

    def test_failed_recorder_start_saves_no_active_claim(self):
        for failure, inactive in ((True, False), (False, True)):
            with tempfile.TemporaryDirectory() as root, Runtime(root, "fixture") as runtime:
                process = RecorderProcess(failure, inactive)
                with self.assertRaises((Refused, subprocess.CalledProcessError)):
                    capture.start_recording(runtime, Compositor(), run=process, directory=Path(root) / "video")
                self.assertIsNone(runtime.load_recording())

    def test_foreign_or_stale_unit_never_signals_foreign_process(self):
        with tempfile.TemporaryDirectory() as root, Runtime(root, "fixture") as runtime:
            state = {"nonce": "a" * 24, "unit": "nx077-record-fixture-" + "a" * 24 + ".service"}
            runtime.save_recording(state)
            process = RecorderProcess()
            process.values = {"LoadState": "loaded", "Description": "operator-owned foreign service", "Transient": "yes"}
            with self.assertRaises(Refused):
                capture.stop_recording(runtime, process)
            self.assertFalse(any(argv[:3] == ["systemctl", "--user", "stop"] for argv in process.calls))
            self.assertIsNotNone(runtime.load_recording())
            process.values = {"LoadState": "not-found"}
            capture.stop_recording(runtime, process)
            self.assertIsNone(runtime.load_recording())

    def test_recording_region_cancel_and_ambiguous_geometry(self):
        with tempfile.TemporaryDirectory() as root, Runtime(root, "fixture") as runtime:
            def cancel(argv, **_kwargs):
                self.assertEqual(argv, ["slurp"])
                return SimpleNamespace(returncode=1, stdout="")
            self.assertFalse(capture.start_recording(runtime, Compositor(), region=True, run=cancel))
            self.assertIsNone(runtime.load_recording())
        for geometry in ("bad", "0,0 0x10", "900,0 200x100"):
            with self.assertRaises(Refused):
                capture.geometry_output(Compositor().entries, geometry)

    def test_recording_geometry_change_never_starts_a_unit(self):
        with tempfile.TemporaryDirectory() as root, Runtime(root, "fixture") as runtime:
            compositor = Compositor()
            calls = []
            def select_region(argv, **_kwargs):
                calls.append(argv)
                self.assertEqual(argv, ["slurp"])
                compositor.entries[0]["position"]["x"] = 20
                return SimpleNamespace(returncode=0, stdout="0,0 100x100\n")
            with self.assertRaises(Refused):
                capture.start_recording(runtime, compositor, region=True, run=select_region, directory=Path(root) / "video")
            self.assertEqual(calls, [["slurp"]])
            self.assertIsNone(runtime.load_recording())
            self.assertFalse((Path(root) / "video").exists())

    def test_recorder_relationship_and_signal_policy_are_mandatory(self):
        for key in ("Transient", "PartOf", "Requisite", "After", "KillSignal"):
            with tempfile.TemporaryDirectory() as root, Runtime(root, "fixture") as runtime:
                process = RecorderProcess()
                capture.start_recording(runtime, Compositor(), run=process, directory=Path(root) / "video")
                process.calls.clear()
                process.values[key] = "foreign"
                with self.assertRaises(Refused):
                    capture.stop_recording(runtime, process)
                self.assertFalse(any(argv[:3] == ["systemctl", "--user", "stop"] for argv in process.calls))

    def test_runtime_state_rejects_fifo_hardlinks_symlinks_and_oversize(self):
        with tempfile.TemporaryDirectory() as root, Runtime(root, "fixture") as runtime:
            state = Path(root) / "nx077-umbriel-fixture" / "recording.json"
            foreign = Path(root) / "foreign"
            foreign.touch(mode=0o600)
            state.symlink_to(foreign)
            with self.assertRaises(OSError):
                runtime.load_recording()
            state.unlink()
            os.link(foreign, state)
            with self.assertRaises(Refused):
                runtime.load_recording()
            state.unlink()
            os.mkfifo(state, mode=0o600)
            with self.assertRaises(Refused):
                runtime.load_recording()
            state.unlink()
            state.write_bytes(b"x" * 4097)
            state.chmod(0o600)
            with self.assertRaises(Refused):
                runtime.load_recording()

    def test_runtime_is_per_display(self):
        with tempfile.TemporaryDirectory() as root, Runtime(root, "one") as one, Runtime(root, "two") as two:
            data = {"nonce": "b" * 24, "unit": "nx077-record-one-" + "b" * 24 + ".service"}
            one.save_recording(data)
            self.assertEqual(one.load_recording(), data)
            self.assertIsNone(two.load_recording())


if __name__ == "__main__":
    unittest.main(verbosity=2)
