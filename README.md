# Shaun's Dotfiles

## Setup

* Create symlinks from home directory to desired dotfiles
* `git submodule init && git submodule update`

## Brew commands

Some useful homebrew commands.

```
brew doctor   # Check your system for potential problems
brew update   # Fetch the newest version of Homebrew and all formulae
brew upgrade  # Upgrade outdated, unpinned brews
brew cleanup  # Remove stale lock files and outdated downloads
brew prune    # Remove dead symlinks from the Homebrew prefix

# Casks
brew cask doctor
brew cask upgrade

# Bundle
brew bundle dump  # Generate Brewfile
```

## ZSH Theme

**srh-agnoster**

* Added newline to PROMPT
* Removed leading whitespace in PROMPT
* Added datetime and command history index to RPROMPT

### Installation

* Install oh-my-zsh: https://ohmyz.sh/
* `ln -s ~/.dotfiles/srh-agnoster.zsh-theme ~/.oh-my-zsh/custom/themes/`
* Install powerline font: https://github.com/Lokaltog/powerline-fonts
* Set iTerm2 font to `Meslo LG M DZ for Powerline`
  * Preferences > Profiles > Text > Font
