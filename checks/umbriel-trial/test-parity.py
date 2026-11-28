#!/usr/bin/env python3
"""Compare source inventory and rendered config; not live workflow acceptance."""

import json
from pathlib import Path
import re
import sys
import tomllib

config_path, manifest_path, template_path, extras_path, host_path, diagnostic_path, noctalia_path, niri_path, niri_startup_path = map(Path, sys.argv[1:])
config = tomllib.loads(config_path.read_text())
manifest = json.loads(manifest_path.read_text())
template, extras, host = (path.read_text() for path in (template_path, extras_path, host_path))
diagnostics = json.loads(diagnostic_path.read_text())
assert diagnostics["valid"] and not diagnostics["diagnostics"], diagnostics
pattern = re.compile(r'^\s*((?:(?:Mod|Ctrl|Alt|Shift)\+)+[A-Za-z0-9]+|Print|XF86[A-Za-z0-9]+)(?:\s+[^\{]*)?\s*\{', re.M)
source = pattern.findall(template) + pattern.findall(extras)
assert len(source) == len(set(source)) == 112, (len(source), len(set(source)))
records = manifest["bindings"]
assert len(records) == 112
assert {entry["source"] for entry in records} == set(source)
by_target = {}
for entry in records:
    assert entry["source"] in source
    target = entry["target"]
    if target in by_target:
        assert entry["binding"] == by_target[target]["binding"], "alias has inconsistent semantics"
    by_target[target] = entry
assert len(by_target) == 110
assert set(config["keybinds"]) == set(by_target)
# Store prefixes differ between manifest fixture and real installed helper.
for target, record in by_target.items():
    binding = config["keybinds"][target]
    for key in ("allow_when_locked", "cooldown_ms", "repeat", "release"):
        assert binding.get(key) == record["binding"].get(key), (target, key)
locked = {key for key, value in config["keybinds"].items() if value.get("allow_when_locked", False)}
source_locked = {line.strip().split()[0] for line in template.splitlines() if "allow-when-locked=true" in line}
assert len(locked) == 10 and locked == source_locked
for target in ("Mod+WheelUp", "Mod+WheelDown", "Mod+Shift+WheelUp", "Mod+Shift+WheelDown"):
    assert config["keybinds"][target]["cooldown_ms"] == 150
numbered_names = ("main-term", "main-browser", "main-code", "chat", "email", "ext-term", "ext-browser", "ext-code")
for index, name in enumerate(numbered_names, 1):
    target = f"Mod+{index}"
    expected = {"action": f"workspace-switch {name}", "repeat": False}
    assert config["keybinds"][target] == expected, target
    assert by_target[target]["binding"] == expected, target
    shifted = f"Mod+Shift+{index}"
    assert config["keybinds"][shifted]["action"].startswith("spawn ")
    assert config["keybinds"][shifted]["action"].endswith(f"/bin/umbriel-trial move {name}")
assert config["keybinds"]["Ctrl+Alt+Up"] == {"action": "workspace-previous"}
assert config["keybinds"]["Ctrl+Alt+Down"] == {"action": "workspace-next"}
assert config["keybinds"]["Ctrl+Alt+B"]["action"].endswith("select browser")
assert config["keybinds"]["Mod+BracketRight"]["action"].endswith("expel")
assert config["keybinds"]["Mod+Tab"]["action"].endswith("tab next")
assert config["keybinds"]["Mod+Shift+Tab"]["action"].endswith("tab previous")
assert config["keybinds"]["Mod+I"]["action"] == config["keybinds"]["Mod+Shift+I"]["action"] == "spawn noctalia msg notification-clear-active"
assert config["keybinds"]["XF86AudioPlay"]["action"] == "spawn mpc toggle"
assert config["keybinds"]["XF86AudioNext"]["action"] == "spawn mpc next"
assert config["keybinds"]["XF86AudioPrev"]["action"] == "spawn mpc prev"
assert config["keybinds"]["XF86AudioStop"]["action"] == "spawn mpc stop"
assert config["keybinds"]["Mod+Shift+Left"]["action"] == "column-move-left"
assert config["keybinds"]["Mod+Shift+Comma"]["action"] == "column-move-to-output-left"
assert config["keybinds"]["Ctrl+Alt+Shift+Down"]["action"] == "column-move-to-workspace-next"
assert config["keybinds"]["Mod+Ctrl+Period"]["action"] == "workspace-move-to-output-right"
assert len(re.findall(r'^\s*window-rule\s*\{', template + '\n' + extras + '\n' + host, re.M)) == 17
assert len(config["window_rule"]) == 16
assert len(manifest["ruleLedger"]) == 17
assert [entry["sourceRule"] for entry in manifest["ruleLedger"]] == list(range(1, 18))
assert manifest["ruleLedger"][-1]["disposition"] == "unverified-direct-xwayland-zoom-awaits-consented-metadata"
for rule in config["window_rule"]:
    assert "zoom" not in json.dumps(rule).lower(), "unevidenced Zoom rule"
expected_names = {"main-term", "main-browser", "main-code", "chat", "email", "ext-term", "ext-browser", "ext-code"}
assert len(config["workspace"]) == 8
assert {entry["name"] for entry in config["workspace"]} == expected_names
assert {entry["output"] for entry in config["workspace"]} == {"eDP-1"}
for name, body in re.findall(r'output "([^"]+)"\s*\{([^}]+)\}', template):
    output = config["output"][name]
    assert output["mode"] == re.search(r'mode "([^"]+)"', body)[1]
    assert output["scale"] == float(re.search(r'scale ([0-9.]+)', body)[1])
    position = re.search(r'position x=(-?\d+) y=(-?\d+)', body)
    assert output["position"] == [int(position[1]), int(position[2])]
assert config["input"]["keyboard"] == {"layout": "us", "repeat_delay": 600, "repeat_rate": 25}
assert config["input"]["touchpad"]["sensitivity"] == 0.2
assert not config["input"]["touchpad"]["natural_scroll"]
assert len(config["general"]["autostart"]) == 1
assert "startup" in config["general"]["autostart"][0]
assert "noctalia" not in config["general"]["autostart"][0]
assert not set(config["environment"]) & {"XDG_CURRENT_DESKTOP", "XDG_SESSION_DESKTOP", "XDG_SESSION_TYPE"}
niri = niri_path.read_text()
for daemon in ('spawn-at-startup "mako"', 'spawn-at-startup "awww-daemon"', 'spawn-at-startup "wl-paste"', 'spawn-at-startup "fcitx5"', '~/.config/niri/scripts/statusbar', 'sleep 1 && ~/.config/niri/scripts/wallpaper --default'):
    assert daemon not in niri, "duplicate unsupervised Niri shell startup"
assert len(pattern.findall(niri)) == 112
assert '~/.config/niri/scripts/startup_apps' in niri
niri_startup = niri_startup_path.read_text()
assert re.findall(r'^([A-Za-z0-9-]+) &$', niri_startup, re.M) == ["discord", "signal-desktop", "Telegram", "viber", "logseq"]
assert "\nsleep 2\n" in niri_startup and "exec ghostty" in niri_startup
assert not re.search(r'^\s*vivaldi\b', niri_startup, re.M), "browser must not autostart"
noctalia = tomllib.loads(noctalia_path.read_text())
assert noctalia["storage"] == {"key_source": "secret-service", "key_file": ""}
assert noctalia["wallpaper"]["directory"] == "/home/sinh/Pictures/Wallpapers"
assert not noctalia["lockscreen"]["enabled"]
assert not noctalia["shell"]["polkit_agent"]
assert noctalia["shell"]["clipboard_auto_paste"] == "off"
for name in ("save_to_file", "copy_to_clipboard", "pipe_to_command", "copy_on_close", "close_on_copy", "close_on_save"):
    assert noctalia["shell"]["screenshot"][name] is False
assert noctalia["shell"]["screenshot"]["annotate"] is True
assert noctalia["shell"]["screenshot"]["format"] == "png"
actions = noctalia["shell"]["session"]["actions"]
assert [action["label"] for action in actions] == ["Lock", "Hibernate", "Logout", "Reboot", "Shutdown"]
assert all(action["action"] not in ("suspend", "lock_and_suspend") for action in actions)
assert actions[1]["command"].endswith("/bin/umbriel-controls hibernate")
assert noctalia["shell"]["session"]["power"]["suspend"] == actions[1]["command"]
assert all(behavior["enabled"] is False for behavior in noctalia["idle"]["behavior"].values())
print("PASS: source/config inventory, exact deviations, 17 rule dispositions, 8 names and declared capture/power/storage safeguards; live parity unverified")
