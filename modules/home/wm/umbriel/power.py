"""Protocol-acknowledged swaylock gate. No privileged/authentication fallbacks."""

import os
import select
import subprocess
import sys
import time

from runtime import Refused


LOCK_ARGS = (
    "--config", "/dev/null",  # Do not inherit a profile's daemonize or unrelated UI options.
    "--ignore-empty-password", "--show-failed-attempts", "--hide-keyboard-layout",
    "--indicator-caps-lock", "--color", "183044",
)


def report(message, run=subprocess.run):
    print(message, file=sys.stderr)
    # Never D-Bus-activate the legacy Mako daemon when the trial shell is absent.
    try:
        run(["busctl", "--user", "--auto-start=no", "call", "org.freedesktop.Notifications",
             "/org/freedesktop/Notifications", "org.freedesktop.Notifications", "Notify",
             "susssasa{sv}i", "Umbriel trial", "0", "", "Umbriel trial", message, "0", "0", "6000"],
            check=False, capture_output=True, timeout=3)
    except (OSError, subprocess.SubprocessError):
        pass


def wait_ready(fd, process, timeout):
    deadline = time.monotonic() + timeout
    while process.poll() is None:
        remaining = deadline - time.monotonic()
        if remaining <= 0:
            raise Refused("Lock acknowledgement timed out; no Hibernate requested.")
        ready, _, _ = select.select([fd], [], [], remaining)
        if not ready:
            raise Refused("Lock acknowledgement timed out; no Hibernate requested.")
        data = os.read(fd, 2)
        if data != b"\n":
            raise Refused("Lock refused, closed or sent an invalid acknowledgement; no Hibernate requested.")
        if process.poll() is not None:
            raise Refused("Locker exited before dispatch; no Hibernate requested.")
        return
    raise Refused("Locker exited before acknowledgement; no Hibernate requested.")


def guard(mode, runtime, popen=subprocess.Popen, run=subprocess.run, notify=report, timeout=10):
    if mode not in ("lock", "hibernate"):
        raise Refused("Unsupported power action.")
    with runtime.lock("power.lock"):
        read_fd, write_fd = os.pipe2(os.O_CLOEXEC)
        process = None
        try:
            try:
                # No --daemonize: this process remains the actual locker client
                # whose liveness is checked before the ordinary logind request.
                process = popen(["swaylock", *LOCK_ARGS, "--ready-fd", str(write_fd)],
                                pass_fds=(write_fd,), stdin=subprocess.DEVNULL)
            finally:
                os.close(write_fd)
            status = 0
            try:
                wait_ready(read_fd, process, timeout)
                if mode == "hibernate":
                    if process.poll() is not None:
                        raise Refused("Locker exited before dispatch; no Hibernate requested.")
                    result = run(["systemctl", "hibernate"], check=False)
                    if result.returncode != 0:
                        raise Refused("Hibernate denied or failed; the lock is retained.")
            except (OSError, Refused, subprocess.SubprocessError) as error:
                status = 1
                notify(str(error))
            finally:
                # Never kill a possibly secure locker on timeout or denial. Keep
                # duplicate requests serialized until it exits/authenticates.
                exited = process.wait()
                if status == 0 and exited != 0:
                    notify("Locker exited unexpectedly; secure compositor blanking requires operator qualification.")
                    status = 1
            return status
        finally:
            os.close(read_fd)
