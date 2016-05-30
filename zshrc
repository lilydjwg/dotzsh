# 基本设置 {{{1
_zdir=${ZDOTDIR:-$HOME}
HISTFILE=${_zdir}/.histfile
HISTSIZE=10000
SAVEHIST=10000

zstyle :compinstall filename "$_zdir/.zshrc"
fpath=($_zdir/.zsh/Completion $_zdir/.zsh/functions $fpath)
autoload -Uz compinit
compinit

# 确定环境 {{{1
OS=${$(uname)%_*}
if [[ $OS == "CYGWIN" || $OS == "MSYS" ]]; then
  OS=Linux
elif [[ $OS == "Darwin" ]]; then
  OS=FreeBSD
fi
# check first, or the script will end wherever it fails
zmodload zsh/regex 2>/dev/null && _has_re=1 || _has_re=0
unsetopt nomatch
zmodload zsh/subreap 2>/dev/null && subreap
# 选项设置{{{1
unsetopt beep
# 不需要打 cd，直接进入目录
setopt autocd
# 自动记住已访问目录栈
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushd_minus
# rm * 时不要提示
setopt rm_star_silent
# 允许在交互模式中使用注释
setopt interactive_comments
# disown 后自动继续进程
setopt auto_continue
setopt extended_glob
# 单引号中的 '' 表示一个 ' （如同 Vimscript 中者）
setopt rc_quotes
# 补全列表不同列可以使用不同的列宽
setopt listpacked
# 补全 identifier=path 形式的参数
setopt magic_equal_subst
# 为方便复制，右边的提示符只在最新的提示符上显示
setopt transient_rprompt
# setopt 的输出显示选项的开关状态
setopt ksh_option_print
setopt no_bg_nice
setopt noflowcontrol
stty -ixon # 上一行在 tmux 中不起作用
# 历史记录{{{2
# 不保存重复的历史记录项
setopt hist_save_no_dups
setopt hist_ignore_dups
# setopt hist_ignore_all_dups
# 在命令前添加空格，不将此命令添加到记录文件中
setopt hist_ignore_space
# zsh 4.3.6 doesn't have this option
setopt hist_fcntl_lock 2>/dev/null
if [[ $_has_re -eq 1 && 
  ! ( $ZSH_VERSION =~ '^[0-4]\.' || $ZSH_VERSION =~ '^5\.0\.[0-4]' ) ]]; then
  setopt hist_reduce_blanks
else
  # This may cause the command messed up due to a memcpy bug
fi

# 补全与 zstyle {{{1
# 自动补全 {{{2
# 用本用户的所有进程补全
zstyle ':completion:*:processes' command 'ps -afu$USER'
zstyle ':completion:*:*:*:*:processes' force-list always
# 进程名补全
zstyle ':completion:*:processes-names' command  'ps c -u ${USER} -o command | uniq'

# 警告显示为红色
zstyle ':completion:*:warnings' format $'\e[01;31m -- No Matches Found --\e[0m'
# 描述显示为淡色
zstyle ':completion:*:descriptions' format $'\e[2m -- %d --\e[0m'
zstyle ':completion:*:corrections' format $'\e[01;33m -- %d (errors: %e) --\e[0m'

# cd 补全顺序
zstyle ':completion:*:-tilde-:*' group-order 'named-directories' 'path-directories' 'users' 'expand'
# 在 .. 后不要回到当前目录
zstyle ':completion:*:cd:*' ignore-parents parent pwd

# complete manual by their section, from grml
zstyle ':completion:*:manuals'    separate-sections true
zstyle ':completion:*:manuals.*'  insert-sections   true

zstyle ':completion:*' menu select
# 分组显示
zstyle ':completion:*' group-name ''
# 歧义字符加粗（使用「true」来加下划线）；会导致原本的高亮失效
# http://www.thregr.org/~wavexx/rnd/20141010-zsh_show_ambiguity/
# zstyle ':completion:*' show-ambiguity '1;37'
# 在最后尝试使用文件名
zstyle ':completion:*' completer _complete _match _approximate _expand_alias _ignored _files
# 修正大小写
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'
zstyle -e ':completion:*' special-dirs \
  '[[ $PREFIX == (../)#(|.|..) ]] && reply=(..)'
# 使用缓存。某些命令的补全很耗时的（如 aptitude）
zstyle ':completion:*' use-cache on
_cache_dir=${XDG_CACHE_HOME:-$HOME/.cache}/zsh
zstyle ':completion:*' cache-path $_cache_dir
unset _cache_dir

compdef pkill=killall
compdef pgrep=killall
compdef vman=man
compdef proxychains=command
compdef watch=command
compdef rlwrap=command
compdef ptyless=command
compdef grc=command
compdef agg=ag 2>/dev/null
compdef downgrade=pactree 2>/dev/null
# not only pdf files
compdef -d evince
compdef _gnu_generic exa
compdef whoneeds=pactree 2>/dev/null

# 我的自动补全 {{{2
zstyle ':completion:*:*:pdf2png:*' file-patterns \
  '*.pdf:pdf-files:pdf\ files *(-/):directories:directories'
zstyle ':completion:*:*:x:*' file-patterns \
  '*.{7z,bz2,gz,rar,tar,tbz,tgz,zip,chm,xz,exe,xpi,apk,maff,crx}:compressed-files:compressed\ files *(-/):directories:directories'
zstyle ':completion:*:*:evince:*' file-patterns \
  '*.{pdf,ps,eps,dvi,djvu,pdf.gz,ps.gz,dvi.gz}:documents:documents *(-/):directories:directories'
zstyle ':completion:*:*:gbkunzip:*' file-patterns '*.zip:zip-files:zip\ files *(-/):directories:directories'
zstyle ':completion:*:*:flashplayer:*' file-patterns '*.swf'
zstyle ':completion:*:*:hp2ps:*' file-patterns '*.hp'
zstyle ':completion:*:*:feh:*' file-patterns '*.{png,gif,jpg,svg}:images:images *(-/):directories:directories'
zstyle ':completion:*:*:sxiv:*' file-patterns '*.{png,gif,jpg}:images:images *(-/):directories:directories'
zstyle ':completion:*:*:timidity:*' file-patterns '*.mid'

# 命令行编辑{{{1
bindkey -e

# ^Xe 用$EDITOR编辑命令
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

zle -C complete-file menu-expand-or-complete _generic
zstyle ':completion:complete-file:*' completer _files

autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic
toggle-uqm () {
  if zle -l self-insert; then
    zle -A .self-insert self-insert && zle -M "switched to self-insert"
  else
    zle -N self-insert url-quote-magic && zle -M "switched to url-quote-magic"
  fi
}
zle -N toggle-uqm
bindkey '^X$' toggle-uqm

# better than copy-prev-word
bindkey "^[^_" copy-prev-shell-word

insert-last-word-r () {
  zle insert-last-word -- 1
}
zle -N insert-last-word-r
bindkey "\e_" insert-last-word-r
# Not works with my insert-last-word-r
# autoload -Uz smart-insert-last-word
# zle -N insert-last-word smart-insert-last-word
autoload -Uz copy-earlier-word
zle -N copy-earlier-word
bindkey '\e=' copy-earlier-word

autoload -Uz prefix-proxy
zle -N prefix-proxy
bindkey "^Xp" prefix-proxy

zmodload zsh/complist
bindkey -M menuselect '^O' accept-and-infer-next-history

bindkey "^X^I" complete-file
bindkey "^X^f" complete-file
bindkey "^U" backward-kill-line
bindkey "^]" vi-find-next-char
bindkey "\e]" vi-find-prev-char
bindkey "\eq" push-line-or-edit
bindkey -s "\e[Z" "^P"
bindkey '^Xa' _expand_alias
bindkey '^[/' _history-complete-older
bindkey '\e ' set-mark-command
# 用单引号引起最后一个单词
# FIXME 如何引起光标处的单词？
bindkey -s "^['" "^[] ^f^@^e^[\""
# 打开 zsh 的PDF格式文档
bindkey -s "^X^D" "evince ~/文档/编程/shell/zsh/zsh.pdf &^M"
bindkey -s "^Xc" "tmux attach -d^M"

bindkey '^[p' up-line-or-search
bindkey '^[n' down-line-or-search

# jump to a position in a command line {{{2
# https://github.com/scfrazer/zsh-jump-target
autoload -Uz jump-target
zle -N jump-target
bindkey "^J" jump-target

# restoring an aborted command-line {{{2
# unsupported with 4.3.17
if zle -la split-undo; then
  zle-line-init () {
    if [[ -n $ZLE_LINE_ABORTED ]]; then
      _last_aborted_line=$ZLE_LINE_ABORTED
    fi
    if [[ -n $_last_aborted_line ]]; then
      local savebuf="$BUFFER" savecur="$CURSOR"
      BUFFER="$_last_aborted_line"
      CURSOR="$#BUFFER"
      zle split-undo
      BUFFER="$savebuf" CURSOR="$savecur"
    fi
  }
  zle -N zle-line-init
  zle-line-finish() {
    unset _last_aborted_line
  }
  zle -N zle-line-finish
fi
# move by shell word {{{2
zsh-word-movement () {
  # see select-word-style for more
  local -a word_functions
  local f

  word_functions=(backward-kill-word backward-word
    capitalize-word down-case-word
    forward-word kill-word
    transpose-words up-case-word)

  if ! zle -l $word_functions[1]; then
    for f in $word_functions; do
      autoload -Uz $f-match
      zle -N zsh-$f $f-match
    done
  fi
  # set the style to shell
  zstyle ':zle:zsh-*' word-style shell
}
zsh-word-movement
unfunction zsh-word-movement
bindkey "\eB" zsh-backward-word
bindkey "\eF" zsh-forward-word
bindkey "\eW" zsh-backward-kill-word
# Esc-Esc 在当前/上一条命令前插入 sudo {{{2
sudo-command-line() {
    [[ -z $BUFFER ]] && zle up-history
    [[ $BUFFER != sudo\ * ]] && {
      typeset -a bufs
      bufs=(${(z)BUFFER})
      if (( $+aliases[$bufs[1]] )); then
        bufs[1]=$aliases[$bufs[1]]
      fi
      bufs=(sudo $bufs)
      BUFFER=$bufs
    }
    zle end-of-line
}
zle -N sudo-command-line
bindkey "\e\e" sudo-command-line
# 插入当前的所有补全 http://www.zsh.org/mla/users/2000/msg00601.html {{{2
_insert_all_matches () {
    setopt localoptions nullglob rcexpandparam extendedglob noshglob
    unsetopt markdirs globsubst shwordsplit nounset ksharrays
    compstate[insert]=all
    compstate[old_list]=keep
    _complete
}
zle -C insert-all-matches complete-word _insert_all_matches
bindkey '^Xi' insert-all-matches
# 别名 {{{1
# 命令别名 {{{2
alias ll='ls -lh'
alias la='ls -A'
if [[ $OS == 'Linux' ]]; then
  alias ls='ls --color=auto'
elif [[ $OS == 'FreeBSD' ]]; then
  alias ls='ls -G'
else
  alias ls='ls -F'
fi
if [[ $OS == 'Linux' || $OS == 'FreeBSD' ]]; then
  alias grep='grep --color=auto'
fi
alias n='nautilus --no-desktop'
alias py='python3'
alias svim="vim -i NONE"
alias rv='EDITOR="vim --servername GVIM --remote-tab-wait"'
alias :q="exit"
alias girl=man
alias woman=man
alias 7z="7z '-xr!*~' '-xr!*.swp'"
alias mytex=". ~/soft/context/tex/setuptex"
(( $+commands[zhcon] )) && alias zhcon="zhcon --utf8"
(( $+commands[luit] )) && alias gbk="luit -encoding gbk"
(( $+commands[rlwrap] )) && {
  (( $+commands[ilua] )) && alias ilua='rlwrap ilua'
  (( $+commands[psh] )) && alias psh='rlwrap psh'
}
(( $+commands[irb] )) && alias irb='irb -r irb/completion'
(( $+commands[ccal] )) && alias ccal='ccal -ub'
(( $+commands[zbarcam] )) && alias zbarcam='LD_PRELOAD=/usr/lib/libv4l/v4l1compat.so zbarcam'
(( $+commands[ghc] )) && alias ghc='ghc -i$HOME/scripts/haskell/lib'
(( $+commands[l] )) || alias l='locate'
(( $+commands[lre] )) || alias lre='locate -b --regex'
(( $+commands[lrew] )) || alias lrew='locate --regex'
(( $+commands[2to3] )) && alias py2to3="2to3 -w --no-diffs -n"
(( $+commands[you-get] )) && alias you-getp="you-get -p mpv"
(( $+commands[git] )) && alias gitc="git clone"
# GnuPG 2.1 and mutt don't play well
(( $+commands[mutt] )) && alias mutt="GPG_AGENT_INFO= mutt"
(( $+commands[openssl] )) && alias showcert='openssl x509 -text -noout -in'
(( $+commands[trans] )) && alias trans='proxychains -q trans'
(( $+commands[nvim] )) && alias nv=nvim
(( $+commands[mysql] )) && alias mysql='mysql --sigint-ignore'
(( $+commands[diff-so-fancy] )) && alias diff-so-fancy='diff-so-fancy | less'

# for systemd 230+
# see https://github.com/tmux/tmux/issues/428
if [[ $_has_re -eq 1 ]] && \
  (( $+commands[tmux] )) && (( $+commands[systemctl] )); then
  [[ $(systemctl --version) =~ 'systemd ([0-9]+)' ]] || true
  if [[ $match -ge 230 ]]; then
    tmux () {
      if command tmux has; then
        command tmux $@
      else
        systemd-run --user --scope tmux $@
      fi
    }
  fi
  unset match
fi

alias winxp="VBoxManage startvm WinXP"
alias winxp2="VBoxManage startvm WinXP_test"
alias dmount="udisksctl mount --block-device"
alias ren="vim +'Ren'"
# 查看进程数最多的程序
alias topnum="ps -e|sort -k4|awk '{print \$4}'|uniq -c|sort -n|tail"
alias soul="mplayer -really-quiet -nolirc -loop 0 ~/音乐/_纯音乐/忧伤还是快乐.mp3"
alias xcp="rsync -aviHAXKhP --delete --exclude='*~' --exclude=__pycache__"
alias mozrepl='socat readline tcp:127.0.0.1:4242'
alias nonet="HTTP_PROXY='http://localhost:1' HTTPS_PROXY='http://localhost:1' FTP_PROXY='http://localhost:1' http_proxy='http://localhost:1' https_proxy='http://localhost:1' ftp_proxy='http://localhost:1'"
alias fromgbk="iconv -t latin1 | iconv -f gb18030"
alias swaptop='watch -n 1 "swapview | tail -\$((\$LINES - 2)) | cut -b -\$COLUMNS"'

# for systemd {{{3
alias sysuser="systemctl --user"
function juser () {
  # sadly, this won't have nice completion
  typeset -a args
  integer nextIsService=0 isfirst
  for i; do
    if [[ $i == -u ]]; then
      nextIsService=1
    else
      if [[ $nextIsService -eq 1 ]]; then
        nextIsService=0
        isfirst=1
        for g in $(journalctl --user -F _SYSTEMD_CGROUP|command grep -P "^/user\\.slice/user-$UID\\.slice/user@$UID\\.service/$i\."); do
          if [[ isfirst -eq 1 ]]; then
            args=($args _SYSTEMD_CGROUP=$g)
          else
            args=($args + _SYSTEMD_CGROUP=$g)
          fi
          isfirst=0
        done
        if [[ isfirst -eq 1 ]]; then
          args=($args USER_UNIT=$i.service)
        else
          args=($args + USER_UNIT=$i.service)
        fi
      else
        args=($args $i)
      fi
    fi
  done
  journalctl -n $((${LINES:=40} - 4)) --user ${^args}
}
alias privoxy_log="juser -u privoxy -a -f | ssed -R 's/(?<=\]:) [\d-]+ [\d:.]+ [\da-f]+//'"

# 后缀别名 {{{2
alias -s xsl="vim"
alias -s {html,htm}="firefox"
alias -s {pdf,ps,djvu}="evince"
alias -s ttf="gnome-font-viewer"
alias -s {png,jpg,gif}="feh"
alias -s jar="java -jar"
alias -s swf="flashplayer"

# 路径别名 {{{2
hash -d tmp="$HOME/tmpfs"
hash -d py="$HOME/scripts/python"
hash -d ebook="$HOME/temp/ebook"
hash -d ff="$HOME/.mozilla/firefox/profile"

# 全局别名 {{{2
# 当前目录下最后修改的文件
# 来自 http://roylez.heroku.com/2010/03/06/zsh-recent-file-alias.html
alias -g NN="*(oc[1])"
alias -g NNF="*(oc[1].)"
alias -g NUL="/dev/null"
alias -g XS='"$(xsel)"'
alias -g ANYF='**/*[^~](.)'

# 函数 {{{1
autoload zargs
autoload zmv
TRAPTERM () { exit }
update () { . $_zdir/.zshrc }
if (( $+commands[vimtrace] )); then
  (( $+commands[strace] )) && alias strace='vimtrace strace'
  (( $+commands[ltrace] )) && alias ltrace='vimtrace ltrace'
else
  (( $+commands[strace] )) && strace () { (command strace "$@" 3>&1 1>&2 2>&3) | vim -R - }
  (( $+commands[ltrace] )) && ltrace () { (command ltrace "$@" 3>&1 1>&2 2>&3) | vim -R - }
fi
vman () { vim +"set ft=man" +"Man $*" }
song () { find ~/音乐 -iname "*$1*" }
mvpc () { mv $1 "`echo $1|ascii2uni -a J`" } # 将以 %HH 表示的文件名改正常
nocolor () { sed -r "s:\x1b\[[0-9;]*[mK]::g" }
sshpubkey () { tee < ~/.ssh/id_*.pub(om[1]) >(xsel -i) }
rmempty () { #删除空文件 {{{2
  for i; do
    [[ -f $i && ! -s $i ]] && rm $i
  done
  return 0
}
breakln () { #断掉软链接 {{{2
  for f in $*; do
    tgt=$(readlink "$f")
    unlink "$f"
    cp -r "$tgt" "$f"
  done
}
if [[ $TERM == screen* ]]; then # {{{2 设置标题
  # 注：不支持中文
  title () { echo -ne "\ek$*\e\\" }
else
  title () { echo -ne "\e]0;$*\a" }
fi
if [[ $TERM == xterm* || $TERM == *rxvt* ]]; then # {{{2 设置光标颜色
  cursorcolor () { echo -ne "\e]12;$*\007" }
elif [[ $TERM == screen* ]]; then
  if (( $+TMUX )); then
    cursorcolor () { echo -ne "\ePtmux;\e\e]12;$*\007\e\\" }
  else
    cursorcolor () { echo -ne "\eP\e]12;$*\007\e\\" }
  fi
fi
if [[ -d ${VIMTMP:=~/tmpfs} ]]; then # {{{2 gcc & g++
  gcc () { # {{{3
    errfile=$VIMTMP/.error
    command gcc -g -Wall "$@" >$errfile 2>&1
    ret=$?
    cat $errfile
    return $ret
  }
  g++ () { # {{{3
    errfile=$VIMTMP/.error
    command g++ -g -Wall "$@" >$errfile 2>&1
    ret=$?
    cat $errfile
    return $ret
  }
fi
2mp3 () { # 转换成 mp3 格式 {{{2
  [[ $# -ne 1 ]] && echo "Usage: $0 FILE" && return 1
  mplayer -vo null -vc dummy -af resample=44100 -ao pcm:waveheader "$1" && \
  lame -m s audiodump.wav -o "$1:r.mp3" && rm audiodump.wav || \
  {echo Failed. && return 2}
}
ptyrun () { # 使用伪终端代替管道，对 ls 这种“顽固分子”有效 {{{2
  local ptyname=pty-$$
  zmodload zsh/zpty
  zpty $ptyname "$@"
  if [[ ! -t 1 ]]; then
    setopt local_traps
    trap '' INT
  fi
  zpty -r $ptyname
  zpty -d $ptyname
}
ptyless () {
  ptyrun "$@" | tr -d $'\x0f' | less
}
clipboard2qr () { # 剪贴板数据到QR码 {{{2
  data="$(xsel)"
  echo $data
  echo $data | qrencode -t UTF8
}
mvgb () { # 文件名从 GB 转码，带确认{{{2
  for i in $*; do
    new="`echo $i|iconv -f utf8 -t latin1|iconv -f gbk`"
    echo $new
    echo -n 'Sure? '
    read -q ans && mv -i $i $new
    echo
  done
}
iip () { #{{{2
  qip=${1:-cip}
  echo -n "ip> "
  read ip
  while [[ $ip != 'q' ]]; do
    $qip $ip
    echo -n "ip> "
    read ip
  done
  unset ip
}
pid () { #{{{2
  s=0
  for i in $*; do
    echo -n "$i: "
    r=$(cat /proc/$i/cmdline|tr '\0' ' ' 2>/dev/null)
    if [[ $? -ne 0 ]]; then
      echo not found
      s=1
    else
      echo $r
    fi
  done
  return $s
}
s () { # 快速查找当前目录下的文件 {{{2
  name=$1
  shift
  find . -name "*$name*" "$@"
}
en () { # 使用 DNS TXT 记录的词典 {{{2
  # https://github.com/chuangbo/jianbing-dictionary-dns
  dig "$*.jianbing.org" +short txt | perl -pe's/\\(\d{1,3})/chr $1/eg; s/(^"|"$)//g'
}
shutdown () { #{{{2
  echo -n 你确定要关机吗？
  read i
  if [[ $i == [Yy] ]]; then
    systemctl poweroff
    # dbus-send --system --print-reply --dest=org.freedesktop.ConsoleKit /org/freedesktop/ConsoleKit/Manager org.freedesktop.ConsoleKit.Manager.Stop
  fi
}
killssh () { #{{{2 kill all ssh that using default master socket
  local key=$1
  local pids="$(netstat -nxlp 2>/dev/null | awk -v HOME=$HOME -v key=$key '{if(index($NF, HOME"/.ssh/master-"key) == 1){print $9}}' | grep -o '^[[:digit:]]\+')"
  [[ -n $pids ]] && kill ${=pids}
}

_killssh_items () {
  netstat -nxlp 2>/dev/null | awk -v HOME=$HOME 'BEGIN{P=HOME"/.ssh/master-";L=length(P);}{if(index($NF, P) == 1){a=substr($NF,L+1);sub(/\.[[:alnum:]]+$/,"",a);print a}}'
}

_killssh () {
  _arguments \
    ':what:($(_killssh_items))'
  return 0
}
compdef _killssh killssh
xmpphost () { #{{{2 query XMPP SRV records
  host -t SRV _xmpp-client._tcp.$1
  host -t SRV _xmpp-server._tcp.$1
}
tianqi () { #天气预报 {{{2
  local city
  if [[ $# -eq 1 ]]; then
    city=$1
  elif [[ $# -eq 0 ]]; then
    city=南京
  else
    echo "城市？" >&2
    return 1
  fi
  w3m -dump "http://weather1.sina.cn/dpool/weather_new/forecast_new.php?city=$city&vt=4" 2>/dev/null | sed '1,/更换城市/d;/^loading/,$d;s/\[[^]]\+\]//g'
}
yuntu_url () { #最新卫星云图 {{{2
  curl -s --compressed http://www.weather.com.cn/static/product_video_v1.php\?class\=JC_YT_DL_WXZXCSYT | grep -E 'sevp_nsmc_wxcl_asc_e99_achn_lno_py_(.+)? w' | cut -c62-157
}
yuniodl () { #下载云诺分享文件 {{{2
  token=$1
  [[ -z $token ]] && return 1
  wget -c --header "Referer: http://s.yunio.com/$token" http://s.yunio.com/publiclink/download/"$token?&path=&type=none&name="
}
duppkg4repo () { #软件仓库中重复的软件包 {{{2
  local repo=$1
  [[ -z $repo ]] && { echo >&2 'which repository to examine?'; return 1 }
  local pkgs
  pkgs=$(comm -12 \
    <(pacman -Sl $repo|awk '{print $2}'|sort) \
    <(pacman -Sl|awk -vrepo=$repo '$1 != repo {print $2}'|sort) \
  )
  [[ -z $pkgs ]] && return 0
  LANG=C pacman -Si ${=pkgs} | awk -vself=$repo '/^Repository/{ repo=$3; } /^Name/ && repo != self { printf("%s/%s\n", repo, $3); }'
}
try_until_succeed () { #反复重试，直到成功 {{{2
  while ! $*; do :; done
}
testgoogleip () { # {{{2
  url=$1
  ip=$2
  host=${${url#*//}%%/*}
  curl -v -i --resolve $host:80:$ip --resolve $host:443:$ip $url
}
install_autojump () { # autojump 快速安装 {{{2
  mkdir -p ~/.local/bin ${_zdir}/.zsh/Completion
  pushd ~/.local/bin > /dev/null
  wget -N https://github.com/joelthelion/autojump/raw/master/bin/autojump{,_{data,argparse,utils}.py}
  chmod +x autojump
  popd > /dev/null
  wget https://github.com/joelthelion/autojump/raw/master/bin/autojump.zsh -O ${_zdir}/.zsh/autojump.zsh
  wget https://github.com/joelthelion/autojump/raw/master/bin/_j -O ${_zdir}/.zsh/Completion/_j
}
# 变量设置 {{{1
# re-tie fails for zsh 4
export -TU PYTHONPATH pythonpath 2>/dev/null
export -U PATH
# don't export FPATH
typeset -U FPATH
(( -z $MAKEFLAGS && $+commands[nproc] )) && export MAKEFLAGS=-j$(nproc)
(( -z $EDITOR && $+commands[vim] )) && export EDITOR=vim

[[ -f $_zdir/.zsh/zshrc.local ]] && source $_zdir/.zsh/zshrc.local
# zsh{{{2
# 提示符
# %n --- 用户名
# %~ --- 当前目录
# %h --- 历史记录号
# git 分支显示 {{{3

if (( $+commands[git] )); then
  _nogit_dir=()
  for p in $nogit_dir; do
    [[ -d $p ]] && _nogit_dir+=$(realpath $p)
  done
  unset p

  _setup_current_branch_async () { # {{{4
    typeset -g _current_branch= vcs_info_fd=
    zmodload zsh/zselect 2>/dev/null

    _vcs_update_info () {
      eval $(read -rE -u$1)
      zle -F $1 && vcs_info_fd=
      exec {1}>&-
      # update prompt only when necessary to avoid double first line
      [[ -n $_current_branch ]] && zle reset-prompt
    }

    _set_current_branch () {
      _current_branch=
      [[ -n $vcs_info_fd ]] && zle -F $vcs_info_fd
      cwd=$(pwd -P)
      for p in $_nogit_dir; do
        if [[ $cwd == $p* ]]; then
          return
        fi
      done

      setopt localoptions no_monitor
      coproc {
        _br=$(git branch --no-color 2>/dev/null)
        if [[ $? -eq 0 ]]; then
          _current_branch=$(echo $_br|awk '$1 == "*" {print "%{\x1b[33m%} (" substr($0, 3) ")"}')
        fi
        # always gives something for reading, or _vcs_update_info won't be
        # called, fd not closed
        #
        # "typeset -p" won't add "-g", so reprinting prompt (e.g. after status
        # of a bg job is printed) would miss it
        #
        # need to substitute single ' with double ''
        print "typeset -g _current_branch='${_current_branch//''''/''}'"
      }
      disown %{\ _br
      exec {vcs_info_fd}<&p
      # wait 0.1 seconds before showing up to avoid unnecessary double update
      # precmd functions are called *after* prompt is expanded, and we can't call
      # zle reset-prompt outside zle, so turn to zselect
      zselect -r -t 10 $vcs_info_fd 2>/dev/null
      zle -F $vcs_info_fd _vcs_update_info
    }
  }

  _setup_current_branch_sync () { # {{{4
    _set_current_branch () {
      _current_branch=
      cwd=$(pwd -P)
      for p in $_nogit_dir; do
        if [[ $cwd == $p* ]]; then
          return
        fi
      done

      _br=$(git branch --no-color 2>/dev/null)
      if [[ $? -eq 0 ]]; then
        _current_branch=$(echo $_br|awk '{if($1 == "*"){print "%{\x1b[33m%} (" substr($0, 3) ")"}}')
      fi
    }
  } # }}}

  if [[ $_has_re -ne 1 ||
    $ZSH_VERSION =~ '^[0-4]\.' || $ZSH_VERSION =~ '^5\.0\.[0-5]' ]]; then
    # zsh 5.0.5 has a CPU 100% bug with zle -F
    _setup_current_branch_sync
  else
    _setup_current_branch_async
  fi
  typeset -gaU precmd_functions
  precmd_functions+=_set_current_branch
fi
# }}}3
[[ -n $ZSH_PS_HOST && $ZSH_PS_HOST != \(*\)\  ]] && ZSH_PS_HOST="($ZSH_PS_HOST) "

setopt PROMPT_SUBST
E=$'\x1b'
# reset on the second line to make it the same in tmux + ncurses 6.0
PS1="%{${E}[2m%}%h $ZSH_PS_HOST%(?..%{${E}[1;31m%}%?%{${E}[0m%} )%{${E}[2;32m%}%~\$_current_branch
%{${E}[0m%}%(!.%{${E}[0;31m%}###.%{${E}[1;34m%}>>>)%{${E}[0m%} "
# 次提示符：使用暗色
PS2="%{${E}[2m%}%_>%{${E}[0m%} "
# 右边的提示
RPS1="%(1j.%{${E}[1;33m%}%j .)%{${E}[m%}%T"
unset E

CORRECT_IGNORE='_*'
READNULLCMD=less
watch=(notme root)
WATCHFMT='%n has %a %l from %M'
REPORTTIME=5

# TeX{{{2
export TEXMFCACHE=${XDG_CACHE_HOME:-$HOME/.cache}
export OSFONTDIR=$HOME/.fonts:/usr/share/fonts/TTF

# gstreamer mp3 标签中文设置{{{2
export GST_ID3_TAG_ENCODING=GB18030:UTF-8
export GST_ID3V2_TAG_ENCODING=GB18030:UTF-8

# 图形终端下(包括ssh登录时)的设置{{{2
if [[ -n $DISPLAY ]]; then
  export AGV_EDITOR='vv "$file:$line:$col"'
else
  export AGV_EDITOR='vim +"call setpos(\".\", [0, $line, $col, 0])" "$file"'
fi
# 默认浏览器
if [[ -n $DISPLAY && -z $SSH_CONNECTION ]]; then
  export BROWSER=firefox
  export wiki_browser=firefox
fi
if [[ -n $DISPLAY || -n $SSH_CONNECTION ]]; then
  # 让 less 将粗体/下划线等显示为彩色
  export LESS_TERMCAP_mb=$'\x1b[01;31m'
  export LESS_TERMCAP_md=$'\x1b[01;38;5;74m'
  export LESS_TERMCAP_me=$'\x1b[0m'
  export LESS_TERMCAP_se=$'\x1b[0m'
  export LESS_TERMCAP_so=$'\x1b[7m'
  export LESS_TERMCAP_ue=$'\x1b[0m'
  export LESS_TERMCAP_us=$'\x1b[04;38;5;146m'

  if [[ $TERM == linux ]]; then
    _256colors=0
  else
    [[ $TERM != *color* ]] && export TERM=${TERM%%[.-]*}-256color
    _256colors=1
  fi
else
  # tty 下光标显示为块状
  echo -ne "\e[?6c"
  zshexit () {
    [[ $SHLVL -eq 1 ]] && echo -ne "\e[?0c"
  }
  [[ $TERM == *color* ]] && _256colors=1
fi
if [[ $OS = Linux ]]; then
  # under fbterm
  # can't see parent on some restricted systems
  if [[ $_has_re -eq 1 &&
    $(</proc/$PPID/cmdline) =~ '(^|/)fbterm' ]] 2>/dev/null; then
    export TERM=fbterm
    export LANG=zh_CN.UTF-8
    # This term is quirk. ls doesn't like it.
    # _256colors=1
  fi
  if [[ $_256colors -eq 1 ]]; then
    export LS_COLORS='rs=0:di=38;5;27:ln=38;5;51:mh=44;38;5;15:pi=40;38;5;11:so=38;5;13:do=38;5;5:bd=48;5;232;38;5;11:cd=48;5;232;38;5;3:or=48;5;232;38;5;9:mi=05;48;5;232;38;5;15:su=48;5;196;38;5;15:sg=48;5;11;38;5;16:ca=48;5;196;38;5;226:tw=48;5;10;38;5;16:ow=48;5;10;38;5;21:st=48;5;21;38;5;15:ex=38;5;34:*.tar=38;5;9:*.tgz=38;5;9:*.arc=38;5;9:*.arj=38;5;9:*.taz=38;5;9:*.lha=38;5;9:*.lzh=38;5;9:*.lzma=38;5;9:*.tlz=38;5;9:*.txz=38;5;9:*.tzo=38;5;9:*.t7z=38;5;9:*.zip=38;5;9:*.z=38;5;9:*.Z=38;5;9:*.dz=38;5;9:*.gz=38;5;9:*.lrz=38;5;9:*.lz=38;5;9:*.lzo=38;5;9:*.xz=38;5;9:*.bz2=38;5;9:*.bz=38;5;9:*.tbz=38;5;9:*.tbz2=38;5;9:*.tz=38;5;9:*.deb=38;5;9:*.rpm=38;5;9:*.jar=38;5;9:*.war=38;5;9:*.ear=38;5;9:*.sar=38;5;9:*.rar=38;5;9:*.alz=38;5;9:*.ace=38;5;9:*.zoo=38;5;9:*.cpio=38;5;9:*.7z=38;5;9:*.rz=38;5;9:*.cab=38;5;9:*.jpg=38;5;13:*.JPG=38;5;13:*.jpeg=38;5;13:*.gif=38;5;13:*.bmp=38;5;13:*.pbm=38;5;13:*.pgm=38;5;13:*.ppm=38;5;13:*.tga=38;5;13:*.xbm=38;5;13:*.xpm=38;5;13:*.tif=38;5;13:*.tiff=38;5;13:*.png=38;5;13:*.svg=38;5;13:*.svgz=38;5;13:*.mng=38;5;13:*.pcx=38;5;13:*.mov=38;5;13:*.mpg=38;5;13:*.mpeg=38;5;13:*.m2v=38;5;13:*.mkv=38;5;13:*.ogm=38;5;13:*.mp4=38;5;13:*.m4v=38;5;13:*.mp4v=38;5;13:*.vob=38;5;13:*.qt=38;5;13:*.nuv=38;5;13:*.wmv=38;5;13:*.asf=38;5;13:*.rm=38;5;13:*.rmvb=38;5;13:*.flc=38;5;13:*.avi=38;5;13:*.fli=38;5;13:*.flv=38;5;13:*.webm=38;5;13:*.gl=38;5;13:*.dl=38;5;13:*.xcf=38;5;13:*.xwd=38;5;13:*.yuv=38;5;13:*.cgm=38;5;13:*.emf=38;5;13:*.axv=38;5;13:*.anx=38;5;13:*.ogv=38;5;13:*.ogx=38;5;13:*.aac=38;5;45:*.au=38;5;45:*.flac=38;5;45:*.mid=38;5;45:*.midi=38;5;45:*.mka=38;5;45:*.mp3=38;5;45:*.m4a=38;5;45:*.mpc=38;5;45:*.ogg=38;5;45:*.opus=38;5;45:*.3gp=38;5;45:*.ra=38;5;45:*.wav=38;5;45:*.axa=38;5;45:*.oga=38;5;45:*.spx=38;5;45:*.xspf=38;5;45:'
  else
    (( $+commands[dircolors] )) && eval "$(dircolors -b)"
  fi
  zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
fi
unset _256colors
unset _has_re
# 不同的 OS {{{2
if [[ $OS != *BSD ]]; then
  # FreeBSD 和 OpenBSD 上，MANPATH 会覆盖默认的配置
  [[ -d $HOME/.cabal/share/man ]] && export MANPATH=:$HOME/.cabal/share/man
elif [[ $OS = FreeBSD ]]; then
  export PAGER=less
fi

# 其它程序 {{{2
AUTOJUMP_KEEP_SYMLINKS=1
export LESS="-FRXM"
# default has -S
export SYSTEMD_LESS="${LESS#-}K"

# 其它 {{{1

# When starting as a non-login shell
[[ -z $functions[j] && -f /etc/profile.d/autojump.zsh ]] && source /etc/profile.d/autojump.zsh
# Debian Wheezy
[[ -z $functions[j] && -f /usr/share/autojump/autojump.zsh ]] && source /usr/share/autojump/autojump.zsh
[[ -z $functions[j] && -f ${_zdir}/.zsh/autojump.zsh ]] && source ${_zdir}/.zsh/autojump.zsh

unset OS
setopt nomatch
return 0

# Public link: https://github.com/lilydjwg/dotzsh

# vim:fdm=marker
