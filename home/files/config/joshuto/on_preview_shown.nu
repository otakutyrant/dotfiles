#!/usr/bin/env nu
# Use icat to place an image on top of joshuto's preview window.
const GAP = 4
const CACHE_DIR = "/tmp/joshuto-cache"
def cache-file [file_path: string] {
    let file_name = (
        ^printf "%s" $file_path | ^md5sum | split row " " | first
    )
    $CACHE_DIR | path join $"($file_name).jpg"
}
def show-image [
    file_path: string
    preview_x: int
    preview_y: int
    preview_width: int
    preview_height: int
] {
    let place_height = ($preview_height - $GAP)
    let place_y = ($preview_y + $GAP)
    let place = ([
        $preview_width
        "x"
        $place_height
        "@"
        $preview_x
        "x"
        $place_y
    ] | each {|part| $part | into string } | str join)
    do { ^kitty +kitten icat --clear --transfer-mode=memory --place $place $file_path } | complete | ignore
}
def ensure-svg-cache [file_path: string] {
    let cached = (cache-file $file_path)
    if not ($cached | path exists) {
        mkdir $CACHE_DIR
        let result = (do {
            ^convert -- $file_path $cached
        } | complete)
        if $result.exit_code != 0 {
            exit 1
        }
    }
    $cached
}
def ensure-video-cache [file_path: string] {
    let cached = (cache-file $file_path)
    if not ($cached | path exists) {
        mkdir $CACHE_DIR
        let result = (do {
            ^ffmpeg -ss 00:00:30 -i $file_path -vf "scale=960:960:force_original_aspect_ratio=decrease" -vframes 1 $cached
        } | complete)
        if $result.exit_code != 0 {
            exit 1
        }
    }
    $cached
}
def clear-image [] {
    do { ^kitty +kitten icat --clear --transfer-mode=memory } | complete | ignore
}
def main [
    file_path: string
    preview_x: int
    preview_y: int
    preview_width: int
    preview_height: int
] {
    let mime_type = (^file -bL --mime-type $file_path | str trim)
    match $mime_type {
        "image/svg+xml" | "image/svg" => {
            let cached = (ensure-svg-cache $file_path)
            show-image $cached $preview_x $preview_y $preview_width $preview_height
        }
        _ => { show-image $file_path $preview_x $preview_y $preview_width $preview_height }
        _ => {
            let cached = (ensure-video-cache $file_path)
            show-image $cached $preview_x $preview_y $preview_width $preview_height
        }
        _ => { clear-image }
    }
}
