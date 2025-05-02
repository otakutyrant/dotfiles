# Nushell is case-insensitive in environment variables, and if I set http_proxy and
# https_proxy, Nushell will discard HTTP_PROXY and HTTPS_PROXY.
$env.http_proxy = "http://127.0.0.1:2340"
$env.https_proxy = "http://127.0.0.1:2340"

def --env envproxy [] {
  $env.HTTP_PROXY = "http://127.0.0.1:2340"
  $env.HTTPS_PROXY = "http://127.0.0.1:2340"
  "http proxy on"
}

def --env noproxy [] {
  hide-env HTTP_PROXY
  hide-env HTTPS_PROXY
  "http proxy off"
}
