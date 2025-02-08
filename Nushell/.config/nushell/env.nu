# PATH
$env.PATH = ( $env.PATH | split row (char esep) )

# ArchWiki: Environment Viriables
# https://wiki.archlinux.org/index.php/Environment_variables#Examples
# Note that some variables may be full pathnames.
# https://github.com/mobile-shell/mosh/issues/722#issuecomment-176266421
$env.SHELL = "/usr/bin/nu"
$env.PAGER = "page"
$env.EDITOR = "nvim"
$env.VISUAL = "nvim"

# Due to Nushell cannot "source" modules dymmatically, I maintain modules 
# in $env.NU_PLUGIN_DIR. To avoid polluting namespaces,
# after sourcing modules, I hide $env.nu-plugins-dir from $env.NU_LIB_DIRS
# in config.nu.
$env.nu-plugins-dir = ( $nu.default-config-dir | path join plugins )
$env.NU_LIB_DIRS = [ $env.nu-plugins-dir ]
