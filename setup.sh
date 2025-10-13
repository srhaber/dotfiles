#!/bin/bash

# Dotfiles Setup Script
# Safe, idempotent installation of dotfiles and configuration
# Usage: ./setup.sh

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Create symlink if it doesn't exist or is different
safe_symlink() {
    local source="$1"
    local target="$2"

    if [ -L "$target" ]; then
        # It's already a symlink
        local current_source=$(readlink "$target")
        if [ "$current_source" = "$source" ]; then
            info "Symlink already correct: $target -> $source"
            return 0
        else
            warning "Symlink exists but points elsewhere: $target -> $current_source"
            read -p "Replace with $source? (y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                rm "$target"
            else
                warning "Skipping $target"
                return 1
            fi
        fi
    elif [ -e "$target" ]; then
        # File exists but is not a symlink
        warning "File exists: $target"
        read -p "Backup and replace with symlink? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            mv "$target" "${target}.backup-$(date +%Y%m%d-%H%M%S)"
            success "Backed up existing file to ${target}.backup-$(date +%Y%m%d-%H%M%S)"
        else
            warning "Skipping $target"
            return 1
        fi
    fi

    ln -s "$source" "$target"
    success "Created symlink: $target -> $source"
}

# Main setup
main() {
    echo
    info "Starting dotfiles setup..."
    echo

    # Get the directory where this script is located
    DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    info "Dotfiles directory: $DOTFILES_DIR"
    echo

    # Check if Homebrew is installed
    if ! command_exists brew; then
        warning "Homebrew not found!"
        read -p "Install Homebrew? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            info "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

            # Add Homebrew to PATH for this session
            if [[ $(uname -m) == "arm64" ]]; then
                eval "$(/opt/homebrew/bin/brew shellenv)"
            else
                eval "$(/usr/local/bin/brew shellenv)"
            fi
            success "Homebrew installed"
        else
            error "Homebrew is required. Exiting."
            exit 1
        fi
    else
        success "Homebrew found: $(brew --version | head -n1)"
    fi
    echo

    # Install packages from Brewfile
    if [ -f "$DOTFILES_DIR/Brewfile" ]; then
        info "Installing packages from Brewfile..."
        read -p "Install/update Homebrew packages? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            brew bundle install --file="$DOTFILES_DIR/Brewfile"
            success "Homebrew packages installed"
        else
            warning "Skipped Homebrew package installation"
        fi
    else
        warning "Brewfile not found, skipping package installation"
    fi
    echo

    # Create symlinks for dotfiles
    info "Creating symlinks for dotfiles..."
    echo

    safe_symlink "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
    safe_symlink "$DOTFILES_DIR/.vimrc" "$HOME/.vimrc"
    safe_symlink "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
    safe_symlink "$DOTFILES_DIR/.gitignore_global" "$HOME/.gitignore_global"
    safe_symlink "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"
    safe_symlink "$DOTFILES_DIR/.gemrc" "$HOME/.gemrc"
    safe_symlink "$DOTFILES_DIR/.terraformrc" "$HOME/.terraformrc"

    echo

    # Install Vim plugins
    if [ -f "$HOME/.vimrc" ]; then
        info "Installing Vim plugins..."
        read -p "Install Vim plugins with vim-plug? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            vim +PlugInstall +qall
            success "Vim plugins installed"
        else
            warning "Skipped Vim plugin installation"
        fi
    fi
    echo

    # Check for oh-my-zsh
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        warning "oh-my-zsh not found!"
        read -p "Install oh-my-zsh? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            info "Installing oh-my-zsh..."
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
            success "oh-my-zsh installed"
        else
            warning "oh-my-zsh not installed (required for shell configuration)"
        fi
    else
        success "oh-my-zsh found"
    fi
    echo

    # Check for Starship
    if ! command_exists starship; then
        warning "Starship not found (should be installed via Brewfile)"
    else
        success "Starship found: $(starship --version)"
    fi
    echo

    # Apply macOS defaults
    if [ -f "$DOTFILES_DIR/.macos" ]; then
        info "macOS system preferences script found"
        read -p "Apply macOS defaults? (requires restart/logout for some changes) (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            bash "$DOTFILES_DIR/.macos"
            success "macOS defaults applied"
        else
            warning "Skipped macOS defaults"
        fi
    fi
    echo

    # Final message
    echo
    success "=========================================="
    success "Dotfiles setup complete!"
    success "=========================================="
    echo
    info "Next steps:"
    echo "  1. Restart your terminal or run: source ~/.zshrc"
    echo "  2. Install iTerm2 color theme manually (see README)"
    echo "  3. Set iTerm2 font to 'MesloLGM Nerd Font' (see README)"
    echo "  4. Configure Raycast, AlDente, and other GUI apps"
    echo
    info "For more information, see: $DOTFILES_DIR/README.md"
    echo
}

# Run main function
main
