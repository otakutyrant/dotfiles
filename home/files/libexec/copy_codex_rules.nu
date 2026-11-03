# Install regular rule files because Codex skips symlinks, preserving prior copies.
def main [rules_dir: path, tools_source: path, safety_source: path] {
    mkdir $rules_dir
    for rule in [
        {name: tools, source: $tools_source}
        {name: safety, source: $safety_source}
    ] {
        let target = $rules_dir | path join $"($rule.name).rules"
        if ($target | path type) == file {
            if (open --raw $target) == (open --raw $rule.source) {
                continue
            }
        }
        if ($target | path exists --no-symlink) {
            let backup_dir = mktemp --directory --tmpdir-path $rules_dir backup.XXXXXXXX
            let backup = $backup_dir | path join $"($rule.name).rules"
            mv --no-clobber $target $backup
            print $"Preserved previous Codex rules at ($backup)"
        }
        cp --no-clobber $rule.source $target
    }
}
