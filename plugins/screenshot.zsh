# take screenshot to stdout (PNG)

if [[ $XDG_SESSION_TYPE == wayland ]]; then
  if (( $+commands[slurp] && $+commands[grim] )); then
    _screenshot="slurp -b ff00ff20 -B ff00ff20 -c ff00ff80 -o | grim -g - -"
  fi
else
  if (( $+commands[maim] )); then
    _screenshot="maim -s -l -c 255,0,255,0.15 -k -n 2"
  elif (( $+commands[flameshot] )); then
    _screenshot="flameshot gui -r"
  elif (( $+commands[import] )); then
    _screenshot="import png:-"
  fi
fi

if (( $+_screenshot )); then
  screenshot () {
    if [[ -t 1 ]]; then
      echo >&2 "Refused to write image to terminal."
      return 1
    fi
    eval ${_screenshot} "$@"
  }
fi

screen2clipboard () {
  screenshot | uniclip --input --clipboard -t image/png
}
