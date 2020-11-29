# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew update
brew upgrade

# Install packages
fzf
lf
luarocks
rbenv
ripgrep
tmux
vim

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
