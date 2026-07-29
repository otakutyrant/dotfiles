# XDG
# Autoloaded modules depend on these values, so they must be set before config.nu.
# https://wiki.archlinux.org/title/XDG_Base_Directory
$env.XDG_CONFIG_HOME = ($env.HOME | path join .config)
$env.XDG_CACHE_HOME = ($env.HOME | path join .cache)
$env.XDG_DATA_HOME = ($env.HOME | path join .local share)
$env.XDG_STATE_HOME = ($env.HOME | path join .local state)
# XDG_BIN_DIR is not standardized formally yet.
$env.XDG_BIN_DIR = ($env.HOME | path join .local bin)
use std/util "path add"
# Convert PATH from a separated string to rows, and keep generated additions available to login/session env.
$env.PATH = ($env.PATH | split row (char esep) | uniq)
path add "~/.nix-profile/bin"
path add $env.XDG_BIN_DIR
# Shell/session variables
$env.SHELL = (which nu | first | get path)
$env.PAGER = if (which page | is-empty) { "less" } else { "page" }
$env.EDITOR = "nvim"
$env.VISUAL = "nvim"
# Prisma's downloaded schema engine is not reliable on NixOS.
let schema_engine = (which schema-engine | get path)
if (($schema_engine | length) > 0) {
    $env.PRISMA_SCHEMA_ENGINE_BINARY = ($schema_engine | first)
}
# Export some environment variables about api keys, such as OpenAI.
const api_keys = if ("~/api_keys.nu" | path expand | path exists) { "~/api_keys.nu" } else { null }
source-env $api_keys
