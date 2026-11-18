# Install everything with: brew bundle --file=Brewfile
# Review before running: casks install apps that ask for system/network permissions on first launch.

tap "nikgrbn/tap"

# Finder
brew "nikgrbn/tap/finder-menu"  # right-click: New File…, Open Terminal Here, Copy Path, Open Folder With (run `finder-menu enable` once)

# Automation
cask "hammerspoon"              # see .hammerspoon/init.lua

# Security apps (Objective-See, free and open source)
cask "lulu"                     # outbound firewall: asks before an app connects out
cask "blockblock"               # alerts when something installs itself to run at login (persistence)
cask "knockknock"               # one-off scan of everything that runs at login

# Security CLI scanners
brew "lynis"                    # host audit: sudo lynis audit system
brew "gitleaks"                 # secrets in git repos: scripts/scan-repos-secrets.sh
brew "osv-scanner"              # known vulnerabilities in npm/PyPI/Composer/... lockfiles: scripts/scan-repos-deps.sh
brew "trivy"                    # vulnerabilities in container images, filesystems, IaC
brew "nmap"                     # port scans (external check: from a phone hotspot)
brew "nuclei"                   # template-based vulnerability scan of web services on the LAN
