__background_color () {
  local l
  exec {tty}<>/dev/tty
  echo -n "\x1B]11;?\x07" >&$tty; read -rsd $'\x07' l <&$tty
  exec {tty}>&-
  [[ $l =~ 'rgb:([0-9a-fA-F]+)/([0-9a-fA-F]+)/([0-9a-fA-F]+)$' ]]
  print $(( 0x$match[1] / 0x100 )) $(( 0x$match[2] / 0x100 )) $(( 0x$match[3] / 0x100 ))
}

__is_light_background () {
  local c=($(__background_color))
  local max=0
  if [[ $c[1] -gt $max ]]; then max=$c[1]; fi
  if [[ $c[2] -gt $max ]]; then max=$c[2]; fi
  if [[ $c[3] -gt $max ]]; then max=$c[3]; fi
  (( max > 127 ))
}

__is_light_background_fix () {
  if [[ -n $TMUX ]]; then
    # FIXME: tmux only returns the first attached client
    #        and sometimes stuck when changing terminal profiles
    if [[ $XDG_SESSION_TYPE == wayland ]]; then
      [[ $(current-output) == 'HDMI-A-1' ]]
    else
      false
    fi
  else
    __is_light_background
  fi
}

sk_extra_args () {
  if __is_light_background; then
    echo "--color=light"
  fi
}

mutt () {
  if __is_light_background; then
    command mutt -F ~/.muttrc.eink "$@"
  else
    command mutt "$@"
  fi
}

chp () {
  if [[ $XDG_SESSION_TYPE == wayland ]]; then
    local key=$(( $1 + 1 ))
    ydotool key 42:1 68:1 68:0 42:0 19:1 19:0 $key:1 $key:0
  else
    xdotool key --clearmodifiers Shift+F10 r $1
  fi
}
theme-light () {
  chp 1
}
theme-dark () {
  chp 2
}

