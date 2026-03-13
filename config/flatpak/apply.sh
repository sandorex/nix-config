#!/usr/bin/env bash
# script that links flatpak overrides

set -eo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1

CONFIGS="$PWD"
HOST_CONFIGS="$PWD/$HOSTNAME"
TARGET_DIR=".local/share/flatpak/overrides"

if ! command -v systemd-tmpfiles &>/dev/null; then
    echo "systemd-tmpfiles is required for this script to function!"
    exit 1
fi

# it shouldn't happen but just in case
if [[ "$CONFIGS" == "$HOST_CONFIGS" ]]; then
    echo "error could not read hostname"
    exit 1
fi

if [[ -z "$*" ]]; then
    cat <<EOF
Usage: $0 <flatpak id..>

Available overrides:
EOF
    for module in "$HOST_CONFIGS"/* "$PWD"/*; do
        # skip directories
        if [[ ! -f "$module" ]]; then
            continue
        fi

        # skip the script and readme
        module_name="$(basename "$module")"
        case "$module" in
            # skip non-conf files
            *.sh|*.md)
                continue
                ;;
        esac
        echo "  $module_name"
    done
    echo

    exit 0
fi

# check each module exists before actually running it
missing=()
configs=""
for path in "$@"; do
    # prioritize host configs
    # NOTE wont overwrite files
    if [[ -f "$HOST_CONFIGS/$path" ]]; then
        configs="${configs}L$ %h/$TARGET_DIR/$path - - - - $HOST_CONFIGS/$path\n"
    elif [[ -f "$CONFIGS/$path" ]]; then
        configs="${configs}L$ %h/$TARGET_DIR/$path - - - - $CONFIGS/$path\n"
    else
        missing+=( "$path" )
    fi
done

# print invalid modules
if [[ "${#missing[@]}" -ne 0 ]]; then
    echo "Flatpak override not found for:"
    for module in "${missing[@]}"; do
        echo "  $module"
    done
    exit 1
fi

# makes systemd-tmpfiles give more information what is happening
# export SYSTEMD_LOG_LEVEL=debug

# dry run by default
arg=""
if [[ -z "$DRY_RUN" || "$DRY_RUN" -ne 0 ]]; then
    echo "Dry run enabled, disable with DRY_RUN=0"
    arg="--dry-run"
fi

echo -e "$configs" | systemd-tmpfiles $arg --user --create -
