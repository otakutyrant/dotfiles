{
  pkgs,
  ...
}:

# Command-line tools for inspecting, converting, and controlling media.
with pkgs;
[
  (callPackage ../pkgs/imageflow.nix { }) # Image tool, an alternative to ImageMagick.
  (callPackage ../pkgs/oximedia.nix { }) # Video converter, an alternative to ffmpeg or mediainfo.
  wiremix # Rust terminal mixer for stream volumes, routing, and device profiles.
]
