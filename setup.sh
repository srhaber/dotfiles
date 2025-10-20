#!/bin/bash

# Dotfiles Setup Script
# Safe, idempotent installation of dotfiles and configuration
# Usage: ./setup.sh [OPTIONS]

# Show usage information
usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Safe, idempotent installation of dotfiles and configuration.

OPTIONS:
    -y, --yes       Auto-accept all prompts (non-interactive mode)
    -h, --help      Show this help message and exit

EXAMPLES:
    $(basename "$0")           # Interactive mode (default)
    $(basename "$0") -y        # Auto-accept all prompts
    $(basename "$0") --help    # Show this help

EOF
    exit 0
}

# Parse command line arguments
AUTO_YES=false
while [[ $# -gt 0 ]]; do
    case $1 in
        -y|--yes)
            AUTO_YES=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            echo "Run '$(basename "$0") --help' for usage information."
            exit 1
            ;;
    esac
done

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Track errors
ERROR_COUNT=0

# Helper functions
info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    ((ERROR_COUNT++))
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Prompt helper - returns 0 for yes, 1 for no
prompt_or_auto() {
    local prompt="$1"
    if [ "$AUTO_YES" = true ]; then
        return 0
    fi
    read -p "$prompt (y/n) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

# Backup existing file with timestamp
backup_file() {
    local file="$1"
    local backup="${file}.backup-$(date +%Y%m%d-%H%M%S)"
    mv "$file" "$backup"
    info "Backed up: $backup"
}

# Create symlink with proper handling
safe_symlink() {
    local source="$1"
    local target="$2"

    # Already correctly linked
    if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
        return 0
    fi

    # Existing symlink pointing elsewhere
    if [ -L "$target" ]; then
        warning "Symlink exists but points to: $(readlink "$target")"
        if prompt_or_auto "Replace with $source?"; then
            rm "$target"
        else
            return 0
        fi
    fi

    # Regular file exists
    if [ -e "$target" ]; then
        warning "File exists: $target"
        if prompt_or_auto "Backup and replace with symlink?"; then
            backup_file "$target"
        else
            return 0
        fi
    fi

    ln -s "$source" "$target"
    success "Linked: $target"
}

# Generic component installer
install_component() {
    local name="$1"
    local check_cmd="$2"
    local install_cmd="$3"
    local prompt_msg="$4"

    if eval "$check_cmd"; then
        success "$name found"
        return 0
    fi

    warning "$name not found"
    if prompt_or_auto "$prompt_msg"; then
        if eval "$install_cmd"; then
            success "$name installed"
            return 0
        else
            error "Failed to install $name"
            return 1
        fi
    else
        warning "$name not installed"
        return 1
    fi
}

# Main setup
main() {
    info "Starting dotfiles setup..."
    echo

    # Get script directory
    DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    info "Dotfiles directory: $DOTFILES_DIR"
    echo

    # Install Homebrew
    install_component \
        "Homebrew" \
        "command_exists brew" \
        "/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\" && \
         if [[ \$(uname -m) == 'arm64' ]]; then eval \"\$(/opt/homebrew/bin/brew shellenv)\"; \
         else eval \"\$(/usr/local/bin/brew shellenv)\"; fi" \
        "Install Homebrew?"
    echo

    # Install packages from Brewfile
    if [ -f "$DOTFILES_DIR/Brewfile" ]; then
        if prompt_or_auto "Install/update Homebrew packages?"; then
            info "Installing packages from Brewfile..."
            if brew bundle install --file="$DOTFILES_DIR/Brewfile"; then
                success "Homebrew packages installed"
            else
                error "Some Homebrew packages failed to install"
            fi
        else
            warning "Skipped Homebrew package installation"
        fi
    else
        warning "Brewfile not found, skipping package installation"
    fi
    echo

    # Create symlinks
    info "Creating symlinks for dotfiles..."

    # Traditional dotfiles
    declare -a DOTFILES=(
        ".zshrc"
        ".vimrc"
        ".tmux.conf"
        ".gemrc"
        ".terraformrc"
    )

    for file in "${DOTFILES[@]}"; do
        safe_symlink "$DOTFILES_DIR/$file" "$HOME/$file"
    done

    # XDG-compliant configs
    mkdir -p "$HOME/.config"
    safe_symlink "$DOTFILES_DIR/.config/starship.toml" "$HOME/.config/starship.toml"
    safe_symlink "$DOTFILES_DIR/.config/git" "$HOME/.config/git"

    # Claude Code configuration
    mkdir -p "$HOME/.claude"
    safe_symlink "$DOTFILES_DIR/.claude/statusline-command.sh" "$HOME/.claude/statusline-command.sh"
    chmod +x "$HOME/.claude/statusline-command.sh" 2>/dev/null
    echo

    # Install Vim plugins
    if [ -f "$HOME/.vimrc" ] && prompt_or_auto "Install Vim plugins with vim-plug?"; then
        info "Installing Vim plugins..."
        if vim +PlugInstall +qall 2>/dev/null; then
            success "Vim plugins installed"
        else
            error "Failed to install Vim plugins"
        fi
    fi
    echo

    # Install oh-my-zsh
    install_component \
        "oh-my-zsh" \
        "[ -d \"\$HOME/.oh-my-zsh\" ]" \
        "sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\" \"\" --unattended" \
        "Install oh-my-zsh?"
    echo

    # Verify Starship
    if command_exists starship; then
        success "Starship found: $(starship --version)"
    else
        warning "Starship not found (should be installed via Brewfile)"
    fi
    echo

    # Install Claude Code
    install_component \
        "Claude Code" \
        "command_exists claude" \
        "npm install -g @anthropics/claude-code 2>/dev/null" \
        "Install Claude Code via npm? (requires Node.js)"
    echo

    # Apply macOS defaults
    if [ -f "$DOTFILES_DIR/.macos" ]; then
        if prompt_or_auto "Apply macOS defaults? (requires restart/logout for some changes)"; then
            info "Applying macOS defaults..."
            if bash "$DOTFILES_DIR/.macos"; then
                success "macOS defaults applied"
            else
                error "Failed to apply some macOS defaults"
            fi
        else
            warning "Skipped macOS defaults"
        fi
    fi
    echo

    # Final summary
    if [ $ERROR_COUNT -eq 0 ]; then
        success "=========================================="
        success "Dotfiles setup complete!"
        success "=========================================="
    else
        warning "=========================================="
        warning "Setup complete with $ERROR_COUNT error(s)"
        warning "=========================================="
    fi
    echo

    info "Next steps:"
    echo "  1. Restart your terminal or run: source ~/.zshrc"
    echo "  2. Import iTerm2 color theme from $DOTFILES_DIR/iterm2/"
    echo "  3. Set iTerm2 font to 'MesloLGM Nerd Font'"
    echo "  4. Configure GUI apps (Raycast, AlDente, etc.)"
    echo
    info "For more information, see: $DOTFILES_DIR/README.md"

    [ $ERROR_COUNT -gt 0 ] && exit 1
    exit 0
}

# Run main function
main
