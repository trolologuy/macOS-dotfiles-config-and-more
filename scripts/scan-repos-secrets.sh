#!/usr/bin/env bash
# Scan every git repository under a folder for committed secrets (whole history), with gitleaks.
#
#   ./scripts/scan-repos-secrets.sh                 scan repos under ~/Projects (default)
#   ./scripts/scan-repos-secrets.sh ~/code ~/work   scan repos under these folders
#
# Reports go to ~/.cache/secret-scan/<repo>.json (secrets redacted, but they still say where secrets are: keep them private).
# Found something? Rotate the secret first (deleting it from git does not remove it from history or clones),
# then remove it from the files and move it to the password manager / 1Password references.
set -uo pipefail

command -v gitleaks >/dev/null || { echo "gitleaks is missing: brew install gitleaks" >&2; exit 2; }
ROOTS=("$@")
[[ ${#ROOTS[@]} -eq 0 ]] && ROOTS=("$HOME/Projects")
OUT="$HOME/.cache/secret-scan"
mkdir -p "$OUT" && chmod 700 "$OUT"

clean=0 leaky=0 errors=0
while IFS= read -r gitdir; do
  repo=$(dirname "$gitdir")
  name=$(basename "$repo")
  report="$OUT/$name.json"
  gitleaks git "$repo" --redact --no-banner --exit-code 3 --report-format json --report-path "$report" >/dev/null 2>&1
  case $? in
    0) clean=$((clean + 1)); printf '  clean  %s\n' "$repo"; rm -f "$report" ;;
    3) leaky=$((leaky + 1)); printf '  LEAKS  %s  (%s finding(s), %s)\n' "$repo" \
         "$(grep -c '"RuleID"' "$report" 2>/dev/null || echo '?')" "$report" ;;
    *) errors=$((errors + 1)); printf '  error  %s\n' "$repo" ;;
  esac
done < <(find "${ROOTS[@]}" -maxdepth 4 -type d -name .git -prune 2>/dev/null)

echo; echo "Repos: $clean clean, $leaky with findings, $errors error(s)."
echo "Details: gitleaks git <repo> --redact -v   |   false positive: add the fingerprint to <repo>/.gitleaksignore"
exit $(( leaky > 0 ))
