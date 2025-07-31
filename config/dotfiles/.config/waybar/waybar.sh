#!/usr/bin/env bash
# script to run waybar properly
#
# this allows all paths inside the config to be relative

set -eo pipefail

# cd in script directory
cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1

prefix=""
if [[ "$#" -ge 1 ]]; then
    prefix="${1}-"
elif [[ -n "$XDG_CURRENT_DESKTOP" ]]; then
    prefix="${XDG_CURRENT_DESKTOP,,}-"
fi

exec waybar -c ${prefix}config.jsonc
