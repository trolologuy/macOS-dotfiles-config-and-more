#!/usr/bin/env bash
# macOS security audit: read-only checks by default, opt-in fixes one at a time.
#
#   ./macos/security-audit.sh                  audit only (no changes, no sudo needed for most checks)
#   ./macos/security-audit.sh --apply          after the audit, offer each safe fix and ask y/N before running it
#   ./macos/security-audit.sh --check-updates  also list pending macOS updates (slow: asks Apple's servers)
#
# Exit code: 0 = no FAIL, 1 = at least one FAIL. WARN = worth a look, may be intended (SSH you use, file sharing, ...).
# For a full baseline (CIS Level 1, ~100 rules) use NIST mSCP: https://github.com/usnistgov/macos_security
# (generates <baseline>_compliance.sh with --check/--fix). Audit first; don't apply a full baseline blindly.
set -uo pipefail

APPLY=0 UPDATES=0
for a in "$@"; do
  case $a in
    --apply) APPLY=1 ;;
    --check-updates) UPDATES=1 ;;
    -h|--help) sed -n '2,12p' "$0"; exit 0 ;;
    *) echo "unknown option: $a" >&2; exit 2 ;;
  esac
done
[[ "$(uname)" == "Darwin" ]] || { echo "macOS only." >&2; exit 1; }

PASS=0 WARN=0 FAIL=0
FIXES=()   # "description|command"
FW=/usr/libexec/ApplicationFirewall/socketfilterfw

pass() { PASS=$((PASS + 1)); printf '  \033[32mPASS\033[0m  %s\n' "$1"; }
warn() { WARN=$((WARN + 1)); printf '  \033[33mWARN\033[0m  %s\n' "$1"; [[ -n "${2:-}" ]] && printf '        -> %s\n' "$2"; }
fail() { FAIL=$((FAIL + 1)); printf '  \033[31mFAIL\033[0m  %s\n' "$1"; [[ -n "${2:-}" ]] && printf '        -> %s\n' "$2"; }
fix()  { FIXES+=("$1|$2"); }
listening() { netstat -anp tcp 2>/dev/null | awk -v p="$1" '$6=="LISTEN" && $4 ~ ("[.:]" p "$") {f=1} END {exit !f}'; }
pref() { defaults read "$1" "$2" 2>/dev/null; }

echo "macOS $(sw_vers -productVersion) on $(sysctl -n hw.model 2>/dev/null)"

echo; echo "System integrity"
if csrutil status 2>/dev/null | grep -q "enabled"; then pass "System Integrity Protection is on"
else fail "System Integrity Protection is off" "Recovery mode > Terminal > csrutil enable (only off for kernel debugging)"; fi

if spctl --status 2>/dev/null | grep -q "assessments enabled"; then pass "Gatekeeper is on"
else fail "Gatekeeper is off" "sudo spctl --global-enable"; fix "Turn Gatekeeper on" "sudo spctl --global-enable"; fi

if [[ "$(fdesetup status 2>/dev/null)" == *"FileVault is On"* ]]; then pass "FileVault disk encryption is on"
else fail "FileVault is off: anyone with the Mac can read the disk" "System Settings > Privacy & Security > FileVault (keep the recovery key in your password manager)"; fi

echo; echo "Firewall"
if [[ -x $FW ]]; then
  if $FW --getglobalstate 2>/dev/null | grep -qiE "enabled|state = [12]"; then pass "Application firewall is on"
  else fail "Application firewall is off" "sudo $FW --setglobalstate on"; fix "Turn the application firewall on" "sudo $FW --setglobalstate on"; fi
  if $FW --getstealthmode 2>/dev/null | grep -qiE "enabled|is on"; then pass "Stealth mode is on (no answer to pings/probes)"
  else warn "Stealth mode is off" "sudo $FW --setstealthmode on"; fix "Turn stealth mode on" "sudo $FW --setstealthmode on"; fi
else
  warn "socketfilterfw not found; check System Settings > Network > Firewall"
fi
if [[ -d /Applications/LuLu.app ]]; then pass "LuLu outbound firewall is installed"
else warn "No outbound firewall" "brew install --cask lulu (asks before an app connects out)"; fi

echo; echo "Updates"
SU=/Library/Preferences/com.apple.SoftwareUpdate
for key in AutomaticCheckEnabled AutomaticDownload CriticalUpdateInstall ConfigDataInstall; do
  v=$(pref $SU $key)
  if [[ "$v" == "1" ]]; then pass "Software Update: $key"
  elif [[ -z "$v" ]]; then pass "Software Update: $key (macOS default, not overridden)"
  else fail "Software Update: $key is off" "System Settings > General > Software Update > Automatic updates"
       fix "Turn on $key" "sudo defaults write $SU $key -bool true"; fi
done
if [[ "$(pref /Library/Preferences/com.apple.commerce AutoUpdate)" == "0" ]]; then
  warn "App Store apps do not update automatically" "App Store > Settings > Automatic Updates"
fi
if [[ $UPDATES == 1 ]]; then
  pending=$(softwareupdate -l 2>&1 | grep -E '^\s*\* Label:' || true)
  if [[ -n "$pending" ]]; then fail "macOS updates pending:" "$(echo "$pending" | sed 's/.*Label: //' | paste -sd ',' -)"
  else pass "No pending macOS updates"; fi
fi
if command -v brew >/dev/null; then
  n=$(brew outdated --quiet 2>/dev/null | wc -l | tr -d ' ')
  [[ "$n" == "0" ]] && pass "Homebrew packages up to date" || warn "$n Homebrew package(s) outdated" "brew upgrade"
fi

echo; echo "Login and screen"
if [[ "$(pref /Library/Preferences/com.apple.loginwindow GuestEnabled)" == "1" ]]; then
  fail "Guest account is on" "sudo sysadminctl -guestAccount off"; fix "Turn the guest account off" "sudo sysadminctl -guestAccount off"
else pass "Guest account is off"; fi
if [[ "$(pref /Library/Preferences/com.apple.loginwindow autoLoginUser)" != "" ]]; then
  fail "Automatic login is on: FileVault is bypassed at boot for that user" "System Settings > Users & Groups > Automatically log in as: Off"
else pass "No automatic login"; fi
lock=$(sysadminctl -screenLock status 2>&1 | tr '[:upper:]' '[:lower:]')
if [[ "$lock" == *"immediate"* ]]; then pass "Password required immediately after sleep/screen saver"
elif [[ -n "$lock" && "$lock" != *"error"* ]]; then warn "Screen lock delay: ${lock##*delay is }" "System Settings > Lock Screen > Require password: Immediately"
else warn "Could not read the screen lock delay" "System Settings > Lock Screen > Require password: Immediately"; fi

echo; echo "Sharing (listening services)"
service_name() {  # macOS ships bash 3.2: no associative arrays
  case $1 in
    22) echo "Remote Login (SSH)" ;; 445) echo "File Sharing (SMB)" ;; 548) echo "File Sharing (AFP)" ;;
    5900) echo "Screen Sharing (VNC)" ;; 3283) echo "Remote Management (ARD)" ;; 3689) echo "Media Sharing (DAAP)" ;;
    7000) echo "AirPlay Receiver" ;;
  esac
}
any=0
for port in 22 445 548 5900 3283 3689 7000; do
  if listening "$port"; then
    any=1; warn "$(service_name "$port") is listening on port $port" "System Settings > General > Sharing: turn off if unused"
  fi
done
[[ $any == 0 ]] && pass "No sharing service is listening"
if [[ -f /etc/ssh/sshd_config ]] && listening 22; then
  if sshd -T 2>/dev/null | grep -qi '^passwordauthentication yes'; then
    warn "SSH accepts passwords" "Use keys only: PasswordAuthentication no in /etc/ssh/sshd_config.d/"
  fi
fi

echo; echo "Persistence (what starts by itself)"
n=0
for d in /Library/LaunchAgents /Library/LaunchDaemons "$HOME/Library/LaunchAgents"; do
  [[ -d $d ]] && n=$((n + $(find "$d" -maxdepth 1 -name '*.plist' 2>/dev/null | wc -l)))
done
warn "$n launch agent/daemon file(s) outside the system folders" "Review them with KnockKnock (brew install --cask knockknock); BlockBlock alerts on new ones"
[[ -d /Applications/BlockBlock\ Helper.app || -d /Applications/BlockBlock.app ]] && pass "BlockBlock is installed" \
  || warn "BlockBlock is not installed" "brew install --cask blockblock"

echo; echo "Recovery"
if tmutil destinationinfo 2>/dev/null | grep -q "Name"; then pass "Time Machine has a destination"
else warn "No Time Machine destination" "Back up the Mac (3-2-1: one copy offline)"; fi
if nvram -x -p 2>/dev/null | grep -q "fmm-mobileme-token-FMM"; then pass "Find My Mac is on"
else warn "Find My Mac looks off" "System Settings > Apple Account > iCloud > Find My Mac"; fi

echo
printf 'Summary: %d pass, %d warn, %d fail\n' "$PASS" "$WARN" "$FAIL"

if [[ $APPLY == 1 && ${#FIXES[@]} -gt 0 ]]; then
  echo; echo "Fixes (each asks first; nothing runs without 'y'):"
  for f in "${FIXES[@]}"; do
    desc=${f%%|*} cmd=${f#*|}
    read -r -p "  $desc  [$cmd]  run? [y/N] " ans </dev/tty
    if [[ $ans =~ ^[Yy]$ ]]; then
      if eval "$cmd"; then echo "    done"; else echo "    failed"; fi
    fi
  done
  echo "Run the audit again to confirm."
elif [[ ${#FIXES[@]} -gt 0 ]]; then
  echo "${#FIXES[@]} fix(es) can be applied with --apply (asked one by one)."
fi
exit $(( FAIL > 0 ))
