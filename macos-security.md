# macOS security: audit, hardening, Homebrew and dependency scanning

Everything here is opt-in and starts with a read-only check. Order: install the tools, audit, fix one thing at a time.

```sh
brew bundle --file=Brewfile                 # tools (review the Brewfile first)
./macos/security-audit.sh                   # read-only audit: PASS / WARN / FAIL with how to fix
./macos/security-audit.sh --apply           # offers the safe fixes one by one (y/N each)
./macos/security-audit.sh --check-updates   # also lists pending macOS updates (slow)
```

## What the audit checks

| Area | Checks | Fix offered by `--apply` |
|---|---|---|
| System integrity | SIP, Gatekeeper, FileVault | Gatekeeper on (FileVault and SIP: instructions only) |
| Firewall | application firewall, stealth mode, LuLu installed | firewall on, stealth mode on |
| Updates | automatic check/download/security responses, App Store auto-update, outdated Homebrew packages | turn on each automatic-update setting |
| Login | guest account, automatic login, password immediately after sleep | guest account off |
| Sharing | SSH, SMB, AFP, Screen Sharing, Remote Management, Media Sharing, AirPlay Receiver listening; SSH password login | none (they may be intended) |
| Persistence | launch agents/daemons outside system folders, BlockBlock installed | none: review with KnockKnock |
| Recovery | Time Machine destination, Find My Mac | none |

Not tested on every macOS version: a check that cannot read a value says so (WARN) instead of guessing PASS.

## Full baseline: NIST mSCP

For a complete audit (CIS Benchmark Level 1, ~100 rules) use the NIST macOS Security Compliance Project:
<https://github.com/usnistgov/macos_security> → generate the `cis_lvl1` baseline → run
`sudo ./build/cis_lvl1_macos_<version>/cis_lvl1_macos_<version>_compliance.sh` and use its *check* option first.

Pitfall: its *fix* option applies everything at once (SSH, sharing, screen-lock timings, Bluetooth, ...). Read the failed
rules and fix them one by one, or exempt the ones you need.

## Security apps (Brewfile)

| App | What it does | When it bothers you |
|---|---|---|
| [LuLu](https://objective-see.org/products/lulu.html) | outbound firewall: asks before an app connects out | many prompts the first days; allow the apps you know |
| [BlockBlock](https://objective-see.org/products/blockblock.html) | alerts when something installs itself to run at login | each installer that adds a helper |
| [KnockKnock](https://objective-see.org/products/knockknock.html) | one-off list of everything that runs at login, with VirusTotal lookups | never: run it monthly |

Not installed on purpose: [Santa](https://github.com/northpolesec/santa) (app allow-listing, maintained by North Pole
Security since Google archived it) is built for fleets; [Pareto Security](https://github.com/ParetoSecurity/pareto-mac)
overlaps with `security-audit.sh`.

## Homebrew: keeping installs safe

- **Known vulnerabilities**: `brew vulns` (built into Homebrew 7; before that `brew install homebrew/brew-vulns/brew-vulns`)
  checks installed formulae against OSV.dev. `brew vulns --brewfile` checks this Brewfile, `brew vulns --list-skipped`
  shows formulae it could not check (no result is not a clean result).
- **Update often**: `brew update && brew upgrade` (the audit warns when packages are outdated). `brew autoremove` and
  `brew cleanup` remove what you no longer use, so less to patch.
- **Provenance**: `export HOMEBREW_VERIFY_ATTESTATIONS=1` in `~/.zshrc` makes `brew install` verify that each bottle was
  built by Homebrew's own CI (needs `gh auth login`; it fails closed when the check fails).
- **Taps are trust decisions**: `brew tap` lists them. A third-party tap (`nikgrbn/tap` for Finder Menu) runs its own
  formula code on your Mac. Keep the list short; `brew untap` what you no longer use.
- **Keep Gatekeeper's quarantine**: never install casks with `--no-quarantine`.
- **Lookalikes**: info-stealers are spread through fake "install Homebrew" pages and ads. Only use the command on
  <https://brew.sh> and type `brew install <name>` from formulae.brew.sh, never from a random blog.

## Dependencies in your projects (npm, Python, Composer, ...)

`./scripts/scan-repos-deps.sh ~/Projects` runs [OSV-Scanner](https://github.com/google/osv-scanner) over every project:
it reads the lockfiles (package-lock.json, pnpm-lock.yaml, yarn.lock, poetry.lock, uv.lock, requirements.txt,
composer.lock, Gemfile.lock, go.mod, Cargo.lock, ...) and reports known vulnerabilities and known malicious packages.

Per ecosystem, the built-in equivalents: `npm audit`, `pip-audit` (`brew install pip-audit`), `composer audit`.

Habits that matter more than the scan:
- **Commit lockfiles**: without one there is nothing exact to check, and installs float to whatever is newest.
- **Install scripts are the npm attack path** (2025 worms spread through `postinstall`): `npm config set ignore-scripts true`
  globally, or use pnpm 10+, which does not run dependency scripts unless allowed.
- **GitHub Dependabot alerts** (repo Settings → Advanced Security): free, no GitHub Actions minutes, emails on new
  vulnerable dependencies. Version-update PRs are optional.

## Secrets in git

`./scripts/scan-repos-secrets.sh ~/Projects` runs gitleaks over the full history of every repo. This repository is public:
scan before pushing. When something is found, rotate the secret first; deleting the file does not remove it from history.

## Pre-commit hooks (block problems before they enter history)

```sh
./scripts/install-git-hooks.sh        # once per Mac: git config --global core.hooksPath -> git-hooks/
./scripts/install-git-hooks.sh --off  # undo
```

[`git-hooks/_run`](git-hooks/_run) runs for every repository on the Mac:

1. **pre-commit**: gitleaks on the staged changes; a commit containing a secret is refused.
2. **pre-commit**: if the repo has a `.pre-commit-config.yaml`, runs it with the pre-commit framework (shellcheck, ruff,
   yamllint, ... as the repo defines). No `pre-commit install` per clone: it would refuse while `core.hooksPath` is set.
3. **every hook**: then runs the repo's own `.git/hooks/<name>`, which a global `core.hooksPath` would otherwise skip.

Limits: hooks are local. `git commit --no-verify` skips them, and other machines (or an AI agent's sandbox) don't have
them, so the scan scripts and PR checks still matter. False positive: add the fingerprint gitleaks prints to the repo's
`.gitleaksignore`, or commit once with `SKIP_GLOBAL_HOOKS=1 git commit ...`.

## Other scanners (homelab)

- `trivy image <image>` / `trivy fs .`: vulnerabilities in container images, filesystems and IaC.
- `nuclei -u https://service.lan`: template-based checks of web services on your LAN (only scan what you own).
- `nmap -Pn <public IP>` from a phone hotspot: what the internet sees.
- `sudo lynis audit system`: generic Unix host audit, complements `security-audit.sh`.
