#!/usr/bin/env python3
"""Production boundary fixtures. Never call real systemctl or a compositor."""

import importlib.util
import os
from pathlib import Path
import subprocess
import sys
import tempfile
from types import SimpleNamespace
import unittest

spec = importlib.util.spec_from_file_location("session", sys.argv.pop(1))
session = importlib.util.module_from_spec(spec)
spec.loader.exec_module(session)


class Fake:
    def __init__(self, states="inactive\ninactive\n", fail=None, code=0, interrupt=False):
        self.states = states
        self.fail = fail
        self.code = code
        self.interrupt = interrupt
        self.calls = []
        self.launch_env = None

    def __call__(self, argv, **kwargs):
        self.calls.append(argv)
        if self.fail is not None and self.fail(argv):
            raise subprocess.CalledProcessError(1, argv)
        if argv[0] == "/fixture/launcher":
            self.launch_env = kwargs["env"]
            if self.interrupt:
                raise SystemExit(143)
            return SimpleNamespace(returncode=self.code)
        return SimpleNamespace(stdout=self.states, returncode=0)

    @property
    def launched(self):
        return self.launch_env is not None


class SessionFixtures(unittest.TestCase):
    def test_round_trip_both_identities_and_cleanup(self):
        for desktop in session.DESKTOPS:
            with self.subTest(desktop=desktop):
                fake = Fake()
                original = {name: "STALE" for name in session.SESSION_VARIABLES}
                original["GTK_IM_MODULE"] = "fcitx"
                code = session.run_session(desktop, ["/fixture/launcher"], fake, original)
                self.assertEqual(code, 0)
                self.assertTrue(fake.launched)
                self.assertEqual(fake.launch_env["XDG_CURRENT_DESKTOP"], desktop)
                self.assertEqual(fake.launch_env["XDG_SESSION_DESKTOP"], desktop)
                self.assertEqual(fake.launch_env["XDG_SESSION_TYPE"], "wayland")
                self.assertEqual(fake.launch_env["GTK_IM_MODULE"], "fcitx")
                self.assertNotIn("DISPLAY", fake.launch_env)
                self.assertNotIn("NIRI_SOCKET", fake.launch_env)
                self.assertNotIn("UMBRIEL_SOCKET", fake.launch_env)
                self.assertEqual(original["DISPLAY"], "STALE")
                launch = fake.calls.index(["/fixture/launcher"])
                self.assertEqual(fake.calls[1], ["systemctl", "--user", "stop", *session.PORTALS])
                self.assertEqual(fake.calls[2][0], "dbus-update-activation-environment")
                self.assertIn(["systemctl", "--user", "unset-environment", *session.SESSION_VARIABLES], fake.calls[:launch])
                self.assertIn(["systemctl", "--user", "start", "--job-mode=replace-irreversibly", f"{desktop}-shutdown.target"], fake.calls[launch + 1:])
                self.assertEqual(sum(call[0] == "/fixture/launcher" for call in fake.calls), 1)

    def test_active_transitioning_unknown_and_malformed_are_side_effect_free(self):
        for states in ("active inactive", "inactive active", "activating inactive", "inactive deactivating", "unknown inactive", "", "inactive", "inactive inactive inactive"):
            with self.subTest(states=states):
                fake = Fake(states)
                with self.assertRaises(RuntimeError):
                    session.run_session("umbriel", ["/fixture/launcher"], fake, {})
                self.assertEqual(len(fake.calls), 1)
                self.assertFalse(fake.launched)

    def test_failed_states_can_be_recovered(self):
        fake = Fake("failed failed")
        self.assertEqual(session.run_session("niri", ["/fixture/launcher"], fake, {}), 0)

    def test_preparation_errors_never_launch(self):
        for command in ("show", "stop", "dbus-update-activation-environment", "unset-environment"):
            with self.subTest(command=command):
                fake = Fake(fail=lambda argv: command in argv)
                with self.assertRaises(subprocess.CalledProcessError):
                    session.run_session("umbriel", ["/fixture/launcher"], fake, {})
                self.assertFalse(fake.launched)

    def test_launch_failure_and_interruption_still_cleanup(self):
        for code, interrupt in ((7, False), (0, True)):
            fake = Fake(code=code, interrupt=interrupt)
            if interrupt:
                with self.assertRaises(SystemExit):
                    session.run_session("umbriel", ["/fixture/launcher"], fake, {})
            else:
                self.assertEqual(session.run_session("umbriel", ["/fixture/launcher"], fake, {}), 7)
            self.assertEqual(fake.calls[-1], ["systemctl", "--user", "unset-environment", *session.SESSION_VARIABLES])

    def test_cleanup_refuses_new_foreign_session(self):
        fake = Fake("active inactive")
        with self.assertRaises(RuntimeError):
            session.finish("umbriel", fake)
        self.assertEqual(len(fake.calls), 1)

    def test_unknown_desktop_is_side_effect_free(self):
        fake = Fake()
        with self.assertRaises(ValueError):
            session.run_session("other", ["/fixture/launcher"], fake, {})
        self.assertEqual(fake.calls, [])

    def test_missing_or_relative_runtime_refused(self):
        for runtime in (None, "", "."):
            with self.assertRaises(RuntimeError):
                with session.session_lock(runtime):
                    self.fail("nonabsolute runtime accepted")

    def test_private_lock_duplicate_and_reuse(self):
        with tempfile.TemporaryDirectory() as runtime:
            with session.session_lock(runtime):
                with self.assertRaises(RuntimeError):
                    with session.session_lock(runtime):
                        self.fail("duplicate acquired")
            with session.session_lock(runtime):
                pass

    def test_lock_rejects_symlinks_hardlinks_fifo_and_open_permissions(self):
        with tempfile.TemporaryDirectory() as temp:
            parent = Path(temp)
            runtime = parent / "runtime"
            runtime.mkdir(mode=0o700)
            alias = parent / "alias"
            alias.symlink_to(runtime)
            with self.assertRaises(OSError):
                with session.session_lock(alias):
                    self.fail("symlink runtime accepted")
            lock = runtime / "nx077-session.lock"
            target = parent / "operator-state"
            target.touch(mode=0o600)
            lock.symlink_to(target)
            with self.assertRaises(OSError):
                with session.session_lock(runtime):
                    self.fail("symlink lock accepted")
            lock.unlink()
            os.link(target, lock)
            with self.assertRaises(RuntimeError):
                with session.session_lock(runtime):
                    self.fail("hardlink lock accepted")
            lock.unlink()
            os.mkfifo(lock, mode=0o600)
            with self.assertRaises(RuntimeError):
                with session.session_lock(runtime):
                    self.fail("FIFO lock accepted")
            lock.unlink()
            runtime.chmod(0o755)
            with self.assertRaises(RuntimeError):
                with session.session_lock(runtime):
                    self.fail("public runtime accepted")


if __name__ == "__main__":
    unittest.main(verbosity=2)
