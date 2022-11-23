#!/bin/sh

# Start the gnome-keyring-daemon from xinitrc
# https://wiki.archlinux.org/index.php/GNOME/Keyring#xinitrc_method
eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
export SSH_AUTH_SOCK

# With GDM, XDM, KDM or LightDM there is no need to source ~/.Xmodmap
# https://wiki.archlinux.org/index.php/Xmodmap
[[ -s ~/.Xmodmap ]] && xmodmap ~/.Xmodmap

# Merge Xresources automatically
[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

# https://wiki.archlinux.org/index.php/Activating_Numlock_on_Bootup#startx
numlockx &

# Executed by startx (run your window manager from here)
exec i3
