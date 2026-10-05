{
  config,
  pkgs,
  ...
}:

{
  # Small command-line and desktop integration utilities used across workflows.
  home.packages = [
    config.programs.git.package # Distributed version control system.
    pkgs.gh # GitHub client.
    pkgs.git-lfs # A Git extension for large files.

    config.programs.ssh.package # SSH client and related secure-shell utilities.

    pkgs.file # Joshuto uses this command to detect file types and MIME types.

    config.programs.direnv.package # Per-directory environment loader.

    # `openai-whisper` is accurate, but it brings a heavier Python stack and does not support GPU.
    # `whisper-ctranslate2` can be fast, but its Python/CUDA dependency surface is larger.
    # `whisperx` is useful for word timestamps and diarization, but it is overkill for normal SRT files.
    # `whisper-cpp-vulkan` is a useful non-CUDA fallback, but CUDA is better for this NVIDIA machine.
    (pkgs.whisper-cpp.override {
      cudaSupport = true;
    })

    # Rust-powered
    config.programs.nushell.package # Shell.
    config.programs.starship.package # Cross-shell command prompt.
    pkgs.local.nur # Task runner.
    pkgs.page # Pager, based on Neovim.
    pkgs.ouch # Archiver.
    pkgs.vimv # Batch files renamer, based on Neovim.
    pkgs.tokei # Source code lines counter.
    pkgs.local.tree # Treer, optimized for document comments.
    pkgs.sd # Steam EDitor, search and replace, an alternative to sed.
    pkgs.macchina # System information shower, an alternative to lsb-release.
    pkgs.local.clipcat # Clipboard manager, with robust large-image publishing on Wayland.
    # Use the current rqbit release from unstable. Magnet links are submitted
    # separately through its HTTP API because rqbit 9's CLI is stateless.
    pkgs.unstable.rqbit # BitTorrent client, an alternative to Fragments or qBittorrent.

    # Media tools, Rust-powered
    pkgs.local.imageflow # Image tool, an alternative to ImageMagick.
    pkgs.local.oximedia # Video converter, an alternative to ffmpeg or mediainfo.
    pkgs.wiremix # Rust terminal mixer for stream volumes, routing, and device profiles.

    # Miscellanea
    pkgs.scowl # English words.
  ];
}
