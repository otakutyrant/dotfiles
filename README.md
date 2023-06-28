# Glossary

Amazingly, "split window horizontally/vertically" is terribly ambiguous in [Linux](https://english.stackexchange.com/q/293520/355018). As an ESL learner, I want to focus in the verb "split" itself. By instinct, if I split an object, I cut it through a horizontal line. But I think some other people may focus in object itself. In other words, if an object is split "horizontally", it become two objects, distributed in horizontal direction. No wonder some Linux software will split objects horizontally in two different ways, because they focus in either verb or noun.

To be clear. In this repository, "split window horizontally" means to cut it through a horizontal line. However sometimes it is necessary to distribute windows horizontally or vertically. I won't use "split" but "distribute". I think "distribute all windows horizontally" is unambiguous. Due to some Linux software have a contract meaning of "split horizontally" from their reserved keywords in config, or even use "split" and "distribute" interchangeably, I will clarify them by comments, especially in i3.

dotfiles
========

I [use GNU Stow to manage my dotfiles](http://brandon.invergo.net/news/2012-05-26-using-gnu-stow-to-manage-your-dotfiles.html) with elaborate comments inside. It is strongly recommended to use the `--no-folding` option when you stow dotfiles in new operating systems, otherwise thereafter some new generated files will appear in dotfiles rather than the corresponding position of the home directory, like [this](https://superuser.com/questions/1632928/gnu-stow-only-symlink-files-not-directories).

It may be inconvenient to manage DE via dotfiles. I do not use any DE but i3.

# some txts for convenient Arch Linux installation

I use pikaur as the third-party package manager and maintain some text files about necessary packages for different cases, like `applications.txt` and `development.txt`. You may execute such commands as below to strip comments and install only needed packages.

```
grep -v "^#" applications.md | pikaur -S --needed -
grep -v "^#" development.md | pikaur -S --needed -
```

## Default Applications

I follow [XDG MIME Applications](https://wiki.archlinux.org/title/XDG_MIME_Applications) to set [Default applications](https://wiki.archlinux.org/index.php/Default_applications), meanwhile some related environments are set in `.zshenv`.

## Git

Nvimpager and meld are recommended as pager and merge tool respectively.

## X11

.config/gtk-3.0/bookmarks: for Nautilus.
.config/gtk-3.0/setting.ini: GTK+ 3 config.
.config/.gtkrc-2.0: GTK+ 2 config.
.xinitrc & .Xmodmap: X11 config.
