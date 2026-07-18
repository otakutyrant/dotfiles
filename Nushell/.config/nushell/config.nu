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
