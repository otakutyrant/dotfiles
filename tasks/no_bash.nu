#!/usr/bin/env nu

# Report a fatal scanner failure at the source argument that caused it.
def fail [message: string, context: string]: nothing -> error {
    error make {
        msg: $message
        label: {
            text: "while checking this source"
            span: (metadata $context).span
        }
    }
}

# Read source as bytes so binary files can be skipped without executing them.
# Keep the contextual read-error boundary; this try/catch is not a single call.
# nu-lint-ignore: single_call_command
def read-source [file: path]: nothing -> binary {
    try {
        open --raw $file | into binary
    } catch {|failure|
        fail $"Cannot read source file ($file): ($failure.msg)" $file
    }
}

# Inspect only the first line, preserving binary bodies after a valid shebang.
def has-shell-shebang [source: binary]: nothing -> bool {
    let prefix = $source | bytes at ..4095
    if not ($prefix | bytes starts-with 0x[2321]) { return false }
    let newline = $prefix | bytes index-of 0x[0a]
    let header = (if $newline >= 0 {
        $prefix | bytes at ..<$newline
    } else {
        $prefix
    } | decode utf-8 | str trim)

    let direct = '^#!\s*(?:\S*/)?(?:ba)?sh(?:\s|$)'
    let via_env = '^#!\s*(?:\S*/)?env\s+(?:(?:-S|--split-string|-i|--ignore-environment|--|[A-Za-z_]\w*=\S+)\s+)*(?:--split-string=)?[\x22\x27]?(?:\S*/)?(?:ba)?sh(?:[\s\x22\x27]|$)'
    $header =~ $direct or $header =~ $via_env
}

# Resolve workflow, runner, job, and step defaults without hiding YAML errors.
def workflow-violations [name: string, text: string]: nothing -> list<record> {
    let workflow = try {
        $text | from yaml
    } catch {|failure|
        fail $"Cannot parse workflow ($name): ($failure.msg)" $name
    }
    let workflow_shell = $workflow.defaults?.run?.shell?
    mut found = []
    for job in ($workflow.jobs | values) {
        let runner = $job.runs-on? | default ubuntu-latest | to json --raw
        let runner_shell = if $runner =~ windows- { "pwsh" } else { "bash" }
        let job_shell = $job.defaults?.run?.shell? | default ($workflow_shell | default $runner_shell)
        for step in ($job.steps? | default []) {
            if $step.run? == null { continue }
            let shell = $step.shell? | default $job_shell
            if $shell !~ '^(?:\S*/)?(?:ba)?sh(?:\s|$)' { continue }
            $found ++= [
                {
                    line: 1
                    reason: "GitHub Actions run step uses sh/Bash (including implicit defaults)"
                }
            ]
        }
    }
    $found
}

# Recognize command positions and shell APIs, leaving ordinary prose as data.
def line-reason [extension: string, code: string]: nothing -> string {
    let invocation = '(?:^|[;&|`]|\$\(|\^|\b(?:env|exec|command|sudo)\s+)(?:[\x22\x27])?(?:[^\s\x22\x27;|()`]*/)?(?:ba)?sh(?:[\x22\x27]|\s|$)'
    let quoted_executable = '\b(?:spawn(?:Sync)?|execFile(?:Sync)?|execvp|Command::new|subprocess\.(?:run|call|Popen|check_call|check_output))\s*\(\s*\[?\s*[\x22\x27](?:[^\s\x22\x27]*/)?(?:ba)?sh[\x22\x27]'
    let shell_option = '(?i)\bshell\s*[:=]\s*(?:true|[\x22\x27](?:[^\x22\x27]*/)?(?:ba)?sh[\x22\x27])'
    let nix_hook = '\b(?:shellHook|preShellHook|postShellHook|preBuild|postBuild|preInstall|postInstall|preCheck|postCheck|preInstallCheck|postInstallCheck|buildPhase|installPhase|checkPhase|installCheckPhase|configurePhase|unpackPhase|patchPhase|fixupPhase)\s*=\s*(?:[\x22]|\x27\x27)'
    let nix_builder = '\b(?:writeShellScript(?:Bin)?|writeShellApplication|runCommand(?:Local)?|runCommandNoCC|entryBefore|entryAfter|entryBetween|entryAnywhere)\b'
    let python_shell_api = '\bos\.(?:system|popen)\s*\(\s*[\x22\x27]'
    let js_shell_api = '\b(?:child_process\.)?exec(?:Sync)?\s*\(\s*[\x22\x27`]'
    let implicit_shell = ($extension == py and $code =~ $python_shell_api) or ($extension in [
        js
        cjs
        mjs
        jsx
        ts
        cts
        mts
        tsx
    ] and $code =~ $js_shell_api)
    if $code =~ $invocation or $code =~ $quoted_executable or $code =~ $shell_option or $implicit_shell {
        "explicit sh/Bash invocation or implicit shell execution"
    } else if $extension == nix and ($code =~ $nix_hook or $code =~ $nix_builder) {
        "Nix shell hook, phase, or shell-script builder"
    } else { "" }
}

# A justified marker exempts exactly the following line, never the whole file.
def line-violations [extension: string, text: string]: nothing -> list<record> {
    let source_lines = $text | lines
    mut found = []
    for line in ($source_lines | enumerate) {
        let code = $line.item | str trim
        if $code =~ '^(?:#|//|/\*|\*)' { continue }
        if $line.index > 0 and ($source_lines | get --optional ($line.index - 1)) =~ '^\s*(?:#|//) no-bash-allow: \S.*$' {
            continue
        }
        let reason = line-reason $extension $code
        if $reason != "" {
            $found ++= [
                {
                    line: ($line.index + 1)
                    reason: $reason
                }
            ]
        }
    }
    $found
}

# Scan executable configuration only; binary, prose, and lockfile bodies are data.
def embedded-violations [name: string, source: binary]: nothing -> list<record> {
    let extension = $name | path parse | get extension
    let extensions = [
        nu
        py
        js
        cjs
        mjs
        jsx
        ts
        cts
        mts
        tsx
        nix
        json
        yaml
        yml
        toml
        rs
        go
        c
        cpp
        h
    ]
    if $extension not-in $extensions and ($name | path basename) not-in [nurfile Dockerfile Makefile] {
        return []
    }
    if ($source | bytes index-of 0x[00]) >= 0 { return [] }
    let text = try {
        $source | decode utf-8
    } catch {
        return []
    }
    let workflow = if $name =~ '^\.github/workflows/.*\.ya?ml$' {
        workflow-violations $name $text
    } else { [] }
    $workflow ++ (line-violations $extension $text)
}

# Include tracked and unignored source paths, preserving spaces and newlines.
def source-inventory [root: path]: nothing -> record {
    let resolved = git -C $root rev-parse --show-toplevel | complete
    if $resolved.exit_code != 0 {
        fail $"Cannot locate Git worktree: ($resolved.stderr | str trim)" $root
    }
    let worktree = $resolved.stdout | str trim
    let listing = git -C $worktree ls-files -z --cached --others --exclude-standard | complete
    if $listing.exit_code != 0 {
        fail $"Cannot list source files: ($listing.stderr | str trim)" $root
    }
    {
        worktree: $worktree
        files: (
            $listing.stdout
            | split row (char nul)
            | where $it != ""
            | sort
            | uniq
        )
    }
}

# Never follow symlinks or execute a discovered script.
def file-violations [worktree: path, name: path]: nothing -> list<record> {
    let file = $worktree | path join $name
    if not ($file | path exists --no-symlink) { return [] }
    if ($file | path type) == dir { return [] }
    if ($file | path type) != file { return [] }
    let source = read-source $file
    if $name =~ '\.(?:bash|sh)$' or (has-shell-shebang $source) {
        # Only a leading, justified script marker exempts a required shell
        # interface. Embedded calls in other files need their own line marker.
        let header = ($source | bytes at ..4095 | decode utf-8 | lines | first 3)
        if ($header | any {|line| $line =~ '^# no-bash-script-allow: \S.*$' }) {
            return (embedded-violations $name $source)
        }
        return [
            {line: 1, reason: "sh/Bash script filename or shebang"}
        ]
    }
    embedded-violations $name $source
}

# Reject recognizable shell execution while treating source files only as data.
def main [
    root: path = "." # Git worktree to inspect.
]: nothing -> nothing {
    let inventory = source-inventory $root
    mut violations = 0
    for name in $inventory.files {
        for finding in (file-violations $inventory.worktree $name) {
            print --stderr $"($name | to json --raw):($finding.line): no-bash: ($finding.reason); use Nushell. Review and apply the project-agents-md skill."
            $violations += 1
        }
    }
    if $violations > 0 { fail $"Found ($violations) sh/Bash violations." $root }
}
