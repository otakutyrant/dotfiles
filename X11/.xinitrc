#!/bin/bash

# .xprofile is a user-level configuration, used to execute some commands when
# logging into a graphic user interface.
[ -f ~/.xprofile ] && . ~/.xprofile

# Enable displays connected to the NVIDIA GPU when Xorg starts on the AMD GPU.
if command -v xrandr >/dev/null 2>&1; then
  xrandr --setprovideroutputsource NVIDIA-G0 modesetting >/dev/null 2>&1 || true
  xrandr --auto >/dev/null 2>&1 || true
fi

# Autostart some applications from xinitrc.d.
if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

# Start window manager.
exec i3
