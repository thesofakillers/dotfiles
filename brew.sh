# Install Homebrew
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew update
brew upgrade

# Install packages
brew bundle install --file=./Brewfile

# Wait a bit before moving on...
sleep 1

# ...and then.
echo "Success! Basic brew packages are installed."
# echo "Proceeding with brew cask packages..."

# # Install cask packages
# brew install --cask middleclick
# brew install --cask rectangle
# brew install --cask spotmenu
# brew install --cask basictex
# brew install --cask stretchly
# brew install --cask licecap
# brew install --cask latexit

# the end
echo "Success! Brew cask packages are installed."
