# Enable path completion.
extern stow [directory: path] {}
# --no-folding: When the directory doesn't exist, create it rather than symlink it,
# in order to avoid other irrelevant files, generated by the software,
# appear in dotfiles directory thereafter.
# --target=$HOME: Install dotfiles in $HOME.
alias stow = stow --no-folding --target $env.HOME
# stow with -D: Uninstall dotfiles.
alias unstow = stow -D --target $env.HOME