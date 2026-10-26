# Nushell is case-insensitive in environment variables, and if I set http_proxy
# and https_proxy, Nushell will discard HTTP_PROXY and HTTPS_PROXY.
def --env envproxy [] {
    $env.http_proxy = "http://127.0.0.1:7890"
    $env.https_proxy = "http://127.0.0.1:7890"
    "http proxy on"
}

def --env noproxy [] {
    hide-env HTTP_PROXY
    hide-env HTTPS_PROXY
    "http proxy off"
}
