#! /bin/zsh
source ~/.zplug/init.zsh

zplug "zplug/zplug", hook-build: 'zplug --self-manage'

zplug "MichaelAquilina/zsh-history-substring-search"
zplug "MichaelAquilina/zsh-syntax-highlighting", defer:2
zplug "MichaelAquilina/zsh-completions"
zplug "MichaelAquilina/zsh-emojis"
zplug "MichaelAquilina/zsh-autosuggestions"
zplug "MichaelAquilina/zsh-you-should-use"
export YSU_MODE=BESTMATCH

zplug "MichaelAquilina/zsh-autoswitch-virtualenv"
export AUTOSWITCH_DEFAULTENV="default3"

# Theme
zplug "MichaelAquilina/agnoster-zsh-theme", as:theme, at:personal-fork-new,
export AGNOSTER_DISABLE_FILE_COUNT=1
export AGNOSTER_DISABLE_CONTEXT=1

# Gist Commands
zplug "MichaelAquilina/8d9346a04d67ff2c2c083fb7606bbf2c", \
    as:command, \
    from:gist, \
    use:git_status.sh, \
    rename-to:git_status
zplug "MichaelAquilina/git-clean-branches", \
    as:command, \
    use:git-clean-branches

zplug "lib/completion", from:oh-my-zsh

zplug 'molovo/color', \
  as:command, \
  use:'color.zsh', \
  rename-to:color
zplug 'molovo/revolver', \
  as:command, \
  use:revolver
zplug 'molovo/zunit', \
  as:command, \
  use:zunit, \
  hook-build:'./build.zsh'

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
    echo; zplug install
  fi
fi

# Infinite History
export HISTSIZE="9999999"
export SAVEHIST="9999999"
export HISTFILESIZE="9999999"

setopt HIST_IGNORE_DUPS
setopt EXTENDED_HISTORY
setopt INC_APPEND_HISTORY_TIME

setopt INTERACTIVE_COMMENTS
setopt PROMPT_CR

PREFERRED_HISTFILE="$HOME/Documents/zsh_history"
if [[ -f "$PREFERRED_HISTFILE" ]]; then
  export HISTFILE="$PREFERRED_HISTFILE"
fi

# show ISO8601 timestamp with history
alias history="fc -li 1"


if [[ "$(uname -a)" = *"Ubuntu"* ]]; then
  # Allow ctrl+left and ctrl+right movement
  bindkey ';5D' emacs-backward-word
  bindkey ';5C' emacs-forward-word
else
  # Allow ctrl+left and ctrl+right movement
  bindkey '5D' emacs-backward-word
  bindkey '5C' emacs-forward-word
fi


source =virtualenvwrapper.sh

export PATH="$HOME/.yarn/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.zplug/bin:$PATH"
export PATH="$HOME/bin/:$PATH"

zplug load

# Fix VTE Configuration Issues when using Tilix
# https://github.com/gnunn1/tilix/wiki/VTE-Configuration-Issue#user-content-1-source-vtesh-in-bashrc
if [[ -n "$TILIX_ID" ]]; then
  source /etc/profile.d/vte.sh
fi

# Source any additional configuration specific to this machine
if [[ -f ~/.machinerc.gpg ]]; then
  eval "$(gpg -d --no-tty ~/.machinerc.gpg 2>/dev/null)"
elif [[ -f ~/.machinerc ]]; then
  source ~/.machinerc
fi

if [[ -f ~/.github ]]; then
  export GITHUB_TOKEN="$(<~/.github)"
fi

# Use NeoVim if available
if [[ -n =nvim ]]; then
  alias vim=nvim
fi

eval $(dircolors ~/.dircolors)

# Disable ansible from using cowsay
export ANSIBLE_NOCOWS=1

export WORDCHARS=''

setopt extended_glob

export PAGER="less"
export EDITOR="vim"

# Use pushd instead of cd
setopt AUTO_PUSHD
setopt PUSHD_SILENT

############################
#        FUNCTIONS         #
############################

# Synchronise pass account
function psync() {
  pass git pull origin master
  pass git push origin master
  pass git push backup master
}

# Enable 256 color mode
export TERM="xterm-256color"

function whatismyip() {
  curl ifconfig.co -s --connect-timeout 1
}

# Recursively list all values in gsettings
function all_gsettings() {
  for schema in $(gsettings list-schemas)
  do
      gsettings list-recursively "$schema"
  done
}

function color_cheatsheet() {
   x=`tput op`
   y=`printf %$((${COLUMNS}-6))s`
   for i in {0..256}; do
     o=00$i
     echo -e ${o:${#o}-3:3} `tput setaf $i;tput setab $i`${y// /=}$x
   done
}

function notify() {
  # Used to notify you when a command has completed
  # example:  my-long-running-task | notify
  start_time="$(date +%s)"
  while read line
  do
    echo "$line"
  done <&0
  end_time="$(date +%s)"
  runtime="$((end_time-start_time))"
  notify-send "Command Completed in $runtime seconds!"
}

function flush_gpg_passwords() {
  echo RELOADAGENT | gpg-connect-agent
}

############################
#         ALIASES          #
############################

alias h="history"
alias -g NE="2>/dev/null"

alias v="vim"
alias vi="vim"

# Allows aliases to be expanded on watch commands
# See https://unix.stackexchange.com/questions/25327/watch-command-alias-expansion
alias watch='watch '

alias json="jq '.' -C"

alias ls="ls --color=auto"
alias ll="ls -lh --group-directories-first"
alias l="ls -lah --group-directories-first"

alias less="less -R"

alias shrug='echo $em_shrug'

alias ap="ansible-playbook"
alias dc="docker-compose"

# Git Aliases
alias gs="git status"
alias gc="git commit"
alias gca="git commit --amend"
alias gco="git checkout"
alias gap="git add -p"
alias gpl="git pull"
alias gr="git rebase"
alias gst="git stash"
alias gpum="git pull upstream master"
alias gpoh="git push -u origin HEAD"
alias grim="git rebase -i master"
alias gd="git diff"
alias gcb="git clean-branches"

export GH="git@github.com:MichaelAquilina"
export GL="git@gitlab.com:MichaelAquilina"
export BB="git@bitbucket.org:maquilina"

# Tig Aliases
alias ta="tig --all"
alias t="tig"

# Vagrant Aliases
alias vs="vagrant ssh"
alias vc="vagrant ssh -c"
alias vu="vagrant up"
alias vh="vagrant halt"
alias vp="vagrant provision"

# Docker Aliases
alias dcr="docker-compose run"

# Utilities
alias pm="pygmentize"
alias xopen="xdg-open"
alias LS="LS -e"  # Allow interrupt by Ctrl+C
alias explore="nautilus"
alias xcopy="xsel -i -b"
alias xpaste="xsel -o -b"
alias xc="xcopy"
alias xp="xpaste"
alias md="mkdir"

alias plog='pass git log --pretty="format:%C(bold) %G? %C(cyan) %ai %C(bold yellow)%s"'

# Weather in London
alias weather="curl wttr.in/London"

export MANPATH="$HOME/man:$MANPATH"
export MANPAGER="nvim -c 'set ft=man' -"

export FZF_DEFAULT_COMMAND="rg --files --hidden -g '!.git'"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
