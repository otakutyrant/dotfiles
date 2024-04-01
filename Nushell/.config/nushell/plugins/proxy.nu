def --env envproxy [] {
  $env.http_proxy = "http://127.0.0.1:2340"
  $env.https_proxy = "http://127.0.0.1:2340"
  $env.HTTP_PROXY = "http://127.0.0.1:2340"
  $env.HTTPS_PROXY = "http://127.0.0.1:2340"
  "http proxy on"
}

def --env noproxy [] {
  hide-env http_proxy
  hide-env https_proxy
  hide-env HTTP_PROXY
  hide-env HTTPS_PROXY
  "http proxy off"
}
