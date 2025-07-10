#!/usr/bin/env bash
# simple-ish script that replaces placeholder path in rules and feeds them into
# systemd-tmpfiles to setup links/copies/permissions for dotfiles

set -eo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1

DOTFILES="$PWD/dotfiles"
CONFIGS_PATH="$PWD/rules"

if ! command -v systemd-tmpfiles &>/dev/null; then
    echo "systemd-tmpfiles is required for this script to function!"
    exit 1
fi

if [[ -z "$*" ]]; then
    cat <<EOF
Usage: $0 <modules..>

Available modules:
EOF
    for module in "$CONFIGS_PATH"/*.conf; do
        module="${module%%.conf}"
        echo "  $(basename "$module")"
    done
    echo

    exit 0
fi

# check each module exists before actually running it
modules=()
for path in "$@"; do
    if [[ ! -f "$CONFIGS_PATH/$path.conf" ]]; then
        modules+=( "$path" )
    fi
done

# print invalid modules
if [[ "${#modules[@]}" -ne 0 ]]; then
    echo "Invalid modules:"
    for module in "${modules[@]}"; do
        echo "  $module"
    done
    exit 1
fi

# add .conf suffix
modules=()
for module in "$@"; do
    modules+=( "$CONFIGS_PATH/$module.conf" )
done

# makes systemd-tmpfiles give more information what is happening
# export SYSTEMD_LOG_LEVEL=debug

# dry run by default
arg=""
if [[ -z "$DRY_RUN" || "$DRY_RUN" -ne 0 ]]; then
    echo "Dry run enabled, disable with DRY_RUN=0"
    arg="--dry-run"
fi

# replace the placeholder with real path and pipe into systemd-tmpfiles
sed -e "s%@dotfiles@%$DOTFILES%g" "${modules[@]}" | systemd-tmpfiles $arg --user --create -
