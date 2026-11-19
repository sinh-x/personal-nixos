"""Offline contract tests. --fixture-only qualifies helpers, not the product."""

import argparse
import json
import os
from pathlib import Path
import signal
import stat
import subprocess
import sys
import tempfile
import time
import unittest

ROOT = "/home/sinh/.local/share/gmail-downloader"
WRAPPER = None
MISSING_WRAPPER = None
NONEXECUTABLE_WRAPPER = None


class FixtureCase(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="gmail-schedule-fixture-")
        self.addCleanup(self.temporary.cleanup)
        self.directory = Path(self.temporary.name)
        self.env = os.environ.copy()
        for name in list(self.env):
            if name.startswith("GMAIL_FIXTURE_"):
                del self.env[name]
        self.env["GMAIL_FIXTURE_DIR"] = str(self.directory)
        self.fake = self.directory / "fixture-downloader"
        source = Path(__file__).with_name("fixture-downloader.py").read_text()
        self.fake.write_text(f"#!{sys.executable}\n{source}")
        self.fake.chmod(0o700)
        # This deliberately stays outside generated scripts and logs.
        self.sentinel = "SYNTHETIC-PRIVATE-CONTENT-DO-NOT-EXPORT"
        (self.directory / "private-sentinel").write_text(self.sentinel)

    def calls(self):
        path = self.directory / "calls.jsonl"
        return [json.loads(line) for line in path.read_text().splitlines()] if path.exists() else []

    def run_command(self, command):
        return subprocess.run(command, env=self.env, capture_output=True, text=True, timeout=10)

    def start(self, command):
        child = subprocess.Popen(
            command, env=self.env, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
            text=True, start_new_session=True,
        )

        def settle():
            if child.poll() is None:
                os.killpg(child.pid, signal.SIGKILL)
            child.communicate(timeout=5)

        self.addCleanup(settle)
        return child

    def wait_started(self, profile="personal"):
        deadline = time.monotonic() + 5
        while not (self.directory / f"{profile}.started").exists():
            if time.monotonic() > deadline:
                self.fail("synthetic downloader did not start")
            time.sleep(0.01)

    def expected_calls(self):
        return [["download", "--root", ROOT, "--profile", p] for p in ("personal", "andafin")]


class FixtureTests(FixtureCase):
    def command(self, profile="personal"):
        return [str(self.fake), "download", "--root", ROOT, "--profile", profile]

    def test_fixture_records_without_opening_archive(self):
        result = self.run_command(self.command())
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.calls(), self.expected_calls()[:1])
        self.assertNotIn(self.sentinel, result.stdout + result.stderr)

    def test_fixture_injects_operational_failure(self):
        self.env["GMAIL_FIXTURE_EXIT_PERSONAL"] = "1"
        self.assertEqual(self.run_command(self.command()).returncode, 1)

    def test_fixture_rejects_unexpected_profile_and_filters(self):
        for command in (self.command("third"), self.command() + ["--exclude-spam-trash"]):
            with self.subTest(command=command):
                self.assertEqual(self.run_command(command).returncode, 2)
        self.assertEqual(self.calls(), [])

    def test_fixture_lock_is_nonblocking_and_profile_scoped(self):
        self.env["GMAIL_FIXTURE_WAIT"] = "personal"
        first = self.start(self.command())
        self.wait_started()
        self.assertEqual(self.run_command(self.command()).returncode, 1)
        self.assertEqual(self.run_command(self.command("andafin")).returncode, 0)
        (self.directory / "release").touch()
        first.communicate(timeout=5)
        self.assertEqual(first.returncode, 0)
        # A persistent lock file is normal; reacquire without deleting it.
        self.assertTrue((self.directory / "personal.lock").exists())
        self.assertEqual(self.run_command(self.command()).returncode, 0)


class WrapperTests(FixtureCase):
    def test_exact_selection_and_failure_isolation(self):
        for personal, andafin in ((0, 0), (1, 0), (0, 1), (1, 1), (2, 0)):
            with self.subTest(personal=personal, andafin=andafin):
                (self.directory / "calls.jsonl").unlink(missing_ok=True)
                self.env["GMAIL_FIXTURE_EXIT_PERSONAL"] = str(personal)
                self.env["GMAIL_FIXTURE_EXIT_ANDAFIN"] = str(andafin)
                result = self.run_command([WRAPPER])
                self.assertEqual(result.returncode, int(bool(personal or andafin)), result.stderr)
                self.assertEqual(self.calls(), self.expected_calls())
                self.assertNotIn(self.sentinel, result.stdout + result.stderr)

    def test_missing_and_nonexecutable_fail_before_downloads(self):
        for wrapper in (MISSING_WRAPPER, NONEXECUTABLE_WRAPPER):
            with self.subTest(wrapper=wrapper):
                result = self.run_command([wrapper])
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("executable", result.stderr)
                self.assertEqual(self.calls(), [])

    def test_private_umask_even_when_launched_directly(self):
        result = self.run_command([WRAPPER])
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(stat.S_IMODE((self.directory / "calls.jsonl").stat().st_mode), 0o600)

    def test_slow_profile_is_foreground_and_sequential(self):
        self.env["GMAIL_FIXTURE_WAIT"] = "personal"
        child = self.start([WRAPPER])
        self.wait_started()
        time.sleep(0.2)
        self.assertIsNone(child.poll())
        self.assertEqual(self.calls(), self.expected_calls()[:1])
        (self.directory / "release").touch()
        child.communicate(timeout=5)
        self.assertEqual(child.returncode, 0)
        self.assertEqual(self.calls(), self.expected_calls())

    def test_group_termination_does_not_start_second_profile(self):
        self.env["GMAIL_FIXTURE_WAIT"] = "personal"
        child = self.start([WRAPPER])
        self.wait_started()
        # Model systemd KillMode=control-group, without touching a host unit.
        os.killpg(child.pid, signal.SIGTERM)
        child.communicate(timeout=5)
        self.assertNotEqual(child.returncode, 0)
        self.assertEqual(self.calls(), self.expected_calls()[:1])

    def test_signalled_child_is_not_an_ordinary_profile_failure(self):
        self.env["GMAIL_FIXTURE_EXIT_PERSONAL"] = "143"
        result = self.run_command([WRAPPER])
        self.assertEqual(result.returncode, 143)
        self.assertEqual(self.calls(), self.expected_calls()[:1])

    def test_busy_personal_still_attempts_independent_andafin(self):
        self.env["GMAIL_FIXTURE_WAIT"] = "personal"
        direct = self.start([str(self.fake), "download", "--root", ROOT, "--profile", "personal"])
        self.wait_started()
        result = self.run_command([WRAPPER])
        self.assertEqual(result.returncode, 1)
        self.assertEqual(self.calls(), self.expected_calls())
        (self.directory / "release").touch()
        direct.communicate(timeout=5)
        self.assertEqual(direct.returncode, 0)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--fixture-only", action="store_true")
    mode.add_argument("--wrapper")
    parser.add_argument("--missing-wrapper")
    parser.add_argument("--nonexecutable-wrapper")
    args = parser.parse_args()
    if args.wrapper and not (args.missing_wrapper and args.nonexecutable_wrapper):
        parser.error("product mode requires missing and nonexecutable wrapper variants")
    WRAPPER = args.wrapper
    MISSING_WRAPPER = args.missing_wrapper
    NONEXECUTABLE_WRAPPER = args.nonexecutable_wrapper
    suite = unittest.defaultTestLoader.loadTestsFromTestCase(FixtureTests)
    if WRAPPER:
        suite.addTests(unittest.defaultTestLoader.loadTestsFromTestCase(WrapperTests))
    result = unittest.TextTestRunner(verbosity=2).run(suite)
    sys.exit(not result.wasSuccessful())
