# version = 0.83.1

$env.config = {
    # Disable welcome banner at startup.
    show_banner: false
}

# Arch Linux aliases for package managements.

alias pacupg = pacman -Syu
alias pacin = pacman -S
alias pacins = pacman -U
alias pace = pacman -R'
alias pacsyy = pacman -Syy

alias aurupg = pikaur -Syu
alias aurin = pikaur -S
alias aurins = pikaur -U
alias aure = pikaur -R'
alias aursyy = pikaur -Syy

# Systemd aliases.
def sysctl_actions [] { ["status", "start", "stop", "enable", "disable"] }
export extern systemctl [
    action: string@"sysctl_actions"
    service: string
]
alias sc = systemctl

# A simple command just to show directory contents, like traditional shells.
def l [] { ls | sort-by type name -i | grid -c | str trim }

# Show directory contents fully, alias `ls -al`.
alias ll = ls -al

# stow:
# --no-folding: When the directory doesn't exist, create it rather than symlink it,
# in order to avoid other irrelevant files, generated by the software,
# appear in dotfiles directory thereafter.
# --target=$HOME: Install dotfiles in $HOME.
alias stow = stow --no-folding --target $env.HOME
# stow with -D: Uninstall dotfiles.
alias unstow = stow -D --target $env.HOME

# ripgrep: Pretty output so it can pipe into pagers.
alias rg = rg -p

# yt-dlp: Solve China network issue via proxy, and download Chinese subtitles
# automatically.
alias yt-dlp = yt-dlp --proxy 127.0.0.1:2340 --write-subs --sub-langs zh-CN

# Neovim, tmp.
alias vi = nvim

# Setup zoxide on config.nu.
# TODO: a bug
# source $"($env.XDG_CONFIG_HOME)/nushell/zoxide.nu"