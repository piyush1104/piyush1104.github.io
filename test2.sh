# not-xcode() {
#     if [[ $(xcode-select -p 1>/dev/null 2>/dev/null; echo $?) == 2 ]]
#     then
#         return false
#     else
#         return true
#     fi
# }

# if [[ not-xcode ]]
# then
#         echo "hello not xcode"
# else
#     echo "hello x code"
# fi


# is_xcode_installed() {
#     xcode-select -p 1>/dev/null 2>/dev/null
# }

# if ! is_xcode_installed
# then 
#     echo "xcode is not installed"
# else
#     echo "xcode is installed"
# fi

# until is_xcode_installed
# do
#     echo "xcode installation in progress"
#     sleep 2
# done

# if [[ ! $(git config --global user.name) ]]
# then 
#     echo "config is not set"
# else
#     echo "config is set"
# fi

# setup_git_ssh() {
#     location=~/.ssh/id_ed25519
#     if [[ -r ${location} ]]
#     then
#         echo "ssh key exists"
#     else
#         echo "ssh key does not exist"
#     fi
# }

# setup_git_ssh

# curl -fsSL https://raw.githubusercontent.com/piyush1104/dotfiles/master/macos/Brewfile | brew bundle --file=-

# setup_git_ssh() {
#     location=~/.ssh/id_ed2fds5519
#     if [[ -e ${location} && -r ${location} ]]
#     then
#         echo "key exists already"
#         return
#     fi
#     echo "key does not exist"
# }

# setup_git_ssh

# setup_github() {
#     # ssh-add -K ~/.ssh/id_ed25519
#     # cat ~/.ssh/id_ed25519.pub
#     sleep 1
#     echo ""
#     echo "Do you want to add the ssh key to github? Type y for yes"
#     read -r -p "**** waiting for input ****    "
#     if [[ $REPLY != "y" ]]
#     then
#         return
#     fi
#     echo "ok setting up github"
# }

# setup_github


# read -r -p "hello ===   "

# check_sudo_access(){
#     sudo -n true 2> /dev/null
# }

# if ! check_sudo_access
# then
#     echo "Please provide your admin password"
#     sudo -v
# else
#     echo "sudo is already active"
# fi

# if ! check_sudo_access
# then
#     echo "Please provide your admin password"
#     sudo -v
# else
#     echo "sudo is already active"
# fi

# is_process_active() {
#     kill -0 $$ 1>/dev/null 2>/dev/null
# }

# # sudo -v
# refresh_sudo() {
#     echo "inside refresh_sudo"
#     while true
#     do
#         echo "inside the while loop"
#         # sudo -n true
#         sleep 1
#         if ! is_process_active
#         then
#             echo "process is not active, exiting the background process (while loop)"
#             exit
#         else
#             continue
#             # echo "process is still active, not exiting"
#         fi
#     done
# }

# echo "$$"


# refresh_sudo&


# echo "after refresh_sudo"

# sleep 3


# if (is_process_active)
# then
#     echo "process is active"
# else
#     echo "process is not active"
# fi

# echo $($(is_process_active) || echo "hello")

# echo $($(kill -0 12344231) || echo "hello")

# while true; do echo $$; exit; done &

# sleep 4


# if (is_process_active)
# then
#     echo "process is active"
# else
#     echo "process is not active"
# fi

