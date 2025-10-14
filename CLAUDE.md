# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

Personal dotfiles repository for modern macOS development environment (2025). Manages configuration for shell (zsh), editor (Vim), terminal (iTerm2), git, and development tools. Uses XDG Base Directory specification where supported.

## Setup & Installation

### Initial Setup
```bash
# Automated setup (recommended)
./setup.sh          # Interactive mode
./setup.sh -y       # Non-interactive mode

# Manual Brewfile management
brew bundle install --file=Brewfile    # Install packages
brew bundle check                      # Verify installation
brew bundle dump --force               # Update Brewfile from installed packages

# Shortcut to update and push Brewfile
./bin/brewdump
```

The `setup.sh` script is idempotent and safe to run multiple times. It:
- Installs Homebrew (if needed)
- Installs packages from Brewfile
- Creates symlinks for dotfiles (backs up existing files)
- Installs Vim plugins via vim-plug
- Installs oh-my-zsh (if needed)
- Optionally applies macOS preferences

### Symlink Structure
- Traditional dotfiles: `~/.zshrc`, `~/.vimrc`, `~/.tmux.conf`, `~/.gemrc`, `~/.terraformrc`
- XDG-compliant: `~/.config/git/`, `~/.config/starship.toml`

## Key Architecture

### Shell Configuration (.zshrc)
- Uses **oh-my-zsh** for base shell functionality with plugins: brew, git, docker, golang, jsontools, macos, etc.
- Uses **Starship** for modern cross-shell prompt (replaces oh-my-zsh themes)
- Loads custom aliases from `aliases.sh`
- Loads secrets from `~/.secrets.sh` (if exists)
- Automatically loads nvm if installed at `~/.nvm/`
- Sets up SSH keychain loading and Docker Desktop integration
- Supports both Intel and Apple Silicon Macs

### Starship Prompt (.config/starship.toml)
- Custom format showing: timestamp, username, hostname, directory, git info, command duration, exit status
- Configured to show full date/time (`%F %T`) and exit codes on command failure

### Vim Configuration (.vimrc)
Uses **vim-plug** for plugin management. Install/update plugins with:
```bash
vim +PlugInstall +qall    # Install
vim +PlugUpdate +qall     # Update
vim +PlugClean +qall      # Remove unused
```

**Key bindings:**
- `Ctrl-t`: Toggle NERDTree
- `Ctrl-p`: FZF file finder
- `Ctrl-b`: FZF buffer switcher
- `Ctrl-f`: FZF ripgrep search
- `gcc`: Toggle comment (vim-commentary)
- `F6`: Toggle paste mode

**Plugins:** vim-sensible, vim-fugitive, vim-commentary, vim-surround, vim-gitgutter, fzf.vim, ale, nerdtree, vim-airline

### Git Configuration (.config/git/)
- `config`: Custom aliases and settings
- `helpers`: Shell functions for pretty git log/branch formatting
- `ignore`: Global gitignore patterns

**Notable git aliases:**
- `git l`: Pretty formatted log
- `git b`: Pretty formatted branches
- `git bs`: Branches sorted by commit date
- `git hp`: Show head commit with diff

### Custom Aliases (aliases.sh)
Modern CLI tools and shortcuts. Only includes aliases not provided by oh-my-zsh plugins.
- `b`, `bcat`: bat (better cat with syntax highlighting)
- `awsv`, `awsl`, `awse`: aws-vault shortcuts
- `brewup`: Update and cleanup Homebrew
- `reload`: Reload zsh configuration
- Various utilities: `myip`, `localip`, `ports`, `weather`

### Utility Scripts (bin/)
- `brewdump`: Updates Brewfile from installed packages, commits, and pushes to git

## Development Workflow

### Adding New Packages
```bash
# Install with brew
brew install <package>

# Update Brewfile and commit
./bin/brewdump
```

### Modifying Configuration
```bash
# Edit aliases
vim ~/.dotfiles/aliases.sh
source ~/.zshrc  # or use 'reload' alias

# Edit vim config
vim ~/.dotfiles/.vimrc
# Reopen vim or :source ~/.vimrc

# Edit git config
vim ~/.dotfiles/.config/git/config
# Changes take effect immediately

# Edit Starship prompt
vim ~/.dotfiles/.config/starship.toml
# Changes take effect on next prompt
```

### Syncing to New Machine
```bash
git clone https://github.com/srhaber/dotfiles ~/.dotfiles
cd ~/.dotfiles
./setup.sh
```

## Important Notes

- **nvm**: Not installed automatically. Use official installer from https://github.com/nvm-sh/nvm (not Homebrew)
- **Nerd Fonts**: Required for Starship icons. Install via Brewfile: `font-meslo-lg-nerd-font`
- **macOS defaults**: `.macos` script available for system preferences (requires logout/restart)
- **Secrets**: Store sensitive config in `~/.secrets.sh` (sourced by .zshrc, not tracked in git)
- **iTerm2 theme**: Manual import required from `iterm2/Tomorrow-Night.itermcolors`

## File Organization

```
.
├── setup.sh              # Main installation script
├── Brewfile              # Homebrew packages/casks
├── .zshrc                # Zsh configuration
├── .vimrc                # Vim configuration
├── .tmux.conf            # Tmux configuration
├── .gemrc                # Ruby gems configuration
├── .terraformrc          # Terraform configuration
├── .macos                # macOS system preferences script
├── aliases.sh            # Custom shell aliases
├── bin/
│   └── brewdump          # Brewfile update/commit script
├── .config/
│   ├── git/              # Git config, helpers, ignore
│   └── starship.toml     # Starship prompt config
├── .vim/                 # Vim plugins and runtime
└── iterm2/               # iTerm2 color schemes
```
