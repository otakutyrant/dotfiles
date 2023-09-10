# https://wiki.archlinux.org/title/XDG_Base_Directory
$env.XDG_CONFIG_HOME = ( $env.HOME | path join .config )
$env.XDG_CACHE_HOME = ( $env.HOME | path join .cache )
$env.XDG_DATA_HOME = ( $env.HOME | path join .local share )
$env.XDG_STATE_HOME = ( $env.HOME | path join .local state )
# XDG_BIN_DIR is not standardized formally yet.
$env.XDG_BIN_DIR = ( $env.HOME | path join .local bin )

$env.PATH = ( $env.PATH | prepend $env.XDG_BIN_DIR )
