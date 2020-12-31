# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew update
brew upgrade

# Install packages
brew install git
brew install fzf
brew install lf
brew install lua@5.3
brew install luarocks
brew install rbenv
brew install ripgrep
brew install tmux
brew install neovim
brew install pandoc
brew install tree
brew install git-subrepo
brew install shfmt
brew install the_silver_searcher
brew install hugo

# Wait a bit before moving on...
sleep 1

# ...and then.
echo "Success! Basic brew packages are installed."
echo "Proceeding with brew cask packages..."

# Install cask packages
brew cask install middleclick
brew cask install rectangle
brew cask install spotmenu

# the end
echo "Success! Brew cask packages are installed."
