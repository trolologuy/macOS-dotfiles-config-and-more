# Decisions

| Date | Decision | Why | Alternatives considered |
|---|---|---|---|
| 2026-11-18 | Finder right-click items via **Finder Menu** (nikgrbn/finder-menu) | open source (MIT), Homebrew install, covers New File (any extension), Open Terminal Here (iTerm2), Copy Path | RClick (GPL-3, macOS 15.6+), paid App Store extensions, Automator Quick Actions (not shippable as plain files) |
| 2026-11-18 | Hammerspoon hotkeys as keyboard fallback for the Finder actions | already in use; no extra permission beyond Finder automation | none |
| 2026-11-18 | Finder settings applied by a script that writes an undo script | settings are reviewable and reversible | manual System Settings steps |
| 2026-11-18 | Security: **read-only audit first, fixes opt-in one by one** | a full baseline changes SSH, sharing, screen-lock timings at once | applying NIST mSCP CIS Level 1 directly (kept as the "full audit" reference) |
| 2026-11-18 | Security apps: LuLu, BlockBlock, KnockKnock; CLI: lynis, gitleaks, osv-scanner, trivy, nmap, nuclei | free, open source, cover outbound traffic, persistence, secrets, dependencies, images, ports | Santa (fleet-oriented), Pareto Security (overlaps with the audit script) |
| 2026-11-18 | Dependency scanning with OSV-Scanner over lockfiles | one tool for npm, Python, Composer and more; also flags known malicious packages | per-ecosystem `npm audit` / `pip-audit` / `composer audit` (documented as alternatives) |
| 2026-11-18 | Global git hooks via `core.hooksPath` (gitleaks), chaining to each repo's `.pre-commit-config.yaml` and `.git/hooks` | one install covers every repo, including new clones; repos keep their own checks | only per-repo pre-commit configs (needs `pre-commit install` per clone, easy to forget) |
| 2026-11-23 | Dotfiles managed with **chezmoi + 1Password** (`.chezmoiroot = home`, docs stay at root) | one public repo; private values (SSH hosts, git identity) are read from 1Password when you run `chezmoi apply` and never reach git; reproducible on a new Mac | private companion repo (second repo for secrets), making this repo private |
| 2026-11-23 | Homelab inventory = YAML in the 1Password secure note `homelab-inventory`; `~/.ssh/config` is generated from it | one source for host/IP/user, nothing about the network in git | private inventory repo (values duplicated in ssh config) |
| 2026-11-23 | SSH via the 1Password agent, `IdentitiesOnly yes`, `ForwardAgent no`, `ProxyJump` for hosts behind another; password login disabled on the NAS | keys never on disk, Touch ID approval, no agent exposure on jump hosts | keys in `~/.ssh` + macOS keychain, agent forwarding |
| 2026-11-23 | `core.hooksPath` set in the managed `.gitconfig` template instead of `install-git-hooks.sh` | `git config --global` edits would be overwritten by `chezmoi apply` | keep the script (drifts) |
| 2026-11-23 | oh-my-zsh plugins fetched via `.chezmoiexternal.toml`; oh-my-zsh itself and the Spaceship theme not managed yet | oh-my-zsh auto-updates itself; theme needs a symlink, handled later | `exact` archive of all of `~/.oh-my-zsh` (would wipe custom content) |
