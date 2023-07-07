#!/bin/bash

# Load Xmodmap.
[[ -s ~/.Xmodmap ]] && xmodmap ~/.Xmodmap

# Load Xresources.
[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources

# Autostart some applications from xinitrc.d.
if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

# Start window manager.
exec i3
