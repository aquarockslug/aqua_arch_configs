#!/bin/bash

# The main file of the aqua_profile plugin

# check for Windows Subsystem for Linux
if [[ -f /proc/sys/fs/binfmt_misc/WSLInterop || "$TERM_PROGRAM" = 'vscode' ]]
then WSL=true; else WSL=false; fi

# SETTINGS
zstyle ':omz:update' mode auto
export BROWSER='waterfox'
[ $WSL = true ] && export BROWSER='wsl-open' && export OPENER='wsl-open'
export DISABLE_AUTO_TITLE='true'
export EDITOR='nvim';
export HISTFILE="/home/aqua/.zsh_history"
export HISTSIZE=10000
export SAVEHIST=10000
setopt SHARE_HISTORY
export LFS="/mnt/lfs"
export MAKEFLAGS=-j$(nproc) # use all available cores when running "make"
export NAP_DEFAULT_LANGUAGE='md'
export PAGER='bat'
export PATH="$PATH:/home/aqua/.local/share/nvim/mason/bin" # mason for nvim language servers
export PATH="$PATH:~/.local/share/pnpm"
export PNPM_HOME="~/.local/share/pnpm"
export ZELLIJ_CONFIG_DIR=/etc/zellij;
export ZELLIJ_CONFIG_FILE=/etc/zellij/config.kdl
bindkey " " magic-space
# TODO bindkey "^E" zellij action edit-scrollback

# SYSTEM
alias q="exit"
alias s="sudo"
[ $WSL = true ] && alias open='wsl-open'

# CLIPBOARD
alias yank="xclip -selection clipboard" && alias put="xclip -o -selection clipboard"
[ $WSL = true ] && alias yank="wcopy" && alias put="wpaste" # use wsl-clipboard if on WSL

# SYSTEM INFO
alias ls='eza --icons --group-directories-first'
alias tasks="ps aux"
alias fd="sudo fdisk -l"
alias df="duf"
alias du="dust"
alias cat="bat"
alias top="htop"

# MOVEMENT
alias ..='cd ../'
alias ...='cd ../../'
alias ....='cd ../../../'
alias cls='clear && ls'
alias l='clear && ls'

# APPLICATIONS
alias buku="buku --suggest"
alias chat="gomuks"
alias ddgr="ddgr --rev"
alias ld="lazydocker"
alias lg="lazygit"
alias mail="aerc"
alias py="python"
alias rsync="rsync -Phav"
alias torrent="rtorrent"
alias v="nvim"
alias zj="zellij"
alias zjv="zellij action edit"

source "${0:A:h}"/aqua_dracula_theme.zsh

# %% zsh functions %%
hist() { peco < $HISTFILE } # search history
chmodx() { sudo chmod u+x $1 }
take() { mkdir $1 && cd $1 }
lfcd () { cd "$(command lf -print-last-dir "$@")" }

n() { nap $(nap list | peco)} # quick open note
nap_import() { cd $1; for f in  */*; do nap $f < $f; done; cd ~ } # import from given nap source directory
nap_export() { cd ~/.local/share/nap; for f in *; do rsync --mkpath -uv $f $1$(echo $f | tr '-' '/' ); done; cd ~ }

docs() { $(gum choose "cht" "cheat" "tldr" "cd ~/home/share/docs" "firefox overapi.com/" "firefox quickref.me") }
cht() { cht.sh $(gum input --placeholder "query...") | gum pager }

dlp() { if [ -z ${*+x} ]; then yt-dlp $(gum write); else yt-dlp $*; fi }
dls() { wget -q -O - $1 | nap }
