# dotfiles

A backup of my [dotfiles](https://dotfiles.github.io/).
Feel free to review/improve/fork!

## Setup

Clone this repository into your `$HOME` directory:

```sh
cd $HOME
git clone https://github.com/dijonkitchen/dotfiles/
```

Install [Homebrew](https://brew.sh/)

To install all the brew packages from the
[Brewfile](https://github.com/Homebrew/homebrew-bundle),
run: 

```sh
cd $HOME/dotfiles
brew bundle
```

In your `$HOME` directory,
symbolic link these files:
```sh
cd $HOME
ln -s ./dotfiles/.zshrc
ln -s ./dotfiles/.bash_profile
ln -s ./dotfiles/.bashrc
```

Optionally link `.gitconfig`
or use your own credentials.
```sh
ln -s ./dotfiles/.gitconfig
```

Install [nvm](https://github.com/nvm-sh/nvm)

```shell script
nvm install --lts
nvm alias default lts/*
```

### Experimental setup

```sh
chmod +x ./install.sh
./install.sh
```
Go through prompts.

## Typefaces

The only other main setting
is using any of my preferred typefaces:
- [Jetbrains Mono](https://www.jetbrains.com/lp/mono/)
- [Fira Code](https://github.com/tonsky/FiraCode)
- [Input Mono](http://input.fontbureau.com)

Just download any of them
and add it to your Font book (on macOS).

I use them with ligatures on.


## Backup brew packages

`brew bundle dump -f --file=- > Brewfile`
