# Making your BASH history more efficient
# http://jorge.fbarr.net/2011/03/24/making-your-bash-history-more-efficient/
export HISTCONTROL="ignoreboth"
export HISTSIZE=1000000

if command -v zsh >/dev/null 2>&1; then
  export SHELL="$(command -v zsh)"
else
  export SHELL="/usr/bin/zsh"
fi
if command -v page >/dev/null 2>&1; then
  export PAGER="page"
else
  export PAGER="less"
fi
export EDITOR="nvim"
export VISUAL="nvim"
export XDG_CONFIG_HOME="$HOME/.config"
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

export QT_SELECT=5
export no_proxy="/var/run/docker.sock"
export SDL_VIDEO_FULLSCREEN_HEAD=1
export AGV_EDITOR="gvim"
export CPUPROFILE=$HOME/tmp/gperf.out
export CHROOT=$HOME/chroot
export _JAVA_OPTIONS="-Dawt.useSystemAAFontSettings=on"

export CAFFE_DIR="${HOME}/Projects/caffe"
PATH="${CAFFE_DIR}/build/tools:$PATH"
PATH="/usr/local/cuda/bin:$PATH"
export RP_DIR="${HOME}/Projects/RoadPerception"
LD_LIBRARY_PATH="/usr/local/cuda-8.0/lib64:$LD_LIBRARY_PATH"
typeset -U LD_LIBRARY_PATH
export LD_LIBRARY_PATH

PATH="${HOME}/.local/bin:$PATH"
typeset -U PATH
export PATH

export LANG=en_US.UTF-8
export LANGUAGE=en_US
export LC_CTYPE=en_US.UTF-8

HIST_FORMAT="'%Y-%m-%d %T:'$(echo -e '\t')"
alias history="fc -t "$HIST_FORMAT" -il 1"

TIMEFMT=$'\n================\nCPU\t%P\nuser\t%*U\nsystem\t%*S\ntotal\t%*E'

export GBM_BACKEND=nvidia-drm
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export WLR_NO_HARDWARE_CURSORS=1
