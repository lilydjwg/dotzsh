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

__sk () {
  local args=
  if (( $+functions[sk_extra_args] )); then
    args=$(sk_extra_args)
  fi
  sk --no-mouse -e --tiebreak index --height $(__calc_height) ${=args} "$@"
}

sk-vim-mru () {
  local file cmd
  cmd=${1:-vim}
  file=$(tail -n +2 ~/.vim/vim_mru_files | __sk --reverse -p "$cmd> ")
  if [[ -n $file ]]; then
    ${=cmd} $file
  else
    return 130
  fi
}

sk-search-history () {
  local cmd n match
  cmd=$(history 1 | sed 's/^\s*//' | \
    __sk --with-nth=2.. --tac --reverse -p 'cmd> ' \
    --preview 'echo {}' --preview-window=down:3:wrap \
    --query "$BUFFER" --print-query)
  if [[ $cmd == *$'\n'* ]]; then
    cmd=${cmd#*$'\n'}
    [[ $cmd == (#b)\ #([0-9]##)\ ##(*) ]]
    n=$match[1]
    cmd=$match[2]

    HISTNO=$n
    BUFFER=${cmd//\\n/$'\n'}
    (( CURSOR = $#BUFFER ))
  else
    # FIXME: can't get query string
    # BUFFER=$cmd
  fi
  # on the successful branch: for syntax highlight
  # the other: fix prompt
  zle redisplay
}

sk-cd () {
  local dir
  dir=$(sort -nr ~/.local/share/autojump/autojump.txt | \
    cut -f2- | __sk --reverse -p 'cd> ')
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
