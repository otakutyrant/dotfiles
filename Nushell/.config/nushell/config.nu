# version = 0.104.0

# Disable welcome banner at startup.
$env.config.show_banner = false
# Choose nvim as the default editor for editing the config
$env.config.buffer_editor = "nvim"

# A simple command just to show directory contents, like traditional shells.
def l [] { ls | sort-by type name -i | grid -c | str trim }

# Show directory contents fully, alias `ls -al`.
alias ll = ls -al

# Search and replace.
def replace [from: string, to: string] {
    rg -l --color=never $from | lines | each { |f| sd $from $to $f }
    null
}

# convert PATH from separated-by-char string to rows,
# and use uniq to avoid duplicate elements
$env.PATH = ( $env.PATH | split row (char esep) | uniq )

# ArchWiki: Environment Viriables
# https://wiki.archlinux.org/index.php/Environment_variables#Examples
# Note that some variables may be full pathnames.
# https://github.com/mobile-shell/mosh/issues/722#issuecomment-176266421
$env.SHELL = "/usr/bin/nu"
$env.PAGER = "page"
$env.EDITOR = "nvim"
$env.VISUAL = "nvim"

# Export some environment variables about api keys, such as OpenAI.
source ~/api_keys.nu

# XDG
# Do not encapsulate this section as a plugin because other plugins require these environment variables resolved at first. It can't be helped.
use std/util "path add"

# https://wiki.archlinux.org/title/XDG_Base_Directory
$env.XDG_CONFIG_HOME = ( $env.HOME | path join .config )
$env.XDG_CACHE_HOME = ( $env.HOME | path join .cache )
$env.XDG_DATA_HOME = ( $env.HOME | path join .local share )
$env.XDG_STATE_HOME = ( $env.HOME | path join .local state )
# XDG_BIN_DIR is not standardized formally yet.
$env.XDG_BIN_DIR = ( $env.HOME | path join .local bin )

path add $env.XDG_BIN_DIR
