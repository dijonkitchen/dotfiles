#!/bin/bash

# Clone this repository into your `$HOME` directory:
cd $HOME
git clone https://github.com/dijonkitchen/dotfiles/

# Install [Homebrew](https://brew.sh/)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# To install all the brew packages from the
# [Brewfile](https://github.com/Homebrew/homebrew-bundle),
cd $HOME/dotfiles
brew bundle

# In your `$HOME` directory,
# symbolic link these files:
cd $HOME
ln -s ./dotfiles/.zshrc
ln -s ./dotfiles/.bash_profile
ln -s ./dotfiles/.bashrc

# Optionally link `.gitconfig`
# or use your own credentials.
ln -s ./dotfiles/.gitconfig

# Install [nvm](https://github.com/nvm-sh/nvm)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash