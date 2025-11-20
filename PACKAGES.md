# Package Reference

This document provides detailed information about all packages in the [Brewfile](Brewfile), organized by category.

---

## Core System Utilities

Low-level GNU utilities and build tools that provide foundational system functionality.

| Package | Purpose | Why Included |
|---------|---------|--------------|
| **coreutils** | GNU File, Shell, and Text utilities | Provides GNU versions of core commands (mv, cp, ls, etc.) which are more feature-rich than macOS BSD versions |
| **libtool** | Generic library support script | Required for building many open-source libraries from source |
| **make** | Build automation tool | Essential for compiling software and running project build scripts |
| **automake** | Makefile generator | Generates GNU-compliant Makefiles for portable builds |
| **cmake** | Cross-platform build system | Modern build system used by many C/C++ projects |
| **ccache** | Compiler cache | Speeds up recompilation by caching previous compilations |

---

## Modern CLI Replacements

Modern alternatives to traditional Unix tools with better UX, performance, and features. These are the 2025 standard for developer environments.

| Package | Replaces | Why Better | Links |
|---------|----------|------------|-------|
| **bat** | cat | Syntax highlighting, Git integration, line numbers, paging | [github.com/sharkdp/bat](https://github.com/sharkdp/bat) |
| **delta** | diff | Syntax highlighting, side-by-side diffs, better git integration | [github.com/dandavison/delta](https://github.com/dandavison/delta) |
| **eza** | ls | Colors, icons, git status, tree view | [github.com/eza-community/eza](https://github.com/eza-community/eza) |
| **fd** | find | Simpler syntax, faster, respects .gitignore, colored output | [github.com/sharkdp/fd](https://github.com/sharkdp/fd) |
| **fzf** | - | Fuzzy finder for files/history/commands (essential for shell/vim) | [github.com/junegunn/fzf](https://github.com/junegunn/fzf) |
| **glow** | - | Render markdown on the CLI with syntax highlighting and formatting | [github.com/charmbracelet/glow](https://github.com/charmbracelet/glow) |
| **htop** | top | Interactive, colored, mouse support, tree view | [htop.dev](https://htop.dev) |
| **ripgrep** | grep | 10-100x faster, respects .gitignore, better regex | [github.com/BurntSushi/ripgrep](https://github.com/BurntSushi/ripgrep) |
| **tree** | - | Visual directory tree structure | Standard Unix utility |

**Aliases configured:** `b` and `bcat` for bat (see [aliases.sh](aliases.sh))

---

## Version Control

Git and GitHub integration tools.

| Package | Purpose | Notes |
|---------|---------|-------|
| **git** | Distributed version control | Core VCS |
| **git-lfs** | Git Large File Storage | Handles large binary files in git repos |
| **gh** | GitHub CLI | Official GitHub CLI for PRs, issues, actions (replaces deprecated `hub`) |

**Custom git configuration:** See [.config/git/](.config/git/) for custom aliases, helpers, and global ignore patterns.

**Key git aliases:**
- `git l` - Pretty formatted log
- `git b` - Pretty formatted branches
- `git bs` - Branches sorted by commit date
- `git hp` - Show head commit with diff

---

## Programming Languages & Runtimes

Language installations and version managers. Version managers are preferred over direct installations for flexibility across projects.

| Package | Language | Type | Notes |
|---------|----------|------|-------|
| **go** | Go | Direct install | Single version, manually update as needed |
| **node** | Node.js | Direct install | Base installation |
| **nodenv** | Node.js | Version manager | Manage multiple Node.js versions per project |
| **pyenv** | Python | Version manager | Manage Python versions (preferred over `brew install python@X.Y`) |
| **rust** | Rust | Direct install | Includes cargo package manager |
| **openjdk@11** | Java | Direct install | Java 11 LTS with link to system java |

**Important:** For Python, use `pyenv` to install specific versions rather than installing `python@3.x` via brew. This provides better project isolation and version management.

**nvm alternative:** While `nodenv` is included for Node version management, you can also use `nvm` (install manually from [github.com/nvm-sh/nvm](https://github.com/nvm-sh/nvm)). The [.zshrc](.zshrc) is configured to load nvm if present.

---

## Terminal & Shell

Terminal multiplexer and prompt enhancement.

| Package | Purpose | Configuration |
|---------|---------|---------------|
| **tmux** | Terminal multiplexer | Config: [.tmux.conf](.tmux.conf) - Enables split panes, session persistence |
| **starship** | Cross-shell prompt | Config: [.config/starship.toml](.config/starship.toml) - Shows git status, timestamps, exit codes |

**Starship features:** Fast, shows git branch/status, language versions, command duration, and custom timestamps with timezone.

**Starship config highlights:**
- Full date/time format: `%F %T %Z`
- Shows day of week
- Exit code display on failure
- Custom format without "at" prefix

---

## Kubernetes & Container Orchestration

Kubernetes CLI tools for cluster management.

| Package | Purpose | Interface |
|---------|---------|-----------|
| **kubernetes-cli** | kubectl | Command-line interface for Kubernetes clusters |
| **k9s** | Kubernetes TUI | Terminal UI for managing k8s clusters - navigate, inspect, manage resources with keyboard |

**k9s** is a powerful TUI that makes k8s management faster than raw kubectl commands. Features include:
- Real-time cluster resource monitoring
- Interactive pod logs and shell access
- Quick resource deletion/editing
- Vim-like keybindings

Learn more: [k9scli.io](https://k9scli.io)

---

## AWS & Cloud Tools

AWS CLI and secure credential management.

| Package | Purpose | Usage |
|---------|---------|-------|
| **awscli** | AWS CLI v2 | Official AWS command-line interface |
| **aws-vault** | Credential manager | Securely store and access AWS credentials, manages MFA tokens |

**Aliases configured:**
- `awsv` - aws-vault shortcut
- `awsl` - aws-vault login
- `awse` - aws-vault exec

See [aliases.sh](aliases.sh) for details.

**aws-vault benefits:**
- Stores credentials in system keychain (more secure than ~/.aws/credentials)
- Automatic MFA token management
- Session management and expiration
- Works with AWS SSO

---

## Infrastructure as Code

Terraform tooling with version management.

| Package | Purpose | Why Version Manager |
|---------|---------|---------------------|
| **tfenv** | Terraform version manager | Different projects often require different Terraform versions |
| **tgenv** | Terragrunt version manager | Manages Terragrunt versions alongside Terraform |

**Usage examples:**
```bash
# Terraform version management
tfenv list-remote         # List available versions
tfenv install 1.6.0       # Install specific version
tfenv use 1.6.0          # Use specific version
tfenv list               # List installed versions

# Terragrunt version management
tgenv list-remote
tgenv install 0.55.0
tgenv use 0.55.0
```

**Project-specific versions:** Create `.terraform-version` or `.terragrunt-version` files in project roots to automatically switch versions.

---

## Build Tools & CI/CD

Build systems and artifact management for large-scale projects.

| Package | Purpose | Use Case |
|---------|---------|----------|
| **bazelisk** | Bazel launcher | Automatically downloads correct Bazel version (Google's build system) |
| **jfrog-cli** | JFrog CLI | Interact with JFrog Artifactory for artifact management |
| **watchman** | File watcher | Watches file changes, triggers builds (used by React Native, Metro bundler, etc.) |

**Bazelisk:** Reads `.bazelversion` file in project root and automatically uses the correct Bazel version. Eliminates "works on my machine" issues.

**Watchman:** High-performance file watching service. More efficient than filesystem polling, especially for large codebases.

---

## Data Processing & Formats

JSON/YAML processors for configuration and data manipulation.

| Package | Purpose | Common Usage |
|---------|---------|--------------|
| **jq** | JSON processor | `cat file.json \| jq '.field'` - Query, filter, transform JSON |
| **yq** | YAML/JSON/XML processor | Like jq but for YAML (also handles JSON, XML, CSV) |
| **jsonnet** | Data templating | Generate JSON configuration from templates (infrastructure as code) |

**jq examples:**
```bash
curl https://api.github.com/repos/srhaber/dotfiles | jq '.stargazers_count'
echo '{"name":"value"}' | jq '.name'
jq '.items[] | select(.price > 10)' products.json
```

**yq examples:**
```bash
yq eval '.spec.containers[0].image' deployment.yaml
yq -o json eval deployment.yaml  # Convert YAML to JSON
```

---

## Monitoring & Observability

System and application monitoring.

| Package | Purpose | Use Case |
|---------|---------|----------|
| **prometheus** | Time-series database | Monitoring system for metrics collection, alerting, and visualization |

**Prometheus features:**
- Time-series metrics storage
- Powerful query language (PromQL)
- Service discovery
- Alerting integration

---

## Networking & Debugging

Network utilities and file transfer tools.

| Package | Purpose | Notes |
|---------|---------|-------|
| **wget** | File downloader | HTTP/HTTPS/FTP downloads (alternative to curl, supports recursion) |
| **rsync** | File synchronization | Fast incremental file transfer and backup |
| **tcptraceroute** | TCP traceroute | Traceroute using TCP packets (often works when ICMP is blocked) |

**rsync common usage:**
```bash
rsync -avz source/ destination/  # Archive mode, verbose, compressed
rsync -avz --delete source/ dest/  # Sync and delete files not in source
```

---

## Security & Certificates

TLS/SSL certificate management for local development.

| Package | Purpose | Usage |
|---------|---------|-------|
| **mkcert** | Local certificate generator | Create locally-trusted HTTPS certificates for development |
| **nss** | Network Security Services | Mozilla's security library (required by some apps for certificate handling) |

**mkcert setup:**
```bash
mkcert -install                    # Install local CA (one-time setup)
mkcert example.local localhost     # Create certificate for domains
mkcert "*.example.local"          # Wildcard certificate
```

Certificates are automatically trusted by browsers and system. No more security warnings in local development!

---

## Document & Image Processing

PDF, image, and document manipulation libraries.

| Package | Purpose | Use Case |
|---------|---------|----------|
| **poppler** | PDF rendering library | Extract text/data from PDFs, convert PDFs with `pdftotext`, `pdfinfo`, etc. |
| **jpeg** | JPEG library | Image manipulation and processing |
| **openjpeg** | JPEG-2000 library | Handle JPEG-2000 format images |
| **openblas** | Linear algebra library | Optimized BLAS (Basic Linear Algebra Subprograms) for scientific computing |

**poppler tools:**
```bash
pdftotext document.pdf output.txt  # Extract text
pdfinfo document.pdf              # Show PDF metadata
pdftoppm -png document.pdf page   # Convert pages to images
```

---

## Text & Diff Tools

Text processing and code formatting.

| Package | Purpose | Usage |
|---------|---------|-------|
| **dwdiff** | Word-level diff | Show differences at word level instead of line level |
| **shfmt** | Shell formatter | Format shell scripts with consistent style |

**shfmt usage:**
```bash
shfmt -i 2 -w script.sh    # Format with 2-space indent, write back
shfmt -d .                 # Check formatting (dry-run)
```

Configured to format with 2-space indentation, simplify code, and follow Google's shell style guide.

---

## Android Development

Android-specific development tools.

| Package | Purpose | Usage |
|---------|---------|-------|
| **pidcat** | Colored logcat | Filter and color Android logcat output by app package name |

**pidcat usage:**
```bash
pidcat com.example.app           # Show logs for specific app
pidcat com.example.app -t MyTag  # Filter by tag
```

Much more readable than raw `adb logcat` with automatic color coding by log level.

---

## Applications (Casks)

GUI applications installed via Homebrew.

| Application | Category | Purpose | Website |
|-------------|----------|---------|---------|
| **font-meslo-lg-nerd-font** | Font | Nerd Font with icons for Starship prompt and terminal | [nerdfonts.com](https://www.nerdfonts.com/) |
| **Cursor** | Editor | AI-powered code editor (fork of VS Code) with built-in AI chat | [cursor.sh](https://cursor.sh/) |
| **Docker Desktop** | Development | Container management with GUI, includes Docker Engine and Kubernetes | [docker.com](https://www.docker.com/products/docker-desktop/) |
| **iTerm2** | Terminal | Modern terminal emulator with split panes, search, themes, tmux integration | [iterm2.com](https://iterm2.com/) |
| **Raycast** | Productivity | Spotlight replacement with clipboard history, window management, workflows | [raycast.com](https://www.raycast.com/) |
| **session-manager-plugin** | AWS | AWS Systems Manager plugin for AWS CLI to connect to EC2 instances | [AWS Docs](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html) |
| **Visual Studio Code** | Editor | Popular code editor with extensive extension ecosystem | [code.visualstudio.com](https://code.visualstudio.com/) |
| **Warp** | Terminal | Rust-based terminal with AI features, modern UX, and command completion | [warp.dev](https://www.warp.dev/) |

**Terminal comparison:**
- **iTerm2:** Traditional, stable, highly configurable, wide compatibility
- **Warp:** Modern, AI-powered, blocks-based interface, built-in command history search

**Editor comparison:**
- **VS Code:** Mature, extensive extensions, widely adopted
- **Cursor:** AI-first, copilot-like features built-in, VS Code compatible

---

## VS Code Extensions

Essential extensions for VS Code development.

| Extension | ID | Purpose |
|-----------|-----|---------|
| **Claude Code** | `anthropic.claude-code` | AI pair programming with Claude directly in VS Code |
| **GitLens** | `eamodio.gitlens` | Enhanced git integration, blame annotations, history exploration |
| **Prettier** | `esbenp.prettier-vscode` | Code formatter for JS/TS/CSS/HTML/JSON/Markdown |
| **GitHub Copilot** | `github.copilot` | AI pair programmer for code suggestions and completions |
| **GitHub Copilot Chat** | `github.copilot-chat` | Chat interface for GitHub Copilot |
| **Terraform** | `hashicorp.terraform` | Terraform syntax highlighting, validation, formatting, IntelliSense |
| **Azure Container Tools** | `ms-azuretools.vscode-containers` | Docker and container management tools |
| **Python Debugger** | `ms-python.debugpy` | Python debugging support |
| **Python** | `ms-python.python` | Python language support with IntelliSense, linting, debugging |
| **Pylance** | `ms-python.vscode-pylance` | Fast Python language server with type checking |
| **Python Environments** | `ms-python.vscode-python-envs` | Manage Python virtual environments and interpreters |
| **Remote - Containers** | `ms-vscode-remote.remote-containers` | Develop inside Docker containers |
| **Remote - SSH** | `ms-vscode-remote.remote-ssh` | Open folders on remote machines via SSH |
| **Remote - SSH: Editing** | `ms-vscode-remote.remote-ssh-edit` | Edit SSH configuration files |
| **Remote - WSL** | `ms-vscode-remote.remote-wsl` | Develop in Windows Subsystem for Linux |
| **Remote Development** | `ms-vscode-remote.vscode-remote-extensionpack` | Extension pack for remote development |
| **Remote Explorer** | `ms-vscode.remote-explorer` | View and manage remote connections |
| **Remote - Tunnels** | `ms-vscode.remote-server` | Connect to remote machines via tunnels |

**AI Assistants:** Claude Code and GitHub Copilot provide AI-powered code suggestions, completions, and chat interfaces for pair programming.

**Python Development:** The Python extensions provide a complete development environment with IntelliSense, debugging, linting, formatting, and virtual environment management.

**Remote Development:** The suite of remote extensions allows seamless development on remote machines, in containers, or in WSL as if working locally.

---

## Package Management Commands

Quick reference for managing packages in this environment.

### Homebrew Commands
```bash
# Update package lists
brew update

# Upgrade all packages
brew upgrade

# Install from Brewfile
brew bundle install --file=Brewfile

# Check if Brewfile matches installed packages
brew bundle check --file=Brewfile

# Update Brewfile from installed packages
brew bundle dump --force --file=Brewfile

# Clean up old versions
brew cleanup
```

### Version Manager Commands
```bash
# pyenv (Python)
pyenv install 3.11.0
pyenv global 3.11.0
pyenv versions

# nodenv (Node.js)
nodenv install 20.0.0
nodenv global 20.0.0
nodenv versions

# tfenv (Terraform)
tfenv install 1.6.0
tfenv use 1.6.0
tfenv list

# tgenv (Terragrunt)
tgenv install 0.55.0
tgenv use 0.55.0
tgenv list
```

### Custom Scripts
```bash
# Update Brewfile and commit to git
~/.dotfiles/scripts/brewdump
```

---

## Package Selection Philosophy

This Brewfile follows these principles:

1. **Version managers over direct installs** - Use `pyenv`, `nodenv`, `tfenv`, etc. for flexibility
2. **Modern CLI tools** - Prefer faster, more user-friendly alternatives (ripgrep, fd, bat, etc.)
3. **Essential only** - Only include tools that are regularly used or hard to install otherwise
4. **Avoid redundancy** - Remove deprecated tools (hub → gh), prefer single solution per category
5. **Declarative infrastructure** - Everything in Brewfile for reproducibility

---

## Adding New Packages

To add a new package to this environment:

1. Search for the package:
   ```bash
   brew search package-name
   ```

2. Install it:
   ```bash
   brew install package-name  # or: brew install --cask app-name
   ```

3. Update Brewfile:
   ```bash
   brew bundle dump --force --file=~/.dotfiles/Brewfile
   ```

4. Commit to git:
   ```bash
   cd ~/.dotfiles
   git add Brewfile
   git commit -m "Add package-name to Brewfile"
   git push
   ```

Or use the convenience script:
```bash
~/.dotfiles/scripts/brewdump
```

---

## Useful Resources

- **Homebrew:** [brew.sh](https://brew.sh)
- **Homebrew Formulae Search:** [formulae.brew.sh](https://formulae.brew.sh)
- **Modern Unix Tools:** [github.com/ibraheemdev/modern-unix](https://github.com/ibraheemdev/modern-unix)
- **Awesome macOS CLI:** [github.com/herrbischoff/awesome-macos-command-line](https://github.com/herrbischoff/awesome-macos-command-line)
