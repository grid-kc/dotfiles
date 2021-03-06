# In Mac's Terminal.app, all shells are login shells, so you must source this
# file from $HOME/.bash_profile.

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# --- Some aliases
alias ll='ls -lah'

# --- VIm
# set -o vi
export VISUAL=vim
export EDITOR=vim

# --- History Configuration ---
# No duplicate lines or lines starting with space
HISTCONTROL=ignoreboth:erasedups

# Default history is 500, which is a bit small
HISTSIZE=1000
HISTFILESIZE=$HISTSIZE

# Append to the history file, don't overwrite it
shopt -s histappend

# --- Share History Across All Running Sessions ---
# Adapted from https://unix.stackexchange.com/questions/1288/preserve-bash-history-in-multiple-terminal-windows
# Basically, this makes the session-local "history list" a non-entity, using the history file
# as the source of truth.

sync_history() {
  # Append this session's history list to the history file
  builtin history -a
  # Truncate the file if necessary
  HISTFILESIZE=$HISTSIZE
  # Clear out this session's history list
  builtin history -c
  # Reload the contents of the history file
  builtin history -r
}

export PROMPT_COMMAND="sync_history; $PROMPT_COMMAND"

# --- General Shell Options ---
# Update display after each command
shopt -s checkwinsize

# **/ matches directories and subdirectories
shopt -s globstar

# Expand $PWD in commands
shopt -s direxpand

# --- Turn on completion ---
if ! shopt -oq posix; then
  # Linux completion locations
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  # Mac completion location
  elif [ -f /usr/local/etc/bash_completion ]; then
    . /usr/local/etc/bash_completion
  fi
fi

# --- Git completion: Mac ---
git_root=/usr/local/Cellar/git
if [[ -d  $git_root ]]; then
  . "$(find $git_root -name 'git-completion.bash' | sort -n | head -n1)"
fi

# --- kubectl completion ---
if command -v kubectl &>/dev/null; then
  source <(command kubectl completion bash)
fi

# --- Prompt Config ---
function git_branch() {
  local ref
  ref=$(command git symbolic-ref HEAD 2>/dev/null)\
    || ref=$(command git rev-parse --short HEAD 2>/dev/null)\
    || return
  echo "${ref#refs/heads/}"
}

# The way this works is:
# \e[0;32m -> start using the color specified by the ANSI color code "0;32"
# \e[m -> stop using the color
export PS1=$'\e[0;32m\w\e[m\e[0;31m|\e[m\e[0;34m$(git_branch)\e[m \$\n'

# --- Colored output for ls ---
if command -v dircolors &>/dev/null; then
  # If on linux, use dircolors
  eval $(dircolors -b)
  alias ls='ls --color=auto'
elif [[ "$(command uname)" == "Darwin" ]]; then
  # On Mac, just use BSD default colors
  alias ls='ls -G'
fi

# --- Turn off trackpad on laptop ---
alias disable-trackpad='xinput set-prop $(xinput list | grep -i touchpad | cut -f 2 | cut -d = -f 2) "Device Enabled" 0'
alias enable-trackpad='xinput set-prop $(xinput list | grep -i touchpad | cut -f 2 | cut -d = -f 2) "Device Enabled" 1'

# --- Initialize pyenv ---
if command -v pyenv &>/dev/null; then
  eval "$(pyenv init -)"
fi

# --- Local pip on Linux ---
if [[ -d $HOME/.local/bin ]]; then
  export PATH=$PATH:$HOME/.local/bin
fi
