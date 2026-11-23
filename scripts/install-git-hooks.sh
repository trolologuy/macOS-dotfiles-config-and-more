#!/usr/bin/env bash
# Turn the global git hooks on (or off) for every repository on this Mac.
#
#   ./scripts/install-git-hooks.sh          set git config --global core.hooksPath to this repo's git-hooks/
#   ./scripts/install-git-hooks.sh --off    remove it (repos go back to their own .git/hooks)
#
# Needs: brew install gitleaks pre-commit (both in the Brewfile). Repos with a .pre-commit-config.yaml get it run
# automatically; no `pre-commit install` needed (and it would refuse while core.hooksPath is set).
set -euo pipefail
dir=$(cd "$(dirname "$0")/../git-hooks" && pwd)

if grep -q "Managed by chezmoi" "$HOME/.gitconfig" 2>/dev/null; then
  echo "~/.gitconfig is managed by chezmoi: core.hooksPath is set in home/dot_gitconfig.tmpl." >&2
  echo "To turn hooks off, remove the [core] hooksPath lines there and run 'chezmoi apply'." >&2
  exit 0
fi

if [[ "${1:-}" == "--off" ]]; then
  git config --global --unset core.hooksPath || true
  echo "Global hooks off."
  exit 0
fi
current=$(git config --global core.hooksPath || true)
if [[ -n "$current" && "$current" != "$dir" ]]; then
  echo "core.hooksPath is already set to $current; not overwriting. Unset it first if you want these hooks." >&2
  exit 1
fi
git config --global core.hooksPath "$dir"
echo "Global hooks on: $dir"
command -v gitleaks >/dev/null || echo "Missing: brew install gitleaks"
command -v pre-commit >/dev/null || echo "Missing: brew install pre-commit"
