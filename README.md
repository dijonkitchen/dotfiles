# dotfiles

A backup of my [dotfiles](https://dotfiles.github.io/).
Feel free to review/improve/fork!


## Setup

This will download the latest
installation script
and run it.

It's also what will be
automatically used
by GitHub Codespaces.

```sh
curl https://raw.githubusercontent.com/dijonkitchen/dotfiles/main/bootstrap.sh | bash
nvm install --lts
nvm alias default 'lts/*'
```

Go through prompts,
if any.

Open a new terminal
for latest settings.

### Manual setup

Follow along
comments in [./initialize.sh](./initialize.sh).

Then,
in a new terminal:
```sh
nvm install --lts
nvm alias default 'lts/*'
```

### Editor

You may need to add `/usr/local/bin`
as [shell script path for IntelliJ](https://www.jetbrains.com/help/idea/working-with-the-ide-features-from-command-line.html#toolbox).


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
