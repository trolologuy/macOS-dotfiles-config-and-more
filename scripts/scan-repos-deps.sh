#!/usr/bin/env bash
# Check the dependencies of every project under a folder for known vulnerabilities (and known malicious packages),
# from their lockfiles: package-lock.json / pnpm-lock.yaml / yarn.lock / bun.lock, poetry.lock / uv.lock /
# Pipfile.lock / requirements.txt, composer.lock, Gemfile.lock, go.mod, Cargo.lock, ...  Data source: OSV.dev.
#
#   ./scripts/scan-repos-deps.sh                 scan ~/Projects (default)
#   ./scripts/scan-repos-deps.sh ~/code ~/work   scan these folders
#
# Only package names and versions are sent to osv.dev, not your code. No lockfile = nothing to check: commit lockfiles.
# Fix: upgrade the package (npm: `osv-scanner fix -M package.json -L package-lock.json` suggests upgrades), then rescan.
set -uo pipefail

command -v osv-scanner >/dev/null || { echo "osv-scanner is missing: brew install osv-scanner" >&2; exit 2; }
ROOTS=("$@")
[[ ${#ROOTS[@]} -eq 0 ]] && ROOTS=("$HOME/Projects")

rc=0
for root in "${ROOTS[@]}"; do
  echo "== $root"
  # --recursive walks into every project; .gitignore'd folders (node_modules, .venv, vendor) are skipped by default
  osv-scanner scan source --recursive "$root" || rc=1
done
[[ $rc == 0 ]] && echo "No known vulnerabilities found." || echo "Vulnerabilities found (see above)."
exit $rc
