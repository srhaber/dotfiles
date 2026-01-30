# If you come from bash you might have to change your $PATH.
# Personal bin takes precedence over dotfiles bin
export PATH=$HOME/bin:$HOME/.local/bin:$HOME/.dotfiles/bin:/usr/local/sbin:$PATH

if [[ -d $HOME/go/bin ]]; then
	export PATH=$HOME/go/bin:$PATH
fi

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Different user names on different macs.
if [ ! -d $ZSH ]; then
  export ZSH="$HOME/.oh-my-zsh"
fi

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
# Disabled in favor of Starship prompt
ZSH_THEME=""

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
export UPDATE_ZSH_DAYS=7

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.

# NOTE: Enabling this creates bug with autocompletion eating newline in prompt
# Reference: https://github.com/robbyrussell/oh-my-zsh/issues/6226
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="yyyy-mm-dd"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  fzf-tab
  zsh-autosuggestions
  brew
  colored-man-pages
  colorize
  common-aliases
  copyfile
  copypath
  docker
  docker-compose
  encode64
  git
  golang
  jsontools
  macos
  rsync
  urltools
  ssh-agent
  zsh-syntax-highlighting  # Must be last plugin
)

source $ZSH/oh-my-zsh.sh

# zsh-autosuggestions color customization for Tomorrow Night theme
# Uses Tomorrow Night's comment color for subtle but visible suggestions
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#969896'

# zsh-autosuggestions key bindings
# Default: Right arrow and End accept suggestions
# Additional: Ctrl+Space to accept suggestion (easier to reach)
bindkey '^ ' autosuggest-accept

# zsh-syntax-highlighting color customization for Tomorrow Night theme
# See: https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/main.md
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red,bold'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[alias]='fg=cyan,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=cyan,bold'
ZSH_HIGHLIGHT_STYLES[function]='fg=cyan,bold'
ZSH_HIGHLIGHT_STYLES[command]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=green,underline'
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[path]='fg=white,underline'
ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=white,underline'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=blue'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=magenta'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=magenta'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=yellow'

# User configuration

export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='vim'
fi

# Compilation flags - support both Intel and Apple Silicon
if [[ $(uname -m) == "arm64" ]]; then
  export ARCHFLAGS="-arch arm64"
else
  export ARCHFLAGS="-arch x86_64"
fi

# ssh
export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

[[ -r ~/.dotfiles/aliases.sh ]] && source ~/.dotfiles/aliases.sh
[[ -r ~/.secrets.sh ]] && source ~/.secrets.sh

# Prompt configuration moved to Starship (see end of file)
# PDE SETUP || 2022-04-22T14:06:32-0700
##############################################
/usr/bin/ssh-add --apple-load-keychain >/dev/null 2>&1
##############################################

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Docker Desktop (only load if file exists)
[[ -f $HOME/.docker/init-zsh.sh ]] && source $HOME/.docker/init-zsh.sh

# Initialize Starship prompt (modern, cross-shell prompt)
# https://starship.rs/
if command -v starship &> /dev/null; then
  eval "$(starship init zsh)"
fi

# Initialize zoxide (smart cd - jumps to frequent/recent directories)
# https://github.com/ajeetdsouza/zoxide
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi

# Initialize direnv (auto-load .envrc files for per-project environments)
# https://direnv.net/
if command -v direnv &> /dev/null; then
  eval "$(direnv hook zsh)"
fi

# Initialize tf wrapper completion (terraform/terragrunt)
[[ -r ~/.dotfiles/bin/tf-completion.zsh ]] && source ~/.dotfiles/bin/tf-completion.zsh

# Terraform provider cache (speeds up init by sharing providers across workspaces)
export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"

# Initialize pyenv (Python version manager)
# https://github.com/pyenv/pyenv
if [[ -d "$HOME/.pyenv" ]]; then
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
fi

# Added by Antigravity
[[ -d "$HOME/.antigravity/antigravity/bin" ]] && export PATH="$HOME/.antigravity/antigravity/bin:$PATH"
