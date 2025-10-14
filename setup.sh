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

# Track errors but don't fail the entire script
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
            if [ "$AUTO_YES" = true ]; then
                info "Auto-accepting: replacing symlink"
                rm "$target"
            else
                read -p "Replace with $source? (y/n) " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    rm "$target"
                else
                    warning "Skipping $target"
                    return 0  # Don't fail the script, just skip
                fi
            fi
        fi
    elif [ -e "$target" ]; then
        # File exists but is not a symlink
        warning "File exists: $target"
        if [ "$AUTO_YES" = true ]; then
            info "Auto-accepting: backing up and replacing"
            mv "$target" "${target}.backup-$(date +%Y%m%d-%H%M%S)"
            success "Backed up existing file"
        else
            read -p "Backup and replace with symlink? (y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                mv "$target" "${target}.backup-$(date +%Y%m%d-%H%M%S)"
                success "Backed up existing file to ${target}.backup-$(date +%Y%m%d-%H%M%S)"
            else
                warning "Skipping $target"
                return 0  # Don't fail the script, just skip
            fi
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
        if [ "$AUTO_YES" = true ]; then
            info "Auto-accepting: installing Homebrew"
            if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
                # Add Homebrew to PATH for this session
                if [[ $(uname -m) == "arm64" ]]; then
                    eval "$(/opt/homebrew/bin/brew shellenv)"
                else
                    eval "$(/usr/local/bin/brew shellenv)"
                fi
                success "Homebrew installed"
            else
                error "Failed to install Homebrew"
            fi
        else
            read -p "Install Homebrew? (y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                info "Installing Homebrew..."
                if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
                    # Add Homebrew to PATH for this session
                    if [[ $(uname -m) == "arm64" ]]; then
                        eval "$(/opt/homebrew/bin/brew shellenv)"
                    else
                        eval "$(/usr/local/bin/brew shellenv)"
                    fi
                    success "Homebrew installed"
                else
                    error "Failed to install Homebrew"
                fi
            else
                warning "Homebrew not installed (required for package management)"
            fi
        fi
    else
        success "Homebrew found: $(brew --version | head -n1)"
    fi
    echo

    # Install packages from Brewfile
    if [ -f "$DOTFILES_DIR/Brewfile" ]; then
        info "Installing packages from Brewfile..."
        if [ "$AUTO_YES" = true ]; then
            if brew bundle install --file="$DOTFILES_DIR/Brewfile"; then
                success "Homebrew packages installed"
            else
                error "Some Homebrew packages failed to install"
            fi
        else
            read -p "Install/update Homebrew packages? (y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                if brew bundle install --file="$DOTFILES_DIR/Brewfile"; then
                    success "Homebrew packages installed"
                else
                    error "Some Homebrew packages failed to install"
                fi
            else
                warning "Skipped Homebrew package installation"
            fi
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
    safe_symlink "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"
    safe_symlink "$DOTFILES_DIR/.gemrc" "$HOME/.gemrc"
    safe_symlink "$DOTFILES_DIR/.terraformrc" "$HOME/.terraformrc"

    # Create .config directory if it doesn't exist
    mkdir -p "$HOME/.config"

    # Symlink XDG-compliant configs
    safe_symlink "$DOTFILES_DIR/.config/starship.toml" "$HOME/.config/starship.toml"
    safe_symlink "$DOTFILES_DIR/.config/git" "$HOME/.config/git"

    # Create .claude directory if it doesn't exist
    mkdir -p "$HOME/.claude"

    # Symlink Claude Code configuration
    safe_symlink "$DOTFILES_DIR/.claude/statusline-command.sh" "$HOME/.claude/statusline-command.sh"
    chmod +x "$HOME/.claude/statusline-command.sh"

    echo

    # Install Vim plugins
    if [ -f "$HOME/.vimrc" ]; then
        info "Installing Vim plugins..."
        if [ "$AUTO_YES" = true ]; then
            if vim +PlugInstall +qall 2>/dev/null; then
                success "Vim plugins installed"
            else
                error "Failed to install Vim plugins"
            fi
        else
            read -p "Install Vim plugins with vim-plug? (y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                if vim +PlugInstall +qall 2>/dev/null; then
                    success "Vim plugins installed"
                else
                    error "Failed to install Vim plugins"
                fi
            else
                warning "Skipped Vim plugin installation"
            fi
        fi
    fi
    echo

    # Check for oh-my-zsh
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        warning "oh-my-zsh not found!"
        if [ "$AUTO_YES" = true ]; then
            info "Auto-accepting: installing oh-my-zsh"
            if sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; then
                success "oh-my-zsh installed"
            else
                error "Failed to install oh-my-zsh"
            fi
        else
            read -p "Install oh-my-zsh? (y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                info "Installing oh-my-zsh..."
                if sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; then
                    success "oh-my-zsh installed"
                else
                    error "Failed to install oh-my-zsh"
                fi
            else
                warning "oh-my-zsh not installed (required for shell configuration)"
            fi
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
        if [ "$AUTO_YES" = true ]; then
            if bash "$DOTFILES_DIR/.macos"; then
                success "macOS defaults applied"
            else
                error "Failed to apply some macOS defaults"
            fi
        else
            read -p "Apply macOS defaults? (requires restart/logout for some changes) (y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                if bash "$DOTFILES_DIR/.macos"; then
                    success "macOS defaults applied"
                else
                    error "Failed to apply some macOS defaults"
                fi
            else
                warning "Skipped macOS defaults"
            fi
        fi
    fi
    echo

    # Final message
    echo
    if [ $ERROR_COUNT -eq 0 ]; then
        success "=========================================="
        success "Dotfiles setup complete!"
        success "=========================================="
    else
        warning "=========================================="
        warning "Dotfiles setup complete with $ERROR_COUNT error(s)"
        warning "=========================================="
        warning "Some steps failed but the script continued. Review errors above."
    fi
    echo
    info "Next steps:"
    echo "  1. Restart your terminal or run: source ~/.zshrc"
    echo "  2. Import iTerm2 color theme from $DOTFILES_DIR/iterm2/Tomorrow-Night.itermcolors (see README)"
    echo "  3. Set iTerm2 font to 'MesloLGM Nerd Font' (see README)"
    echo "  4. Configure Claude Code statusline (see README for manual setup)"
    echo "  5. Configure Raycast, AlDente, and other GUI apps"
    echo
    info "For more information, see: $DOTFILES_DIR/README.md"
    echo

    # Exit with error code if there were errors, but still show completion message
    if [ $ERROR_COUNT -gt 0 ]; then
        exit 1
    fi
}

# Run main function
main
