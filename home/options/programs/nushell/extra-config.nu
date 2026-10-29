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

# Highlight zero Git counts in white and non-zero counts by their meaning.
def highlight-count [value: int, color: string] {
    if $value == 0 {
        $"(ansi white)(ansi bo)0(ansi reset)"
    } else {
        $"(ansi $color)(ansi bo)($value)(ansi reset)"
    }
}

# Highlight a clean repository path in white and a dirty one in red.
def highlight-path [path: string, clean: bool] {
    let color = if $clean { "white" } else { "red" }
    $"(ansi $color)(ansi bo)($path)(ansi reset)"
}

# Show Git status for direct child directories that are repository roots.
def git-status-subdirs [] {
    let current = (pwd)

    ls
    | where type == dir
    | each {|entry|
        let path = $current | path join $entry.name
        let root = (^git --no-optional-locks -C $path rev-parse --show-toplevel | complete)
        if $root.exit_code != 0 or ($root.stdout | str trim) != $path {
            return null
        }

        let result = (^git --no-optional-locks -C $path status --porcelain=v1 --branch --ahead-behind --untracked-files=normal | complete)
        if $result.exit_code != 0 {
            return null
        }

        let lines = $result.stdout | lines
        let header = $lines | where {|line| $line | str starts-with "##" } | first | default "## HEAD"
        let branch = $header | str replace --regex '^## ' '' | str replace --regex '\.\.\..*$' ''
        let ahead = (if ($header | str contains "ahead ") {
            $header | split row "ahead " | get 1 | split row "]" | first | into int
        } else { 0 })
        let behind = (if ($header | str contains "behind ") {
            $header | split row "behind " | get 1 | split row "]" | first | into int
        } else { 0 })
        let changes = $lines | where {|line| not ($line | str starts-with "##") }
        let staged = $changes | where {|line| ($line | str substring 0..0) != " " } | length
        let unstaged = $changes | where {|line| ($line | str substring 1..1) != " " } | length
        let untracked = $changes | where {|line| $line | str starts-with "??" } | length
        let clean = $ahead == 0 and $behind == 0 and $staged == 0 and $unstaged == 0 and $untracked == 0

        {
            path: (highlight-path $entry.name $clean),
            branch: $branch,
            ahead: (highlight-count $ahead cyan),
            behind: (highlight-count $behind red),
            staged: (highlight-count $staged blue),
            unstaged: (highlight-count $unstaged yellow),
            untracked: (highlight-count $untracked red),
        }
    }
    | compact
    | sort-by path
}
