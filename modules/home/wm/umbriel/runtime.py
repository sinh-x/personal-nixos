"""Private per-display runtime bookkeeping for trial helpers (no credentials)."""

import contextlib
import fcntl
import json
import os
import re
import stat


class Refused(RuntimeError):
    pass


def checked(fd, directory=False):
    info = os.fstat(fd)
    valid_type = stat.S_ISDIR(info.st_mode) if directory else stat.S_ISREG(info.st_mode)
    if (not valid_type or info.st_uid != os.getuid() or info.st_mode & 0o077
            or (not directory and info.st_nlink != 1)):
        raise Refused("unsafe private runtime object")
    return info


class Runtime:
    def __init__(self, root=None, display=None):
        root = root if root is not None else os.environ.get("XDG_RUNTIME_DIR", "")
        self.display = display if display is not None else os.environ.get("WAYLAND_DISPLAY", "")
        if not os.path.isabs(root) or not re.fullmatch(r"[A-Za-z0-9_.-]{1,64}", self.display):
            raise Refused("missing private runtime or invalid display identity")
        parent = os.open(root, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW)
        try:
            checked(parent, directory=True)
            name = "nx077-umbriel-" + self.display
            try:
                os.mkdir(name, 0o700, dir_fd=parent)
            except FileExistsError:
                pass
            self.fd = os.open(name, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW, dir_fd=parent)
            try:
                checked(self.fd, directory=True)
            except BaseException:
                os.close(self.fd)
                raise
        finally:
            os.close(parent)

    def __enter__(self):
        return self

    def __exit__(self, *_args):
        os.close(self.fd)

    @contextlib.contextmanager
    def lock(self, name):
        if name not in ("power.lock", "recording.lock"):
            raise Refused("unknown runtime lock")
        fd = os.open(name, os.O_CREAT | os.O_RDWR | os.O_NOFOLLOW, 0o600, dir_fd=self.fd)
        try:
            checked(fd)
            try:
                fcntl.flock(fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
            except BlockingIOError as error:
                raise Refused("duplicate request already in progress") from error
            yield
        finally:
            os.close(fd)

    def load_recording(self):
        try:
            fd = os.open("recording.json", os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK, dir_fd=self.fd)
        except FileNotFoundError:
            return None
        try:
            if checked(fd).st_size > 4096:
                raise Refused("oversized recording state")
            data = json.loads(os.read(fd, 4097))
        finally:
            os.close(fd)
        if (not isinstance(data, dict) or set(data) != {"nonce", "unit"}
                or not isinstance(data["nonce"], str) or not re.fullmatch(r"[0-9a-f]{24}", data["nonce"])
                or data["unit"] != f"nx077-record-{self.display}-{data['nonce']}.service"):
            raise Refused("invalid recording ownership state")
        return data

    def save_recording(self, data):
        fd = os.open("recording.json", os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW, 0o600, dir_fd=self.fd)
        try:
            checked(fd)
            payload = json.dumps(data).encode()
            if len(payload) > 4096:
                raise Refused("oversized recording ownership state")
            while payload:
                written = os.write(fd, payload)
                payload = payload[written:]
            os.fsync(fd)
        finally:
            os.close(fd)

    def clear_recording(self):
        # All callers hold recording.lock; do not follow links or remove a
        # foreign object if operator state has replaced our private record.
        fd = os.open("recording.json", os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK, dir_fd=self.fd)
        try:
            checked(fd)
            before = os.fstat(fd)
            current = os.stat("recording.json", dir_fd=self.fd, follow_symlinks=False)
            if (before.st_dev, before.st_ino) != (current.st_dev, current.st_ino):
                raise Refused("recording state changed")
            os.unlink("recording.json", dir_fd=self.fd)
        finally:
            os.close(fd)
