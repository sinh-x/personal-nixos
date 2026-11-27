#!/usr/bin/env python3
"""Trial controls. Core functions take fake dependencies for headless fixtures."""

import os
import shlex
import subprocess
import sys

from ipc import IPC, InvalidState
import power
from runtime import Refused, Runtime


SINK = "@DEFAULT_AUDIO_SINK@"
SOURCE = "@DEFAULT_AUDIO_SOURCE@"


def clipboard_ready(run=subprocess.run):
    base = ["busctl", "--user", "--auto-start=no"]
    alias = run(base + ["call", "org.freedesktop.secrets", "/org/freedesktop/secrets",
                       "org.freedesktop.Secret.Service", "ReadAlias", "s", "default"],
                check=True, capture_output=True, text=True, timeout=5)
    parts = shlex.split(alias.stdout)
    if len(parts) != 2 or parts[0] != "o" or not parts[1].startswith("/org/freedesktop/secrets/collection/"):
        raise Refused("Clipboard persistence unavailable: no existing default Secret Service collection. Ask Sinh; do not create a credential store.")
    locked = run(base + ["get-property", "org.freedesktop.secrets", parts[1],
                        "org.freedesktop.Secret.Collection", "Locked"],
                 check=True, capture_output=True, text=True, timeout=5)
    if shlex.split(locked.stdout) != ["b", "false"]:
        raise Refused("Clipboard persistence unavailable: existing collection is locked or unverified. Ask Sinh; no plaintext-key fallback.")


def utility(action, run=subprocess.run):
    if action in ("volume-up", "volume-down"):
        run(["wpctl", "set-mute", SINK, "0"], check=True)
        run(["wpctl", "set-volume", "-l", "1.0", SINK, "5%+" if action == "volume-up" else "5%-"], check=True)
        run(["noctalia", "msg", "volume-osd"], check=True)
    elif action in ("volume-mute", "mic-mute"):
        run(["wpctl", "set-mute", SOURCE if action == "mic-mute" else SINK, "toggle"], check=True)
        run(["noctalia", "msg", "mic-volume-osd" if action == "mic-mute" else "volume-osd"], check=True)
    elif action in ("brightness-up", "brightness-down"):
        run(["brightnessctl", "set", "+5%" if action == "brightness-up" else "5%-"], check=True)
        run(["noctalia", "msg", "brightness-osd"], check=True)
    elif action == "power-menu":
        run(["noctalia", "msg", "panel-toggle", "session"], check=True)
    elif action in ("reboot", "shutdown"):
        run(["systemctl", "reboot" if action == "reboot" else "poweroff"], check=True)
    else:
        raise Refused("Unknown trial utility action.")


def main():
    if os.environ.get("XDG_CURRENT_DESKTOP") != "umbriel":
        raise Refused("Control helper is scoped to the Umbriel trial.")
    if len(sys.argv) != 2:
        raise Refused("One trial action is required.")
    action = sys.argv[1]
    if action == "clipboard-ready":
        clipboard_ready()
        return 0
    if action in ("lock", "hibernate"):
        with Runtime() as runtime:
            return power.guard(action, runtime)
    if action == "logout":
        IPC().action("session-quit", skip_confirmation=False)
        return 0
    utility(action)
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, ValueError, Refused, InvalidState, subprocess.SubprocessError) as error:
        # No command output/collection contents are logged; diagnostics are fixed
        # refusal reasons or failing command names, never credentials.
        power.report(f"Trial control refused: {error}")
        sys.exit(1)
