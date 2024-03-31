#!/usr/bin/env bash

# Install Apple Developer Tools (git, etc.)
xcode-select --install

# Change shell to default to bash
chsh -s "$(which bash)"

# Install [Homebrew](https://brew.sh/)
# bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Clone this repository into your `$HOME` directory:
cd "$HOME" || exit
git clone https://github.com/dijonkitchen/dotfiles/

# To install all the brew packages from the
# [Brewfile](https://github.com/Homebrew/homebrew-bundle),
# cd "$HOME"/dotfiles || exit
# brew bundle --file=Brewfile

# In your `$HOME` directory,
# symbolic link these files:
cd "$HOME" || exit
ln -si ./dotfiles/.bashrc .
ln -si ./dotfiles/.bash_profile .
ln -si ./dotfiles/.zshrc .

# Optionally link `.gitconfig`
# or use your own credentials.
ln -si ./dotfiles/.gitconfig .

# Rust installation for Ruby YJIT
curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh

# mise for language version management
curl https://mise.run | sh
~/.local/bin/mise --version
cd "$HOME/dotfiles" || exit
mkdir -p ~/.config/mise && cp config.toml ~/.config/mise/config.toml
mise install

source .bashrc
