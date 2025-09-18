# shellcheck disable=SC2034,SC2153,SC2086,SC2155

# Above line is because shellcheck doesn't support zsh, per
# https://github.com/koalaman/shellcheck/wiki/SC1071, and the ignore: param in
# ludeeus/action-shellcheck only supports _directories_, not _files_. So
# instead, we manually add any error the shellcheck step finds in the file to
# the above line ...

__cursor_pos () {
  local pos tty
  exec {tty}<>/dev/tty
  echo -n '\e[6n' >&$tty; read -rsdR pos <&$tty
  exec {tty}>&-
  [[ $pos =~ '([0-9]+);([0-9]+)$' ]]
  print $match[1] $match[2]
}

__calc_placement () {
  local pos
  typeset -i height left want
  pos=($(__cursor_pos))
  left=$(( LINES - pos[1] ))
  want=$(( LINES * 0.4 ))
  if (( left < want )); then
    height=$((want + 1)) # the prompt line is used too
    {
      printf '\n%.0s' {1..$want}
      printf '\e[%dA' $want
    } >/dev/tty
  else
    height=$((left + 1))
  fi
  print -- --inline-height $height
}

# Source this in your ~/.zshrc
autoload -U add-zsh-hook

zmodload zsh/datetime 2>/dev/null

export ATUIN_SESSION=$(atuin uuid)
ATUIN_HISTORY_ID=""

_atuin_preexec() {
    ATUIN_HISTORY_ID=$(atuin history start -- "$1")
    __atuin_preexec_time=${EPOCHREALTIME-}
}

_atuin_precmd() {
    local EXIT="$?" __atuin_precmd_time=${EPOCHREALTIME-}

    [[ -z "${ATUIN_HISTORY_ID:-}" ]] && return

    local duration=""
    if [[ -n $__atuin_preexec_time && -n $__atuin_precmd_time ]]; then
        printf -v duration %.0f $(((__atuin_precmd_time - __atuin_preexec_time) * 1000000000))
    fi

    (ATUIN_LOG=error atuin history end --exit $EXIT ${duration:+--duration=$duration} -- $ATUIN_HISTORY_ID &) >/dev/null 2>&1
    ATUIN_HISTORY_ID=""
}

_atuin_search() {
    emulate -L zsh
    zle -I

    # swap stderr and stdout, so that the tui stuff works
    # TODO: not this
    local output
    # shellcheck disable=SC2048
    setopt localoptions nonotify
    output=$(ATUIN_SHELL_ZSH=t ATUIN_LOG=error atuin search $* -i $(__calc_placement) -- $BUFFER 3>&1 1>&2 2>&3)

    zle reset-prompt
    # re-enable bracketed paste
    echo -n $zle_bracketed_paste[1] >/dev/tty

    if [[ -n $output ]]; then
        RBUFFER=""
        LBUFFER=$output

        if [[ $LBUFFER == __atuin_accept__:* ]]
        then
            LBUFFER=${LBUFFER#__atuin_accept__:}
            zle accept-line
        else
            zle infer-next-history && zle up-history
        fi
    fi
}

_atuin_up_search() {
    # Only trigger if the buffer is a single line
    if [[ ! $BUFFER == *$'\n'* ]]; then
        _atuin_search --shell-up-key-binding "$@"
    else
        zle up-line
    fi
}

add-zsh-hook preexec _atuin_preexec
add-zsh-hook precmd _atuin_precmd

zle -N atuin-search _atuin_search

bindkey -M emacs "\esa" sk-search-history
bindkey -M emacs "\es\ea" sk-search-history
bindkey -M emacs "\esr" atuin-search
