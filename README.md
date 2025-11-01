# Shaun's Dotfiles

Modern development environment configuration for macOS (2025).

## Quick Setup

### Automated Setup (Recommended)

```bash
git clone https://github.com/srhaber/dotfiles ~/.dotfiles
cd ~/.dotfiles
./setup.sh
```

**Non-interactive mode** (auto-accept all prompts):
```bash
./setup.sh -y
```

The setup script will:
- Install Homebrew (if not present)
- Install all packages from Brewfile
- Create symlinks for all dotfiles
- Install Vim plugins
- Install oh-my-zsh (if not present)
- Optionally apply macOS system preferences

**Safe & Idempotent:** The script checks before overwriting files and can be run multiple times safely.

**Command-line options:**
- `-y, --yes` - Auto-accept all prompts (non-interactive mode)
- `-h, --help` - Show usage information

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
ln -s ~/.dotfiles/.tmux.conf ~/.tmux.conf
ln -s ~/.dotfiles/.gemrc ~/.gemrc
ln -s ~/.dotfiles/.terraformrc ~/.terraformrc

# Create XDG-compliant config symlinks
mkdir -p ~/.config
ln -s ~/.dotfiles/.config/git ~/.config/git
ln -s ~/.dotfiles/.config/starship.toml ~/.config/starship.toml

# Create Claude Code global config symlinks
mkdir -p ~/.claude
ln -s ~/.dotfiles/claude-global/statusline-command.sh ~/.claude/statusline-command.sh
ln -s ~/.dotfiles/claude-global/CLAUDE.md ~/.claude/CLAUDE.md
ln -s ~/.dotfiles/claude-global/commands ~/.claude/commands
chmod +x ~/.claude/statusline-command.sh
```

### 5. Configure iTerm2

**Install color theme:**
1. Open iTerm2 and press `Cmd + ,` to open Preferences
2. Go to **Profiles** → **Colors**
3. Click **Color Presets** → **Import...**
4. Navigate to `~/.dotfiles/iterm2/Tomorrow-Night.itermcolors`
5. Select **Tomorrow Night** from the Color Presets dropdown

*Browse 425+ alternative color schemes at: https://github.com/mbadolato/iTerm2-Color-Schemes*

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

### Configuration Structure
This dotfiles repo follows the XDG Base Directory specification where supported:
- `~/.config/git/` - Git configuration (config, ignore patterns, helper scripts)
- `~/.config/starship.toml` - Starship prompt configuration
- Traditional dotfiles remain at `~/` for tools without XDG support (.zshrc, .vimrc, etc.)

### Installed Packages

**See [PACKAGES.md](PACKAGES.md)** for comprehensive package documentation including:
- All brews, casks, and VS Code extensions
- Descriptions, usage examples, and official links
- Package management commands
- Why each tool was included

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

## Package Management

See **[PACKAGES.md](PACKAGES.md)** for complete package management guide including Homebrew commands and version manager usage.

**Quick commands:**
```bash
brew bundle install            # Install from Brewfile
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


## Claude Code Setup

This repo includes both **global** and **project-specific** Claude Code configuration:

### Global Configuration (`claude-global/`)
Applies to all projects on your machine (symlinked to `~/.claude/`):
- **`claude-global/CLAUDE.md`** - Personal preferences and instructions for Claude across all projects
- **`claude-global/commands/`** - Global slash commands (e.g., `/save-session`)
- **`claude-global/statusline-command.sh`** - Custom statusline script

### Project-Specific Configuration (`.claude/`, `CLAUDE.md`)
Applies only when working in the dotfiles repo:
- **`.claude/`** - Project-specific slash commands or overrides (if needed)
- **`CLAUDE.md`** - Instructions specific to managing this dotfiles repository

### Statusline

The custom statusline displays:
- **Timestamp with timezone** - Shows day, date, time, and timezone (e.g., `[Tue 2025-10-14 14:30:45 PDT]`)
- **Current directory** - Full path to working directory
- **Git branch** - Current branch if in a git repository
- **Model name** - Which Claude model is being used
- **Session duration** - How long the current session has been active
- **Message count** - Number of messages in the current conversation

### Setup Instructions

After running `./setup.sh`, the global configuration from `claude-global/` will be symlinked to `~/.claude/`:
- `statusline-command.sh` - Custom statusline script
- `CLAUDE.md` - Personal Claude preferences and instructions
- `commands/` - Global slash commands directory

These configs will apply to all Claude Code sessions on your machine.

To enable the statusline, you need to manually configure the settings:

1. Create or edit `~/.claude/settings.json`:
```json
{
  "statusLine": {
    "type": "command",
    "command": "/Users/YOUR_USERNAME/.claude/statusline-command.sh"
  }
}
```

2. Replace `YOUR_USERNAME` with your actual username

3. Restart Claude Code to see the new statusline

### Example Output

```
[Tue 2025-10-14 14:30:45 PDT] /Users/shaber/dotfiles on master
Claude 3.5 Sonnet (15m23s) (52 msgs)
```

The statusline updates automatically as you work, showing real-time session information.
