#!/usr/bin/env python3
"""Operator-only initialization/certificate publication. Never print secret bytes.

Imported functions are exercised unprivileged against synthetic temporary fixtures.
The production entry point requires root and is run only by approved systemd units.
"""
import os
import pwd
import stat
import subprocess
import sys
import uuid
from pathlib import Path

MAX_FILE = 1024 * 1024


def directory(path, uid):
    path = Path(path)
    if not path.is_absolute() or path.resolve() != path:
        raise ValueError("Noncanonical private directory retained")
    fd = os.open(path, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW)
    info = os.fstat(fd)
    if info.st_uid != uid or stat.S_IMODE(info.st_mode) != 0o700:
        os.close(fd)
        raise ValueError("Unexpected private directory owner/mode retained")
    return fd


def private_file(fd, name, uid):
    stream = os.open(name, os.O_RDONLY | os.O_NOFOLLOW, dir_fd=fd)
    try:
        info = os.fstat(stream)
        if not stat.S_ISREG(info.st_mode) or info.st_nlink != 1 or stat.S_IMODE(info.st_mode) != 0o600 or info.st_uid != uid:
            raise ValueError("Unexpected private file retained")
        data = bytearray()
        while True:
            chunk = os.read(stream, 8192)
            if not chunk:
                break
            data.extend(chunk)
            if len(data) > MAX_FILE:
                raise ValueError("Private file bound exceeded")
        if not data:
            raise ValueError("Empty private file retained")
        return bytes(data)
    finally:
        os.close(stream)


def publish(source, target, uid, gid):
    """Anchor both directories; never follow target symlinks or chown arbitrary paths."""
    src = directory(source, os.geteuid())
    dst = directory(target, uid)
    prepared = []
    try:
        for name in ("cert.pem", "key.pem"):
            data = private_file(src, name, os.geteuid())
            try:
                old = os.stat(name, dir_fd=dst, follow_symlinks=False)
            except FileNotFoundError:
                old = None
            if old is not None:
                if not stat.S_ISREG(old.st_mode) or old.st_nlink != 1 or old.st_uid != uid or stat.S_IMODE(old.st_mode) != 0o600:
                    raise ValueError("Aliased/unexpected installed certificate retained")
                if private_file(dst, name, uid) == data:
                    continue
            stage = ".publish-" + str(uuid.uuid4())
            fd = os.open(stage, os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW, 0o600, dir_fd=dst)
            try:
                if os.geteuid() == 0:
                    os.fchown(fd, uid, gid)
                elif (uid, gid) != (os.geteuid(), os.getegid()):
                    raise ValueError("Fixture cannot change ownership")
                os.fchmod(fd, 0o600)
                with os.fdopen(fd, "wb", closefd=False) as stream:
                    stream.write(data)
                    stream.flush()
                    os.fsync(fd)
            finally:
                os.close(fd)
            prepared.append((stage, name))
        # Both source files were checked before replacing either destination.
        # Pair replacement can briefly fail TLS closed; it never exposes a bad pair.
        for stage, name in prepared:
            os.replace(stage, name, src_dir_fd=dst, dst_dir_fd=dst)
        os.fsync(dst)
    finally:
        os.close(src)
        os.close(dst)
    # Interrupted staging is retained for operator inspection, never broadly swept.


def initialize(binary, target, account):
    identity = pwd.getpwnam(account)
    root = directory(target, identity.pw_uid)
    try:
        try:
            os.stat("auth.json", dir_fd=root, follow_symlinks=False)
        except FileNotFoundError:
            pass
        else:
            private_file(root, "auth.json", identity.pw_uid)
            return  # Never reset an existing browser/device roster or password.
        password = "browser-password"
        fd = os.open(password, os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW, 0o600, dir_fd=root)
        try:
            import secrets
            with os.fdopen(fd, "wb", closefd=False) as stream:
                stream.write((secrets.token_urlsafe(36) + "\n").encode("ascii"))
                stream.flush()
                os.fsync(fd)
            os.fchown(fd, identity.pw_uid, identity.pw_gid)
            os.fsync(root)
            # Drop privilege for the native writer so auth.json AND its stable lock
            # already belong to the service account, including later enroll/revoke.
            subprocess.run([binary, "init-auth", "--credentials", str(Path(target) / "auth.json"),
                            "--username", "owner", "--password-file", str(Path(target) / password)],
                           check=True, user=identity.pw_uid, group=identity.pw_gid, extra_groups=[])
        finally:
            # The retained plaintext browser password is operator-readable only.
            os.fchown(fd, 0, 0)
            os.fchmod(fd, 0o600)
            os.fsync(fd)
            os.close(fd)
        private_file(root, "auth.json", identity.pw_uid)
        os.fsync(root)
    finally:
        os.close(root)


def main():
    if os.geteuid() != 0:
        raise ValueError("Production credential operations require the operator/root unit")
    if len(sys.argv) == 5 and sys.argv[1] == "init":
        initialize(sys.argv[2], sys.argv[3], sys.argv[4])
    elif len(sys.argv) == 5 and sys.argv[1] == "publish":
        account = pwd.getpwnam(sys.argv[4])
        publish(sys.argv[2], sys.argv[3], account.pw_uid, account.pw_gid)
    else:
        raise ValueError("Unknown operator operation")


if __name__ == "__main__":
    try:
        main()
    except Exception:
        print("Timelapse credential preparation stopped; retain files and inspect privately. No reset attempted.", file=sys.stderr)
        raise SystemExit(1)
