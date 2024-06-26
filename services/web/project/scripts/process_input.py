#!/usr/bin/env python3

import subprocess
import shlex
from tempfile import mktemp
import multiprocessing
import argparse
import os
from flask import g

# This is to execute arbitrary command with
# - exeute a thread with the command
# - stream stdout and stderr of the thread to a file
# - return the file name to the user and exit while the thread is still running


def execute_command(command, foutname):
    with open(foutname, 'a+') as fout:
        command_split = shlex.split(command)
        try:
            popen = subprocess.Popen(command_split, stdout=fout, stderr=fout, bufsize=1)
            print(f"#pid [{popen.pid}]", file=fout)  # Print the PID
        except Exception as e:
            print(f"#ERROR_FLAG - {e}", file=fout)
            print(f'#end [{command}] > {foutname}', file=fout)
            return
        popen.wait()
        print(f'#end [{command}] > {foutname}', file=fout)


def get_link_button(fname, text):
    return f'<a href="/stream?q=cat+{fname}" class="btn btn-link" role="button">{text}</a>'


def process_input(command, link=False):
    fout_dir = os.path.join(g.config["STATIC_FOLDER"], 'proc_out')
    if not os.path.exists(fout_dir):
        os.makedirs(fout_dir)
    foutname = mktemp(dir=fout_dir)
    # relhttp = foutname.replace(g.config["STATIC_FOLDER"], 'static')
    with open(foutname, 'w') as fout:
        mtime = os.path.getmtime(foutname)
        if link:
            print(f'#begin [{command}] [{mtime}]', get_link_button(foutname, foutname), file=fout)
        else:
            print(f'#begin [{command}] [{mtime}] > {foutname}', file=fout)
    # execute command in a separate process and quit
    process = multiprocessing.Process(target=execute_command, args=(command, foutname))
    process.start()
    # print(f"#pid pipe [{process.pid}]", file=fout)  # Print the PID - this would write to the file used by pipe...
    return foutname, process.pid


def main():
    argparser = argparse.ArgumentParser(description='Execute command and stream output to file')
    argparser.add_argument('command', nargs=argparse.REMAINDER, help='Command to execute')
    args = argparser.parse_args()
    cmnd = ' '.join(args.command)
    out = process_input(cmnd)
    print(out)


if __name__ == '__main__':
    main()
