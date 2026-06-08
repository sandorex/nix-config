#!/usr/bin/env bash
# wrapper script to cd into waybar directory so paths can be relative

cd "$(dirname "${BASH_SOURCE[0]}")/waybar" || exit 1
exec waybar -c ./config.jsonc -s ./style.css
