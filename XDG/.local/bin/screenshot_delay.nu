#!/usr/bin/env nu

# Delay before opening niri's Rust-native interactive screenshot UI.
sleep 5sec
^niri msg action screenshot
