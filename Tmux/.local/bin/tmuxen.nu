#!/usr/bin/env nu

def main [] {
    let cmd = (which tmux | get 0.path)
    let session = (hostname -s | str trim)

    let exists = (do {
        ^$cmd has -t $session
    } | complete)

    if $exists.exit_code != 0 {
        ^$cmd new -d -n zsh -s $session zsh
    }

    ^$cmd att -t $session
}
