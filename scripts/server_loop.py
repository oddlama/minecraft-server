#!/usr/bin/env python3
# Necessary env: PIDFILE (will be created and deleted)

import os
import signal
import subprocess
import sys
import time
from pathlib import Path

def main():
    if len(sys.argv) < 2:
        print("usage: {sys.argv[0]} COMMAND")
        sys.exit(1)

    blockfile = Path('start.block')

    # Check and create pidfile
    pid = str(os.getpid())
    pidfile = os.environ["PIDFILE"]

    if os.path.isfile(pidfile):
        print(f"Pidfile {pidfile} already exists, exiting")
        sys.exit(1)

    with open(pidfile, 'w') as f:
        f.write(pid)

    # Global state
    shared_data = {
        "stop": False,
        "process": None,
    }

    def block_start():
        print(f"Blocking on {blockfile}")
        blockfile.touch()
        while blockfile.exists():
            time.sleep(.5)

    def run_server():
        print("Blockfile deleted, starting server ...")
        shared_data["process"] = subprocess.Popen(sys.argv[1:])
        shared_data["process"].wait()
        shared_data["process"] = None

    def signal_handler(sig, frame):
        print(shared_data["process"])
        if not shared_data["process"]:
            sys.exit(0)
        else:
            print("Passing signal to child ...")
            shared_data["process"].send_signal(sig)
            shared_data["stop"] = True

    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)

    # Run until killed
    try:
        while not shared_data["stop"]:
            block_start()
            run_server()
    finally:
        os.unlink(pidfile)

if __name__ == '__main__':
    main()
