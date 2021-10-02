#!/usr/bin/env bash

# Run this script
# curl -fsSL https://piyush1104.github.io/macos-setup.sh | bash
# /bin/bash -c "$(curl -fsSL https://piyush1104.github.io/macos-setup.sh)"

echo "Hello $(whoami)! Let's get you set up."

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront
echo "Please provide your admin password"
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Install XCode Command Line Tools.
if [[ ! $(xcode-select --print-path &> /dev/null) ]]
then
        echo "Installing Command Line tools"
        xcode-select --install &> /dev/null
fi

# Wait until XCode Command Line Tools installation has finished.
until $(xcode-select --print-path &> /dev/null); do
  sleep 5;
done

echo "installing homebrew"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo "installing packages"
brew install git \
	tree \
	bat \
	clintmod/formulas/macprefs \
	stow \
	node \
	fzf

$(brew --prefix)/opt/fzf/install


echo "Installing nvm"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash

# TODO: install global npm packages - prettier, 

echo "installing apps with brew cask"
brew install --cask google-chrome \
	firefox \
	iterm \
	google-drive \
	visual-studio-code \
	sublime-text \
	vlc \
	discord \
	zoom \
	qlcolorcode \
	qlmarkdown \
	qlstephen \
	quicklook-json \
	webpquicklook \
	suspicious-package \
	qlvideo \
	spotify \
	focus \
	qmoji \
	slack


echo "Generating a new SSH key for GitHub"

default_email="bansalpiyush177@gmail.com"
default_comment="me+github@piyush1104.com from Macbook Pro"
echo "Please enter your comment for the public key, press Enter to use default comment- ${default_comment}"
read -r comment

if [[ ! $comment ]]
then
	comment=$default_comment
fi
ssh-keygen -t ed25519 -C "${comment}" -f ~/.ssh/id_ed25519

# eval "$(ssh-agent -s)"
touch ~/.ssh/config
echo "Host *\n AddKeysToAgent yes\n UseKeychain yes\n IdentityFile ~/.ssh/id_ed25519" | tee ~/.ssh/config

# ssh-add -K ~/.ssh/id_ed25519

cat ~/.ssh/id_ed25519.pub
pbcopy < ~/.ssh/id_ed25519.pub
echo "Copied the above file to your clipboard, press ENTER to go ahead"
read -r

echo "cloning dotfiles"
git clone git@github.com:piyush1104/dotfiles.git "${HOME}/dotfiles"

cd dotfiles
stow vim
stow zsh
stow nvim

# Install tmpmail
echo "Installing tmpmail"
curl -L "https://git.io/tmpmail" > tmpmail && chmod +x tmpmail

echo "Installing ohmyzsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
echo "Remember that ohmyzsh would have backed up your original zshrc file"

echo "Setting your preferences"
export MACPREFS_BACKUP_DIR="$HOME/dotfiles/macos/preferences"

echo "Press y to change your preferences, anything else for skipping this step"
read -r
if [[ $REPLY == 'y' ]]
then
	if [[ -d $MACPREFS_BACKUP_DIR && -r $MACPREFS_BACKUP_DIR ]]
	then
		macprefs restore
	fi
fi


echo "You might have to logout and log back in, once the script ends"


# TODO: iterm preferences, notes preferences, automatic signin for slack, notes and apple.
# TODO: check packages before installing them
