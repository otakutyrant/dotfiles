# How to manage dotfiles

I [use GNU Stow to manage my dotfiles](http://brandon.invergo.net/news/2012-05-26-using-gnu-stow-to-manage-your-dotfiles.html).

It is strongly recommended to use the `--no-folding` option when you stow dotfiles in new operating systems, otherwise thereafter some new generated files will appear in dotfiles rather than the corresponding position of the home directory, like [this](https://superuser.com/questions/1632928/gnu-stow-only-symlink-files-not-directories).
So I `alias_or_warning stow "stow --no-folding --target=$HOME"` in my `.zshrc`.
`--target=$HOME` allows you to put the dotfiles wherever you like. I used to put it in `$HOME/Projects` directory.

For convenience, I `alias_or_warning unstow "stow -D --target=$HOME"` too.

Unfortunately, stow doesn't supervise installed packages and automatically install new files or remove deleted files. You have to manually stow or unstow the packages after you add/remove some files inside. Any better alternatives advice are welcome.

Note: `alias_or_warning` is a function in `.zshrc`, used to avoid any implicit conflict alias.

# Make dotfiles simple

Find a client which has highly refined default configuration so you do not override them too much (Neovim works well that it changes many vim default options). When overriding them, comment why you do that.

As for Neovim. If you can use third-part tool to handle files, use them rather than install an corresponding plugin, like useless Black plugin because you can execute external commands in Ex command as `:!black %`. Tinkering Neovim is ceaseless.

# Introduction to unified, hierarchical windows management

Before the introduction, let us make sure what split means. Amazingly, "split window horizontally/vertically" is terribly ambiguous in [Linux](https://english.stackexchange.com/q/293520/355018). As an ESL learner, I decide to focus in the verb "split" itself. By instinct, if I split an object, I cut it through a horizontal line. But some other people may focus in the object itself. In other words, when the object is split "horizontally", it becomes two objects, distributed in horizontal direction. No wonder some Linux software will split objects horizontally in two different ways, because they focus in either verb or noun.

To be clear. In the dotfiles, "split window horizontally" means to cut it through a horizontal line. However sometimes it is necessary to distribute windows horizontally or vertically. I won't use "split" but "distribute". I think "distribute all windows horizontally" is unambiguous. Due to some Linux software have a contract meaning of "split horizontally" from their reserved keywords in configuration, or even use "split" and "distribute" interchangeably, I will clarify them by comments, especially in i3.

Now image you have multiple windows in your screen and you are a heavy Vim user. You have a master key, used to combine with any key to manage **tabs** and **windows**. Tabs are usually numbered, and a tab contains multiple windows. Windows can be split, distributed, moved between tabs, and killed.

When you want to jump the specific tab, just hit `master+num`.

When you want split a window vertically or horizontally, hit `master+v` or `master+s` respectively. If you want distribute all windows in the current tab instantly, hit `master+|` or `master+-`, the meaning of bar and hash symbols are enough obvious.

You would like to move focus between windows via `master+hjkl`.

When you want to kill a windows, hit `master+q`.

Now time to make the windows management hierarchical! In Linux, I use a windows manager, i3, to handles multiple GUI clients, including a virtual terminal, kitty. In turn, I use kitty to handles multiple CLI clients, including shells and an editor, Neovim. Eventually, I use Neovim to handles multiple files. The windows management of such three hierarchies are almost consistent, list as below:

|    Hierarchies   |  name  | What do they manage? | What do master keys call in them? | binded key |
|:----------------:|:------:|----------------------|:---------------------------------:|:----------:|
| Windows Manager  | i3     | GUI clients          | $mod                              | super      |
| Virtual Terminal | kitty  | CLI clients          | N/A                               | alt        |
| Editor           | Neovim | Files                | key                               | space      |
| Multiplixer      | tmux   | Remote sessions      | the prefix key                    | ctrl-w     |

| name   | What do tabs call in them? | How to allocate a new tab? | How to jump to a tab? |
|--------|----------------------------|----------------------------|-----------------------|
| i3     | workspace                  | N/A                        | super+num             |
| kitty  | tab                        | alt+n                      | alt+num               |
| Neovim | tabpage                    | space+n                    | space+num             |
| tmux   | window                     | ctrl-w+n                   | ctrl-w+num            |

| name   | What do windows call in them? | How to move focus between windows? | How to split a window horizontally or vertically? | How to distribute windows horizontally or vertically? | How to kill a window? |
|--------|-------------------------------|------------------------------------|---------------------------------------------------|-------------------------------------------------------|-----------------------|
| i3     | window                        | mod+hjkl                           | super+s or super+v,                               | super+- or super+\|,                                  | super+q               |
| kitty  | window                        | alt+hjkl                           | alt+s or alt+v                                    | alt+- or alt+\|                                       | alt+q                 |
| Neovim | window                        | space+hjkl                         | space+s or space+v                                | N/A                                                   | space+q               |
| tmux   | pane                          | ctrl-w+hjkl                        | ctrl-w+s or ctrl-w+v                              | N/A                                                   | ctrl-w+q              |

Note:

1. kitty does not define master key, but you can use it anyway.
2. Creating tabs are unnecessary in i3, ten tabs are perpetually allocated to begin with.
3. In kitty, as far as I know, when you create a window, it always is a shell.
4. When you split in i3, no gap will be shown unless a new GUI client is launched. See https://github.com/i3/i3/discussions/5546
5. \- is a minus symbol and | bar symbol.
6. If you want to adjust the border between windows, use mouse. All hierarchies support it.
7. It seems that tmux can distribute windows too. But I have no interest to figure out how.
8. i3 and kitty can distribute windows layout to tabbed, stacked, and so on. Explorer it by yourself.

Do you notice the relation between master keys? They are distributed in the left-bottom part of my Happy Hacking Keyboard exactly. How well organized they are.

Haplessly, kitty cannot handle remote sessions so far. So though I dislike tmux, it is still maintained as alternative to kitty in the dotfiles and listed in the table.

# XDG

I use [mineapps.list](https://wiki.archlinux.org/title/XDG_MIME_Applications) to set [Default applications](https://wiki.archlinux.org/index.php/Default_applications).

All configuration in this dotfiles are put in `$XDG_CONFIG_HOME` as possible as they can.

Personal commands congregate in `$HOME/.local/bin`, although `XDG_BIN_HOME` is not specified so far.

# Environment Variables

Some packages have `dotenv` to export their environment variables. `.zshrc` will try to scan them in `XDG_CONFIG_HOME/*/dotenv`. Other environment variables concentrate at `.zshenv`.

# X11

I tried to migrate to Wayland but terminated, because Nvidia support is not good enough yet. Blame Nvidia!

# Two lists to install in Arch Linux

By the way, I use Arch Linux. So I maintained two lists for CLI clients and GUI clients, highly commented. After installing Arch Linux in a new machine, I install all packages from the files via this way like `pacman -S $(sed "/#/D" gui_clients.txt)`.

I noticed a trend that traditional GNU CLI clients are replaced by high-performance Rust alternatives, like `find` is replaced by `fd`, `grep` by `ripgrep` or `fzf`, `less` by `page` and so on.

# China network issue

There are some related configuration. Ignore them if you do not live in China.

# Too many themes and you do not know which one is the best?

Don't worry, only infants make choice, while adults want the whole enchilada! Just install all of them and random pick one every time you launch the client. You can consult how I do that in my [Neovim themes](Neovim/.config/nvim/lua/plugins/themes.lua). When fate plays its hand, a captivating theme will gracefully unfurl.

The random theme mechanism of kitty, i3, and so on is working in progress.
