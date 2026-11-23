# macOS - dotfiles, config and more
You'll find here config and dot files as well as documentation and scripts i use to configure macOS to suit my needs

## Quick start

```sh
brew bundle --file=Brewfile            # apps and CLI tools (review the Brewfile first)
./macos/finder-defaults.sh --dry-run   # then without --dry-run
./macos/security-audit.sh              # read-only security audit; --apply to fix things one by one
./scripts/install-git-hooks.sh         # gitleaks before every commit, in every repo
```

## Fileslist
The different files contained in the repository split by usage.

### Setup
* [Brewfile](Brewfile) - Apps and CLI tools: Finder Menu, Hammerspoon, Objective-See security apps, security scanners

### Finder
* [finder.md](finder.md) - Path bar, status bar with free disk space, full path in the title, right-click New File / Open Terminal Here / Copy Path, hidden files
* [macos/finder-defaults.sh](macos/finder-defaults.sh) - Applies the Finder settings (dry run, undo script)

### Security
* [macos-security.md](macos-security.md) - Audit, hardening, Homebrew safety, dependency and secret scanning
* [macos/security-audit.sh](macos/security-audit.sh) - Read-only audit (FileVault, firewall, updates, sharing, persistence, ...) with opt-in fixes
* [scripts/scan-repos-secrets.sh](scripts/scan-repos-secrets.sh) - gitleaks over every git repo in a folder (whole history)
* [scripts/scan-repos-deps.sh](scripts/scan-repos-deps.sh) - OSV-Scanner over every project's lockfiles (npm, Python, Composer, ...)
* [git-hooks/](git-hooks/_run) + [scripts/install-git-hooks.sh](scripts/install-git-hooks.sh) - Global git hooks: gitleaks on every commit, then the repo's own pre-commit config and hooks

### Shell
* [oh-my-zsh-setup.md](oh-my-zsh-setup.md) - A quickstart guide for [oh-my-zsh](https://ohmyz.sh/)

### Hammerspoon
* [hammerspoon-shortcuts.md](hammerspoon-shortcuts.md) - A beginner-friendly introduction for [hammerspoon](https://www.hammerspoon.org/)
* [init.lua](.hammerspoon/init.lua) - My [hammerspoon](https://www.hammerspoon.org/) config file, with a lots of comments, I'm trying to make it as beginner friendly as possible.

### Decisions
* [decisions.md](decisions.md) - Why things are done the way they are

## Install

Managed with chezmoi + 1Password. See [docs/chezmoi.md](docs/chezmoi.md) and [decisions.md](decisions.md).
