{
  lib,
  makeWrapper,
  symlinkJoin,
}:

{
  package,
  executables,
}:

# Sway does not implement the Wayland text-input protocol used by Qt, so Qt
# applications need Fcitx's Qt input module even when the rest of the desktop
# uses Fcitx's native Wayland frontend. Keep the override local to the listed
# executables instead of changing every process in the session.
symlinkJoin {
  name = "${lib.getName package}-with-fcitx-qt";
  paths = [ package ];
  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    for executable in ${lib.escapeShellArgs executables}; do
      if [[ ! -x "$out/bin/$executable" ]]; then
        echo "wrap-with-fcitx-qt: $out/bin/$executable is not executable" >&2
        exit 1
      fi

      wrapProgram "$out/bin/$executable" --set QT_IM_MODULE fcitx
    done

    # Most desktop entries use a command from PATH. WPS instead embeds its
    # original Nix store path, which would bypass the wrappers above. Copy only
    # affected entries out of the symlink tree and point them at this package.
    if [[ -d "$out/share/applications" ]]; then
      for desktopEntry in "$out"/share/applications/*.desktop; do
        [[ -e "$desktopEntry" ]] || continue
        if grep -Fq '${package}/bin/' "$desktopEntry"; then
          cp --remove-destination "$(readlink -f "$desktopEntry")" "$desktopEntry"
          substituteInPlace "$desktopEntry" \
            --replace-fail '${package}/bin/' "$out/bin/"
        fi
      done
    fi
  '';

  inherit (package) meta;
}
