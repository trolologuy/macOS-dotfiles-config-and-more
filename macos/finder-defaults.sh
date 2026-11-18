#!/usr/bin/env bash
# Finder settings: path bar, status bar (free disk space), full path in the title, file extensions, list view, ...
#
#   ./macos/finder-defaults.sh            apply (saves the current values first, see "Undo")
#   ./macos/finder-defaults.sh --dry-run  show what would change, change nothing
#
# Undo: every run writes ~/.config/macos-dotfiles/finder-defaults-restore-<time>.sh, which puts back the previous values.
# Show/hide hidden files is deliberately not forced on: toggle it with Cmd+Shift+. in any Finder window.
set -euo pipefail

DRY=0
[[ "${1:-}" == "--dry-run" ]] && DRY=1
[[ "$(uname)" == "Darwin" ]] || { echo "macOS only." >&2; exit 1; }

RESTORE_DIR="$HOME/.config/macos-dotfiles"
RESTORE="$RESTORE_DIR/finder-defaults-restore-$(date +%Y%m%d-%H%M%S).sh"
CHANGED=0

# set DOMAIN KEY TYPE VALUE DESCRIPTION
set_default() {
  local domain=$1 key=$2 type=$3 value=$4 desc=$5 current
  current=$(defaults read "$domain" "$key" 2>/dev/null || echo "__unset__")
  # defaults prints booleans as 1/0
  local want=$value
  [[ $type == bool ]] && { [[ $value == true ]] && want=1 || want=0; }
  if [[ "$current" == "$want" ]]; then
    printf '  ok      %s\n' "$desc"
    return
  fi
  printf '  change  %s  (%s -> %s)\n' "$desc" "$current" "$want"
  CHANGED=$((CHANGED + 1))
  [[ $DRY == 1 ]] && return
  if [[ $current == "__unset__" ]]; then
    echo "defaults delete '$domain' '$key' 2>/dev/null || true" >>"$RESTORE"
  else
    echo "defaults write '$domain' '$key' -$type '$current'" >>"$RESTORE"
  fi
  defaults write "$domain" "$key" "-$type" "$value"
}

if [[ $DRY == 0 ]]; then
  mkdir -p "$RESTORE_DIR"
  printf '#!/usr/bin/env bash\n# Restores the Finder settings from before %s\n' "$(date)" >"$RESTORE"
fi

echo "Finder"
set_default com.apple.finder ShowPathbar bool true "path bar at the bottom of every window (View > Show Path Bar)"
set_default com.apple.finder ShowStatusBar bool true "status bar: item count and available disk space (View > Show Status Bar)"
set_default com.apple.finder _FXShowPosixPathInTitle bool true "full POSIX path in the window title"
set_default com.apple.finder FXPreferredViewStyle string Nlsv "list view by default for new folders"
set_default com.apple.finder _FXSortFoldersFirst bool true "folders before files when sorting by name"
set_default com.apple.finder FXDefaultSearchScope string SCcf "search the current folder, not the whole Mac"
set_default com.apple.finder NewWindowTarget string PfHm "new windows open the home folder"
set_default com.apple.finder ShowExternalHardDrivesOnDesktop bool true "external disks on the desktop"
set_default com.apple.finder ShowRemovableMediaOnDesktop bool true "USB sticks / SD cards on the desktop"

echo "All apps"
set_default NSGlobalDomain AppleShowAllExtensions bool true "always show file extensions (invoice.pdf.app tricks become visible)"

echo "No .DS_Store litter"
set_default com.apple.desktopservices DSDontWriteNetworkStores bool true "no .DS_Store files on network shares (NAS)"
set_default com.apple.desktopservices DSDontWriteUSBStores bool true "no .DS_Store files on USB drives"

echo "Library folder"
if [[ -n "$(ls -lOd "$HOME/Library" | awk '{print $5}' | grep -w hidden || true)" ]]; then
  printf '  change  show ~/Library in Finder\n'
  CHANGED=$((CHANGED + 1))
  if [[ $DRY == 0 ]]; then
    echo "chflags hidden \"\$HOME/Library\"" >>"$RESTORE"
    chflags nohidden "$HOME/Library"
  fi
else
  printf '  ok      ~/Library is visible\n'
fi

if [[ $DRY == 1 ]]; then
  echo; echo "Dry run: $CHANGED setting(s) would change."
  exit 0
fi
chmod +x "$RESTORE"
if [[ $CHANGED -gt 0 ]]; then
  killall Finder 2>/dev/null || true
  echo; echo "$CHANGED setting(s) changed, Finder restarted. Undo: $RESTORE"
else
  rm -f "$RESTORE"
  echo; echo "Nothing to change."
fi

cat <<'EOF'

Built-in shortcuts worth knowing:
  Cmd+Shift+.     show/hide hidden files
  Opt+Cmd+C       copy the selected item's path (or right-click, hold Option, "Copy ... as Pathname")
  Opt+Cmd+P       toggle the path bar;  Cmd+/  toggle the status bar
  Right-click > Services > "New Terminal at Folder"  (enable it in System Settings > Keyboard > Keyboard Shortcuts > Services)
Right-click New File / Open Terminal Here / Copy Path: Finder Menu (Brewfile), then `finder-menu enable`.
EOF
