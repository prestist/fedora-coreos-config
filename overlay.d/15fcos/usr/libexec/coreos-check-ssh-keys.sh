#!/usr/bin/bash
# This script will print a message in the serial console 
# if no ssh keys were added by ignition/afterburn.
main() {
    # Change the output color to yellow
    warn='\033[0;33m'
    # No color
    nc='\033[0m'

    # See https://github.com/coreos/ignition/pull/964 for the MESSAGE_ID 
    # source. It will track the authorized-ssh-keys entries in journald 
    # provided via ignition.
    ignitionusers=$(journalctl -o json-pretty MESSAGE_ID=225067b87bbd4a0cb6ab151f82fa364b | jq -r '.MESSAGE')

    # See https://github.com/coreos/afterburn/pull/397 for the MESSAGE_ID 
    # source. It will track the authorized-ssh-keys entries in journald  
    # provided via afterburn.
    afterburnusers=$(journalctl -o json-pretty MESSAGE_ID=0f7d7a502f2d433caa1323440a6b4190 | jq -r '.MESSAGE')

    output=''
    if [ -n "$ignitionusers" ]; then
        output+="$ignitionusers"
    fi
    if [ -n "$afterburnusers" ]; then
        output+="$afterburnusers"
    fi

    if [ -n "$output" ]; then
        echo "$output" > /run/console-login-helper-messages/issue.d/30_ssh_authorized_keys.issue
    else
        echo -e "${warn}No ssh authorized keys provided by Ignition or Afterburn${nc}" \
             > /run/console-login-helper-messages/issue.d/30_ssh_authorized_keys.issue
    fi
}

main
