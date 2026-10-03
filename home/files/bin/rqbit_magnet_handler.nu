#!@nu@

def notify [message: string, urgency: string = "normal"] {
    ^@notifySend@ --app-name rqbit --urgency $urgency "rqbit magnet handler" $message
}

def main [magnet: string] {
    notify "Magnet link received; adding it to rqbit."

    let start = (^@systemctl@ --user start rqbit | complete)
    if $start.exit_code != 0 {
        print --stderr ($start.stderr | str trim)
        notify "Could not start the rqbit service." "critical"
        exit $start.exit_code
    }

    let submit = (
        ^@curl@ --fail-with-body --silent --show-error --max-time 180 --data-binary $magnet http://127.0.0.1:3030/torrents
        | complete
    )
    if $submit.exit_code == 0 {
        notify "Torrent added to rqbit."
    } else {
        print --stderr (($submit.stderr + $submit.stdout) | str trim)
        notify "rqbit could not add this magnet link." "critical"
        exit $submit.exit_code
    }
}
