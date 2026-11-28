#!/usr/bin/env python3
"""Bounded, typed Umbriel IPC adapters for NX-077. Never evaluate window titles."""

import argparse
import contextlib
import fcntl
import json
import os
import shlex
import socket
import stat
import subprocess
import sys
import time
import unicodedata


NAMES = ("main-term", "main-browser", "main-code", "chat", "email", "ext-term", "ext-browser", "ext-code")
BROWSERS = frozenset(("vivaldi", "vivaldi-stable", "zen", "zen-twilight", "google-chrome", "google-chrome-stable", "com.google.chrome"))
MAX_REPLY = 1024 * 1024


class InvalidState(RuntimeError):
    pass


def identifier(value):
    if (not isinstance(value, str) or not value or len(value) > 512
            or any(unicodedata.category(c).startswith("C") for c in value)):
        raise InvalidState("invalid opaque identifier")
    return value


def inventory(value, key, fields):
    if not isinstance(value, list) or len(value) > 4096:
        raise InvalidState("invalid inventory")
    seen = set()
    for entry in value:
        if not isinstance(entry, dict) or not fields <= entry.keys():
            raise InvalidState("incomplete inventory entry")
        item_id = identifier(entry[key])
        if item_id in seen:
            raise InvalidState("duplicate inventory identifier")
        seen.add(item_id)
    return value


class IPC:
    def __init__(self):
        self.path = os.environ.get("UMBRIEL_SOCKET")
        if not self.path:
            runtime = os.environ["XDG_RUNTIME_DIR"]
            display = identifier(os.environ["WAYLAND_DISPLAY"])
            if "/" in display:
                raise InvalidState("invalid Wayland display name")
            self.path = f"{runtime}/umbriel-{display}.sock"

    def request(self, payload):
        with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as connection:
            connection.settimeout(3)
            connection.connect(self.path)
            connection.sendall((json.dumps(payload) + "\n").encode())
            with connection.makefile("rb") as stream:
                line = stream.readline(MAX_REPLY + 1)
            if len(line) > MAX_REPLY or not line.endswith(b"\n"):
                raise InvalidState("oversized or incomplete IPC reply")
        reply = json.loads(line)
        if not isinstance(reply, dict) or set(reply) != {"ok"}:
            raise InvalidState("compositor rejected request or returned invalid JSON")
        return reply["ok"]

    def query(self, command):
        return self.request({"cmd": command})

    def action(self, action, **fields):
        return self.request({"cmd": "action", "action": action, **fields})


def outputs(ipc):
    result = inventory(ipc.query("outputs"), "name", {"name", "enabled", "focused", "active_workspace"})
    for entry in result:
        if type(entry["enabled"]) is not bool or type(entry["focused"]) is not bool:
            raise InvalidState("invalid output flags")
    return [entry for entry in result if entry["enabled"]]


def topology(ipc):
    return tuple(sorted(entry["name"] for entry in outputs(ipc)))


def workspaces(ipc):
    result = inventory(ipc.query("workspaces"), "id", {"id", "name", "named", "index", "output", "focused"})
    for entry in result:
        identifier(entry["output"])
        identifier(entry["name"])
        if type(entry["named"]) is not bool or type(entry["focused"]) is not bool:
            raise InvalidState("invalid workspace flags")
        if type(entry["index"]) is not int or entry["index"] < 1:
            raise InvalidState("invalid workspace position")
    return result


def resolve_named(entries, name):
    if name not in NAMES:
        raise InvalidState("unknown named workspace")
    matches = [entry for entry in entries if entry["named"] and entry["name"] == name]
    if len(matches) != 1:
        raise InvalidState("missing or ambiguous named workspace")
    return matches[0]


def named(ipc, name):
    return resolve_named(workspaces(ipc), name)


def focus_workspace(ipc, workspace):
    ipc.action("workspace-switch", workspace=workspace["name"], output=workspace["output"])


def route(ipc, name, move=False):
    before = topology(ipc)
    workspace = named(ipc, name)
    if workspace["output"] not in before or topology(ipc) != before:
        raise InvalidState("topology changed before workspace action")
    ipc.action("column-move-to-workspace" if move else "workspace-switch",
               workspace=name, output=workspace["output"])


def smart_spawn(ipc, kind, primary="eDP-1", browser=None):
    if kind not in ("terminal", "browser"):
        raise InvalidState("unknown launch kind")
    initial = outputs(ipc)
    signature = tuple(sorted(entry["name"] for entry in initial))
    focused = [entry for entry in initial if entry["focused"]]
    if len(focused) != 1:
        raise InvalidState("no unambiguous focused output")
    external = sorted(entry["name"] for entry in initial if entry["name"] != primary)
    prefix = "ext-" if focused[0]["name"] == primary and external else "main-"
    target = named(ipc, prefix + ("term" if kind == "terminal" else "browser"))
    if target["output"] not in signature or topology(ipc) != signature:
        raise InvalidState("topology changed before launch routing")
    argv = ["ghostty"] if kind == "terminal" else shlex.split(browser or "zen-twilight")
    if not argv or any("\x00" in word for word in argv):
        raise InvalidState("invalid application command")
    focus_workspace(ipc, target)
    # Requery after focus/hotplug. A stale action may have partially changed focus,
    # but must not launch into an unresolved or substituted destination.
    current = outputs(ipc)
    destination = named(ipc, target["name"])
    focused = [entry for entry in current if entry["focused"]]
    if (tuple(sorted(entry["name"] for entry in current)) != signature
            or destination["id"] != target["id"] or destination["output"] != target["output"]
            or len(focused) != 1 or focused[0]["name"] != target["output"]
            or focused[0]["active_workspace"] != target["id"]):
        raise InvalidState("launch destination changed; application was not started")
    # Only program argv is quoted into the compositor's documented shell spawn;
    # titles, selected IDs and output names never become shell commands.
    ipc.action("spawn", command=shlex.join(argv))


def windows(ipc):
    return inventory(ipc.query("windows"), "id", {"id", "app_id", "title", "workspace", "column", "row", "floating"})


def eligible(entry, kind):
    app = entry["app_id"]
    if not isinstance(app, str):
        raise InvalidState("invalid app identity")
    return kind == "all" or (kind == "browser" and app.lower() in BROWSERS) or (kind == "ghostty" and app == "com.mitchellh.ghostty")


def label(value):
    if not isinstance(value, str) or not value:
        return "[Untitled]"
    return "".join(" " if unicodedata.category(c).startswith("C") or c in "\u2028\u2029" else c for c in value)[:400]


def select_window(ipc, kind, run=subprocess.run):
    if kind not in ("all", "browser", "ghostty"):
        raise InvalidState("unknown selector")
    choices = [entry for entry in windows(ipc) if eligible(entry, kind)]
    if not choices:
        return
    text = "".join(f"[{index + 1}] {label(entry['app_id'])}: {label(entry['title'])}\n" for index, entry in enumerate(choices))
    selected = run(["rofi", "-dmenu", "-no-custom", "-format", "i", "-p", kind.title(),
                    "-theme", os.path.expanduser("~/.config/niri/rofi/ghostty_switcher.rasi")],
                   input=text, capture_output=True, text=True, check=False)
    if selected.returncode != 0:
        return
    choice = next((entry for index, entry in enumerate(choices) if selected.stdout == f"{index}\n"), None)
    if choice is None:
        return
    current = [entry for entry in windows(ipc) if entry["id"] == choice["id"]]
    if len(current) != 1 or current[0]["app_id"] != choice["app_id"] or not eligible(current[0], kind):
        return
    ipc.action("window-focus", window=choice["id"])


def column_context(ipc):
    focused = ipc.query("focused-window")
    if not isinstance(focused, dict):
        raise InvalidState("invalid focused window")
    identifier(focused.get("id"))
    candidates = windows(ipc)
    current = next((entry for entry in candidates if entry["id"] == focused["id"]), None)
    if current is None or current["floating"] is not False:
        raise InvalidState("focused window is not in a tiled column")
    tiled = [entry for entry in candidates if entry["workspace"] == current["workspace"] and entry["floating"] is False]
    for entry in tiled:
        if type(entry["column"]) is not int or type(entry["row"]) is not int or min(entry["column"], entry["row"]) < 0:
            raise InvalidState("layout has no stable column/row order")
    positions = [(entry["column"], entry["row"]) for entry in tiled]
    if len(set(positions)) != len(positions):
        raise InvalidState("ambiguous column/row order")
    return current, sorted(tiled, key=lambda entry: (entry["column"], entry["row"]))


def traverse(ipc, step):
    current, ordered = column_context(ipc)
    index = next(index for index, entry in enumerate(ordered) if entry["id"] == current["id"])
    target = index + step
    if 0 <= target < len(ordered):
        ipc.action("window-focus", window=ordered[target]["id"])


def expel_bottom(ipc):
    current, ordered = column_context(ipc)
    column = [entry for entry in ordered if entry["column"] == current["column"]]
    if len(column) < 2:
        return
    bottom = column[-1]
    ipc.action("window-focus", window=bottom["id"])
    check, fresh = column_context(ipc)
    fresh_column = [entry for entry in fresh if entry["column"] == current["column"]]
    if check["id"] != bottom["id"] or [entry["id"] for entry in fresh_column] != [entry["id"] for entry in column]:
        raise InvalidState("column changed before expel")
    ipc.action("window-consume-or-expel-right")


def reconcile(ipc, primary="eDP-1"):
    enabled = outputs(ipc)
    names = sorted(entry["name"] for entry in enabled)
    if not names:
        raise InvalidState("no enabled output")
    external = [name for name in names if name != primary]
    destination = external[0] if external else primary
    if destination not in names:
        raise InvalidState("no valid workspace destination")
    entries = workspaces(ipc)
    focused = [entry for entry in entries if entry["focused"]]
    initial = {name: resolve_named(entries, name) for name in NAMES}
    for name in NAMES:
        workspace = named(ipc, name)
        if workspace["id"] != initial[name]["id"]:
            raise InvalidState("workspace identity changed during assignment")
        target = destination if name.startswith("ext-") else (primary if primary in names else destination)
        if workspace["output"] == target:
            continue
        if topology(ipc) != tuple(names):
            raise InvalidState("topology changed during workspace assignment")
        ipc.action("workspace-move-to-output", destination=target, workspace=name, output=workspace["output"])
    if len(focused) == 1:
        current = [entry for entry in workspaces(ipc) if entry["id"] == focused[0]["id"]]
        if len(current) == 1:
            focus_workspace(ipc, current[0])


@contextlib.contextmanager
def routing_lock():
    runtime = os.environ.get("XDG_RUNTIME_DIR", "")
    if not os.path.isabs(runtime):
        raise InvalidState("missing absolute private runtime")
    directory = os.open(runtime, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW)
    try:
        info = os.fstat(directory)
        if info.st_uid != os.getuid() or info.st_mode & 0o077:
            raise InvalidState("unsafe runtime directory")
        fd = os.open("nx077-routing.lock", os.O_CREAT | os.O_RDWR | os.O_NOFOLLOW, 0o600, dir_fd=directory)
        try:
            info = os.fstat(fd)
            if not stat.S_ISREG(info.st_mode) or info.st_uid != os.getuid() or info.st_nlink != 1 or info.st_mode & 0o077:
                raise InvalidState("unsafe routing lock")
            fcntl.flock(fd, fcntl.LOCK_EX)
            yield
        finally:
            os.close(fd)
    finally:
        os.close(directory)


def startup(ipc, primary, sleep=time.sleep):
    # Like Niri, app startup needs the compositor, not the desktop shell.
    # Noctalia keeps its independent encrypted-storage readiness guard.
    # Do not hold the routing lock while waiting for readiness or settling apps.
    deadline = time.monotonic() + 20
    while True:
        try:
            if outputs(ipc):
                break
        except (OSError, InvalidState):
            pass
        if time.monotonic() >= deadline:
            raise InvalidState("compositor startup readiness timed out")
        sleep(0.2)
    with routing_lock():
        reconcile(ipc, primary)
        for argv in (["discord"], ["signal-desktop"], ["Telegram"], ["viber"]):
            ipc.action("spawn", command=shlex.join(argv))
    # Match Niri's terminal-last policy; this is not application readiness.
    sleep(2)
    with routing_lock():
        route(ipc, "main-term")
        ipc.action("spawn", command="ghostty")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("command", choices=("focus", "move", "spawn", "select", "tab", "expel", "reconcile", "startup", "watch"))
    parser.add_argument("argument", nargs="?")
    parser.add_argument("--primary", default="eDP-1")
    args = parser.parse_args()
    ipc = IPC()
    if args.command == "select":
        select_window(ipc, args.argument)
        return
    if args.command == "startup":
        startup(ipc, args.primary)
        return
    if args.command == "watch":
        # Only connector enablement changes trigger routing. Focus/scale events
        # must never continuously undo deliberately transferred workspaces.
        previous = None
        while True:
            current = topology(ipc)
            if current != previous:
                with routing_lock():
                    reconcile(ipc, args.primary)
                previous = current
            time.sleep(0.5)
        return
    with routing_lock():
        if args.command in ("focus", "move"):
            route(ipc, args.argument, move=args.command == "move")
        elif args.command == "spawn":
            smart_spawn(ipc, args.argument, args.primary, os.environ.get("BROWSER"))
        elif args.command == "tab":
            if args.argument not in ("next", "previous"):
                raise InvalidState("expected next or previous traversal")
            traverse(ipc, 1 if args.argument == "next" else -1)
        elif args.command == "expel":
            expel_bottom(ipc)
        elif args.command == "reconcile":
            reconcile(ipc, args.primary)


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, KeyError, InvalidState, subprocess.SubprocessError) as error:
        print(f"Umbriel trial adapter: {error}", file=sys.stderr)
        # Only fixed diagnostics, never window titles, enter the notification.
        subprocess.run(["busctl", "--user", "--auto-start=no", "call", "org.freedesktop.Notifications",
                        "/org/freedesktop/Notifications", "org.freedesktop.Notifications", "Notify",
                        "susssasa{sv}i", "Umbriel trial", "0", "", "Umbriel trial",
                        "Desktop action failed; see session log.", "0", "0", "6000"],
                       check=False, capture_output=True, timeout=3)
        sys.exit(1)
