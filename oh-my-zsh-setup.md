# Prerequisites

## (optional) install iterm2
* [iterm2](https://iterm2.com/downloads.html)

## Download the latest version of oh-my-zsh
`sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`




# Theme

## Themes to choose from
My favorites :
* [powerlevel10k](https://github.com/romkatv/powerlevel10k)
* [spaceship](https://github.com/denysdovhan/spaceship-prompt)

[All of the themes](https://github.com/ohmyzsh/ohmyzsh/wiki/themes)

## Theme installation 
__Prerequisite__: iTerm2 installed on the machine

### powerlevel10k theme

More info can be found [here]()

#### Installation
`git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k`

`sed -i'.bak' -e 's/^\(ZSH_THEME=\s*\).*$/\ZSH_THEME=\"powerlevel10k\/powerlevel10k\"/' ~/.zshrc`

`rm .zshrc.bak`

After the installation it will ask you to restart iTerm and will start the configuration wizard.
 
### spaceship theme
More info can be found [here](https://github.com/denysdovhan/spaceship-prompt)

#### Installation
`git clone https://github.com/denysdovhan/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt"`

`ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"`

`sed -i'.bak' -e 's/^\(ZSH_THEME=\s*\).*$/\ZSH_THEME=\"spaceship\"/' ~/.zshrc`

`rm .zshrc.bak`

`source .zshrc`

# Plugins

## List of plugins that are added
* [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
* [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
* [colored-man-pages](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/colored-man-pages)

## Add the zsh-syntax-highlighting plugin
`git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting`

## Add the zsh-autosuggestions plugin
`git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions`

## Add the plugins to the config file. 
`sed -i'.bak' -e 's/^\(plugins=\s*\).*$/\plugins=(git zsh-syntax-highlighting zsh-autosuggestions colored-man-pages)/' ~/.zshrc`

If it fails, check [this article](https://stackoverflow.com/questions/4247068/sed-command-with-i-option-failing-on-mac-but-works-on-linux)

## Remove backup of .zshrc file
`rm .zshrc.bak`

## Reload the current shell
`source .zshrc`