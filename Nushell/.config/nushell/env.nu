use std/util "path add"
# Convert PATH from a separated string to rows and remove duplicate entries.
$env.PATH = ($env.PATH | split row (char esep) | uniq)
$env.SHELL = (which nu | first | get path)
# Prisma's downloaded schema engine is not reliable on NixOS.
let schema_engine = (which schema-engine | get path)
if (($schema_engine | length) > 0) {
    $env.PRISMA_SCHEMA_ENGINE_BINARY = ($schema_engine | first)
}
# Export some environment variables about api keys, such as OpenAI.
const api_keys = if ("~/api_keys.nu" | path expand | path exists) { "~/api_keys.nu" } else { null }
source-env $api_keys
