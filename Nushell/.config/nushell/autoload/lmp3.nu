# Iterate the current directory and output every mp3 file name and the corresponding time length.
def lmp3 [filename: string] {
    # Use ffprobe to extract the duration in seconds
    let duration = (
        ffprobe $"($filename)"
            -v error
            -show_entries format=duration
            -of default=noprint_wrappers=1:nokey=1
            | str trim
            | into int
            | into duration --unit sec
    )

    # Now count chars within the corresponding srt file
    let srt_filename = $filename | str replace "mp3" "srt"
    let content = open $srt_filename
    # Extract content lines, removing timestamps, indexes, and empty lines
    let lines = $content
        | lines
        | each { |line| $line | str trim } # Improved filter: trim lines first, then check conditions
        | where { |line|
            not ($line =~ '^\d+$'
            or $line =~ '^\d\d:\d\d:\d\d,\d{3} --> '
            or $line == '')
        } # Check for empty string after trim
    # Count grapheme-based character count per line
    let count = $lines
        | reduce -f 0 { |line, acc| $acc + ($line | str length -g) }

    # Calculate cps
    let seconds = ($duration | into int) // 1_000_000_000
    let cps = $count / $seconds

    # Finally, return a record with filename and duration
    {
        name: $filename
        duration: $duration
        chars: $count
        cps: $cps
    }
}

# Define a custom command `llmp3` to list all .mp3 files in the current directory
# along with their audio duration in a human-readable format (e.g., 1h 2m 3s).
# At the end, it prints the average duration of all files.
# Also, it counts chars.
def llmp3 [directory: path = "."] {
    if not ($directory | path exists) or (($directory | path type) != "dir") {
        error make {msg: $"{$directory} is not a directory"}
    }

    # List all .mp3 files and convert each to a record with name and readable duration
    let file_list = (
        ls ($"($directory)/*.mp3" | into glob)
            | where type == 'file'
            | each { |it| lmp3 $it.name }
    )

    # Compute total duration in seconds
    let total_durations = $file_list | get duration | math sum
    # Compute average duration in seconds
    let average_duration = $file_list | get duration | math avg
        | format duration sec | split row " " | get 0 | into int | into string
        | append "sec" | str join | into duration
    # Compute total chars
    let total_chars = $file_list | get chars | math sum
    # Compute average chars
    let average_chars = $file_list | get chars | math avg | into int
    # Compute average cps
    let total_seconds = ($total_durations | into int) // 1_000_000_000
    let avarage_cps = $total_chars / $total_seconds

    # Output the files along with the total and average in duration and chars
    $file_list
        | append {
            name: "TOTAL", duration: $total_durations, chars: $total_chars
        }
        | append {
            name: "AVERAGE", duration: $average_duration chars: $average_chars
            cps: $avarage_cps
        }
}
