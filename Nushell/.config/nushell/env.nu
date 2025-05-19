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
