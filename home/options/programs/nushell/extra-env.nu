# Home Manager's `home.sessionPath` is written for login-session setup, but
# Nushell starts from its own generated environment. Keep these user paths in
# Nushell too so wrappers in ~/.local/bin can override Nix profile binaries.
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
