# Dotfiles with chezmoi + 1Password

This repo is a [chezmoi](https://www.chezmoi.io/) source. Files under `home/` map to `$HOME`
(`dot_x` → `.x`, `private_` → mode 600/700, `.tmpl` → rendered template). Docs stay at the repo root.

**No secrets in git.** Templates read private values from 1Password at `chezmoi apply` time
through the `op` CLI. Touch ID unlocks it.

| Target | Source | 1Password item (vault set at `chezmoi init`) |
|---|---|---|
| `~/.hammerspoon/` | `home/dot_hammerspoon/` | none |
| `~/.ssh/config` | `home/private_dot_ssh/private_config.tmpl` | `homelab-inventory` secure note (YAML in notes) |
| `~/.ssh/homelab.pub` | `home/private_dot_ssh/homelab.pub.tmpl` | SSH Key item (default `homelab-ssh`) |
| `~/.gitconfig`, `~/.gitconfig-work` | `home/dot_gitconfig*.tmpl` | `git-identity` secure note (fields `name`, `email`, optional `work_dir`, `work_email`) |

Unmanaged extras go in `~/.ssh/config.local` and `~/.gitconfig.local` (included, never committed).

## New Mac

```sh
brew install chezmoi 1password-cli
# 1Password → Settings → Developer: enable CLI integration + SSH agent
git clone https://github.com/trolologuy/macOS-dotfiles-config-and-more.git ~/.local/share/chezmoi
~/.local/share/chezmoi/scripts/bootstrap.sh
```

## Daily use

- `chezmoi edit ~/.ssh/config`, then `chezmoi diff`, then `chezmoi apply`
- Add or change a homelab host: edit the `homelab-inventory` note in 1Password, then `chezmoi apply`
- Add a new dotfile: `chezmoi add ~/.zshrc`. If it contains tokens, use `chezmoi add --template`
  and replace each secret with `{{ onepasswordRead "op://<vault>/<item>/<field>" }}`.
- `chezmoi cd` opens the source repo, where you commit and push as usual.

## Pitfalls

- `chezmoi apply` **overwrites** managed files. Always run `chezmoi diff` first.
- Tools that edit `~/.ssh/config` themselves (OrbStack, Colima) will be reverted. Put their `Include` lines in `config.local`.
- `config.local` is included first, and ssh uses the first match, so remove duplicated hosts from it.
- Every apply asks 1Password for approval. That's intended.
