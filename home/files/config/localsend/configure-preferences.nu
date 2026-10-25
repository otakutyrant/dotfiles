# Preserve LocalSend's mutable preferences while enforcing the settings owned
# by Home Manager each time the user service starts.
def main [preferences_file: path] {
    mkdir ($preferences_file | path dirname)

    let preferences = if ($preferences_file | path exists) {
        open $preferences_file
    } else {
        {}
    }

    $preferences
    | upsert "flutter.ls_minimize_to_tray" true
    | save --force $preferences_file
}
