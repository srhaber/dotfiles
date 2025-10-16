tap "homebrew/bundle"

# ==============================================================================
# Homebrew Bundle for Modern macOS Development Environment
# ==============================================================================
# For detailed information about each package, see PACKAGES.md
# To install: brew bundle install --file=Brewfile
# To verify: brew bundle check --file=Brewfile
# To update: brew bundle dump --force --file=Brewfile

# ==============================================================================
# CORE SYSTEM UTILITIES
# ==============================================================================
# GNU utilities and low-level system tools

# GNU File, Shell, and Text utilities - Core GNU tools (mv, cp, ls, etc.)
brew "coreutils"
# Generic library support script - Build tool for libraries
brew "libtool"
# Utility for directing compilation - Build automation
brew "make"
# Tool for generating GNU Standards-compliant Makefiles
brew "automake"
# Cross-platform make - CMake build system
brew "cmake"
# Object-file caching compiler wrapper - Speed up compilation
brew "ccache"

# ==============================================================================
# MODERN CLI REPLACEMENTS
# ==============================================================================
# Modern alternatives to traditional Unix tools with better UX and performance

# Clone of cat(1) with syntax highlighting and Git integration
brew "bat"
# Syntax-highlighting pager for git and diff output
brew "delta"
# Modern, maintained replacement for ls
brew "eza"
# Simple, fast and user-friendly alternative to find
brew "fd"
# Command-line fuzzy finder - Essential for shell/vim workflows
brew "fzf"
# Improved top (interactive process viewer)
brew "htop"
# Search tool like grep and The Silver Searcher - Extremely fast code search
brew "ripgrep"
# Display directories as trees (with optional color/HTML output)
brew "tree"

# ==============================================================================
# VERSION CONTROL
# ==============================================================================
# Git and GitHub tools

# Distributed revision control system
brew "git"
# Git extension for versioning large files
brew "git-lfs"
# GitHub command-line tool - Official GitHub CLI (replaces deprecated 'hub')
brew "gh"

# ==============================================================================
# PROGRAMMING LANGUAGES & RUNTIMES
# ==============================================================================
# Language installations and version managers

# Open source programming language to build simple/reliable/efficient software
brew "go"
# Platform built on V8 to build network applications
brew "node"
# Manage multiple Node.js versions
brew "nodenv"
# Python version management - Use this instead of brew python versions
brew "pyenv"
# Safe, concurrent, practical language
brew "rust"
# Development kit for the Java programming language
brew "openjdk@11", link: true

# ==============================================================================
# TERMINAL & SHELL
# ==============================================================================
# Terminal multiplexer and shell enhancements

# Terminal multiplexer - Split terminals, session persistence
brew "tmux"
# Cross-shell prompt for astronauts - Modern, fast prompt
brew "starship"

# ==============================================================================
# KUBERNETES & CONTAINER ORCHESTRATION
# ==============================================================================
# Kubernetes CLI tools

# Kubernetes command-line interface - kubectl
brew "kubernetes-cli"
# Kubernetes CLI To Manage Your Clusters In Style! - Terminal UI for k8s
brew "k9s"

# ==============================================================================
# AWS & CLOUD TOOLS
# ==============================================================================
# AWS CLI and credential management

# Official Amazon AWS command-line interface
brew "awscli"
# Securely store and access AWS credentials in development environments
brew "aws-vault"

# ==============================================================================
# INFRASTRUCTURE AS CODE
# ==============================================================================
# Terraform and related tools

# Terraform version manager inspired by rbenv
brew "tfenv"
# Terragrunt version manager inspired by tfenv
brew "tgenv"

# ==============================================================================
# BUILD TOOLS & CI/CD
# ==============================================================================
# Build systems and artifact management

# User-friendly launcher for Bazel - Google's build system
brew "bazelisk"
# Command-line interface for JFrog products - Artifact management
brew "jfrog-cli"
# Watch files and take action when they change - Build automation
brew "watchman"

# ==============================================================================
# DATA PROCESSING & FORMATS
# ==============================================================================
# JSON, YAML, and data manipulation tools

# Lightweight and flexible command-line JSON processor
brew "jq"
# Process YAML, JSON, XML, CSV and properties documents from the CLI
brew "yq"
# Domain specific configuration language for defining JSON data
brew "jsonnet"

# ==============================================================================
# MONITORING & OBSERVABILITY
# ==============================================================================
# System monitoring and metrics

# Service monitoring system and time series database
brew "prometheus"

# ==============================================================================
# NETWORKING & DEBUGGING
# ==============================================================================
# Network utilities and debugging tools

# Internet file retriever - Download files via HTTP/HTTPS/FTP
brew "wget"
# Utility that provides fast incremental file transfer
brew "rsync"
# Traceroute implementation using TCP packets
brew "tcptraceroute"

# ==============================================================================
# SECURITY & CERTIFICATES
# ==============================================================================
# TLS/SSL and certificate management

# Simple tool to make locally trusted development certificates
brew "mkcert"
# Libraries for security-enabled client and server applications
brew "nss"

# ==============================================================================
# DOCUMENT & IMAGE PROCESSING
# ==============================================================================
# PDF, image manipulation, and document tools

# PDF rendering library - Extract text/data from PDFs
brew "poppler"
# Image manipulation library - JPEG processing
brew "jpeg"
# Library for JPEG-2000 image manipulation
brew "openjpeg"
# Optimized BLAS library - Linear algebra computations
brew "openblas"

# ==============================================================================
# TEXT & DIFF TOOLS
# ==============================================================================
# Text processing and comparison

# Diff that operates at the word level - Better diff output
brew "dwdiff"
# Autoformat shell script source code - Shell script linter/formatter
brew "shfmt"

# ==============================================================================
# ANDROID DEVELOPMENT
# ==============================================================================
# Android-specific tools

# Colored logcat script to show entries only for specified app
brew "pidcat"

# ==============================================================================
# APPLICATIONS (CASKS)
# ==============================================================================
# GUI applications installed via Homebrew

# Battery health management and charging control
cask "aldente"
# Meslo Nerd Font with icon support for terminals
cask "font-meslo-lg-nerd-font"
# Write, edit, and chat about your code with AI
cask "cursor"
# App to build and share containerised applications and microservices
cask "docker-desktop"
# Replacement for Terminal and the successor to iTerm
cask "iterm2"
# Control your tools with a few keystrokes - Spotlight replacement
cask "raycast"
# Plugin for AWS CLI to start and end sessions that connect to managed instances
cask "session-manager-plugin"
# Open-source code editor
cask "visual-studio-code"
# Rust-based terminal with AI features
cask "warp"

# ==============================================================================
# VS CODE EXTENSIONS
# ==============================================================================
# Visual Studio Code extensions

vscode "eamodio.gitlens"
vscode "esbenp.prettier-vscode"
vscode "hashicorp.terraform"
vscode "ms-vscode-remote.remote-containers"
vscode "ms-vscode-remote.remote-ssh"
vscode "ms-vscode-remote.remote-ssh-edit"
vscode "ms-vscode-remote.remote-wsl"
vscode "ms-vscode-remote.vscode-remote-extensionpack"
vscode "ms-vscode.remote-explorer"
vscode "ms-vscode.remote-server"
