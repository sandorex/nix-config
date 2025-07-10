#!/usr/bin/env bash
# generates systemd-tmpfiles config

set -eo pipefail

placeholder='@dotfiles@'

link="${1:?Invalid arguments}"
target="$2"

if [[ -n "$target" ]]; then
    echo "L\$ %h/$1 - - - - ${placeholder}/$2"
else
    echo "L\$ %h/$1 - - - - ${placeholder}/$1"
fi
