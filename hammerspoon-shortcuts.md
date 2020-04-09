# Beginner-Friendly introduction to Hammerspoon 

Hammerspoon is a great automation tool for macOS, it'll help you replace all the utilities that fill your bar.
And it will add features you didn't even know you wanted / needed.
Ready ? Yeah ?
So, let's dive in !

## Install Hammerspoon
Visit [this page](https://github.com/Hammerspoon/hammerspoon)

## Useful Spoons
* [WifiNotifier](https://www.hammerspoon.org/Spoons/WifiNotifier.html) - Receive notifications every time your wifi network changes.
* [Shade](https://www.hammerspoon.org/Spoons/Shade.html) - Creates a semitransparent overlay to reduce screen brightness.
* [MountedVolumes](https://www.hammerspoon.org/Spoons/MountedVolumes.html) - Displays a list of mounted volumes and a pie chart for each indicating free space on the desktop
* [HoldToQuit](https://www.hammerspoon.org/Spoons/HoldToQuit.html) - Instead of pressing <kbd>⌘</kbd> + <kbd>Q</kbd>, hold <kbd>⌘</kbd> + <kbd>Q</kbd> to close applications.
* [ClipboardTool](https://www.hammerspoon.org/Spoons/ClipboardTool.html) - Keep a history of the clipboard for text entries and manage the entries with a context menu
* [DeepLTranslate](https://www.hammerspoon.org/Spoons/DeepLTranslate.html) - Show a popup window with the translation of the currently selected text
* [MenuHammer](https://github.com/FryJay/MenuHammer) - A Spacemacs inspired menu system for macOS built for Hammerspoon.

## Shortcuts

<kbd>ctrl</kbd> + <kbd>⌥</kbd> + <kbd>cmd</kbd> → Is referred to as <kbd>hyper</kbd>

### For example:
<kbd>ctrl</kbd> + <kbd>⌥</kbd> + <kbd>cmd</kbd> + <kbd>d</kbd>

### Becomes:
<kbd>hyper</kbd> + <kbd>d</kbd>

(click the triangle below "►" to expand the list of shortcuts)
<details>
<summary>All the shortcuts</summary>

#### Open Menu (*MenuHammer*)
<kbd>alt</kbd> + <kbd>space</kbd>
  
#### Open new Applications window
<kbd>hyper</kbd> + <kbd>1</kbd>

#### Run the "organize" app
[organize](https://github.com/tfeldmann/organize)
<kbd>hyper</kbd> + <kbd>2</kbd>
  
#### Focus on Finder window
<kbd>hyper</kbd> + <kbd>w</kbd>

#### Open Deepl (*DeepLTranslate*)
<kbd>hyper</kbd> + <kbd>d</kbd>

#### Focus on Firefox
<kbd>hyper</kbd> + <kbd>x</kbd>

#### Focus on Visual Studio Code
<kbd>hyper</kbd> + <kbd>c</kbd>

#### Focus on Telegram
<kbd>hyper</kbd> + <kbd>v</kbd>

#### Focus on Rambox
<kbd>hyper</kbd> + <kbd>b</kbd>

#### Focus on Mailspring
<kbd>hyper</kbd> + <kbd>n</kbd>

#### Focus on iTerm
<kbd>hyper</kbd> + <kbd>,</kbd>

#### Show Clipboard (*ClipboardTool*)
<kbd>hyper</kbd> + <kbd>,</kbd>
  
#### Run shade
<kbd>hyper</kbd> + <kbd>s</kbd>

#### Resize current window (*MiroWindowsManager*)
Resize to use the left half of the screen
<kbd>hyper</kbd> + <kbd>←</kbd>
  
Resize to use the right half of the screen
<kbd>hyper</kbd> + <kbd>→</kbd>
  
Resize to use the left top quarter of the screen
<kbd>hyper</kbd> + <kbd>←</kbd> + <kbd>↑</kbd>
  
Resize to use the right top quarter of the screen
<kbd>hyper</kbd> + <kbd>→</kbd> + <kbd>↑</kbd>

  ...
  
Resize to use the full width of the screen
<kbd>hyper</kbd> + <kbd>←</kbd> + <kbd>→</kbd>
  
Resize to use the full height of the screen
<kbd>hyper</kbd> + <kbd>↑</kbd> + <kbd>↓</kbd>

</details>

## My config
[Can be found here](init.lua)

It is basically a mix from my trials and errors and several examples i found either in the official documentation, or [here](https://msol.io/blog/tech/work-more-efficiently-on-your-mac-for-developers/) and [here](https://zzamboni.org/post/my-hammerspoon-configuration-with-commentary).

I tried it to make it a bit easier to configure and set up than the examples i found online.

# Contribute
If you have improvements idea, or face a bug, feel free to open an issue / pull request.
