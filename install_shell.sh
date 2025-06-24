#!/bin/bash

# Install curl

# Install nerd font

# Install bash fzf
sudo apt install fzf

# Install archive tools
sudo apt install tar unzip unrar bzip2 p7zip-full

# Install starship prompt
curl -sS https://starship.rs/install.sh | sh
## Configuration
starship preset nerd-font-symbols -o ~/.config/starship.toml

# Install bash completion
sudo apt install bash-completion

# Install git
sudo apt install git-all

# Install dircolors
sudo apt install coreutils

# Install lesspipe
sudo apt install less

# Install node version manager (nvm)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash

# Add the ability to download choice background
#   Add options for automatically changing background
# Add the ability to downlaod choice icon
