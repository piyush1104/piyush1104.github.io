#!/usr/bin/env bash

# Run this script (preferred method)
# /bin/bash -c "$(curl -fsSL https://piyush1104.github.io/macos-setup.sh)"

# Obselete method - (for some reason, it fails sometimes)
# curl -fsSL https://piyush1104.github.io/macos-setup.sh | bash


# Some great setup guide-
# https://gist.github.com/millermedeiros/6615994#5-borrow-a-few-osx-settings-from-mathiasbynens-dotfiles
# https://github.com/mathiasbynens/dotfiles/blob/master/.macos

echo "Hello $(whoami)! Let's get you set up."

# Grant full disk access to the terminal
# https://apple.stackexchange.com/questions/361045/open-system-preferences-privacy-full-disk-access-with-url
# https://developer.apple.com/documentation/devicemanagement/systempreferences
# https://developer.apple.com/forums/thread/114452
if [[ ! -r "/Library/Application Support/com.apple.TCC/TCC.db" ]]
then
    echo "You might not have given full disk access to the terminal."
    echo "Press y to open System Preferences to grant full disk access to terminal"

    # Something to learn - "read -p" only works in bash environment
    read -r -p "**** waiting for input ****     "
    if [[ $REPLY == "y" ]]
    then
        echo "Ending the script for now. Run same script again once the permission is given."
        open "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles"
        exit 0
    fi
fi


# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront
echo "Please provide your admin password"
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &


# ================================= #
# Install XCode Command Line Tools. #
# ================================= #

if [[ $(xcode-select --print-path &> /dev/null) ]]
then
    echo ""
    echo "Installing Command Line tools"
    xcode-select --install &> /dev/null
fi

# Wait until XCode Command Line Tools installation has finished.
until $(xcode-select --print-path &> /dev/null)
do
  sleep 5
done


git-clone() {
    url=$1
    repo=$2
    if cd $repo
    then 
        git pull
        cd -
    else 
        git clone $url $repo
    fi
}


# =============== #
# Setting up brew #
# =============== #

if [[ ! $(which brew) ]]
then
    echo "------------===============------------"
    echo "Installing homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 
    sleep 5;
fi

echo "------------===============------------"
echo "installing brews and casks"
# brews=(
# 	"git"
# 	"tree"
# 	"bat"
# 	"clintmod/formulas/macprefs"
# 	"stow"
# 	"node"
# 	"fzf"
# 	"gh"
# )
# casks=(
#         "firefox"   
#         "google-chrome"
#         "iterm2"
#         "google"-"drive"
#         "visual"-"studio"-"code"
#         "sublime"-"text"
#         "vlc"
#         "discord"
#         "zoom"
#         "qlcolorcode"
#         "qlmarkdown"
#         "qlstephen"
#         "quicklook"-"json"
#         "webpquicklook"
#         "suspicious"-"package"
#         "qlvideo"
#         "spotify"
#         "focus"
#         "qmoji"
#         "slack" 
# )
# file=""
# for package in "${casks[@]}"
# do
#         file="${file}cask \"${package}\"\n"
# done
# 
# printf -v file "$file"
# echo "$file" | brew bundle --file=/dev/stdin
# echo "$file" > BREWFILE
# brew bundle --file=BREWFILE


brew bundle --file=- <<-EOF
# For installing packages like this, refer - https://github.com/Homebrew/brew/issues/2491#issuecomment-372402005
# and https://github.com/Homebrew/homebrew-bundle
# Also look at these - https://unix.stackexchange.com/questions/505828/how-to-pass-a-string-to-a-command-that-expects-a-file and https://unix.stackexchange.com/questions/20035/how-to-add-newlines-into-variables-in-bash-script

#installing brews
brew "git"
brew "tree"
brew "bat"
brew "piyush1104/formulas/macprefs"
brew "stow"
brew "node"
brew "fzf"
brew "gh"
brew "jq"
brew "w3m"
brew "bat"
brew "gitui"
brew "zsh-vi-mode"
brew "docker"
brew "mas"

# installing casks
cask "protonvpn"
cask "notion"
cask "figma"
cask "betterzip"
cask "sequel-ace"
cask "google-chrome"
cask "firefox"
cask "iterm2"
cask "google-drive"
cask "visual-studio-code"
cask "sublime-text"
cask "vlc"
cask "discord"
cask "zoom"
cask "sublime-merge"
cask "obsidian"
cask "pycharm-ce"


# I am installing these packages after looking from here - http://sourabhbajaj.com/mac-setup/Homebrew/Cask.html
# Also look it here - https://github.com/sindresorhus/quick-look-plugins
cask "qlcolorcode"
cask "qlmarkdown"
cask "qlstephen"
cask "quicklook-json"
cask "webpquicklook"
cask "suspicious-package"
cask "qmoji"
cask "qlvideo"

cask "spotify"
cask "focus"
cask "slack"
cask "whatsapp"
cask "docker"
cask "flux"
cask "transmission"
cask "macvim"
cask "postman"
cask "stremio"
cask "rectangle"

# good package, but I don't need it yet
# cask "sensiblesidebuttons"

tap "homebrew/cask-fonts"
cask "font-fira-code"
EOF


# another way to install all the casks and brews are -
# valid_casks=()
# for package in "${casks[@]}"
# do
#         brew list --cask $package || valid_casks+=($package)
# done
# 
# brew install --cask "${valid_casks[@]}"


# =================== #
# Setting up your git #
# =================== #

git config --global user.name "Piyush Bansal"
git config --global user.email "bansalpiyush177@gmail.com"

echo "------------===============------------"
echo "Generating a new SSH key for GitHub"

default_email="bansalpiyush177@gmail.com"
default_comment="me+github@piyush1104.com from Macbook Pro"
echo "Please enter your comment for the public key, press Enter to use default comment- ${default_comment}"

read -r -p "**** waiting for input ****    " comment
if [[ ! $comment ]]
then
	comment=${default_comment}
fi

ssh-keygen -t ed25519 -C "${comment}" -f ~/.ssh/id_ed25519

# eval "$(ssh-agent -s)"
touch ~/.ssh/config
echo "Host *\n AddKeysToAgent yes\n UseKeychain yes\n IdentityFile ~/.ssh/id_ed25519" | tee ~/.ssh/config

# ssh-add -K ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub
pbcopy < ~/.ssh/id_ed25519.pub

echo "------------===============------------"
echo "Copied the above file to your clipboard"

echo "Logging you to github using gh, please select n while uploading ssh key"
echo "A good way to login github is either using browser way or a personal token"
gh auth login
gh ssh-key add ~/.ssh/id_ed25519.pub --title="${comment}"

echo "------------===============------------"
echo "Press ENTER for going ahead"
read -r -p "**** waiting for input ****    "


# ================ #
# Cloning dotfiles #
# ================ #

DOTFILES_DIR="${HOME}/dotfiles"
echo "cloning dotfiles"
git-clone git@github.com:piyush1104/dotfiles.git $DOTFILES_DIR
cd ~/dotfiles
stow vim
stow zsh
stow nvim
cd -


# ================================== #
# Installing some command line tools #
# ================================== #

echo "------------===============------------"
echo "Installing fzf utils"
$(brew --prefix)/opt/fzf/install 

echo "------------===============------------"
echo "Installing tmpmail"
curl -sSL "https://git.io/tmpmail" > tmpmail && chmod +x tmpmail
mkdir -p "${HOME}/bin"
mv tmpmail "${HOME}/bin/"

echo "------------===============------------"
echo "Installing ohmyzsh"
git-clone https://github.com/ohmyzsh/ohmyzsh.git "${HOME}/.oh-my-zsh"

echo "------------===============------------"
echo "Installing nvm"
curl -sSLo- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash


if [[ ! $(which npm) ]]
then
    echo "------------===============------------"
    echo "npm is not loaded, would you like to try loading it? Press y for yes"
    read -r -p "**** waiting for input ****    "

    if [[ $REPLY == "y" ]]
    then
        echo ".... loading nvm ...."
        loadnvm
    fi
fi

if [[ $(which npm) ]]
then
    echo "------------===============------------"
    echo "Installing global npm packages like - prettier"
    npm install -g prettier
    npm install -g eslint
    npm install -g yarn
fi


# ======================= #
# Setting mac preferences #
# ======================= #

echo "------------===============------------"
echo "Setting your preferences"
export MACPREFS_BACKUP_DIR="${HOME}/dotfiles/macos/preferences"

echo "Press y to change your preferences, anything else for skipping this step"
read -r -p "**** waiting for input ****    "

if [[ $REPLY == "y" ]]
then

    echo "Make sure that your terminal has full disk access for this to work properly."
    echo "https://osxdaily.com/2018/10/09/fix-operation-not-permitted-terminal-error-macos/"
    read -r -p "Press ENTER if you have made sure."

	if [[ -d $MACPREFS_BACKUP_DIR && -r $MACPREFS_BACKUP_DIR ]]
	then
		macprefs restore -t system_preferences startup_items preferences app_store_preferences internet_accounts
        echo "------------===============------------"
        echo "You might have to logout or maybe even restart, once the script ends for preferences to take effect."
	fi
fi


# TODO: iterm preferences, notes preferences, automatic signin for slack, notes and apple.
# TODO: check packages before installing them

echo "------------===============------------"
echo "Installing tools for vim"

curl -fsSLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
echo "Installed plug.vim, remember to do :PlugInstall after opening vim"
