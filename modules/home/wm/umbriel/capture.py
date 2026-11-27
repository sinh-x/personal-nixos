#!/usr/bin/env python3
"""Explicit screenshot delivery and native session-owned recording.

No clipboard/image export occurs in this adapter; Noctalia's editor owns explicit
Copy/Save. Recorder state contains only a native-unit ownership nonce, never a PID.
"""

from datetime import datetime, timezone
from pathlib import Path
import os
import json
import re
import secrets
import subprocess
import sys
import time

import ipc
import power
from runtime import Refused, Runtime


SCREENSHOT_FLAGS = (
    "--annotate", "--no-skip-annotate-on-copy-save", "--no-save-to-file", "--no-copy-to-clipboard",
    "--no-pipe-to-command", "--no-copy-on-close",
    "--no-close-on-copy", "--no-close-on-save", "--format", "png",
)


def screenshot(kind, delay=0, run=subprocess.run, sleep=time.sleep, directory=None):
    commands = {"region": "screenshot-region", "window": "screenshot-window", "screen": "screenshot-fullscreen"}
    if kind not in commands or delay not in (0, 5, 10):
        raise Refused("Unsupported capture target or delay.")
    if delay:
        power.report(f"Capture in {delay} seconds", run=run)
        sleep(delay)
    directory = directory or str(Path.home() / "Pictures" / "Screenshots")
    run(["noctalia", "msg", commands[kind], *SCREENSHOT_FLAGS, "--directory", directory], check=True)


def menu(labels, run=subprocess.run):
    result = run(["rofi", "-dmenu", "-no-custom", "-format", "i", "-p", "Capture"],
                 input="".join(f"{label}\n" for label in labels), capture_output=True, text=True, check=False)
    if result.returncode != 0:
        return None
    return next((index for index in range(len(labels)) if result.stdout == f"{index}\n"), None)


def screenshot_menu(run=subprocess.run, sleep=time.sleep):
    choices = (("screen", 0), ("region", 0), ("window", 0), ("screen", 5), ("screen", 10))
    choice = menu(("Focused screen", "Region", "Focused window", "Focused screen in 5s", "Focused screen in 10s"), run)
    if choice is not None:
        screenshot(*choices[choice], run=run, sleep=sleep)


def properties(state, run):
    fields = ("LoadState", "ActiveState", "Description", "Transient", "PartOf", "Requisite", "After", "KillSignal")
    result = run(["systemctl", "--user", "show", state["unit"], *(f"--property={key}" for key in fields)],
                 capture_output=True, text=True, check=False, timeout=10)
    values = dict(line.split("=", 1) for line in result.stdout.splitlines() if "=" in line)
    if values.get("LoadState") == "not-found":
        return None
    if (result.returncode != 0 or values.get("LoadState") != "loaded"
            or values.get("Transient") != "yes"
            or values.get("Description") != "NX-077 recorder " + state["nonce"]
            or "umbriel-session.target" not in values.get("PartOf", "").split()
            or not {"umbriel.service", "umbriel-session.target"} <= set(values.get("Requisite", "").split())
            or "umbriel.service" not in values.get("After", "").split()
            or values.get("KillSignal") not in ("2", "SIGINT")):
        raise Refused("Recording state does not identify an owned transient recorder; no process was signalled.")
    if values.get("ActiveState") not in ("active", "activating", "deactivating", "inactive", "failed"):
        raise Refused("Recording state is not inspectable; no process was signalled.")
    return values


def stop_recording(runtime, run=subprocess.run):
    state = runtime.load_recording()
    if state is None:
        return False
    values = properties(state, run)
    if values is not None and values["ActiveState"] not in ("inactive", "failed"):
        # The unit was checked against our private nonce and compositor lifetime;
        # its configured SIGINT is used instead of sending a signal to a stale PID.
        run(["systemctl", "--user", "stop", state["unit"]], check=True, timeout=25)
    runtime.clear_recording()
    return True


def geometry_output(entries, geometry):
    match = re.fullmatch(r"(-?\d+),(-?\d+) (\d+)x(\d+)", geometry)
    if not match:
        raise Refused("Invalid selected recording geometry.")
    x, y, width, height = map(int, match.groups())
    if width <= 0 or height <= 0:
        raise Refused("Empty recording geometry.")
    matches = []
    for output in entries:
        position, size = output.get("position", {}), output.get("logical_size", {})
        values = (position.get("x"), position.get("y"), size.get("width"), size.get("height"))
        if not all(type(value) is int for value in values):
            raise Refused("Output recording geometry is unverified.")
        ox, oy, ow, oh = values
        if ox <= x and oy <= y and x + width <= ox + ow and y + height <= oy + oh:
            matches.append(output)
    if len(matches) != 1:
        raise Refused("Region must belong unambiguously to one enabled output.")
    return matches[0]


def output_signature(entries):
    return tuple(sorted((entry["name"], json.dumps({key: entry.get(key) for key in
                        ("position", "logical_size", "scale", "transform")}, sort_keys=True)) for entry in entries))


def start_recording(runtime, compositor, region=False, audio=False, run=subprocess.run, directory=None):
    if runtime.load_recording() is not None:
        raise Refused("Recording ownership already exists; stop or resolve it first.")
    entries = ipc.outputs(compositor)
    before = output_signature(entries)
    geometry = None
    if region:
        selected = run(["slurp"], capture_output=True, text=True, check=False)
        if selected.returncode != 0:
            return False
        geometry = selected.stdout.removesuffix("\n")
        target = geometry_output(entries, geometry)
    else:
        focused = [entry for entry in entries if entry["focused"]]
        if len(focused) != 1:
            raise Refused("Recording needs one unambiguous focused output.")
        target = focused[0]
    if output_signature(ipc.outputs(compositor)) != before:
        raise Refused("Output topology/geometry changed before recording; no recording was started.")
    nonce = secrets.token_hex(12)
    state = {"nonce": nonce, "unit": f"nx077-record-{runtime.display}-{nonce}.service"}
    directory = Path(directory) if directory is not None else Path.home() / "Videos" / "Recordings"
    directory.mkdir(parents=True, exist_ok=True)
    output = directory / (datetime.now(timezone.utc).strftime("Recording_%Y-%m-%d_%H-%M-%S_") + nonce + ".mp4")
    # Reserve a fresh filename. Never overwrite an existing recording.
    with output.open("xb"):
        pass
    argv = ["systemd-run", "--user", "--unit", state["unit"], "--collect", "--service-type=exec",
            "--description", "NX-077 recorder " + nonce,
            "--property=PartOf=umbriel-session.target",
            "--property=Requisite=umbriel.service umbriel-session.target", "--property=After=umbriel.service",
            "--property=KillSignal=SIGINT", "--property=TimeoutStopSec=15",
            "--setenv=WAYLAND_DISPLAY=" + os.environ.get("WAYLAND_DISPLAY", runtime.display),
            "--setenv=UMBRIEL_SOCKET=" + os.environ.get("UMBRIEL_SOCKET", ""),
            "--", os.environ.get("NX077_WF_RECORDER", "wf-recorder"), "-o", target["name"], "-f", str(output)]
    if geometry is not None:
        argv.extend(["-g", geometry])
    if audio:
        argv.append("--audio")
    try:
        # Requisite refuses an ended session without pulling a compositor back
        # up (unlike Requires/BindsTo). PartOf tears recording down on logout.
        run(argv, check=True, timeout=20)
        values = properties(state, run)
        if values is None or values["ActiveState"] != "active":
            raise Refused("Recorder did not reach an active native unit; no active claim was saved.")
        runtime.save_recording(state)
    except (OSError, Refused, subprocess.SubprocessError):
        # A failed start may have created a native unit. Stop only if its complete
        # ownership contract matches; preserve any unexpected operator state.
        values = properties(state, run)
        if values is not None and values["ActiveState"] not in ("inactive", "failed"):
            run(["systemctl", "--user", "stop", state["unit"]], check=True, timeout=25)
        raise
    return True


def recording_menu(runtime, compositor, run=subprocess.run, toggle=False):
    with runtime.lock("recording.lock"):
        state = runtime.load_recording()
        if state is not None:
            values = properties(state, run)
            active = values is not None and values["ActiveState"] not in ("inactive", "failed")
            if not active:
                runtime.clear_recording()
            elif toggle or menu(("Stop recording",), run) == 0:
                stop_recording(runtime, run)
                return
            else:
                return
        if toggle:
            start_recording(runtime, compositor, run=run)
            return
        choice = menu(("Focused screen", "Region", "Focused screen + audio", "Region + audio"), run)
        if choice is not None:
            start_recording(runtime, compositor, region=choice in (1, 3), audio=choice in (2, 3), run=run)


def main():
    if os.environ.get("XDG_CURRENT_DESKTOP") != "umbriel":
        raise Refused("Capture helper is scoped to the Umbriel trial.")
    if len(sys.argv) != 2:
        raise Refused("One capture action is required.")
    action = sys.argv[1]
    if action in ("region", "window", "screen"):
        screenshot(action)
    elif action == "menu":
        screenshot_menu()
    elif action in ("record-menu", "record-toggle"):
        with Runtime() as runtime:
            recording_menu(runtime, ipc.IPC(), toggle=action == "record-toggle")
    elif action == "record-stop":
        with Runtime() as runtime, runtime.lock("recording.lock"):
            stop_recording(runtime)
    else:
        raise Refused("Unknown capture action.")


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, KeyError, Refused, ipc.InvalidState, subprocess.SubprocessError) as error:
        power.report(f"Capture action refused: {error}")
        sys.exit(1)
