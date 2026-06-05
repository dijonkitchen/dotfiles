# dotfiles

A backup of my [dotfiles](https://dotfiles.github.io/), combined with
runtime configuration for GitHub Codespaces and a set of agent-agnostic
AI skills. Feel free to review/improve/fork!

## Layout

| Path                             | Purpose                                                     |
| -------------------------------- | ----------------------------------------------------------- |
| `.bashrc`, `.zshrc`, `alias.sh`  | Shell config and aliases                                    |
| `.gitconfig`, `.gitmessage`      | Git config                                                  |
| `Brewfile`, `config.toml`        | Package and language version pins (Homebrew, mise)          |
| `.agent/skills/`                 | AI skills (git subtree of `dijonkitchen/skills`)            |
| `.claude/`                       | Claude Code-specific settings and statusline                |
| `bootstrap.sh`                   | Single setup entry point (Codespaces auto-runs it; also for manual macOS / Linux) |
| `link-agents.sh`                 | Symlinks agent-agnostic skills into per-agent install paths |

`bootstrap.sh` detects whether it is running in Codespaces, macOS, or
plain Linux and picks the correct dotfiles location, link mode, and
package manager steps. Codespaces invokes it automatically on container
creation.

## Setup

```sh
curl https://raw.githubusercontent.com/dijonkitchen/dotfiles/main/bootstrap.sh | bash
```

Go through prompts, if any. Open a new terminal for latest settings.

### Manual setup

Follow along comments in [./bootstrap.sh](./bootstrap.sh). Then open a
new terminal.

## AI agents

Skills live under `.agent/skills/<name>/` (git subtree of
`dijonkitchen/skills`). `link-agents.sh` exposes them to each installed
AI coding agent via symlink:

- **Claude Code** — linked into `~/.claude/skills/` automatically.
- **Cursor / Codex / others** — opt-in adapter blocks in
  `link-agents.sh`; uncomment when you start using that agent.

To pull skills updates from upstream:

```sh
git subtree pull --prefix=.agent/skills \
  https://github.com/dijonkitchen/skills.git main --squash
```

### IntelliJ

You may need to add `/usr/local/bin`
as [shell script path for IntelliJ](https://www.jetbrains.com/help/idea/working-with-the-ide-features-from-command-line.html#toolbox).

## Notes

- [Python type checkers: `ty` vs. the rest](docs/python-type-checkers.md) —
  evaluation and recommendation for this Astral/`uv`-based setup.


## Backup brew packages

`brew bundle dump -f --file=- > Brewfile`
