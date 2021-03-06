# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="bullet-train"
BULLETTRAIN_RUBY_SHOW=false
BULLETTRAIN_HG_SHOW=false
BULLETTRAIN_EXEC_TIME_SHOW=true

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="yyyy.mm.dd"

# Would you like to use another custom folder than $ZSH/custom?
ZSH_CUSTOM=$HOME/.zsh-custom

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(systemd pacman pikaur github z)

# User configuration

source $ZSH/oh-my-zsh.sh
# Set all your custom environment variables in .zshenv
source $HOME/.zshenv
# https://wiki.archlinux.org/index.php/Pkgfile#Zsh
source /usr/share/doc/pkgfile/command-not-found.zsh
# https://github.com/wting/autojump
[[ -s /etc/profile.d/autojump.sh ]] && source /etc/profile.d/autojump.sh

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.

alias l='ls --color=auto'
alias vi='nvim'
alias cl='clang'

alias sw='sudo wifi-menu'

# Enables ssh trusted X11 forwarding.
alias ssh='ssh -Y'
# https://wiki.archlinux.org/index.php/Core_utilities#Colored_output_2
alias ll='ls -alFh --color=auto'
# https://wiki.archlinux.org/index.php/Core_utilities#Colored_output
alias grep='grep --color'
alias rm='rm -Iv --one-file-system'
alias mkdir='mkdir -pv'
alias dstat='dstat -cdlmnpsy'
# Let WPS-Office use gtk style
alias wps='wps -style gtk'
alias et='et -style gtk'
alias wpp='wpp -style gtk'

# https://coderwall.com/p/ohk6cg/remote-access-to-ipython-notebooks-via-ssh
alias jupyter-server='ipython notebook --no-browser'
alias jupyter-local='ssh -N -f -L localhost:8888:localhost:8888'

# Use yaourt/pkgfile alias in Ubuntu
# https://github.com/robbyrussell/oh-my-zsh/blob/master/plugins/archlinux/archlinux.plugin.zsh
if (( $+commands[apt-get] )); then
  alias yaupg='sudo apt update'
  alias yain='sudo apt install'
  alias yare='sudo apt remove'
  if (( $+commands[apt-cache] )); then
    alias yarep='apt-cache show'
  else
    alias yarep='aptitude show'
  fi
  alias yareps='apt search'
  if (( $+commands[dpkg] )); then
    alias yaloc='dpkg -s'
  else
    alias yaloc='aptitude show'
  fi
  if (( $+commands[aptitude] )); then
    yalocs() {
      aptitude search '~i(~n $1|-d $1)'
    }
  fi
  alias pkgfile='apt-file search'
fi

# Improve colored output by ls
# https://wiki.archlinux.org/index.php/Core_utilities#Colored_output_2
eval "$(dircolors -b)"

alias fixssh='eval `tmux showenv -s SSH_AUTH_SOCK`'
if { [ "$TERM" = "screen" ] && [ -n "$TMUX" ]; } then
  eval fixssh
fi

alias kill='kill -9'
