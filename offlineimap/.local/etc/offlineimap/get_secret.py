#!/usr/bin/env python

import os.path
import subprocess


def get_secret(account, item):
    f = os.path.expandvars("${XDG_CONFIG_HOME}/offlineimap/secrets.gpg")
    try:
        args = ["gpg", "--batch", "--quiet", "--decrypt", f]
        stdout = subprocess.check_output(args)
    except subprocess.CalledProcessError:
        exit("Could not decrypt password file")

    # Secrets are stored one per line as account:item:secret
    secrets = [x.split(":") for x in stdout.splitlines()]
    try:
        secret = [x for x in secrets if x[0] == account and x[1] == item][0][2]
    except IndexError:
        exit("Could not find item")

    return secret
