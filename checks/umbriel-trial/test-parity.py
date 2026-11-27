#!/usr/bin/env python3
"""Compare source inventory and rendered config; not live workflow acceptance."""

import json
from pathlib import Path
import re
import sys
import tomllib

config_path, manifest_path, template_path, extras_path, host_path, diagnostic_path = map(Path, sys.argv[1:])
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
    for key in ("allow_when_locked", "cooldown_ms"):
        assert binding.get(key) == record["binding"].get(key), (target, key)
locked = {key for key, value in config["keybinds"].items() if value.get("allow_when_locked", False)}
source_locked = {line.strip().split()[0] for line in template.splitlines() if "allow-when-locked=true" in line}
assert len(locked) == 10 and locked == source_locked
for target in ("Mod+WheelUp", "Mod+WheelDown", "Mod+Shift+WheelUp", "Mod+Shift+WheelDown"):
    assert config["keybinds"][target]["cooldown_ms"] == 150
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
print("PASS: source/config inventory, explicit deviations, 17 rule dispositions and 8 qualified names; live parity unverified")
