sk-vim-mru () {
  local file
  file=$(tail -n +2 ~/.vim/vim_mru_files | sk)
  if [[ -n $file ]]; then
    ${1:-vim} $file
  else
    return 130
  fi
}

sk-search-history () {
  local cmd
  cmd=$(history -n 1 | sk)
  if [[ -n $cmd ]]; then
    BUFFER=$cmd
    (( CURSOR = $#BUFFER ))
  fi
}

sk-cd () {
  local dir
  dir=$(sort -nr ~/.local/share/autojump/autojump.txt | awk '{print $2}' | sk)
  if [[ -n $dir ]]; then
    zle push-line
    BUFFER="cd ${(q)dir}"
    zle accept-line
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
  fi
fi

# vim: se ft=zsh:
