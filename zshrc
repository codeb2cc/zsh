# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=20480
SAVEHIST=20480
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/codeb2cc/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# Search history
bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward

# Alias
alias ..='cd ..'
alias vi='vim'
alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias c='clear'
alias rm='rm -i'
alias mv='mv -i'
alias du='du -a -h --max-depth=1'
alias df='df -h'
alias grep='grep --color'
alias sudo='sudo '

# Path shorcuts
cdpath=(~)

# Go Lang
GOROOT=$HOME/Local/lib/go

# User PATH
PATH=$HOME/Local/bin:$HOME/Local/sbin:$HOME/.local/bin:$HOME/.local/sbin:$GOROOT/bin:$PATH

# Key Binding
bindkey "^[[1~" beginning-of-line
bindkey "^[[4~" end-of-line
bindkey "^[[2~" overwrite-mode
bindkey "^[[3~" delete-char

bindkey "\e[1~" beginning-of-line # Home
bindkey "\e[4~" end-of-line # End
bindkey "\e[5~" beginning-of-history # PageUp
bindkey "\e[6~" end-of-history # PageDown
bindkey "\e[2~" quoted-insert # Ins
bindkey "\e[3~" delete-char # Del
bindkey "\e[5C" forward-word
bindkey "\e[5D" backward-word
bindkey "\e\e[C" forward-word
bindkey "\e\e[D" backward-word
bindkey "\e[Z" reverse-menu-complete # Shift+Tab

# Colored man pages
export LESS='-R'
man() {
    env \
        LESS_TERMCAP_mb=$(printf "\e[1;31m") \
        LESS_TERMCAP_md=$(printf "\e[1;31m") \
        LESS_TERMCAP_me=$(printf "\e[0m") \
        LESS_TERMCAP_se=$(printf "\e[0m") \
        LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
        LESS_TERMCAP_ue=$(printf "\e[0m") \
        LESS_TERMCAP_us=$(printf "\e[1;32m") \
            man "$@"
}

# Helpers
function git_prompt_info() {
    ref=$(git symbolic-ref --short HEAD 2> /dev/null) || return
    echo " git:${ref}"
}
function hg_prompt_info() {
    id=$(hg id -b 2> /dev/null) || return
    echo " hg:${id}"
}
function virtual_env_info() {
    env=$(basename $VIRTUAL_ENV 2> /dev/null) || return
    echo "[$env]"
}
function ip_info() {
    ip=$(/sbin/ifconfig eth0 | ack 'inet ([0-9\.]+)' --output="\$1")
    echo "$ip"
}

# Prompt configuration
# {
function precmd {
    local TERMWIDTH
    (( TERMWIDTH = ${COLUMNS} - 1 ))

    # Truncate the path if it's too long.
    PR_FILLBAR=""
    PR_PWDLEN=""

    PR_IP=$(ip_info)

    local promptsize=${#${(%):- %n@%m:%l -}}
    local pwdsize=${#${(%):-%~}}

    if [[ "$promptsize + $pwdsize" -gt $TERMWIDTH ]]; then
        ((PR_PWDLEN=$TERMWIDTH - $promptsize))
    else
    PR_BARCHAR=" "
    PR_FILLBAR="\${(l.(($TERMWIDTH - ($promptsize + $pwdsize)))..${PR_BARCHAR}.)}"
    fi

    PR_GIT=$(git_prompt_info)
    PR_HG=$(hg_prompt_info)
    PR_ENV=$(virtual_env_info)
}

setprompt () {
    # Need this so the prompt will work.
    setopt prompt_subst

    # See if we can use colors.
    autoload colors zsh/terminfo
    if [[ "$terminfo[colors]" -ge 8 ]]; then
    colors
    fi
    for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
    eval PR_$color='%{$terminfo[bold]$fg[${(L)color}]%}'
    eval PR_LIGHT_$color='%{$fg[${(L)color}]%}'
    (( count = $count + 1 ))
    done
    PR_NO_COLOUR="%{$terminfo[sgr0]%}"

    PROMPT='$PR_GREEN┌ %(!.%SROOT%s.%n)$PR_GREEN@%m:%l $PR_CYAN\
${(e)PR_FILLBAR}$PR_CYAN%$PR_PWDLEN<...<%~%<<$PR_CYAN\

$PR_GREEN└ %D{%H:%M:%S}\
$PR_YELLOW$PR_GIT$PR_HG\
%(?.. $PR_LIGHT_RED%?)\
$PR_LIGHT_CYAN %(!.$PR_RED.$PR_WHITE)%# $PR_NO_COLOUR'

    RPROMPT=' $PR_MAGENTA$PR_ENV$PR_CYAN$PR_NO_COLOUR'

    PS2='($PR_LIGHT_GREEN%_$PR_CYAN)$PR_NO_COLOUR '
}

setprompt
# }

# Virtualenvwrapper setting
WORKON_HOME=~/Virtual
source /usr/bin/virtualenvwrapper.sh

