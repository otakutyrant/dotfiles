{ pkgs, ... }:

{
  # Keep the standalone Lua extension beside the structured mpv options.
  xdg.configFile."mpv/scripts" = {
    source = ../../files/config/mpv/scripts;
    recursive = true;
  };

  # Install an mpv package with Unicode-aware subtitle line wrapping through
  # Home Manager's mpv module.
  programs.mpv = {
    enable = true;
    package = pkgs.mpv.override {
      # mpv depends on libass which is not built with libunibreak, so override
      # that dependency for this package.
      mpv-unwrapped = pkgs.mpv-unwrapped.override {
        libass = pkgs.libass.overrideAttrs (oldAttrs: {
          configureFlags = (oldAttrs.configureFlags or [ ]) ++ [ "--enable-libunibreak" ];
          # libunibreak lets libass wrap long Chinese subtitle lines.
          buildInputs = (oldAttrs.buildInputs or [ ]) ++ [ pkgs.libunibreak ];
        });
      };
    };
    # These settings replace the linked mpv.conf and input.conf files.
    config = {
      sub-visibility = "yes";
      sub-auto = "fuzzy";
      audio-file-auto = "fuzzy";
      save-position-on-quit = "yes";
      autofit-larger = "100%x100%";
      geometry = "50%:50%";
      sub-font = "Sarasa Mono Slab SC Semibold";
      sub-font-size = 40;
      sub-margin-x = 80;
      sub-margin-y = 48;
      profile = "gpu-hq";
      scale = "ewa_lanczossharp";
      cscale = "ewa_lanczossharp";
      video-sync = "display-resample";
      interpolation = true;
      tscale = "oversample";
      keep-open = "yes";
    };
    bindings = {
      RIGHT = "sub-seek 1";
      LEFT = "sub-seek -1";
      ENTER = "script-message-to subtitle_cmds ab-loop-sub pause";
      "Shift+ENTER" = "script-message-to subtitle_cmds ab-loop-sub";
      y = "script-message-to subtitle_cmds copy-subtitle";
      # Nix string interpolation must be escaped so mpv receives its own
      # ${...} expressions for the active A-B loop and current filename.
      g = ''run ffmpeg -y -nostdin -ss ''${=ab-loop-a}s -to ''${=ab-loop-b}s -fflags +genpts -i ''${stream-open-filename} -avoid_negative_ts 1 -c copy -map 0 dump_''${filename}_''${=ab-loop-a}-''${=ab-loop-b}.mp4 ; show-text "ffmpeg dumping done"'';
    };
  };
}
