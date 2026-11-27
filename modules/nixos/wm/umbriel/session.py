#!/usr/bin/env python3
"""NX-077 greeter boundary; never restart portals inside an active session.

Uses documented launcher/target APIs, not private compositor unit contents.
All process calls are injected in fixtures; importing this file has no effects.
"""

import contextlib
import fcntl
import os
import signal
import stat
import subprocess
import sys


DESKTOPS = ("niri", "umbriel")
PORTALS = (
    "xdg-desktop-portal.service",
    "xdg-desktop-portal-gnome.service",
    "xdg-desktop-portal-gtk.service",
    "xdg-desktop-portal-umbriel.service",
)
SESSION_VARIABLES = (
    "WAYLAND_DISPLAY", "WAYLAND_SOCKET", "DISPLAY", "NIRI_SOCKET",
    "UMBRIEL_SOCKET", "LIBEI_SOCKET", "XDG_CURRENT_DESKTOP",
    "XDG_SESSION_DESKTOP", "XDG_SESSION_TYPE",
)


def manager(run, *args):
    return run(
        ["systemctl", "--user", *args], check=True,
        capture_output=True, text=True, timeout=30,
    )


def inspect_states(run):
    result = manager(
        run, "show", "--property=ActiveState", "--value",
        *(f"{desktop}.service" for desktop in DESKTOPS),
    )
    states = result.stdout.split()
    if len(states) != 2:
        raise RuntimeError("compositor states are not inspectable")
    return dict(zip(DESKTOPS, states))


def require_inactive(run):
    if any(state not in ("inactive", "failed") for state in inspect_states(run).values()):
        raise RuntimeError("another compositor is active, starting or not inspectable")


def clear_environment(run):
    # D-Bus has no unset operation. Empty its stale activation values, then
    # remove the corresponding keys from the systemd manager environment.
    run(
        ["dbus-update-activation-environment", "--systemd",
         *(f"{name}=" for name in SESSION_VARIABLES)],
        check=True, capture_output=True, text=True, timeout=30,
    )
    manager(run, "unset-environment", *SESSION_VARIABLES)


def prepare(desktop, run, environment):
    if desktop not in DESKTOPS:
        raise ValueError("unsupported desktop")
    require_inactive(run)
    manager(run, "stop", *PORTALS)
    clear_environment(run)
    environment = dict(environment)
    for name in SESSION_VARIABLES:
        environment.pop(name, None)
    environment.update(
        XDG_CURRENT_DESKTOP=desktop,
        XDG_SESSION_DESKTOP=desktop,
        XDG_SESSION_TYPE="wayland",
    )
    return environment


def finish(desktop, run):
    # The upstream launcher normally tears these down. Explicitly cover a
    # failed/interrupted launcher too, but never stop another compositor.
    states = inspect_states(run)
    if any(states[name] not in ("inactive", "failed") for name in DESKTOPS if name != desktop):
        raise RuntimeError("refusing cleanup while another compositor owns a session")
    manager(run, "start", "--job-mode=replace-irreversibly", f"{desktop}-shutdown.target")
    manager(run, "stop", f"{desktop}.service", f"{desktop}-session.target")
    require_inactive(run)
    manager(run, "stop", *PORTALS)
    clear_environment(run)


def run_session(desktop, launcher, run=subprocess.run, environment=None):
    env = prepare(desktop, run, os.environ if environment is None else environment)
    try:
        return run(launcher, check=False, env=env).returncode
    finally:
        finish(desktop, run)


@contextlib.contextmanager
def session_lock(runtime):
    if not runtime or not os.path.isabs(runtime):
        raise RuntimeError("XDG_RUNTIME_DIR must be absolute")
    parent = os.open(runtime, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW)
    try:
        info = os.fstat(parent)
        if info.st_uid != os.getuid() or info.st_mode & 0o077:
            raise RuntimeError("XDG_RUNTIME_DIR must be a private, owned directory")
        # Descriptor-relative access avoids replacing the checked directory
        # between validation and opening the lock. Never truncate existing data.
        fd = os.open("nx077-session.lock", os.O_CREAT | os.O_RDWR | os.O_NOFOLLOW, 0o600, dir_fd=parent)
        try:
            info = os.fstat(fd)
            if (not stat.S_ISREG(info.st_mode) or info.st_uid != os.getuid()
                    or info.st_nlink != 1 or info.st_mode & 0o077):
                raise RuntimeError("unsafe session lock")
            try:
                fcntl.flock(fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
            except BlockingIOError as error:
                raise RuntimeError("another session transition already owns the boundary") from error
            yield
        finally:
            os.close(fd)
    finally:
        os.close(parent)


def terminate(signum, _frame):
    # subprocess.run reaps its child on this exception; the finally block then
    # stops only our selected compositor/target before releasing the lock.
    raise SystemExit(128 + signum)


def main():
    if len(sys.argv) < 3 or sys.argv[1] not in DESKTOPS or not os.path.isabs(sys.argv[2]):
        raise ValueError("usage: session.py {niri|umbriel} /absolute/launcher [args...]")
    signal.signal(signal.SIGTERM, terminate)
    with session_lock(os.environ.get("XDG_RUNTIME_DIR")):
        return run_session(sys.argv[1], sys.argv[2:])


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, RuntimeError, ValueError, subprocess.SubprocessError) as error:
        # Do not dump captured environments or launcher output in errors.
        print(f"NX-077 session boundary refused: {type(error).__name__}: {error}", file=sys.stderr)
        sys.exit(1)
