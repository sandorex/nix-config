#!/usr/bin/env bash
# simple task plugin
#
# requires rofi

set -eo pipefail

TASK_FILE="$HOME/.taskfile"

# ensure everything exists
touch "$TASK_FILE"

case "$1" in
    reset)
        echo "" > "$TASK_FILE"
        ;;
    set)
        shift
        task="$*"
        if [[ -z "$task" ]]; then
            task="$(rofi -dmenu -p "Task")"
        fi

        if [[ -n "$task" ]]; then
            echo -n "$task" > "$TASK_FILE"
        fi
        ;;
    get)
        current="$(cat "$TASK_FILE")"
        if [[ -z "$current" ]]; then
            echo -n "{\"text\": \"\", \"alt\": \"inactive\", \"class\": \"inactive\"}"
            exit 0
        fi

        echo -n "{\"text\": \"$current\", \"alt\": \"active\", \"class\": \"active\"}"
        ;;
    *)
        echo "Unknown command '$1'"
        exit 1
        ;;
esac
