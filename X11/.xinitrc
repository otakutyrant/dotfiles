#!/bin/bash

# .xprofile is a user-level configuration, used to execute some commands when
# logging into a graphic user interface.
[ -f ~/.xprofile ] && . ~/.xprofile

# Autostart some applications from xinitrc.d.
if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

# Start window manager.
exec i3
