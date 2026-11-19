"""Synthetic downloader: records argv only; never opens the supplied archive root."""

import fcntl
import json
import os
from pathlib import Path
import sys
import time


def main():
    args = sys.argv[1:]
    if (
        len(args) != 5
        or args[:3] != ["download", "--root", "/home/sinh/.local/share/gmail-downloader"]
        or args[3] != "--profile"
        or args[4] not in ("personal", "andafin")
    ):
        print("fixture: unexpected selection", file=sys.stderr)
        return 2

    # The test-owned directory is the only writable location. No Gmail/network API.
    directory = Path(os.environ["GMAIL_FIXTURE_DIR"])
    profile = args[4]
    with (directory / f"{profile}.lock").open("a") as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            print(f"{profile}: fixture writer busy", file=sys.stderr)
            return 1
        with (directory / "calls.jsonl").open("a") as calls:
            calls.write(json.dumps(args) + "\n")
        (directory / f"{profile}.started").touch()
        if os.environ.get("GMAIL_FIXTURE_WAIT") == profile:
            while not (directory / "release").exists():
                time.sleep(0.02)
        code = int(os.environ.get(f"GMAIL_FIXTURE_EXIT_{profile.upper()}", "0"))
        print(f"{profile}: fixture exit={code}")
        return code


if __name__ == "__main__":
    sys.exit(main())
