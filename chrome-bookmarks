#!/usr/bin/env bash
#===============================================================================
#   Author: Wenxuan
#    Email: wenxuangm@gmail.com
#  Created: 2018-04-07 00:50
#===============================================================================
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd) && cd "$SCRIPT_DIR"

if [ $(uname) = Darwin ]; then
    open_cmd='open'
    bookmarks_path='~/Library/Application Support/Google/Chrome/Default/Bookmarks'
elif [ $(uname) = Linux ]; then
    open_cmd='xdg-open'
    bookmarks_path='~/.config/google-chrome/Default/Bookmarks'
fi
[ -n "$open_cmd" ] || return 1

which fzf > /dev/null 2>&1 || brew reinstall --HEAD fzf || exit 1

ruby chrome-bookmarks-parser.rb "$bookmarks_path"  |
  fzf --ansi --multi --no-hscroll --tiebreak=begin |
  awk 'BEGIN { FS = "\t" } { print $2 }'           |
  xargs -n1 -I{} nohup $open_cmd {} &>/dev/null
