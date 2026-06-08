#!/usr/bin/env bash

set -euo pipefail

FLAG_FILE=/tmp/.i3status-tittle-toggle

on() {
    swaymsg '[workspace=".*"] border normal, default_border normal'
    touch "$FLAG_FILE"
}

off() {
    swaymsg '[workspace=".*"] border pixel, default_border pixel'
    rm -f "$FLAG_FILE"
}

case "${1:?}" in
    "status")
        [[ -f "$FLAG_FILE" ]] && echo "on"
        ;;
    "on")
        on
        ;;
    "off")
        off
        ;;
    "toggle")
        if [[ -f "$FLAG_FILE" ]]; then
            off
        else
            on
        fi
        ;;
esac
