#!/usr/bin/env bash

# Run this script (preferred method)
# /bin/bash -c "$(curl -fsSL https://piyush1104.github.io/macos-setup.sh)"
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/piyush1104/piyush1104.github.io/master/macos-setup.sh)" - for downloading from specific branch

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
    echo "Type y to open System Preferences to grant full disk access to terminal. You will have to add your terminal by clicking on + button at bottom left."

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



# ========================= #
# Get admin password  #
# ========================= #

# https://askubuntu.com/questions/838850/see-whether-sudo-mode-is-on-password-is-cached-on-the-command-line-prompt
# Ask for the administrator password upfront
check_sudo_access(){
    sudo -n true 2> /dev/null
}
get_sudo_access() {
    if ! check_sudo_access
    then
        echo "Please provide your admin password"
        sudo -v
    fi
}
get_sudo_access
sleep 1


# ========================= #
# Refreshing the Sudo time  #
# ========================= #

# Keep-alive: update existing `sudo` time stamp until the script has finished
# -n, --non-interactive
#                   Avoid prompting the user for input of any kind.  If a password is required for the command to run, sudo will display an error message and
#                   exit.
# So how it works is that we first ask for the password before this while loop (that makes sudo active for some time.)
# now we don't want sudo to end and fail for other commands like. So we non interactively asks for permission every 60 seconds.
# But since sudo is already active, it does throw an error message but resets the time again for sudo
# $$ tells the PID of current process
# The kill -0 command is used to check if a process with a specific process ID (PID) is running. It does not actually terminate or kill the process; instead, it tests whether the process exists and whether the user has permission to send a signal to it.
# if the process exists and the user has permission to send a signal to it, the command will exit successfully (with a return code of 0). If the process does not exist or the user does not have permission, the command will fail (with a non-zero return code).
# so if kill -0 returns successfully (process exists) then the exit in or won't be triggered.
# if it fails, it means the process does not exist anymore, then exit is used to exit from the background process we have created
# while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done &
is_process_active() {
    kill -0 $$ 1>/dev/null 2>/dev/null
}
refresh_sudo() {
    # echo "inside refresh_sudo"
    while true
    do
        # echo "inside the while loop"
        sudo -n true
        sleep 60
        if ! is_process_active
        then
            # echo "process is not active, exiting the background process (while loop)"
            exit
        else
            # echo "process is still active, not exiting"
            continue
        fi
    done
}
refresh_sudo&

# ================================= #
# Install XCode Command Line Tools. #
# ================================= #

# xcode-select -p 1>/dev/null;echo $?

# https://unix.stackexchange.com/questions/232421/why-is-my-function-call-not-working-when-returning-a-boolean
is_xcode_installed() {
    xcode-select -p 1>/dev/null 2>/dev/null
}

setup_xcode() {
    echo ""
    echo "------------===============------------"
    echo "Setting up XCode"
    echo "------------===============------------"
    if is_xcode_installed
    then
        echo "-- skipping -- XCode is already installed, hurray!"
        return
    fi
    echo "Installing Command Line tools (XCode)"
    xcode-select --install
}

setup_xcode
sleep 1


# Wait until XCode Command Line Tools installation has finished.
until is_xcode_installed
do
  sleep 1
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

install_brew() {
    echo ""
    echo "------------===============------------"
    echo "Setting up brew"
    echo "------------===============------------"
    if [[ $(which brew) ]]
    then
        echo "--skipping-- brew is already installed"
        return
    fi

    echo "Installing brew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 
    echo "Installed brew"
}

install_brew
sleep 1

/opt/homebrew/bin/brew install gh

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

install_brews() {
    echo ""
    echo "------------===============------------"
    echo "Installing brews and casks"
    echo "------------===============------------"
    echo "Do you want to install brews and casks? Type y for yes"
    read -r -p "**** waiting for input ****    "
    if [[ $REPLY != "y" ]]
    then
        return
    fi

    curl -fsSL https://raw.githubusercontent.com/piyush1104/dotfiles-public-mirror/mac1/macos/Brewfile | /opt/homebrew/bin/brew bundle --file=-    
}

# install_brews
# sleep 1


# brew bundle --file=- <<-EOF
# # For installing packages like this, refer - https://github.com/Homebrew/brew/issues/2491#issuecomment-372402005
# # and https://github.com/Homebrew/homebrew-bundle
# # Also look at these - https://unix.stackexchange.com/questions/505828/how-to-pass-a-string-to-a-command-that-expects-a-file and https://unix.stackexchange.com/questions/20035/how-to-add-newlines-into-variables-in-bash-script

# #installing brews
# brew "git"
# brew "tree"
# brew "bat"
# brew "piyush1104/formulas/macprefs"
# brew "stow"
# brew "node"
# brew "fzf"
# brew "gh"
# brew "jq"
# brew "w3m"
# brew "bat"
# brew "gitui"
# brew "zsh-vi-mode"
# brew "docker"
# brew "mas"

# # installing casks
# cask "protonvpn"
# cask "notion"
# cask "figma"
# cask "betterzip"
# cask "sequel-ace"
# cask "google-chrome"
# cask "firefox"
# cask "iterm2"
# cask "google-drive"
# cask "visual-studio-code"
# cask "sublime-text"
# cask "vlc"
# cask "discord"
# cask "zoom"
# cask "sublime-merge"
# cask "obsidian"
# cask "pycharm-ce"


# # I am installing these packages after looking from here - http://sourabhbajaj.com/mac-setup/Homebrew/Cask.html
# # Also look it here - https://github.com/sindresorhus/quick-look-plugins
# cask "qlcolorcode"
# cask "qlmarkdown"
# cask "qlstephen"
# cask "quicklook-json"
# cask "webpquicklook"
# cask "suspicious-package"
# cask "qmoji"
# cask "qlvideo"

# cask "spotify"
# cask "focus"
# cask "slack"
# cask "whatsapp"
# cask "docker"
# cask "flux"
# cask "transmission"
# cask "macvim"
# cask "postman"
# cask "stremio"
# cask "rectangle"

# # good package, but I don't need it yet
# # cask "sensiblesidebuttons"

# tap "homebrew/cask-fonts"
# cask "font-fira-code"
# EOF


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

setup_git_config() {
    echo ""
    echo "------------===============------------"
    echo "Setting default configs for git"
    echo "------------===============------------"
    if [[ $(git config --global user.name) ]]
    then
        echo "--skipping-- git config is already set"
        return
    fi
    
    git config --global user.name "Piyush Bansal"
    git config --global user.email "bansalpiyush177@gmail.com"
    git config --global url.ssh://git@github.com/.insteadOf https://github.com/
    echo "git config updated"
}

setup_git_config
sleep 1


setup_git_ssh() {
    echo ""
    echo "------------===============------------"
    echo "Setting up your ssh key for GitHub"
    echo "------------===============------------"

    location=~/.ssh/id_ed25519
    if [[ -e ${location} && -r ${location} ]]
    then
        echo "--skipping-- ssh key already exists"
        return
    fi

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
    echo "ssh key setup completed"
}

setup_git_ssh
sleep 1

setup_github() {
    echo ""
    echo "------------===============------------"
    echo "Setting your github"
    echo "------------===============------------"
    echo "Do you want to add the ssh key to github? Type y for yes"
    read -r -p "**** waiting for input ****    "
    if [[ $REPLY != "y" ]]
    then
        return
    fi

    cat ~/.ssh/id_ed25519.pub
    pbcopy < ~/.ssh/id_ed25519.pub

    echo ""
    echo "Copied the above public key to your clipboard"
    echo ""
    echo "Logging you to github using gh, please select n while uploading ssh key"
    echo "A good way to login github is either using browser way or a personal token"
    gh auth login
    gh ssh-key add ~/.ssh/id_ed25519.pub --title="${comment}"
}

setup_github
sleep 1

install_brews
sleep 1

# ================ #
# Cloning dotfiles #
# ================ #

setup_dotfiles() {
    echo ""
    echo "------------===============------------"
    echo "Setting your dotfiles"
    echo "------------===============------------"
    echo "Do you want to setup dotfiles? Type y for yes"
    read -r -p "**** waiting for input ****    "
    if [[ $REPLY != "y" ]]
    then
        return
    fi

    DOTFILES_DIR="${HOME}/dotfiles"
    git clone --single-branch --branch mac1 git@github.com:piyush1104/dotfiles.git $DOTFILES_DIR
    cd ~/dotfiles
    stow vim
    stow zsh
    stow nvim
    cd -

    # . ~/.zshrc
    source ~/.zshrc
}

setup_dotfiles

# ================================== #
# Installing some command line tools #
# ================================== #

install_fzf() {
    echo "------------===============------------"
    echo "Type y to install fzf utils, anything else for skipping this step"
    read -r -p "**** waiting for input ****    "
    if [[ $REPLY != "y" ]]
    then
        return
    fi

    $(/opt/homebrew/bin/brew --prefix)/opt/fzf/install 
}

install_tmpmail() {
    echo "------------===============------------"
    echo "Type y to install tmpmail, anything else for skipping this step"
    read -r -p "**** waiting for input ****    "
    if [[ $REPLY != "y" ]]
    then
        return
    fi

    curl -sSL "https://git.io/tmpmail" > tmpmail && chmod +x tmpmail
    mkdir -p "${HOME}/bin"
    mv tmpmail "${HOME}/bin/"
}

install_ohmyzsh() {
    echo "------------===============------------"
    echo "Type y to install ohmyzsh, anything else for skipping this step"
    read -r -p "**** waiting for input ****    "
    if [[ $REPLY != "y" ]]
    then
        return
    fi

    git-clone https://github.com/ohmyzsh/ohmyzsh.git "${HOME}/.oh-my-zsh"
}

install_tools() {
    echo ""
    echo "------------===============------------"
    echo "Installing some command line tools"
    echo "------------===============------------"
    install_fzf

    install_tmpmail

    install_ohmyzsh

    echo "------------===============------------"
    echo "Installing nvm"
    curl -sSLo- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash


    if [[ ! $(which npm) ]]
    then
        echo "------------===============------------"
        echo "npm is not loaded, would you like to try loading it? Type y for yes"
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
}

install_tools



# ======================= #
# Setting mac preferences #
# ======================= #

setup_preferences() {
    echo ""
    echo "------------===============------------"
    echo "Setting up your preferences"
    echo "------------===============------------"
    echo "Type y to change your preferences, anything else for skipping this step"
    read -r -p "**** waiting for input ****    "
    if [[ $REPLY != "y" ]]
    then
        return
    fi

    echo "Make sure that your terminal has full disk access for this to work properly."
    echo "https://osxdaily.com/2018/10/09/fix-operation-not-permitted-terminal-error-macos/"
    read -r -p "Press ENTER if you have made sure."

    export MACPREFS_BACKUP_DIR="${HOME}/dotfiles/macos/preferences"

    if [[ -d $MACPREFS_BACKUP_DIR && -r $MACPREFS_BACKUP_DIR ]]
    then
        macprefs restore -t system_preferences startup_items preferences app_store_preferences internet_accounts
        echo "------------===============------------"
        echo "You might have to logout or maybe even restart, once the script ends for preferences to take effect."
    fi

    # TODO: iterm preferences, notes preferences, automatic signin for slack, notes and apple.
    # TODO: check packages before installing them
}

setup_preferences

setup_vim_tools() {
    echo ""
    echo "------------===============------------"
    echo "Installing tools for vim"
    echo "------------===============------------"
    echo "Type y to install your vim tools, anything else for skipping this step"
    read -r -p "**** waiting for input ****    "
    if [[ $REPLY != "y" ]]
    then
        return
    fi

    curl -fsSLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    echo "Installed plug.vim, remember to do :PlugInstall after opening vim"

}

setup_vim_tools

install_go_tools() {
    go install github.com/cespare/reflex@latest
    go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.28
    go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.2
}

install_go_tools
