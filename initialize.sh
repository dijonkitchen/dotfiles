#!/usr/bin/env bash

# Install Apple Developer Tools (git, etc.)
xcode-select --install

# Change shell to default to bash
chsh -s "$(which bash)"

# Install [Homebrew](https://brew.sh/)
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Clone this repository into your `$HOME` directory:
cd "$HOME" || exit
git clone https://github.com/dijonkitchen/dotfiles/

# To install all the brew packages from the
# [Brewfile](https://github.com/Homebrew/homebrew-bundle),
cd "$HOME"/dotfiles || exit
brew bundle --file=Brewfile

# In your `$HOME` directory,
# symbolic link these files:
cd "$HOME" || exit
ln -si ./dotfiles/.bashrc .
ln -si ./dotfiles/.bash_profile .

# Optionally link `.gitconfig`
# or use your own credentials.
ln -s ./dotfiles/.gitconfig .

# Install latest [nvm](https://github.com/nvm-sh/nvm) `master` branch install script
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
export NVM_DIR="$HOME/.nvm"
# shellcheck source=/dev/null
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
nvm install --lts
nvm alias default 'lts/*'
