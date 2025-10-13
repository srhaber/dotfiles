# Shaun's Dotfiles

Modern development environment configuration for macOS (2025).

## Quick Setup

### Automated Setup (Recommended)

```bash
git clone https://github.com/srhaber/dotfiles ~/.dotfiles
cd ~/.dotfiles
./setup.sh
```

The setup script will:
- Install Homebrew (if not present)
- Install all packages from Brewfile
- Create symlinks for all dotfiles
- Install Vim plugins
- Install oh-my-zsh (if not present)
- Optionally apply macOS system preferences

**Safe & Idempotent:** The script checks before overwriting files and can be run multiple times safely.

---

## Manual Setup

If you prefer to set up manually:

### 1. Install Homebrew
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Clone this repository
```bash
git clone https://github.com/srhaber/dotfiles ~/.dotfiles
cd ~/.dotfiles
```

### 3. Install applications and tools
```bash
brew bundle install --file=~/.dotfiles/Brewfile
```

### 4. Create symlinks
```bash
ln -s ~/.dotfiles/.zshrc ~/.zshrc
ln -s ~/.dotfiles/.vimrc ~/.vimrc
ln -s ~/.dotfiles/.gitconfig ~/.gitconfig
ln -s ~/.dotfiles/.gitignore_global ~/.gitignore_global
ln -s ~/.dotfiles/.tmux.conf ~/.tmux.conf
ln -s ~/.dotfiles/.gemrc ~/.gemrc
ln -s ~/.dotfiles/.terraformrc ~/.terraformrc
```

### 5. Configure iTerm2

**Install color theme:**
1. Open iTerm2
2. Press `Cmd + ,` to open Preferences
3. Go to **Profiles** → **Colors**
4. Click **Color Presets** → **Import...**
5. Navigate to `~/.dotfiles/iTerm2-Color-Schemes/schemes/`
6. Import **Tomorrow Night.itermcolors**
7. Select **Tomorrow Night** from the Color Presets dropdown

**Set Nerd Font:**
1. In Preferences, go to **Profiles** → **Text**
2. Click **Change Font**
3. Select **MesloLGM Nerd Font** or **MesloLGS Nerd Font**
4. Recommended size: 13 or 14

### 6. Reload shell
```bash
source ~/.zshrc
```

## Key Components

### Shell Prompt
- **Starship** - Modern, fast, cross-shell prompt with icons
- Automatically shows git status, language versions, and execution time
- No custom configuration needed (uses sensible defaults)

### Applications Installed
- **Raycast** - Spotlight replacement with powerful workflows
- **AlDente** - Battery health management
- **iTerm2** - Modern terminal emulator
- **Warp** - AI-powered terminal (alternative to iTerm2)
- **Visual Studio Code** - Code editor
- **Cursor** - AI-powered code editor
- **Docker Desktop** - Container management

### Development Tools
- Git, GitHub CLI (`gh`), Git LFS
- Python (`pyenv`, Python 3.10, 3.11)
- Node.js (`nvm`)
- Go, Rust
- Terraform (`tfenv`, `tgenv`)
- AWS CLI, AWS Vault
- Docker

### Productivity CLI Tools
- `jq` - JSON processor
- `yq` - YAML/JSON/XML processor
- `watchman` - File watching
- `fzf` - Fuzzy finder (if installed)
- `bat` - Better cat (if installed)
- `ripgrep` - Fast grep (if installed)

### Vim Setup
This configuration uses **vim-plug** for modern plugin management.

**Included plugins:**
- `vim-sensible` - Sensible defaults
- `vim-fugitive` - Git integration
- `vim-commentary` - Easy commenting (use `gcc` to toggle comments)
- `vim-surround` - Surround text objects
- `vim-gitgutter` - Git diff indicators in gutter
- `fzf.vim` - Fuzzy file finder
- `ale` - Asynchronous linting and fixing
- `nerdtree` - File explorer
- `vim-airline` - Enhanced status line

**Key bindings:**
- `Ctrl-t` - Toggle NERDTree file explorer
- `Ctrl-p` - Fuzzy find files
- `Ctrl-b` - Switch between buffers
- `Ctrl-f` - Search in files (ripgrep)
- `gcc` - Toggle comment on current line
- `F6` - Toggle paste mode

**First-time setup:**
After symlinking `.vimrc`, open vim and run:
```bash
vim +PlugInstall +qall
```

This will install all plugins automatically.

## Homebrew Commands

```bash
# Keep system updated
brew update                    # Update Homebrew itself
brew upgrade                   # Upgrade all packages
brew cleanup                   # Remove old versions

# Bundle management
brew bundle dump --force       # Update Brewfile from installed packages
brew bundle install            # Install packages from Brewfile
brew bundle check              # Verify Brewfile matches installed packages

# Maintenance
brew doctor                    # Check for issues

# Quick update script
~/.dotfiles/bin/brewdump       # Update Brewfile and push to git
```

## macOS System Preferences

Run the `.macos` script to set sensible macOS defaults:

```bash
~/.dotfiles/.macos
```

This configures:
- Finder settings (show hidden files, extensions, path bar)
- Dock settings (auto-hide, animations)
- Screenshot settings (PNG format, no shadow)
- Keyboard and trackpad improvements
- And more...

**Note:** Some changes require logout/restart to take effect.

## Shell Configuration

This dotfile configuration uses **Starship** for the shell prompt instead of custom oh-my-zsh themes.

### Why Starship?
- Fast, modern, and cross-shell compatible
- No custom fonts required for basic usage (but enhanced with Nerd Fonts)
- Automatically detects and shows context: git status, language versions, etc.
- Zero configuration needed - works great out of the box
- Highly customizable via `~/.config/starship.toml` if desired

### Customizing Starship (Optional)
To customize your prompt, create a configuration file:
```bash
mkdir -p ~/.config
touch ~/.config/starship.toml
```

Visit [starship.rs/config](https://starship.rs/config/) for configuration options.

### Legacy Theme (srh-agnoster)
If you prefer the old agnoster-based theme:
1. Restore from backup: `cp ~/.dotfiles/.zshrc.backup ~/.zshrc`
2. Install oh-my-zsh: https://ohmyz.sh/
3. Link the theme: `ln -s ~/.dotfiles/srh-agnoster.zsh-theme ~/.oh-my-zsh/custom/themes/`
4. Set `ZSH_THEME="srh-agnoster"` in `.zshrc`

## Updating

To keep everything in sync:

```bash
# Update Brewfile from what's currently installed
cd ~/.dotfiles
brew bundle dump --force

# Commit changes
git add Brewfile
git commit -m "Update Brewfile"
git push
```

## Troubleshooting

### Starship prompt shows boxes/question marks
Install a Nerd Font and configure your terminal to use it:
```bash
brew install font-meslo-lg-nerd-font
```
Then set the font in your terminal preferences.

### Restore old shell configuration
```bash
cp ~/.dotfiles/.zshrc.backup ~/.zshrc
source ~/.zshrc
```
