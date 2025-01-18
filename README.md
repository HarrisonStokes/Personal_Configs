# Personal_Configs

## Table of Contents:
1. [Bash](#Bash‎)
2. [VIM](#VIM)

# Bash:
For the ``.bashrc`` it changes the following:
* Shell prompt to look like a katana.
* Adds commands:
   * debug - compiles C++ code with ``g++ -Wall -Werror -ggdb -fsanitize=address -fsanitize=undefined``
   * release - compiles C++ code with ``g++ -O3 -fomit-frame-pointer -funroll-loops -fno-exceptions -fno-rtti``
     
# VIM:
It utilizes the Plug package manager for VIM. It can be installed with:

    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \\
         https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

Once installed open any file in VIM and while in command mode enter the following:

    :PlugInstall

This will install the VIM plugins that are in the ``.vimrc``. The plugins are:

|             Plugin               |                               Function                                   |
|----------------------------------|--------------------------------------------------------------------------|
| vim-airline/vim-airline          | adds a more visually appealing status bar and tabs.
| vim-airline/vim-airline-themes   | adds more themes to airline.
| vim-airblade/vim-gitgutter       | adds a GIT support to the status bar following a similar theme to airline.
| tpope/vim-fugitive               | adds GIT commands to VIM.
| ycm-core/YouCompleteMe           | adds autocomplete to VIM.
| jiangmio/auto-pairs              | adds auto-closing for ``(), [], {}, '', "", \`\`, <>``
| Shirk/vim-gas                    | provides language sever protocol (LSP) for the assembly languages.
| dense-analysis/ale               | adds LSP and linter for high level langauages.
| preservim/nerdtree               | adds a togglable tree-sitter while in VIM.
| ghifarit53/tokyonight-vim        | adds tokyonight themes to vim. (Best color palette btw)


The rest of the ``.vimrc`` contains various remappings to make quality of life and work flow easier. The ``.vimrc`` does contains a table of contents with line numbers if you want to modify it for yourself.

