dotfiles
========

I am [Using GNU Stow to manage my dotfiles](http://brandon.invergo.net/news/2012-05-26-using-gnu-stow-to-manage-your-dotfiles.html), I arrange my all dotfiles here, and there are many comments and references to ArchWiki inside them, which are very helpful.

Let me explain some diretories.

## Default Applications

No DE settings. Instead I follow [Desktop entries](https://wiki.archlinux.org/index.php/Desktop_entries) to set [Default applications](https://wiki.archlinux.org/index.php/Default_applications#MIME_types_and_desktop_entries), while some related environments are set in `.zshenv`.

## Git

Nvimpager and meld are recommended as pager and merge tool respectively.

## X11

.config/gtk-3.0/bookmarks: for Nautilus.
.config/gtk-3.0/setting.ini: GTK+ 3 config.
.config/.gtkrc-2.0: GTK+ 2 config.
.xinitrc & .Xmodmap: X11 config.

By the way, I write some scripts to reinstall Arch Linux quickly, but they are not practical as so far.
