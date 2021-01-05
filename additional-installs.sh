# additional installs
echo "Installing additional packages. Make sure this is running towards the end
of setup"

# list install commands
# CPAN Perl modules
sudo cpan Log::Log4per
sudo cpan YAML::Tiny
sudo cpan File::HomeDir
# tex live package manager
sudo tlmgr update --self
sudo tlmgr install latexmk
sudo tlmgr install latexindent
sudo tlmgr install enumitem
sudo tlmgr install blindtext
sudo tlmgr install titling
sudo tlmgr install titlesec
sudo tlmgr install biber

echo "Success! Installation of additional programs is complete."
