#!/usr/bin/env python3
"""Exercise the real picker with synthetic IPC and no access to live commands."""

import argparse
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
import unittest


MOCK_COMMAND = r'''
import json
import os
from pathlib import Path
import sys

command = Path(sys.argv[0]).name
args = sys.argv[1:]
with Path(os.environ["CALLS"]).open("a") as stream:
    stream.write(json.dumps([command, *args]) + "\n")
if command == "niri" and args == ["msg", "--json", "windows"]:
    sys.stdout.write(os.environ["WINDOWS"])
    sys.exit(int(os.environ["QUERY_STATUS"]))
if command == "niri" and args[:3] == ["msg", "action", "focus-window"]:
    sys.exit(int(os.environ["FOCUS_STATUS"]))
if command == "rofi":
    Path(os.environ["ROWS"]).write_text(sys.stdin.read())
    sys.stdout.write(os.environ["CHOICE"])
    sys.exit(int(os.environ["ROFI_STATUS"]))
sys.exit("Unexpected command in isolated test")
'''


def window(window_id=7, app_id="vivaldi", title="Example", **extra):
    return {"id": window_id, "app_id": app_id, "title": title, **extra}


class BrowserPickerTests(unittest.TestCase):
    def setUp(self):
        self.scratch = tempfile.TemporaryDirectory(prefix="niri-browser-picker-")
        self.addCleanup(self.scratch.cleanup)
        self.root = Path(self.scratch.name)
        self.bin = self.root / "bin"
        self.bin.mkdir()
        for name in ("niri", "rofi", "vivaldi", "zen-twilight", "google-chrome"):
            executable = self.bin / name
            executable.write_text(f"#!{sys.executable}\n" + MOCK_COMMAND)
            executable.chmod(0o755)
        (self.bin / "jq").symlink_to(JQ)
        self.calls_file = self.root / "calls.jsonl"
        self.rows_file = self.root / "rows"
        self.home = self.root / "home"
        self.theme = str(self.home / ".config/niri/rofi/ghostty_switcher.rasi")

    def run_picker(self, windows, choice="0\n", *, raw=False, query_status=0,
                   rofi_status=0, focus_status=0, expected_status=0):
        self.calls_file.unlink(missing_ok=True)
        self.rows_file.unlink(missing_ok=True)
        # No inherited NIRI_SOCKET, Wayland/X display or browser/profile state.
        env = {
            "HOME": str(self.home),
            "PATH": str(self.bin),
            "LC_ALL": "C.UTF-8",
            "CALLS": str(self.calls_file),
            "ROWS": str(self.rows_file),
            "WINDOWS": windows if raw else json.dumps(windows),
            "CHOICE": choice,
            "QUERY_STATUS": str(query_status),
            "ROFI_STATUS": str(rofi_status),
            "FOCUS_STATUS": str(focus_status),
        }
        result = subprocess.run([BASH, str(SCRIPT)], env=env, cwd=self.root, text=True,
                                capture_output=True, timeout=10)
        self.assertEqual(result.returncode, expected_status, result.stderr)
        self.calls = [json.loads(line) for line in self.calls_file.read_text().splitlines()]
        self.rows = self.rows_file.read_text() if self.rows_file.exists() else None
        self.assertEqual(self.calls[0], ["niri", "msg", "--json", "windows"])
        self.assertTrue(all(call[0] in ("niri", "rofi") for call in self.calls))
        return result

    def assert_menu(self, titles):
        self.assertEqual(self.rows, "".join(f"[{i}] {title}\n" for i, title in enumerate(titles, 1)))
        self.assertEqual(self.calls[1], ["rofi", "-dmenu", "-no-custom", "-format", "i",
                                        "-p", "Browser", "-theme", self.theme])

    def assert_focus(self, window_id):
        self.assertEqual(len(self.calls), 3)
        self.assertEqual(self.calls[-1], ["niri", "msg", "action", "focus-window",
                                         "--id", str(window_id)])

    def assert_no_focus(self, menu=False):
        self.assertEqual(len(self.calls), 2 if menu else 1)
        if not menu:
            self.assertIsNone(self.rows)

    def test_browser_aliases_and_case(self):
        aliases = {
            "vivaldi": "Vivaldi", "Vivaldi-stable": "Vivaldi",
            "zen": "Zen", "zen-twilight": "Zen", "ZEN-TWILIGHT": "Zen",
            "google-chrome": "Chrome", "Google-chrome-stable": "Chrome",
            "com.google.Chrome": "Chrome",
        }
        for app_id, browser in aliases.items():
            with self.subTest(app_id=app_id):
                self.run_picker([window(app_id=app_id)])
                self.assert_menu([f"{browser}: Example"])
                self.assert_focus(7)

    def test_excludes_other_apps_and_title_matches(self):
        apps = ["com.mitchellh.ghostty", "firefox", "chromium", "brave-browser",
                "microsoft-edge", "not-vivaldi", "vivaldi-helper", "zenity",
                "google-chrome-unrelated", "", None, 42, {}, []]
        self.run_picker([window(app_id=app, title="Vivaldi Zen Chrome") for app in apps])
        self.assert_no_focus()

    def test_duplicate_titles_and_cross_workspace_ids(self):
        windows = [window(15, "zen", "Same", workspace_id=1),
                   window(303, "google-chrome", "Same", workspace_id=9),
                   window(8, "vivaldi", "Same", workspace_id=None)]
        for index, window_id in enumerate((15, 303, 8)):
            with self.subTest(index=index):
                self.run_picker(windows, f"{index}\n")
                self.assert_menu(["Zen: Same", "Chrome: Same", "Vivaldi: Same"])
                self.assert_focus(window_id)

    def test_all_profiles_and_private_titles(self):
        titles = ["Work Profile", "Personal Profile", "Private Browsing", "Incognito"]
        self.run_picker([window(i, title=title) for i, title in enumerate(titles)], "3\n")
        self.assert_menu([f"Vivaldi: {title}" for title in titles])
        self.assert_focus(3)

    def test_missing_empty_and_nonstring_titles(self):
        windows = [window(0, title=None), window(1, title=""), window(2, title=42),
                   {"id": 3, "app_id": "zen"}]
        self.run_picker(windows, "3\n")
        self.assert_menu(["Vivaldi: [Untitled]"] * 3 + ["Zen: [Untitled]"])
        self.assert_focus(3)

    def test_controls_cannot_inject_rows_or_rofi_metadata(self):
        self.run_picker([window(title="Tab\tLine\nCR\rNul\0icon\x1fESC\x1bDEL\x7fNext\x85LS\u2028PS\u2029End")])
        self.assert_menu(["Vivaldi: Tab Line CR Nul icon ESC DEL Next LS PS End"])
        self.assert_focus(7)

    def test_unicode_shell_metacharacters_and_markup_are_literal(self):
        title = 'Tiếng Việt 🦊 <b>Literal</b> $(touch NEVER) `false` %s \\ "quotes"'
        self.run_picker([window(title=title)])
        self.assert_menu([f"Vivaldi: {title}"])
        self.assert_focus(7)
        self.assertFalse((self.root / "NEVER").exists())

    def test_invalid_window_entries_and_ids_are_skipped(self):
        windows = [None, False, "bad entry", [], {}, {"title": "no ID"}]
        windows += [window(bad_id) for bad_id in (None, "7", -1, 1.5, True, {}, [])]
        windows += [window(0)]
        self.run_picker(windows)
        self.assert_menu(["Vivaldi: Example"])
        self.assert_focus(0)

    def test_empty_window_list(self):
        self.run_picker([])
        self.assert_no_focus()

    def test_cancellation_and_rofi_failure_never_focus(self):
        for status, choice in ((1, ""), (1, "0\n"), (2, ""), (127, "0\n"), (0, "")):
            with self.subTest(status=status, choice=choice):
                self.run_picker([window()], choice, rofi_status=status)
                self.assert_menu(["Vivaldi: Example"])
                self.assert_no_focus(menu=True)

    def test_invalid_indices_are_not_evaluated(self):
        for choice in ("-1", "1", "999999999999999999999999999999", "01", "0+0",
                       " 0", "0 ", "0\n1", "Example", "ids[0]", "$(touch NEVER)"):
            with self.subTest(choice=choice):
                self.run_picker([window()], choice)
                self.assert_no_focus(menu=True)

    def test_failed_query_ignores_even_valid_stdout(self):
        result = self.run_picker([window()], query_status=1, expected_status=1)
        self.assert_no_focus()
        self.assertIn("could not query Niri", result.stderr)

    def test_malformed_ipc_fails_closed_without_content_disclosure(self):
        for raw in ("{BROKEN-SYNTHETIC-TITLE", "null", "{}", '"string"', "42"):
            with self.subTest(raw=raw):
                result = self.run_picker(raw, raw=True, expected_status=1)
                self.assert_no_focus()
                self.assertEqual(result.stderr, "Browser picker: invalid Niri window data.\n")
        self.run_picker("", raw=True)
        self.assert_no_focus()

    def test_disappearing_window_propagates_focus_failure_without_retry(self):
        self.run_picker([window()], focus_status=1, expected_status=1)
        self.assert_focus(7)

    def test_binding_and_declarative_assets(self):
        config = CONFIG.read_text()
        expected = {
            "B": 'Browser Switcher" { spawn "bash" "-c" "~/.config/niri/scripts/rofi-browser-switcher"; }',
            "T": 'Ghostty Switcher" { spawn "bash" "-c" "~/.config/niri/scripts/rofi_ghostty_switcher"; }',
            "W": 'Window Switcher" { spawn "rofi" "-show" "window"; }',
        }
        for key, suffix in expected.items():
            lines = re.findall(rf'^\s*Ctrl\+Alt\+{key}\b[^\n]*', config, re.MULTILINE)
            self.assertEqual([line.strip() for line in lines],
                             [f'Ctrl+Alt+{key} hotkey-overlay-title="{suffix}'])
        self.assertTrue(os.access(SCRIPT, os.X_OK))
        self.assertTrue(THEME.is_file())
        for shared in ("colors.rasi", "fonts.rasi"):
            self.assertTrue((THEME.parent / "shared" / shared).is_file())


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--script", required=True, type=Path)
    parser.add_argument("--config", required=True, type=Path)
    parser.add_argument("--theme", required=True, type=Path)
    args, unittest_args = parser.parse_known_args()
    SCRIPT, CONFIG, THEME = args.script.resolve(), args.config.resolve(), args.theme.resolve()
    BASH, JQ = shutil.which("bash"), shutil.which("jq")
    if not BASH or not JQ:
        parser.error("bash and jq must be available")
    unittest.main(argv=[sys.argv[0], *unittest_args])
