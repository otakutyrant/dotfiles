# Desktop login and systemd already receive home.sessionPath. Retain this
# idempotent fallback for Nushell started outside those entry points, without
# making graphical applications depend on an interactive shell running first.
$env.PATH = (@sessionPath@ | append $env.PATH | uniq)

# Prisma's downloaded schema engine is not reliable on NixOS.
let schema_engine = (which schema-engine | get path)
if (($schema_engine | length) > 0) {
    $env.PRISMA_SCHEMA_ENGINE_BINARY = ($schema_engine | first)
}

# Export local private API keys from Nushell's XDG configuration directory when
# the file exists; secrets remain unmanaged by the dotfiles repository.
const api_keys_path = $nu.default-config-dir | path join "api_keys.nu"
const api_keys = if ($api_keys_path | path exists) { $api_keys_path } else { null }
source-env $api_keys

# Home Manager's ssh-agent user service binds to $XDG_RUNTIME_DIR/ssh-agent,
# but only sets SSH_AUTH_SOCK for POSIX shells. Point Nushell at the same socket.
if (($env.SSH_AUTH_SOCK? | default "") | is-empty) {
    $env.SSH_AUTH_SOCK = $"($env.XDG_RUNTIME_DIR)/ssh-agent"
}
