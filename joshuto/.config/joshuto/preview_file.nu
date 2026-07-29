#!/usr/bin/env nu
const HIGHLIGHT_SIZE_MAX = 262143 # 256 KiB.
def print-command-output [result: record] {
    if not ($result.stdout | is-empty) {
        print -n $result.stdout
    }
}
def run-preview [command: closure] {
    let result = (do $command | complete)
    if $result.exit_code == 0 {
        print-command-output $result
        exit 0
    }
    exit 1
}
def handle-extension [file_path: string, extension: string] { match $extension {
    "a" | "ace" | "alz" | "arc" | "arj" | "bz" | "bz2" | "cab" | "cpio" | "deb" | "gz" | "jar" | "lha" | "lz" | "lzh" | "lzma" | "lzo" | "rpm" | "rz" | "t7z" | "tar" | "tbz" | "tbz2" | "tgz" | "tlz" | "txz" | "tz" | "tzo" | "war" | "xpi" | "xz" | "z" | "zip" => {
        run-preview {|| ^bsdtar --list --file $file_path }
    }
    "rar" => {
        run-preview {|| ^unrar lt -p- -- $file_path }
    }
    "7z" => {
        run-preview {|| ^7zz l -p -- $file_path }
    }
    "json" | "ipynb" => {
        run-preview {|| ^jq --color-output . $file_path }
    }
    "pdf" => {
        run-preview {|| ^exiftool $file_path }
    }
    "torrent" => {
        run-preview {|| ^transmission-show -- $file_path }
    }
    _ => { }
} }
def exif-value [file_path: string, tag: string] {
    let result = (do { ^exiftool -s3 $tag -- $file_path } | complete)
    if $result.exit_code == 0 {
        $result.stdout | str trim
    } else {
        ""
    }
}
def handle-media-preview [file_path: string, kind: string] {
    let file_size = (exif-value $file_path "-FileSize")
    let mime_type = (exif-value $file_path "-MIMEType")
    if $kind == "image" {
        let image_size = (exif-value $file_path "-ImageSize")
        print $"File Size  : ($file_size)\nImage Size : ($image_size)\nMIME Type  : ($mime_type)"
        exit 0
    }
    let duration = (exif-value $file_path "-Duration")
    print $"File Size : ($file_size)\nDuration  : ($duration)\nMIME Type : ($mime_type)"
    exit 0
}
def handle-mime [
    file_path: string
    mime_type: string
    preview_width: int
    preview_height: int
] {
    if ($mime_type | str starts-with "text/") or ($mime_type | str ends-with "/xml") {
        let file_size = (ls $file_path | first | get size | into int)
        if $file_size <= $HIGHLIGHT_SIZE_MAX {
            if not (which bat | is-empty) {
                run-preview {|| ^bat --color=always --paging=never --style=plain --terminal-width $preview_width $file_path }
            }
            run-preview {|| ^sed -n $"1,($preview_height)p" $file_path }
        }
        exit 1
    }
    if ($mime_type | str ends-with "/json") {
        run-preview {|| ^jq --color-output . $file_path }
    }
    if ($mime_type | str starts-with "image/") {
        handle-media-preview $file_path image
    }
    if ($mime_type | str starts-with "video/") {
        handle-media-preview $file_path video
    }
    if ($mime_type | str starts-with "audio/") {
        run-preview {|| ^exiftool $file_path }
    }
}
def handle-fallback [file_path: string] {
    let result = (do { ^file -bL -- $file_path } | complete)
    if $result.exit_code == 0 {
        print "----- File Type Classification -----"
        print-command-output $result
        exit 0
    }
    exit 1
}
def main [--path: int = 10, --preview-height: int = 10] {
    if $path == "" {
        exit 1
    }
    let extension = (
        $path | path parse | get extension | str downcase
    )
    handle-extension $path $extension
    let mime_result = (do { ^file -bL --mime-type -- $path } | complete)
    if $mime_result.exit_code == 0 {
        handle-mime $path ($mime_result.stdout | str trim) $preview_width $preview_height
    }
    handle-fallback $path
}
