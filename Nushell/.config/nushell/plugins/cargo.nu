use std/util "path add"

let CARGO_BIN_DIR = ( $env.XDG_DATA_HOME | path join cargo bin )
path add $CARGO_BIN_DIR
# Enforce cargo to obey XDG.
# Note that the cargo config is in this CARGO_HOME too.
$env.CARGO_HOME = ( $env.XDG_DATA_HOME | path join cargo )
