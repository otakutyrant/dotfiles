# Making your BASH history more efficient
# http://jorge.fbarr.net/2011/03/24/making-your-bash-history-more-efficient/
export HISTCONTROL="ignoreboth"
export HISTSIZE=1000000

# ArchWiki: Environment Viriables
# https://wiki.archlinux.org/index.php/Environment_variables#Examples
# Note that some variables may be full pathnames.
# https://github.com/mobile-shell/mosh/issues/722#issuecomment-176266421
export SHELL="/usr/bin/zsh"
export PAGER="page"
export EDITOR="nvim"
export VISUAL="nvim"
export XDG_CONFIG_HOME="$HOME/.config"
# These addresses are assigned by cow.
proxy () {
  export http_proxy="http://127.0.0.1:2340"
  export https_proxy="http://127.0.0.1:2340"
  export HTTP_PROXY="http://127.0.0.1:2340"
  export HTTPS_PROXY="http://127.0.0.1:2340"
  echo "http proxy on"
}
noproxy () {
  unset http_proxy
  unset https_proxy
  unset HTTP_PROXY
  unset HTTPS_PROXY
  echo "http proxy off"
}

# Choose Default Qt toolkit
# https://wiki.archlinux.org/index.php/Qt#Using_environment_variables
export QT_SELECT=5

# Docker cli ignores environment variable http_proxy
# https://github.com/docker/docker/issues/10224
export no_proxy="/var/run/docker.sock"

# Convert a virtual big screen to two screens for SDL game.
# https://wiki.archlinux.org/index.php/NVIDIA#Gaming_using_TwinView
export SDL_VIDEO_FULLSCREEN_HEAD=1

# https://github.com/lilydjwg/search-and-view
export AGV_EDITOR="/bin/gvim"

# gperftools result position.
# See https://github.com/gperftools/gperftools/blob/master/README
export CPUPROFILE=$HOME/tmp/gperf.out

# CHROOT
# https://wiki.archlinux.org/index.php/DeveloperWiki:Building_in_a_Clean_Chroot#Setting_Up_A_Chroot
export CHROOT=$HOME/chroot

# Java font.
# https://wiki.archlinux.org/index.php/Java#Better_font_rendering
export _JAVA_OPTIONS="-Dawt.useSystemAAFontSettings=on"

# Development needs.
export CAFFE_DIR="${HOME}/Projects/caffe"
PATH="${CAFFE_DIR}/build/tools:$PATH"
PATH="/usr/local/cuda/bin:$PATH"  # for Ubuntu cuda
export RP_DIR="${HOME}/Projects/RoadPerception"
LD_LIBRARY_PATH="/usr/local/cuda-8.0/lib64:$LD_LIBRARY_PATH"
typeset -U LD_LIBRARY_PATH
export LD_LIBRARY_PATH

# PATH
PATH="${HOME}/.local/bin:$PATH"
typeset -U PATH
export PATH

# Locale
# https://github.com/robbyrussell/oh-my-zsh/issues/5790#issuecomment-273468677
export LANG=en_US.UTF-8
export LANGUAGE=en_US
export LC_CTYPE=en_US.UTF-8

# https://github.com/robbyrussell/oh-my-zsh/issues/6109#issuecomment-359274801
# However this alias does not work in .zshrc so I have to move it here
HIST_FORMAT="'%Y-%m-%d %T:'$(echo -e '\t')"
alias history="fc -t "$HIST_FORMAT" -il 1"

# produce millisecond result for time
# https://unix.stackexchange.com/a/453339/34173
TIMEFMT=$'\n================\nCPU\t%P\nuser\t%*U\nsystem\t%*S\ntotal\t%*E'

# Force GBM as a backend as it has wider Wayland compositor support.
export GBM_BACKEND=nvidia-drm
export __GLX_VENDOR_LIBRARY_NAME=nvidia
# Due to mouse cursor will disappear in Wayland with Nvidia property diriver.
export WLR_NO_HARDWARE_CURSORS=1
