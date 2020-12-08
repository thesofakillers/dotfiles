# {{{ neovim envs
# {{{ python 2
conda create -n neovim2 python=2
conda activate neovim2
pip install pynvim
conda deactivate
# }}}
# {{{ python 3
conda create -n neovim3 python=3.6
conda activate neovim3
pip install pynvim
conda deactivate
# }}}
# }}}
