# Custom Shell Aliases
# Only includes aliases not provided by oh-my-zsh plugins

# ===========================
# Modern CLI tool shortcuts
# ===========================
# bat - better cat with syntax highlighting (keep cat pure for scripts)
if command -v bat >/dev/null 2>&1; then
    alias b='bat'
    alias bcat='bat --paging=never'
fi

# ===========================
# macOS specific shortcuts
# ===========================
alias o='open'
alias oo='open .'
alias brewup='brew update && brew upgrade && brew cleanup'
alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'

# ===========================
# AWS (aws-vault specific)
# ===========================
alias awsv='aws-vault'
alias awsl='aws-vault login'
alias awse='aws-vault exec'

# ===========================
# Quick config edits
# ===========================
alias aliases='vim ~/.dotfiles/aliases.sh'
alias reload='source ~/.zshrc'

# ===========================
# Utilities
# ===========================
alias grep='grep --color'
alias grepl='grep --line-number'
alias less='less --LINE-NUMBERS'
alias myip='curl -s ifconfig.me'
alias localip='ipconfig getifaddr en0'
alias ports='sudo lsof -iTCP -sTCP:LISTEN -n -P'
alias path='echo $PATH | tr ":" "\n"'
alias tf='terraform'

# ===========================
# Datetime utilities
# ===========================
alias timestamp='date +%Y%m%d%H%M%S'
alias now='date +"%Y-%m-%d %H:%M:%S"'
alias week='date +%V'
alias weather='curl wttr.in'
