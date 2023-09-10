# version = 0.83.1

$env.config = {
    # Disable welcome banner at startup.
    show_banner: false
}

# A simple command just to show directory contents, like traditional shells.
def l [] { ls | sort-by type name -i | grid -c | str trim }

# Show directory contents fully, alias `ls -al`.
alias ll = ls -al

source prompt.nu

source xdg.nu

source archlinux.nu
source cargo.nu
source docker.nu
source git.nu
source ipython.nu
source nvim.nu
source proxy.nu
source ripgrep.nu
source sdl.nu
source ssh.nu
source stow.nu
source systemd.nu
source yt-dlp.nu
source zoxide.nu

hide-env nu-plugins-dir
