#!/bin/sh
set -eu

# A single ordered entry owns session startup. Separate Sway exec directives
# race: graphical services can start before their display environment arrives.
# Load only the declared public environment, never the interactive shell state.
. "@environmentFile@"
@dbusUpdate@ --systemd @environmentNames@ PATH DISPLAY WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP
@systemctl@ --user start sway-session.target
@systemctl@ --user start xdg-autostart-if-no-desktop-manager.target
@systemctl@ --user restart elephant.service
