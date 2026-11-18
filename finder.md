# Finder setup

## 1. Settings (script)

```sh
./macos/finder-defaults.sh --dry-run   # shows what would change
./macos/finder-defaults.sh             # applies, restarts Finder, writes an undo script
```

| Setting | Effect |
|---|---|
| Path bar | the folder path at the bottom of each window; double-click a part to go there |
| Status bar | item count and **available disk space** at the bottom |
| Full path in title | `/Users/me/Projects/x` instead of `x` in the window title |
| Always show file extensions | `invoice.pdf.app` can no longer pass for a PDF |
| List view, folders first | for new folders |
| Search the current folder | instead of the whole Mac |
| No `.DS_Store` on network and USB drives | keeps NAS shares and sticks clean |
| `~/Library` visible | |
| External disks and USB sticks on the desktop | |

Undo: run the `~/.config/macos-dotfiles/finder-defaults-restore-<time>.sh` that the script printed.

## 2. Right-click menu: Finder Menu

[Finder Menu](https://github.com/nikgrbn/finder-menu) (MIT, open source, built on your Mac) adds to Finder's right-click
menu: **New File…** (any extension: `notes.txt`, `config.yaml`, `.env`; reusable templates), **Open Terminal Here**
(iTerm2 when installed), **Open Folder With** (VS Code, …), **Copy Path** and **Go to Parent Folder**.

```sh
brew install nikgrbn/tap/finder-menu   # also in the Brewfile
finder-menu enable                     # once, and again after each upgrade
finder-menu settings                   # choose items and the terminal
```

It comes from a third-party tap (its formula code runs on your Mac); before `brew uninstall finder-menu`, run
`finder-menu disable`.

## 3. Built-in shortcuts

| What | How |
|---|---|
| Show / hide hidden files | <kbd>⌘</kbd> + <kbd>⇧</kbd> + <kbd>.</kbd> |
| Copy the selected item's path | <kbd>⌥</kbd> + <kbd>⌘</kbd> + <kbd>C</kbd>, or right-click, hold <kbd>⌥</kbd>, "Copy … as Pathname" |
| Path bar / status bar on or off | <kbd>⌥</kbd> + <kbd>⌘</kbd> + <kbd>P</kbd> / <kbd>⌘</kbd> + <kbd>/</kbd> |
| Terminal at a folder without Finder Menu | right-click › Services › New Terminal at Folder (turn it on in System Settings › Keyboard › Keyboard Shortcuts › Services) |
| Go to a path | <kbd>⌘</kbd> + <kbd>⇧</kbd> + <kbd>G</kbd> |

## 4. Hammerspoon shortcuts (keyboard fallback)

In [`.hammerspoon/init.lua`](.hammerspoon/init.lua), section *Finder helpers*, acting on the front Finder window:

| Shortcut | Action |
|---|---|
| <kbd>hyper</kbd> + <kbd>t</kbd> | open iTerm (or Terminal) in the current folder |
| <kbd>hyper</kbd> + <kbd>p</kbd> | copy the paths of the selected items, or of the current folder |
| <kbd>hyper</kbd> + <kbd>e</kbd> | new file: asks for the name (`notes.txt`, `config.yaml`), creates and selects it, never overwrites |

The first use asks to let Hammerspoon control Finder (System Settings › Privacy & Security › Automation).
