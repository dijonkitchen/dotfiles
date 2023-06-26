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
curl https://raw.githubusercontent.com/dijonkitchen/dotfiles/main/initialize.sh | bash
```

Go through prompts,
if any.

Open a new terminal
for latest settings.

### Manual setup

Follow along
comments in [./initialize.sh](./initialize.sh).

Then,
open a new terminal.

### IntelliJ

You may need to add `/usr/local/bin`
as [shell script path for IntelliJ](https://www.jetbrains.com/help/idea/working-with-the-ide-features-from-command-line.html#toolbox).


## Backup brew packages

`brew bundle dump -f --file=- > Brewfile`
