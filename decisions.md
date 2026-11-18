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
