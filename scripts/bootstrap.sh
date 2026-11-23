#!/usr/bin/env bash
# One-time migration + setup for chezmoi with 1Password on macOS.
# Run from the repo clone at ~/.local/share/chezmoi. Safe to re-run.
set -euo pipefail

SRC="$HOME/.local/share/chezmoi"
cd "$SRC" 2>/dev/null || { echo "Clone the repo to $SRC first (see docs/chezmoi.md)."; exit 1; }
git rev-parse --is-inside-work-tree >/dev/null || { echo "$SRC is not a git repo."; exit 1; }

ask() { local p="$1" d="${2:-}" a; read -r -p "$p${d:+ [$d]}: " a; echo "${a:-$d}"; }

echo "==> 1/6 Tools"
for pkg in chezmoi 1password-cli; do
  brew list "$pkg" >/dev/null 2>&1 || brew install "$pkg"
done
echo "In 1Password: Settings → Developer → enable 'Integrate with 1Password CLI' and 'Use the SSH agent'."
op vault list >/dev/null || { echo "op can't reach 1Password (Touch ID prompt denied or CLI integration off)."; exit 1; }

echo "==> 2/6 Move repo files into chezmoi layout"
if [ -d .hammerspoon ] && [ ! -e home/dot_hammerspoon ]; then
  mkdir -p home && git mv .hammerspoon home/dot_hammerspoon
  echo "moved .hammerspoon → home/dot_hammerspoon"
else
  echo "nothing to move"
fi
if ! grep -q "docs/chezmoi.md" README.md 2>/dev/null; then
  printf '\n## Install\n\nManaged with chezmoi + 1Password. See [docs/chezmoi.md](docs/chezmoi.md) and [decisions.md](decisions.md).\n' >> README.md
  echo "added Install section to README.md"
fi

VAULT=$(ask "1Password vault for dotfiles items" "Private")
KEY=$(ask "1Password SSH Key item for homelab hosts" "homelab-ssh")

echo "==> 3/6 1Password items"
if ! op item get "$KEY" --vault "$VAULT" >/dev/null 2>&1; then
  echo "!! SSH Key item '$KEY' not found in '$VAULT'."
  echo "   Create it in 1Password (New Item → SSH Key → Generate, Ed25519), then re-run."
  exit 1
fi

if ! op item get homelab-inventory --vault "$VAULT" >/dev/null 2>&1; then
  tmp=$(mktemp -t homelab-inventory.XXXXXX)
  cp docs/homelab-inventory.example.yaml "$tmp"
  echo "Opening the inventory template. Replace the example hosts with yours, save, close."
  "${EDITOR:-nano}" "$tmp"
  op item create --category "Secure Note" --title homelab-inventory --vault "$VAULT" \
    "notesPlain=$(cat "$tmp")" >/dev/null
  rm -f "$tmp"
  echo "created secure note 'homelab-inventory'"
fi

if ! op item get git-identity --vault "$VAULT" >/dev/null 2>&1; then
  name=$(ask "Git user.name" "$(git config --global user.name 2>/dev/null || true)")
  email=$(ask "Git user.email (personal)" "$(git config --global user.email 2>/dev/null || true)")
  wdir=$(ask "Folder with work repos for a separate identity (empty = none)" "")
  fields=("name[text]=$name" "email[text]=$email")
  if [ -n "$wdir" ]; then
    wemail=$(ask "Git user.email for $wdir" "")
    fields+=("work_dir[text]=$wdir" "work_email[text]=$wemail")
  fi
  op item create --category "Secure Note" --title git-identity --vault "$VAULT" "${fields[@]}" >/dev/null
  echo "created secure note 'git-identity'"
fi

echo "==> 4/6 Keep existing unmanaged config as *.local"
keep() { # $1 = live file, $2 = .local copy
  if [ -f "$1" ] && ! grep -q "Managed by chezmoi" "$1" && [ ! -e "$2" ]; then
    cp -p "$1" "$2"; echo "copied $1 → $2 (prune entries now managed by chezmoi)"
  fi
}
keep "$HOME/.ssh/config" "$HOME/.ssh/config.local"
keep "$HOME/.gitconfig" "$HOME/.gitconfig.local"

echo "==> 5/6 chezmoi init"
chezmoi init --promptString "1Password vault holding the dotfiles items=$VAULT,1Password SSH Key item name for homelab hosts=$KEY"

echo "==> 6/6 Review"
chezmoi diff || true
echo
read -r -p "Apply these changes now? [y/N] " go
if [[ "$go" =~ ^[Yy]$ ]]; then
  chezmoi apply -v
  echo "Test: ssh -G <host> | grep -Ei 'hostname|identityfile|proxyjump'"
else
  echo "Nothing applied. Run 'chezmoi diff' / 'chezmoi apply' when ready."
fi
echo "Then: git add -A && git commit && git push -u origin HEAD, and open the PR."
