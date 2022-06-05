# additional installs
echo "Installing additional packages. Make sure this is running towards the end
of setup"

# list install commands
# CPAN Perl modules, necessary for some latex, such as latexindent
sudo cpan Log::Log4per
sudo cpan YAML::Tiny
sudo cpan File::HomeDir
sudo cpan Unicode::GCString
# tex live package manager
sudo tlmgr update --self
sudo tlmgr install latexmk
sudo tlmgr install latexindent
sudo tlmgr install enumitem
sudo tlmgr install blindtext
sudo tlmgr install titling
sudo tlmgr install titlesec
sudo tlmgr install biber
sudo tlmgr install biblatex
sudo tlmgr install tcolorbox
sudo tlmgr install marginnote
sudo tlmgr install csquotes
sudo tlmgr install preprint
sudo tlmgr install environ
sudo tlmgr install todonotes
sudo tlmgr install units
sudo tlmgr install multirow
sudo tlmgr install wrapfig
sudo tlmgr install appendix
sudo tlmgr install collection-fontsrecommended
sudo tlmgr install pgfplots
sudo tlmgr install preview
sudo tlmgr install standalone
sudo tlmgr install type1cm
sudo tlmgr install dvipng

echo "Success! Installation of additional programs is complete."
