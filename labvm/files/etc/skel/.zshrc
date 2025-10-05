#!/usr/bin/env zsh

# install Zsh Plugin Manager
ZPM_ROOT="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins/@zpm"
if [[ ! -f "$ZPM_ROOT/zpm.zsh" ]]; then
  git clone --recursive https://github.com/zpm-zsh/zpm "$ZPM_ROOT"
fi
source "$ZPM_ROOT/zpm.zsh"

# load /etc/profile via sh emulation
emulate sh -c 'source /etc/profile' || true

### Tmux
export TMUX_AUTOSTART=false
# zpm if ssh load zpm-zsh/tmux
# zpm if-not ssh load zpm-zsh/tmux,apply:path

### VTE
zpm if vte load zpm-zsh/vte

## Spaceship theme
export SPACESHIP_ROOT="$HOME/.config/zsh/spaceship"
if [[ ! -f "$SPACESHIP_ROOT/spaceship.zsh" ]]; then
  mkdir -p "$SPACESHIP_ROOT"
	git clone --depth=1 "https://github.com/spaceship-prompt/spaceship-prompt.git" "$SPACESHIP_ROOT"
fi
source "$SPACESHIP_ROOT/spaceship.zsh"

# comon key binds
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

### 3party plugins
zpm load                      \
  zpm-zsh/core-config         \
  zpm-zsh/ignored-users,async \
  zpm-zsh/check-deps,async    \
  zpm-zsh/ls,async            \
  zpm-zsh/colorize,async      \
  zpm-zsh/ssh,async           \
  zpm-zsh/dot,async           \
  zpm-zsh/undollar,async      \
  zpm-zsh/bookmarks,async     \
  zpm-zsh/zpm-info            \
  voronkovich/gitignore.plugin.zsh,async     \
  zpm-zsh/autoenv,async                      \
  mdumitru/fancy-ctrl-z,async                \
  zpm-zsh/zsh-history-substring-search,async \
  zsh-users/zsh-autosuggestions,async        \
  zpm-zsh/fast-syntax-highlighting,async     \
  zpm-zsh/history-search-multi-word,async

# persistent history settings
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
HIST_STAMPS="dd.mm.yyyy"
HISTIGNORE="ls:cd:cd -:pwd:exit:date:* --help"

setopt extended_history
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_save_no_dups
setopt hist_verify

[ ! -f ~/.zshrc.local ] || source ~/.zshrc.local 2>/dev/null

