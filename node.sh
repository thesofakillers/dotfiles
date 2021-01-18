# Install nvm
echo "Installing nvm..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
# verify installation
command -v nvm

# install node and npm (latest)
echo "Installing latest node and npm versions..."
nvm install node

# activating the node we just installed
nvm use node

# global packages
echo "Installing global npm packages..."
npm install -g neovim
npm install -g terminalizer
npm install -g git-mob

# the end
echo "Success! Node setup complete."
