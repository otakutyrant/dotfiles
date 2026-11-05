#!/usr/bin/env nu

# Run NVIDIA Settings with an explicit XDG configuration path because the
# application otherwise hardcodes ~/.nvidia-settings-rc.
# Use the system executable to stay paired with the active NVIDIA driver.
def --wrapped main [...args: string] {
    let config_home = $env.XDG_CONFIG_HOME? | default "@configHome@"
    let config_file = $config_home | path join "nvidia/settings-rc"
    mkdir ($config_file | path dirname)
    ^/run/current-system/sw/bin/nvidia-settings $"--config=($config_file)" ...$args
}
