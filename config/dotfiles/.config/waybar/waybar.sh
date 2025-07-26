#!/usr/bin/env bash
# script to run waybar properly
#
# this allows all paths inside the config to be relative

set -eo pipefail

# cd in script directory
cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1

prefix=""
if [[ -n "$1" ]]; then
    prefix="${1}-"
fi

exec waybar -c ${prefix}config.jsonc
