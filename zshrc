# 基本设置 {{{1
_zdir=${ZDOTDIR:-$HOME}
HISTFILE=${_zdir}/.histfile
HISTSIZE=10000
SAVEHIST=10000

zstyle :compinstall filename "$_zdir/.zshrc"
if [[ -z $SUDO_UID ]]; then
  fpath=($_zdir/.zsh/Completion $_zdir/.zsh/functions $fpath)
fi
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
stty -ixon # 上一行在 tmux 中时常不起作用
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
zstyle ':completion:*:warnings' format $'\e[91m -- No Matches Found --\e[0m'
# 描述显示为淡色
zstyle ':completion:*:descriptions' format $'\e[2m -- %d --\e[0m'
zstyle ':completion:*:corrections' format $'\e[93m -- %d (errors: %e) --\e[0m'

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
# zstyle ':completion:*' show-ambiguity '97'
# _extensions 为 *. 补全扩展名
# 在最后尝试使用文件名
if [[ $ZSH_VERSION =~ '^[0-4]\.' || $ZSH_VERSION =~ '^5\.0\.[0-5]' ]]; then
  zstyle ':completion:*' completer _complete _match _approximate _expand_alias _ignored _files
else
  zstyle ':completion:*' completer _complete _extensions _match _approximate _expand_alias _ignored _files
fi
# 修正大小写
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'
zstyle -e ':completion:*' special-dirs \
  '[[ $PREFIX == (../)#(|.|..) ]] && reply=(..)'
# 使用缓存。某些命令的补全很耗时的（如 aptitude）
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ${XDG_CACHE_HOME:-$HOME/.cache}/zsh

# complete user-commands for git-*
# https://pbrisbin.com/posts/deleting_git_tags_with_style/
zstyle ':completion:*:*:git:*' user-commands ${${(M)${(k)commands}:#git-*}/git-/}
zstyle ':completion:*:*:git:*' user-commands subrepo:'perform git-subrepo operations'

compdef pkill=killall
compdef pgrep=killall
compdef proxychains=command
compdef watch=command
compdef rlwrap=command
compdef ptyless=command
compdef grc=command
compdef rgg=rg 2>/dev/null
# not only pdf files
compdef -d evince
compdef _gnu_generic exa pamixer

# 我的自动补全 {{{2
zstyle ':completion:*:*:pdf2png:*' file-patterns \
  '*.pdf:pdf-files:pdf\ files *(-/):directories:directories'
zstyle ':completion:*:*:x:*' file-patterns \
  '*.{7z,bz2,gz,rar,tar,tbz,tgz,zip,chm,xz,zst,exe,xpi,apk,maff,crx,deb}:compressed-files:compressed\ files *(-/):directories:directories'
zstyle ':completion:*:*:evince:*' file-patterns \
  '*.{pdf,ps,eps,dvi,djvu,pdf.gz,ps.gz,dvi.gz}:documents:documents *(-/):directories:directories'
zstyle ':completion:*:*:gbkunzip:*' file-patterns '*.zip:zip-files:zip\ files *(-/):directories:directories'
zstyle ':completion:*:*:flashplayer:*' file-patterns '*.swf'
zstyle ':completion:*:*:hp2ps:*' file-patterns '*.hp'
zstyle ':completion:*:*:swayimg:*' file-patterns '*.{png,gif,jpg,JPG,svg,webp,avif,tiff,psd}:images:images *(-/):directories:directories'
zstyle ':completion:*:*:timidity:*' file-patterns '*.mid'

# .zfs handling {{{2
if [[ -f /proc/self/mountinfo ]]; then
  _get_zfs_fake_files () {
    reply=($(awk -vOFS=: -vORS=' ' '$9 == "zfs" && $7 !~ /^master:/ { print $5, ".zfs" }' /proc/self/mountinfo))
  }
  zstyle -e ':completion:*' fake-files _get_zfs_fake_files
fi
# 接受路径中已经匹配的中间项，这将支持 .zfs 隐藏目录
# zstyle ':completion:*' accept-exact-dirs true
# 命令行编辑{{{1
bindkey -e

# ^Xe 用$EDITOR编辑命令
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

zle -C complete-file menu-expand-or-complete _generic
zstyle ':completion:complete-file:*' completer _files

# https://archive.zhimingwang.org/blog/2015-09-21-zsh-51-and-bracketed-paste.html
autoload -Uz bracketed-paste-url-magic
zle -N bracketed-paste bracketed-paste-url-magic

# zsh 5.1+ uses bracketed-paste-url-magic
if [[ $ZSH_VERSION =~ '^[0-4]\.' || $ZSH_VERSION =~ '^5\.0\.[0-9]' ]]; then
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
fi

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
bindkey "^Xo" accept-and-infer-next-history

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
bindkey '^[w' kill-region
# 用单引号引起最后一个单词
bindkey -s "^['" "^[] ^f^@^e^[\""
# 打开 zsh 的PDF格式文档
bindkey -s "^X^D" "evince /usr/share/doc/zsh/zsh.pdf &^M"
bindkey -s "^Xc" "tmux attach -d^M"

bindkey '^[p' up-line-or-search
bindkey '^[n' down-line-or-search

# add a command line to the shells history without executing it
commit-to-history () {
  print -s ${(z)BUFFER}
  zle send-break
}
zle -N commit-to-history
bindkey -M viins "^x^h" commit-to-history
bindkey -M emacs "^x^h" commit-to-history

() {
  setopt localoptions nullglob
  local p name
  for p in $fpath; do
    for name in $p/run-help-*; do
      autoload -Uz $name:t
    done
  done
}

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
bindkey "\eD" zsh-kill-word
# Esc-Esc 在当前/上一条命令前插入 sudo {{{2
sudo-command-line() {
    [[ -z $BUFFER ]] && zle up-history
    [[ $BUFFER != sudo\ * && $UID -ne 0 ]] && {
      typeset -a bufs
      bufs=(${(z)BUFFER})
      while (( $+aliases[$bufs[1]] )); do
        local expanded=(${(z)aliases[$bufs[1]]})
        bufs[1,1]=($expanded)
        if [[ $bufs[1] == $expanded[1] ]]; then
          break
        fi
      done
      bufs=(sudo $bufs)
      BUFFER=$bufs
    }
    zle end-of-line
}
zle -N sudo-command-line
bindkey "\e\e" sudo-command-line
# 插入当前的所有补全 https://www.zsh.org/mla/workers/2020/msg01232.html {{{2
zstyle ':completion:all-matches::::' completer _all_matches _complete
zstyle ':completion:all-matches:*' old-matches true
zstyle ':completion:all-matches:*' insert true
zstyle ':completion:all-matches:*' file-patterns '%p:globbed-files' '*(-/):directories' '*:all-files'
zle -C all-matches complete-word _generic
bindkey '^Xi' all-matches
# 别名 {{{1
# 命令别名 {{{2
alias ll='ls -lh'
alias la='ls -A'
if [[ $OS == 'Linux' ]]; then
  alias ls='ls --color=auto'
elif [[ $OS == 'FreeBSD' ]]; then
  alias ls='ls -G'
elif (( $+commands[colorls] )); then
  alias ls='colorls -G'
else
  alias ls='ls -F'
fi
if [[ $OS == 'Linux' || $OS == 'FreeBSD' ]]; then
  alias grep='grep --color=auto'
fi
alias diff='diff --color=auto'
alias n='thunar'
alias py='python3'
alias nb='numbat'
alias svim="vim -i NONE"
alias rv='EDITOR="vim --servername GVIM --remote-tab-wait"'
alias :q="exit"
alias girl=man
alias woman=man
alias 7z="7z '-xr!*~' '-xr!*.swp'"
alias pvv="pv -F '%N %b %t cur %r avg %a %p %e'"
(( $+commands[zhcon] )) && alias zhcon="zhcon --utf8"
(( $+commands[rlwrap] )) && {
  (( $+commands[ilua] )) && alias ilua='rlwrap ilua'
}
(( $+commands[irb] )) && alias irb='irb -r irb/completion'
(( $+commands[ccal] )) && alias ccal='ccal -ub'
if (( $+commands[plocate] )); then
  mylocate=plocate
else
  mylocate=locate
fi
(( $+commands[l] )) || alias l=$mylocate
(( $+commands[lre] )) || alias lre="$mylocate -b --regex"
(( $+commands[lrew] )) || alias lrew="$mylocate --regex"
(( $+commands[git] )) && alias gitc="git clone"
(( $+commands[git] )) && alias git-export="git daemon --export-all --base-path= --reuseaddr --"
(( $+commands[openssl] )) && {
  alias showcert='openssl x509 -text -noout -in'
  showcert_for_domain () {
    local domain=$1
    openssl s_client -connect $domain:443 -servername $domain <<<'' | ascii2uni -qa7
  }
}
(( $+commands[swayimg] )) && alias imv=swayimg

(( $+commands[exa] )) && {
  xtree () {
    exa -Tl --color=always "$@" | less
  }
}

(( $+commands[ip] )) && alias ip="ip -c"
(( $+commands[ffprobe] )) && alias ffprobe="ffprobe -hide_banner"
(( $+commands[ffmpeg] )) && alias ffmpeg="ffmpeg -hide_banner"

# grc aliases
if (( $+aliases[colourify] )); then
  # default is better
  unalias gcc g++ 2>/dev/null || true
  # bug: https://github.com/garabik/grc/issues/72
  unalias mtr     2>/dev/null || true
  # buffering issues: https://github.com/garabik/grc/issues/25
  unalias ping    2>/dev/null || true
fi

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

_makepkg_prefix=(
  bwrap --unshare-all --share-net --die-with-parent
  --ro-bind /usr /usr --ro-bind /opt /opt --ro-bind /etc /etc --proc /proc --dev /dev --tmpfs /tmp
  --symlink usr/bin /bin --symlink usr/bin /sbin --symlink usr/lib /lib --symlink usr/lib /lib64
  --ro-bind /var/lib/pacman /var/lib/pacman --bind ~/.cache ~/.cache
  --bind ~/.makepkg/gnupg ~/.gnupg
  # work around https://github.com/containers/bubblewrap/issues/395#issuecomment-771159189
  --setenv FAKEROOTDONTTRYCHOWN 1
)
_makepkg_setup () {
  mkdir -m 700 -p ~/.makepkg/gnupg
  # ${_makepkg_prefix[@]} --bind $PWD $PWD "$@"
  ${_makepkg_prefix[@]} --bind $PWD /build --chdir /build "$@"
}
makepkg () {
  _makepkg_setup /usr/bin/makepkg "$@"
}
compdef makepkg=makepkg
updpkgsums () {
  _makepkg_setup /usr/bin/updpkgsums
}
makepkg-recvkeys () {
  _makepkg_setup /usr/bin/bash <<'EOF'
. /usr/share/makepkg/util.sh
. ./PKGBUILD
for key in "${validpgpkeys[@]}"; do
  echo "Receiving key ${key}..."
  # try both servers as some keys exist one place and others another
  # we also want to always try to receive keys to pick up any update
  gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys "$key" || true
  gpg --keyserver hkps://keys.openpgp.org --recv-keys "$key" || true
done
EOF
}

if (( $+commands[npm] )); then
  alias npm="bwrap --unshare-all --share-net --die-with-parent \
    --ro-bind /usr /usr --ro-bind /etc /etc --proc /proc --dev /dev --tmpfs /tmp \
    --symlink usr/bin /bin --symlink usr/bin /sbin --symlink usr/lib /lib --symlink usr/lib /lib64 \
    --ro-bind ~/.npmrc ~/.npmrc --bind ~/.cache/npm ~/.cache/npm \
    --bind \$PWD \$PWD \
    npm"
  alias npx="bwrap --unshare-all --share-net --die-with-parent \
    --ro-bind /usr /usr --ro-bind /etc /etc --proc /proc --dev /dev --tmpfs /tmp \
    --symlink usr/bin /bin --symlink usr/bin /sbin --symlink usr/lib /lib --symlink usr/lib /lib64 \
    --ro-bind ~/.npmrc ~/.npmrc --bind ~/.cache/npm ~/.cache/npm \
    --bind \$PWD \$PWD \
    npx"
fi

cargo-build () {
  cargo fetch --target x86_64-unknown-linux-gnu
  bwrap --unshare-all --die-with-parent \
    --ro-bind /usr /usr --ro-bind /etc /etc --proc /proc --dev /dev --tmpfs /tmp \
    --symlink usr/bin /bin --symlink usr/bin /sbin --symlink usr/lib /lib --symlink usr/lib /lib64 \
    --bind ~/.cargo ~/.cargo --bind-try ~/.rustup ~/.rustup --bind ~target ~target \
    --bind $PWD $PWD \
    cargo build "$@"
}

alias nicest="chrt -i 0 ionice -c3"
alias ren="vim +'Ren'"
# --inplace has issues with -H https://lists.opensuse.org/opensuse-bugs/2012-10/msg02084.html
alias xcp="rsync -aviHAXKhS --one-file-system --partial --info=progress2 --atimes --open-noatime --delete --exclude='*~' --exclude=__pycache__"
alias fromgbk="iconv -t latin1 | iconv -f gb18030"
alias swaptop='watch -n 1 "swapview | tail -\$((\$LINES - 2)) | cut -b -\$COLUMNS"'
alias pkg-check='comm -23 <(pacman -Qettq|sort) <(awk ''$1 != "#" {print $1}'' ~/etc/pkg-why|sort)'
alias pkg-check-old='comm -13 <(pacman -Qq|sort) <(awk ''$1 != "#" {print $1}'' ~/etc/pkg-why|sort)'
alias with-github-name='GIT_COMMITTER_NAME=依云 GIT_COMMITTER_EMAIL=lilydjwg@gmail.com GIT_AUTHOR_NAME=依云 GIT_AUTHOR_EMAIL=lilydjwg@gmail.com'

if (( $+commands[uniclip] )); then
  alias xs="uniclip"
fi

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
        if [[ $i != *.* ]]; then
          i=$i.service
        fi
        if [[ isfirst -eq 1 ]]; then
          args=($args USER_UNIT=$i + _SYSTEMD_USER_UNIT=$i)
        else
          args=($args + USER_UNIT=$i + _SYSTEMD_USER_UNIT=$i)
        fi
      else
        args=($args $i)
      fi
    fi
  done
  journalctl --user ${^args}
}

# 路径别名 {{{2
hash -d tmp="$HOME/tmpfs"
hash -d py="$HOME/scripts/python"
hash -d ff="$HOME/.mozilla/firefox/nightly"

# 全局别名 {{{2
# 当前目录下最后修改的文件
# 来自 https://roylez.info/2010/03/06/zsh-recent-file-alias.html/
alias -g NN="*(oc[1])"
alias -g NNF="*(oc[1].)"
alias -g NND="*(oc[1]/)"
alias -g NUL="/dev/null"
alias -g XS='"$(uniclip)"'
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
  (( $+commands[strace] )) && function strace () { (command strace "$@" 3>&1 1>&2 2>&3) | vim -R - }
  (( $+commands[ltrace] )) && function ltrace () { (command ltrace "$@" 3>&1 1>&2 2>&3) | vim -R - }
fi
song () { find ~/音乐 -iname "*$1*" }
mvpc () { mv -- $1 "$(echo $1|ascii2uni -a J|tr '/' '-')" } # 将以 %HH 表示的文件名改正常
nocolor () { sed -r 's:\x1b\[[0-9;]*[mK]::g;s:[\r\x0f]::g' }
sshpubkey () { tee < ~/.ssh/id_*.pub(om[1]) >(uniclip -i) }
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
    cp -rL "$tgt" "$f"
  done
}
if [[ $TERM == screen* || $TERM == tmux* ]]; then # {{{2 设置标题
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
elif [[ $TERM == tmux* ]]; then
  cursorcolor () { echo -ne "\ePtmux;\e\e]12;$*\007\e\\" }
fi
ptyrun () { # 使用伪终端代替管道，对 ls 这种“顽固分子”有效 {{{2
  local ptyname=pty-$$
  zmodload zsh/zpty
  zpty $ptyname "${(q)@}"
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
  data="$(uniclip)"
  echo $data
  echo $data | qrencode -t UTF8
}
# 剪贴板图像格式互转 {{{2
clipboard_bmp2png () { # 将剪贴板中的图片从 bmp 转到 png。QQ 会使用 bmp
  uniclip --clipboard -t image/bmp | convert - png:- | uniclip -i --clipboard -t image/png
}
clipboard_png2bmp () { # 将剪贴板中的图片从 png 转到 bmp。QQ 会使用 bmp
  uniclip --clipboard -t image/png | convert - bmp:- | uniclip -i --clipboard -t image/bmp
}
mvgb () { # 文件名从 GB 转码，带确认{{{2
  for i in $*; do
    new="$(echo $i|iconv -f utf8 -t latin1|iconv -f gbk)"
    echo $new
    echo -n 'Sure? '
    read -q ans && mv -i $i $new
    echo
  done
}
pid () { #{{{2
  s=0
  for i in $*; do
    i=${i/,/}
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
# s () { 快速查找当前目录下的文件 {{{2
s () {
  find . -name "*$1*"
}
xmpphost () { #{{{2 query XMPP SRV records
  host -t SRV _xmpp-client._tcp.$1
  host -t SRV _xmpp-server._tcp.$1
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
try_until_success () { #反复重试，直到成功 {{{2
  local i=1
  while true; do
    echo "Try $i at $(date)."
    $* && break
    (( i+=1 ))
    echo
  done
}
compdef try_until_success=command
wait_pid () { # {{{2
  local pid=$1
  while true; do
    if [[ -d /proc/$pid ]]; then
      sleep 3
    else
      break
    fi
  done
}
# 变量设置 {{{1
# re-tie fails for zsh 4
export -TU PYTHONPATH pythonpath 2>/dev/null
export -U PATH
# don't export FPATH
typeset -U FPATH
[[ -z $MAKEFLAGS ]] && (( $+commands[nproc] )) && {
  local n=$(nproc)
  export MAKEFLAGS="-j$n -l$n"
}
[[ -z $EDITOR ]] && (( $+commands[vim] )) && export EDITOR=vim

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
      # on NFS this will print an error: "Failed to get current directory: path invalid"
      cwd=$(pwd -P 2>/dev/null)
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
      disown %{\ _br 2>/dev/null
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
PS1="%{${E}[2m%}%h $ZSH_PS_HOST%(?..%{${E}[91m%}%?%{${E}[0m%} )%{${E}[2;32m%}%~\$_current_branch
%{${E}[0m%}%(!.%{${E}[0;31m%}###.%{${E}[94m%}>>>)%{${E}[0m%} "
# 次提示符：使用暗色
PS2="%{${E}[2m%}%_>%{${E}[0m%} "
# 右边的提示
RPS1="%(1j.%{${E}[93m%}%j .)%{${E}[m%}%T"
unset E

CORRECT_IGNORE='_*'
READNULLCMD=less
watch=(notme root)
WATCHFMT='%n has %a %l from %M'
REPORTTIME=5

() { # TIMEFMT {{{3
  local white_b=$'\e[97m' blue=$'\e[94m' rst=$'\e[0m'
  TIMEFMT=("== TIME REPORT FOR $white_b%J$rst =="$'\n'
    "  User: $blue%U$rst"$'\t'"System: $blue%S$rst  Total: $blue%*Es${rst}"$'\n'
    "  CPU:  $blue%P$rst"$'\t'"Mem:    $blue%M MiB$rst")
}

# gstreamer mp3 标签中文设置{{{2
export GST_ID3_TAG_ENCODING=GB18030:UTF-8
export GST_ID3V2_TAG_ENCODING=GB18030:UTF-8

# 色彩相关设置等{{{2
if [[ -n $DISPLAY && -z $SSH_CONNECTION ]]; then
  export BROWSER=firefox-nightly
  export wiki_browser=firefox-nightly
  export AGV_EDITOR='vv ''$file:$line:$col'''
else
  export AGV_EDITOR='vim +"call setpos(\".\", [0, $line, $col, 0])" ''$file'''
fi

# 让 less 将粗体/下划线等显示为彩色
export LESS_TERMCAP_mb=$'\x1b[91m'
export LESS_TERMCAP_md=$'\x1b[38;5;74m'
export LESS_TERMCAP_me=$'\x1b[0m'
export LESS_TERMCAP_se=$'\x1b[0m'
export LESS_TERMCAP_so=$'\x1b[7m'
export LESS_TERMCAP_ue=$'\x1b[0m'
export LESS_TERMCAP_us=$'\x1b[04;38;5;146m'
# man 手册支持彩色
export GROFF_NO_SGR=1

if [[ $TERM == linux ]]; then
  _256colors=0
  # tty 下光标显示为块状
  echo -ne "\e[?6c"
  zshexit () {
    [[ $SHLVL -eq 1 ]] && echo -ne "\e[?0c"
  }
elif [[ $TERM == *color* ]]; then
  _256colors=1
else
  [[ $TERM != alacritty && $TERM != foot && $TERM != dumb ]] && export TERM=${TERM%%[.-]*}-256color
  _256colors=1
fi
if [[ $OS = Linux ]]; then
  if [[ $_256colors -eq 1 ]]; then
    export LS_COLORS='rs=0:di=38;5;27:ln=38;5;51:mh=44;38;5;15:pi=40;38;5;11:so=38;5;13:do=38;5;5:bd=48;5;232;38;5;11:cd=48;5;232;38;5;3:or=48;5;232;38;5;9:mi=05;48;5;232;38;5;15:su=48;5;196;38;5;15:sg=48;5;11;38;5;16:ca=48;5;196;38;5;226:tw=48;5;10;38;5;16:ow=48;5;10;38;5;21:st=48;5;21;38;5;15:ex=38;5;34:*.tar=38;5;9:*.tgz=38;5;9:*.arc=38;5;9:*.arj=38;5;9:*.taz=38;5;9:*.lha=38;5;9:*.lzh=38;5;9:*.lzma=38;5;9:*.tlz=38;5;9:*.txz=38;5;9:*.tzo=38;5;9:*.t7z=38;5;9:*.zip=38;5;9:*.z=38;5;9:*.Z=38;5;9:*.dz=38;5;9:*.gz=38;5;9:*.lrz=38;5;9:*.lz=38;5;9:*.lzo=38;5;9:*.xz=38;5;9:*.zst=38;5;9:*.bz2=38;5;9:*.bz=38;5;9:*.tbz=38;5;9:*.tbz2=38;5;9:*.tz=38;5;9:*.deb=38;5;9:*.rpm=38;5;9:*.jar=38;5;9:*.war=38;5;9:*.ear=38;5;9:*.sar=38;5;9:*.rar=38;5;9:*.alz=38;5;9:*.ace=38;5;9:*.zoo=38;5;9:*.cpio=38;5;9:*.7z=38;5;9:*.rz=38;5;9:*.cab=38;5;9:*.jpg=38;5;13:*.JPG=38;5;13:*.jpeg=38;5;13:*.gif=38;5;13:*.bmp=38;5;13:*.pbm=38;5;13:*.pgm=38;5;13:*.ppm=38;5;13:*.tga=38;5;13:*.xbm=38;5;13:*.xpm=38;5;13:*.tif=38;5;13:*.tiff=38;5;13:*.png=38;5;13:*.webp=38;5;13:*.heic=38;5;13:*.avif=38;5;13:*.svg=38;5;13:*.svgz=38;5;13:*.mng=38;5;13:*.pcx=38;5;13:*.mov=38;5;13:*.mpg=38;5;13:*.mpeg=38;5;13:*.m2v=38;5;13:*.mkv=38;5;13:*.ogm=38;5;13:*.mp4=38;5;13:*.m4v=38;5;13:*.mp4v=38;5;13:*.vob=38;5;13:*.qt=38;5;13:*.nuv=38;5;13:*.wmv=38;5;13:*.asf=38;5;13:*.rm=38;5;13:*.rmvb=38;5;13:*.flc=38;5;13:*.avi=38;5;13:*.fli=38;5;13:*.flv=38;5;13:*.webm=38;5;13:*.gl=38;5;13:*.dl=38;5;13:*.xcf=38;5;13:*.xwd=38;5;13:*.yuv=38;5;13:*.cgm=38;5;13:*.emf=38;5;13:*.axv=38;5;13:*.anx=38;5;13:*.ogv=38;5;13:*.ogx=38;5;13:*.aac=38;5;45:*.au=38;5;45:*.flac=38;5;45:*.mid=38;5;45:*.midi=38;5;45:*.mka=38;5;45:*.mp3=38;5;45:*.m4a=38;5;45:*.mpc=38;5;45:*.ogg=38;5;45:*.opus=38;5;45:*.vorbis=38;5;45:*.3gp=38;5;45:*.ra=38;5;45:*.wav=38;5;45:*.axa=38;5;45:*.oga=38;5;45:*.spx=38;5;45:*.xspf=38;5;45:*~=38;5;244:'
  else
    (( $+commands[dircolors] )) && eval "$(dircolors -b)"
  fi
  zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
fi
export GREP_COLORS=ms=91:mc=91:sl=:cx=:fn=35:ln=32:bn=32:se=36
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
export LESS="-FRXM"
# default has -S
export SYSTEMD_LESS="${LESS#-}K"

# 其它 {{{1

if (( $+commands[zoxide] )) && [[ ! -f ~/.local/share/zoxide/db.zo || $(zstat +uid ~/.local/share/zoxide/db.zo) == $UID ]]; then
  eval "$(zoxide init zsh)"
  function z () {
    if [[ "$#" -eq 0 ]]; then
      __zoxide_z ''
    else
      __zoxide_z "$@"
    fi
  }
  if [[ -z $functions[j] ]]; then
    function j () {
      if [[ -t 1 ]]; then
        z "$@"
      else
        zoxide query "$@"
      fi
    }
  fi
fi
# if zoxide loads but the directory is readonly, remove the chpwd hook
if [[ ${chpwd_functions[(i)__zoxide_hook]} -le ${#chpwd_functions} && \
  -d ~/.local/share/zoxide && ! -w ~/.local/share/zoxide ]]; then
  chpwd_functions[(i)__zoxide_hook]=()
fi

_plugin=${_zdir}/.zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
if [[ -f $_plugin ]]; then
  . $_plugin
  FAST_HIGHLIGHT[use_async]=1
fi
_plugin=${_zdir}/.zsh/plugins/sk-tools.zsh
if [[ -f $_plugin ]]; then
  . $_plugin
fi
_plugin=${_zdir}/.zsh/plugins/screenshot.zsh
if [[ -f $_plugin ]]; then
  . $_plugin
fi
_plugin=${_zdir}/.zsh/functions/zsh-edit-subword
if [[ -f $_plugin && -z $SUDO_USER ]]; then
  autoload -Uz zsh-edit-subword
  for widget in zsh-edit-{{back,for}ward,{backward-,}kill}-{sub,shell-}word; do
    zle -N "$widget" zsh-edit-subword
  done
  zstyle ":edit:*" word-chars ''
  bindkey "\eb" zsh-edit-backward-subword
  bindkey "\ef" zsh-edit-forward-subword
  bindkey "^w" zsh-edit-backward-kill-subword
  bindkey "\ed" zsh-edit-kill-subword
fi
_plugin=${_zdir}/.zsh/plugins/atuin.zsh
if (( $+commands[atuin] )) && [[ -f $_plugin ]]; then
  . $_plugin
fi
_plugin=${_zdir}/.zsh/bgdep.zsh
if [[ -f $_plugin ]]; then
  . $_plugin
fi
unset _plugin

# 共用账户时的定制
if [[ -n $ZDOTDIR ]]; then
  export SHELL=/bin/zsh
  [[ -f $ZDOTDIR/.tmux.conf ]] && alias tmux="tmux -f ~/lily/.tmux.conf -S ~/lily/.tmux.sock"
  [[ -d $ZDOTDIR/bin ]] && path=($ZDOTDIR/bin $path)
  [[ -f $ZDOTDIR/.vim/vimrc ]] && {
    export MYVIMRC=$ZDOTDIR/.vim/vimrc
    export VIMINIT="let &rtp='$ZDOTDIR/.vim,' . &rtp
so $MYVIMRC"
    export VIMTMP=$ZDOTDIR/tmpfs
  }
fi

[[ -f $_zdir/.zsh/zshrc.local.after ]] && source $_zdir/.zsh/zshrc.local.after

unset OS
return 0

# Public link: https://github.com/lilydjwg/dotzsh

# vim:fdm=marker
