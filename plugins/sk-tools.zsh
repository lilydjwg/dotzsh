__cursor_pos () {
  local pos
  exec {tty}<>/dev/tty
  echo -n '\e[6n' >&$tty; read -rsdR pos <&$tty
  exec {tty}>&-
  [[ $pos =~ '([0-9]+);([0-9]+)$' ]]
  print $match[1] $match[2]
}

__calc_height () {
  local pos
  typeset -i height left want
  pos=($(__cursor_pos))
  left=$(( LINES - pos[1] ))
  want=$(( LINES * 0.4 ))
  if (( left > want )); then
    height=$left
  else
    height=$want
  fi
  height=$(( height + 1)) # the prompt line is used too
  print $height
}

sk-vim-mru () {
  local file cmd
  cmd=${1:-vim}
  file=$(tail -n +2 ~/.vim/vim_mru_files | \
    sk -e --tiebreak index --height $(__calc_height) --reverse -p "$cmd> ")
  if [[ -n $file ]]; then
    ${=cmd} $file
  else
    return 130
  fi
}

sk-search-history () {
  local cmd
  cmd=$(history -n 1 | \
    sk -e --tac --tiebreak index --height $(__calc_height) --reverse -p 'cmd> ' \
    --preview 'echo {}' --preview-window=down:3:wrap \
    --query "$BUFFER" --print-query)
  if [[ $cmd == *$'\n'* ]]; then
    BUFFER=${cmd#*$'\n'}
    BUFFER=${BUFFER//\\n/$'\n'}
  else
    # FIXME: can't get query string
    # BUFFER=$cmd
  fi
  (( CURSOR = $#BUFFER ))
  # on the successful branch: for syntax highlight
  # the other: fix prompt
  zle redisplay
}

sk-cd () {
  local dir
  dir=$(sort -nr ~/.local/share/autojump/autojump.txt | \
    cut -f2- | \
    sk -e --tiebreak index --height $(__calc_height) --reverse -p 'cd> ')
  if [[ -n $dir ]]; then
    zle push-line
    zle redisplay
    BUFFER="cd ${(q)dir}"
    zle accept-line
  else
    zle redisplay
  fi
}

if (( $+commands[sk] )); then
  zle -N sk-cd
  bindkey "\esd" sk-cd

  zle -N sk-search-history
  bindkey "\esr" sk-search-history

  vim-mru () { sk-vim-mru }
  if (( $+commands[vv] )); then
    vv-mru () { sk-vim-mru vv }
    bindkey -s "\esv" "vv-mru^M"
  fi

  if [[ -f /usr/share/skim/completion.zsh ]]; then
    . /usr/share/skim/completion.zsh
  fi
fi

# vim: se ft=zsh:
