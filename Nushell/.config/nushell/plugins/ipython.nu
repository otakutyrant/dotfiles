# Enforce IPython to use XDG_CONFIG_HOME rather than ~/.ipython
$env.IPYTHONDIR = ( $env.XDG_CONFIG_HOME | path join ipython )
