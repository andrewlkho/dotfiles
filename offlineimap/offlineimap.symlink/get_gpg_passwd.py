#!/usr/bin/env python

import os.path
import subprocess

def get_gpg_passwd(account):
    f = os.path.expanduser("~/.secret/%s.gpg" % account)
    args = ["gpg", "--quiet", "--decrypt", f]
    try:
        return subprocess.check_output(args).strip()
    except subprocess.CalledProcessError:
        exit("Could not get password")
