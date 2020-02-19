# dotfiles

A backup of my [dotfiles](https://dotfiles.github.io/).
Feel free to review/improve/fork!

## Setup

Install [Homebrew](https://brew.sh/)

To install all the brew packages from the
[Brewfile](https://github.com/Homebrew/homebrew-bundle),
run: `brew bundle`

In your `$HOME` directory,
symbolic link these files:
```sh
ln -s ./dotfiles/.bash_profile
ln -s ./dotfiles/.bashrc
```

Optionally link `.gitconfig`
or use your own credentials.
```sh
ln -s ./dotfiles/.gitconfig
```

The only other main setting
is using [Input Sans](http://input.fontbureau.com)
as my preferred font!
Just download it
and add it to your Font book (on macOS)!

Restart editor
and/or sync new settings in Spacemacs.

## Backup brew packages

`rm Brewfile && brew bundle dump`
