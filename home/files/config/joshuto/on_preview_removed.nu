#!/usr/bin/env nu
# Clear any existing images on the screen when the preview becomes invalid.
def main [] {
    do { ^kitty +kitten icat --transfer-mode=memory --clear } | complete | ignore
}
