#!/bin/sh

TMPPATH="$(
    find "${XDG_CACHE_HOME}/mutt/notmuch-results" -type l -exec sh -c '
            cmp --silent "${XDG_CACHE_HOME}/mutt/recon-msg" "$(readlink {})"
        ' \; -print -quit
    )"
MSGPATH="$(readlink "${TMPPATH}")"

ACCOUNT="$(echo "${MSGPATH}" | cut -d '/' -f 5)"
FOLDER="+$(echo "${MSGPATH}" | cut -d '/' -f 6)"
MESSAGE_ID="$(python3 - <<EOF
import email.parser

with open("${XDG_CACHE_HOME}/mutt/recon-msg", "r") as f:
    message = email.parser.HeaderParser().parse(f)
    print(message["Message-Id"].strip().strip("<>"))
EOF
)"

echo "source ${XDG_CONFIG_HOME}/mutt/account.${ACCOUNT}" > "${XDG_CACHE_HOME}/mutt/recon-msg-details" 
echo "push <change-folder>'${FOLDER}'<enter>" >> "${XDG_CACHE_HOME}/mutt/recon-msg-details"
echo "push \"<search>=i '${MESSAGE_ID}'<enter>\"" >> "${XDG_CACHE_HOME}/mutt/recon-msg-details"
