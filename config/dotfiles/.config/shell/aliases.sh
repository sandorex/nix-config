#!/bin/sh
#
# https://github.com/sandorex/config
# contains aliases for bash/zsh shells

# many scripts in /etc/profile.d/ set aliases and they interfere
unalias -a

# make compdef a noop on bash
if [[ -z "$ZSH_VERSION" ]]; then
    compdef() { :; }
fi

# quickly switch to the bg job
alias z=fg
alias 1="%1"
alias 2="%2"
alias 3="%3"
alias 4="%4"
alias 5="%5"

alias v=nvim; compdef v=nvim
alias a=arcam
alias g='git'; compdef g=git
alias f="$FILE_MANAGER"
alias mv='mv -i' # safe mv, ask on overwrite
alias yeet=shred

# intentionally different command so i know if i am trashing or deleting
# NOTE: requires gvfs
alias t='gio trash'
alias trash='gio trash'
alias trash-list='gio trash --list'
alias trash-restore='gio trash --restore'

# use bat if available
if command -v bat &>/dev/null; then
    alias cat='bat --style=plain'
fi

# use lsd if available
if command -v lsd &>/dev/null; then
    function ls() { lsd -Ft "$@"; }
    function lls() { lsd -Ftl "$@"; }
    function l() { lsd -aFt "$@"; }
    function ll() { lsd -alFt "$@"; }
else
    function ls() { command ls -Ft --color=auto "$@"; }
    function lls() { command ls -Ftl --color=auto "$@"; }
    function l() { command ls -aFt --color=auto "$@"; }
    function ll() { command ls -alFht --color=auto "$@"; }
fi

# make dot without arguments list directory, otherwise just pass args through
_dot() {
    if [ "$#" -eq 0 ]; then
        # as im not using an alias above this should use proper arguments with
        # no duplicated code
        ls
    else
        \. "$@"
    fi
}

alias -- '-'='cd -'
alias -- '.'='_dot'
alias -- '..'='cd ..'
alias -- '...'='cd ../..'
alias -- '....'='cd ../../..'

alias diff='diff --report-identical-files --color=auto'
alias grep='grep --color=auto'
alias isodate="date +'%Y%m%dT%H%M'"
alias qr="qrencode -t UTF8"

# call lua interpreter builtin into neovim
nlua() {
    nvim --clean -l "$@"
}

# function aliases
rcp() {
    # -a = -rlptgoD
    #   -r = recursive
    #   -l = copy symlinks as symlinks
    #   -p = preserve permissions
    #   -t = preserve mtimes
    #   -g = preserve owning group
    #   -o = preserve owner
    # -z = use compression
    # -P = show progress on transferred file
    # -J = don't touch mtimes on symlinks (always errors)
    rsync -azPJ \
        --include=.git/ \
        --filter=':- .gitignore' \
        --filter=":- ~/.config/git/ignore" \
        "$@"
}; compdef rcp=rsync

# enter distrobox by default
dbx() {
    if [[ "$#" == 0 ]]; then
        command distrobox enter
    else
        command distrobox "$@"
    fi
}; compdef dbx=distrobox

