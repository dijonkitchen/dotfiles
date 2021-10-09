#!/bin/bash

# Clone
cd $HOME
git clone https://github.com/dijonkitchen/dotfiles/

# Brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
cd $HOME/dotfiles
brew bundle

# Symlink
cd $HOME
ln -s ./dotfiles/.zshrc
ln -s ./dotfiles/.bash_profile
ln -s ./dotfiles/.bashrc

ln -s ./dotfiles/.gitconfig

# JS/Node/nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install --lts
nvm alias default lts/*