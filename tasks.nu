def checked-files [extension: string] {
    ^git ls-files --cached --others --exclude-standard
    | lines
    | where { |path| ($path | str ends-with $extension) and ($path | path exists) }
    | sort
    | uniq
}

def nix-files [] {
    checked-files ".nix"
    | where { |path| $path != "nixos/hardware-configuration.nix" }
}

def lua-files [] {
    checked-files ".lua"
}

def nu-files [] {
    checked-files ".nu"
}

def architecture-violations [files: list<record>] {
    $files
    | each { |file|
        if ($file.path | str starts-with "home/") and ($file.content | str contains "../nixos") {
            { path: $file.path, forbidden: "nixos/" }
        } else if ($file.path | str starts-with "nixos/") and ($file.content | str contains "../home") {
            { path: $file.path, forbidden: "home/" }
        } else if ($file.path | str starts-with "lib/") and (($file.content | str contains "../home") or ($file.content | str contains "../nixos")) {
            { path: $file.path, forbidden: "configuration tree" }
        }
    }
    | compact
}

def assert-no-architecture-violations [files: list<record>] {
    let violations = (architecture-violations $files)
    if ($violations | is-not-empty) {
        let details = ($violations | each { |item| $"($item.path) imports forbidden ($item.forbidden)" } | str join "; ")
        error make { msg: $"Architecture boundary violation: ($details)" }
    }
}

def ensure-success [result: record, operation: string] {
    if $result.exit_code != 0 {
        let message = ($result.stderr | str trim)
        error make { msg: $"($operation) failed: ($message)" }
    }
}

# Format checked-in Nix files, excluding the generated hardware configuration.
export def "nur format-nix" [] {
    let files = (nix-files)
    if ($files | is-not-empty) {
        ^nixfmt ...$files
    }
}

# Format checked-in Lua files.
export def "nur format-lua" [] {
    let files = (lua-files)
    if ($files | is-not-empty) {
        ^stylua ...$files
    }
}

# Format every source language with an approved safe formatter.
export def "nur format" [] {
    nur format-nix
    nur format-lua
}

# Check Nix formatting, suspicious constructs, and unused bindings.
export def "nur lint-nix" [] {
    let files = (nix-files)
    if ($files | is-empty) {
        return
    }

    ^nixfmt --check ...$files
    for file in $files {
        ^statix check $file
        ^deadnix --fail $file
    }
}

# Check Lua formatting and lint diagnostics.
export def "nur lint-lua" [] {
    let files = (lua-files)
    if ($files | is-empty) {
        return
    }

    ^stylua --check ...$files
    ^selene ...$files
}

# Check Nushell idioms and unused code without rewriting source files.
export def "nur lint-nushell" [] {
    # extra-env.nu is a Home Manager replaceVars template and is not valid Nu
    # until Nix substitutes its @sessionPath@ placeholder.
    let files = (nu-files | where { |path| $path != "home/options/programs/nushell/extra-env.nu" })
    if ($files | is-not-empty) {
        ^nu-lint ...$files
    }
}

# Run all source linters without modifying files.
export def "nur lint" [] {
    nur lint-nix
    nur lint-lua
    nur lint-nushell
}

# Evaluate both supported Nix configuration outputs.
export def "nur typecheck-nix" [] {
    # Nix has no separate type checker. Evaluating the derivation paths checks
    # flake evaluation plus the NixOS and Home Manager module types.
    let nixos = (^nix eval --no-update-lock-file --raw ".#nixosConfigurations.nixos.config.system.build.toplevel.drvPath" | complete)
    ensure-success $nixos "NixOS evaluation"

    let home = (^nix eval --no-update-lock-file --raw ".#homeConfigurations.otakutyrant.activationPackage.drvPath" | complete)
    ensure-success $home "Home Manager evaluation"
}

# Run LuaLS diagnostics, failing only on Error-level findings.
export def "nur typecheck-lua" [] {
    ^lua-language-server --check . --checklevel Error --check_format pretty --logpath /tmp/dotfiles-lua-language-server-log
}

# Check every Nushell source and directly source autoload modules.
export def "nur typecheck-nushell" [] {
    let files = (nu-files)
    for file in ($files | where { |path| $path | str contains "/autoload/" }) {
        ^nu -n -c $"source ($file)"
    }

    for file in $files {
        ^nu --ide-check 0 $file | ignore
    }
}

# Run all type-aware and parser diagnostics.
export def "nur typecheck" [] {
    nur typecheck-nix
    nur typecheck-lua
    nur typecheck-nushell
}

# Validate raw data files without imposing new formatting.
export def "nur validate-data" [] {
    let yaml_files = (
        (checked-files ".yaml")
        | append (checked-files ".yml")
        | where { |path| not ($path | str ends-with ".dict.yaml") }
    )
    for file in $yaml_files {
        let result = (^yq eval "." $file | complete)
        ensure-success $result $"YAML validation for ($file)"
    }

    let toml_files = (checked-files ".toml")
    if ($toml_files | is-not-empty) {
        let result = (^taplo lint ...$toml_files | complete)
        ensure-success $result "TOML validation"
    }

    let json_files = (checked-files ".json")
    if ($json_files | is-not-empty) {
        let result = (^jq empty ...$json_files | complete)
        ensure-success $result "JSON validation"
    }

    let desktop_files = (checked-files ".desktop")
    if ($desktop_files | is-not-empty) {
        let result = (^desktop-file-validate ...$desktop_files | complete)
        ensure-success $result "desktop entry validation"
    }
}

# Reject direct dependencies between system, user, and shared Nix layers.
export def "nur architecture" [] {
    let files = (
        checked-files ".nix"
        | where { |path| ($path | str starts-with "home/") or ($path | str starts-with "nixos/") or ($path | str starts-with "lib/") }
        | each { |path| { path: $path, content: (open --raw $path) } }
    )
    assert-no-architecture-violations $files
}

# Exercise representative allowed and forbidden Nix dependency boundaries.
export def "nur test-architecture" [] {
    assert-no-architecture-violations [
        { path: "home/options/example.nix", content: "import ../../../lib/example.nix" }
        { path: "nixos/options/example.nix", content: "import ../../lib/example.nix" }
        { path: "lib/example.nix", content: "{ lib }: lib.id" }
    ]

    let forbidden = (architecture-violations [
        { path: "home/options/example.nix", content: "import ../../../nixos/example.nix" }
        { path: "nixos/options/example.nix", content: "import ../../home/example.nix" }
        { path: "lib/example.nix", content: "import ../home/example.nix" }
    ])
    if ($forbidden | length) != 3 {
        error make { msg: "Architecture fixtures did not reject every forbidden dependency" }
    }
}

# Run all deterministic repository tests.
export def "nur test" [] {
    nur test-architecture
}

# Run repository structure, raw-data, and deterministic fixture checks.
export def "nur verify" [] {
    nur architecture
    nur validate-data
    nur test
}

# Run every deterministic repository quality check in fail-fast order.
export def "nur check" [] {
    nur lint
    nur typecheck
    nur verify
}

# Build the NixOS configuration without activating it.
export def "nur build-nixos" [] {
    ^nh os build ".#nixos" --no-update-lock-file
}

# Build the standalone Home Manager configuration without activating it.
export def "nur build-home" [] {
    ^nh home build . --configuration otakutyrant --no-update-lock-file
}

# Build and activate the NixOS configuration. Run only when explicitly requested.
export def "nur switch-nixos" [] {
    ^nh os switch ".#nixos" --no-update-lock-file
}

# Build and activate Home Manager. Run only when explicitly requested.
export def "nur switch-home" [] {
    ^nh home switch . --configuration otakutyrant --no-update-lock-file
}
