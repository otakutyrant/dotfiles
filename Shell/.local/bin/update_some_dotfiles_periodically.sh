#!/bin/bash
#
# sourced by .zshrc, supervise some frequently-changed dotfiles and update them periodically

declare -a appended_files
appended_files=(
  $HOME/dotfiles/GoldenDict/.goldendict/learned_words.txt
  $HOME/dotfiles/NeoVim/.config/nvim/spell/en.utf-8.add
  $HOME/dotfiles/NeoVim/.config/nvim/spell/en.utf-8.add.spl
)
changed_files=(
  $HOME/dotfiles/Nautilus/.config/nautilus/search-metadata
  $HOME/dotfiles/X11/.config/gtk-3.0/bookmarks
)

function update() {
  local file=$1
  local days=$2
  if test -f $file; then
    cd $HOME/dotfiles
    if git diff $file; then
      last_modified_time=$(git log -1 --format=%cd --date=unix Git/.config/git/config)
    fi
  fi
}
