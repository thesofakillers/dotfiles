# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew update
brew upgrade

# Install packages
brew install perl
brew install git
brew install fzf
brew install lf
brew install rbenv
brew install ripgrep
brew install tmux
brew install neovim
brew install pandoc
brew install pandoc-crossref
brew install tree
brew install git-subrepo
brew install shfmt
brew install the_silver_searcher
brew install hugo
brew install git-filter-repo
brew install grip
brew install ffmpeg
brew install gnupg
brew install youtube-dl
brew install diff-pdf
brew install wget

# Wait a bit before moving on...
sleep 1

# ...and then.
echo "Success! Basic brew packages are installed."
echo "Proceeding with brew cask packages..."

# Install cask packages
brew install --cask middleclick
brew install --cask rectangle
brew install --cask spotmenu
brew install --cask basictex
brew install --cask stretchly
brew install --cask licecap

# the end
echo "Success! Brew cask packages are installed."
