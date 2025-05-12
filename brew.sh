# Install Homebrew
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew update
brew upgrade

# Install packages
brew install perl # scripting lang used by a lot of other packages
brew install git # version control
brew install fzf # fuzzy finder
brew install lf # file explorer
brew install rbenv # ruby environment manager
brew install ripgrep # rg: file and file content search
brew install tmux # terminal multiplexer
brew install neovim # fork of vim
brew install pandoc # ultimate markdown processor
brew install pandoc-crossref # for making references to sections/figs in pandoc
brew install tree # see tree structure of directories
brew install git-subrepo # Git Submodule Alternative
brew install shfmt # Autoformat shell script source code
brew install the_silver_searcher # ag, file and file-content search
brew install hugo # static site generator
brew install git-filter-repo # Quickly rewrite git repository history
brew install grip # Markdown previewer
brew install ffmpeg # video and audio processor
brew install gnupg # for PGP
brew install youtube-dl # for downloading youtube videos
brew install diff-pdf # for diffing pdfs
brew install wget # for downloading files
brew install graphviz # i think this was for pdf stuff
brew install git-lfs # large files on git
brew install rename # Perl-powered file rename script with many helpful built-ins
brew install watchman # Watch files and take action when they change
brew install pv # monitor progress of data through a pipe
brew install ctags # exuberant ctags, use for vim tagbar

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
