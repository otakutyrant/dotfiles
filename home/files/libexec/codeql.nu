#!/usr/bin/env nu

# Put CodeQL's downloaded packs and compiled query plans in XDG cache while
# calling the declared package directly, independent of the active profile.
def --wrapped main [...args: string] {
    let cache_home = $env.XDG_CACHE_HOME? | default "@cacheHome@"
    let common_caches = $cache_home | path join "codeql"
    mkdir $common_caches
    ^"@codeql@" ...$args $"--common-caches=($common_caches)"
}
