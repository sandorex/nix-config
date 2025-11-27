#!/usr/bin/env bash
# this script makes waybar config a lot more portable
#   1. all paths inside the config can use relative paths, so be more portable
#   2. you can run any config by just adding config argument instead of
#      hardcoding it

set -eo pipefail

# cd in script directory
cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1

file="${1}-config.jsonc"

if [[ ! -f "$file" ]]; then
    echo "Could not find waybar config '$1' ($file)"
    exit 1
fi

exec waybar -c "$file"
