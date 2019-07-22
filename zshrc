#! /bin/zsh
zmodload "zsh/zprof"
# record the amount of time zshrc takes to load
t0=$(date "+%s.%N")

source ~/.zplug/init.zsh

zplug "zplug/zplug", hook-build: 'zplug --self-manage'

zplug "MichaelAquilina/zsh-syntax-highlighting", defer:2
zplug "MichaelAquilina/zsh-autosuggestions"
export ZSH_AUTOSUGGEST_USE_ASYNC=1
zplug "MichaelAquilina/zsh-auto-notify"
zplug "MichaelAquilina/zsh-you-should-use"
export YSU_MODE="BESTMATCH"
export YSU_MESSAGE_POSITION="after"
unset YSU_HARDCORE

zplug "MichaelAquilina/zsh-history-filter"
export HISTORY_FILTER_EXCLUDE=("_KEY" "Authorization: ", "_TOKEN")

zplug "MichaelAquilina/zsh-autoswitch-virtualenv"
export AUTOSWITCH_DEFAULT_PYTHON="/usr/bin/python3"
export AUTOSWITCH_DEFAULT_REQUIREMENTS="$HOME/.requirements.txt"

RED="$(tput setaf 1)"
PURPLE="$(tput setaf 5)"
GREEN="$(tput setaf 2)"
BOLD="$(tput bold)"
NORMAL="$(tput sgr0)"

# Theme
zplug "romkatv/powerlevel10k", as:theme
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(status dir vcs dir_writable)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()
POWERLEVEL9K_DIR_SHORTEN_STRATEGY="dir"
POWERLEVEL9K_DIR_SHORTEN_LENGTH=2
POWERLEVEL9K_VIRTUALENV_BACKGROUND="cyan"

# Gist Commands
zplug "MichaelAquilina/8d9346a04d67ff2c2c083fb7606bbf2c", \
    as:command, \
    from:gist, \
    use:git_status.sh, \
    rename-to:git_status
zplug "MichaelAquilina/git-commands", \
    as:command, \
    use:git-clean-branches
zplug "MichaelAquilina/git-commands", \
    as:command, \
    use:git-web

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

# Remove all aliases from random unexpected places
unalias -a

# Infinite History
export HISTSIZE="9999"
export SAVEHIST="9999"
export HISTFILESIZE="9999"

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

# Allow ctrl+left and ctrl+right movement
bindkey '5D' emacs-backward-word
bindkey '5C' emacs-forward-word
bindkey '5B' beginning-of-line
bindkey '5A' end-of-line

# Use the gnome-keyring-daemon
if [[ -n "$DESKTOP_SESSION" ]]; then
    # Work around a bug where gnome keyring wont work unless ssh-agent is first launched
    eval `ssh-agent -s` > /dev/null
    # if you get a warning about insecure memory - you need to run
    # sudo setcap cap_ipc_lock=+ep `which gnome-keyring-daemon`
    eval `gnome-keyring-daemon -s`
fi

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

if [[ -f ~/.trello ]]; then
  source ~/.trello
fi

# Use NeoVim if available
if type "nvim" >/dev/null; then
  alias vim=nvim
fi

eval $(dircolors ~/.dircolors)

# Disable ansible from using cowsay
export ANSIBLE_NOCOWS=1

export WORDCHARS=''

setopt extended_glob

export PAGER="less"
export EDITOR="nvim"

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

# Get original pass binary path before overriding it
export passbin="$(which pass)"

# Function wrapper around the "pass" command to add some convenient functionality
function pass() {
    local params=()
    if [ "$1" = "generate" ]; then
        # Make sure that generate is only ever called with "--in-place"
        # with existing entries to prevent overriding useful meta-data
        local target="$HOME/.password-store/${@[-2]}.gpg"

        if stat "$target" &> /dev/null && [ ${@[(ie)-i]} -gt ${#@} ]; then
            printf "${RED}"
            echo "Don't use generate without -i (in-place)!"
            echo "Automatically inserting -i for you"
            printf "${NORMAL}"
            # automatically insert -i
            params=("${@[@]:1:1}" "-i" "${@[@]:2}")
        fi
    fi

    # Only re-use the parameters passed in if nothing was populated
    if [[ -z "$params" ]]; then
        params=("${@[@]:1}")
    fi
    echo "Generated pass command: $passbin ${params[@]}"
    "$passbin" ${params[@]}
}

function whatismyip() {
  curl ifconfig.co -s --connect-timeout 1
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

alias todo="tro board -n todo"
alias work="tro board -n work"

alias h="history"
alias -g NE="2>/dev/null"

alias v="vim"

# Allows aliases to be expanded on watch commands
# See https://unix.stackexchange.com/questions/25327/watch-command-alias-expansion
alias watch='watch '

alias json="jq '.' -C"

alias curl="curl --silent"

alias ls="ls --color=auto"
alias ll="ls -lh --group-directories-first"
alias l="ls -lah --group-directories-first"

alias less="less -R"

alias ap="ansible-playbook"
alias dc="docker-compose"

# Git Aliases
alias gs="git status"
alias gc="git commit"
alias gca="git commit --amend"
alias gco="git checkout"
alias gcom="git checkout master"
alias gap="git add -p"
alias gpl="git pull"
alias gr="git rebase"
alias gst="git stash"
alias gw="git web"
alias gwu="git web upstream"
alias gwi="git web --issues"
alias gwp="git web --pulls"
alias gwup="git web upstream --pull-request"
alias gpum="git pull upstream master"
alias gpoh="git push -u origin HEAD"
alias gri="git rebase -i \$(git merge-base HEAD master)"
alias gd="git diff"
alias gcb="git clean-branches"
alias gpohw="gpoh && git web --pull-request"

export GH="git@github.com:MichaelAquilina"
export GL="git@gitlab.com:MichaelAquilina"
export BB="git@bitbucket.org:maquilina"

# Tig Aliases
alias ta="tig --all"
alias t="tig"

# Docker Aliases
alias dcr="docker-compose run --rm"

# Utilities
alias pm="pygmentize"
alias xopen="xdg-open"
alias explore="nautilus"
alias xcopy="xsel -i -b"
alias xpaste="xsel -o -b"
alias xc="xcopy"
alias xp="xpaste"
alias md="mkdir"

if [[ -n "$WAYLAND_DISPLAY" ]]; then
    alias xopen="GDK_BACKEND=wayland xdg-open"
    alias xcopy="wl-copy"
    alias xpaste="wl-paste"
fi

alias plog='pass git log --pretty="format:%C(bold) %G? %C(cyan) %ai %C(bold yellow)%s"'

# Weather in London
alias weather="curl wttr.in/London"

export MANPAGER="nvim -c 'set ft=man' -"

export FZF_DEFAULT_COMMAND="rg --files --hidden -g '!.git'"

fpath+=~/.zfunc

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.yarn/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.rvm/bin:$PATH"

# Leave as last command to prevent weird issues with PATH when
# changing environments
zplug load

export AUTO_NOTIFY_THRESHOLD=8
AUTO_NOTIFY_IGNORE+=("emp" "ipython")

t1=$(date "+%s.%N")
printf "Profile took %.3f seconds to load\n" $((t1-t0))
