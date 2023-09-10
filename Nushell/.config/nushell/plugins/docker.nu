# Make Docker cli ignores the environment variable http_proxy
# https://github.com/docker/docker/issues/10224
$env.no_proxy = /var/run/docker.sock
