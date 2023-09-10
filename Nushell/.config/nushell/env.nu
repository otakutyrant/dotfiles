# XDG
$env.XDG_CONFIG_HOME = ( $env.HOME | path join .config )
$env.XDG_CACHE_HOME = ( $env.HOME | path join .cache )
$env.XDG_DATA_HOME = ( $env.HOME | path join .local share )
$env.XDG_STATE_HOME = ( $env.HOME | path join .local state )
# XDG_BIN_DIR is not standardized formally yet.
$env.XDG_BIN_DIR = ( $env.HOME | path join .local bin )

# PATH
$env.PATH = ( $env.PATH | split row (char esep) )
$env.PATH = ( $env.PATH | prepend $env.XDG_BIN_DIR )
let CARGO_BIN_DIR = ( $env.XDG_DATA_HOME | path join cargo bin )
$env.PATH = ( $env.PATH | prepend $CARGO_BIN_DIR )

# ArchWiki: Environment Viriables
# https://wiki.archlinux.org/index.php/Environment_variables#Examples
# Note that some variables may be full pathnames.
# https://github.com/mobile-shell/mosh/issues/722#issuecomment-176266421
$env.SHELL = /usr/bin/nu
$env.PAGER = page
$env.EDITOR = nvim
$env.VISUAL = nvim

def proxy [] {
  $env.http_proxy = "http://127.0.0.1:2340"
  $env.https_proxy = "http://127.0.0.1:2340"
  $env.HTTP_PROXY = "http://127.0.0.1:2340"
  $env.HTTPS_PROXY = "http://127.0.0.1:2340"
  "http proxy on"
}

def noproxy [] {
  hide-env http_proxy
  hide-env https_proxy
  hide-env HTTP_PROXY
  hide-env HTTPS_PROXY
  "http proxy off"
}

# Make Docker cli ignores the environment variable http_proxy
# https://github.com/docker/docker/issues/10224
$env.no_proxy = /var/run/docker.sock

# Avoid SDL games regarding multiple screens as one big screen.
# https://wiki.archlinux.org/index.php/NVIDIA#Gaming_using_TwinView
$env.SDL_VIDEO_FULLSCREEN_HEAD = 1

$env.CARGO_HOME = ( $env.XDG_DATA_HOME | path join cargo )

$env.NU_LIB_DIRS = [
    ( $nu.default-config-dir | path join "completions" )
]

# Setup zoxide on env.nu.
zoxide init nushell | save -f $"($env.XDG_CONFIG_HOME)/nushell/zoxide.nu"
