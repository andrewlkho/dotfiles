#!/usr/bin/env bash

# Usage: set message_id_format="message_id_gen.sh $from |"
#
# The purpose of this script is to use the domain name of the e-mail address to
# generate the message-id, rather than the hostname of the computer mutt is
# running on.  The left hand side of the message-id is a combination of a
# timestamp (UTC to milliseconds) combined with a random integer, both
# base36-encoded.  This should be sufficient to effectively guarantee
# uniqueness even across widely-used domains.

base36() {
    local n=$1 chars="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ" r=""
    ((n == 0)) && { echo 0; return; }
    while ((n > 0)); do
        r="${chars:n%36:1}$r"
        ((n /= 36))
    done
    echo "$r"
}

# Get current datetime, cut ensures it fits within integer size limit
date="$(date -u +'%Y%m%d%H%M%S%N' | cut -c 1-17)"

# Get random number and mask off the sign bit to ensure positive
rand="$(( $(od -An -tu8 -N8 /dev/urandom | tr -d ' ') & 0x7FFFFFFFFFFFFFFF ))"

# Extract domain from $1
domain="$(echo "$1" | cut -d @ -f 2)"

# Return message id
echo "<$(base36 $date)-$(base36 $rand)@$domain>"
