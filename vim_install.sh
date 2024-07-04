#!/bin/bash
#set -e
#set -x

PATH=/usr/bin:/usr/local/bin:/usr/sbin:/usr/local/sbin

# check privileges
if [[ $EUID -ne 0 ]]; then
    echo "Error: Run this script as sudo"
    exit 1
fi

# check if vim is installed
which vim >/dev/null 
if [[ $? -ne 0 ]]; then

    echo "Installing Vim"
    distro=$(cat /etc/os-release | grep '^ID=' | cut -d= -f2)

    if [[ $distro == 'fedora' ]]; then
	cmd="dnf install -y"

    elif [[ $distro == 'debian' || $distro == 'ubuntu' ]]; then
	cmd="apt-get install"

    elif [[ $distro == 'arch' ]]; then
	cmd="pacman -Sy"

    else
	echo "Error : Unsupported distribution"
	exit 1
    fi

    $cmd vim >/dev/null

else
    echo "Vim is already installed"
fi


echo "Creating vim directory at ~/$SUDO_USER/.vim"
mkdir -p /home/$SUDO_USER/.vim/{colors,undo.d}

if [[ $? -ne 0 ]]; then
    echo "Error : Failed creating /home/$SUDO_USER/.vim"
    exit
fi

echo "Downloading dotfiles"
wget -q -O /home/$SUDO_USER/.vim/vimrc https://raw.githubusercontent.com/0xKrem/dotfiles/master/vimrc_merged 
if [[ $? -ne 0 ]]; then
    echo "Error : Failed to download vimrc from github"
    exit
fi

wget -q -O /home/$SUDO_USER/.vim/colors/tokyonight.vim https://raw.githubusercontent.com/0xKrem/dotfiles/master/vim/colors/tokyonight.vim 
if [[ $? -ne 0 ]]; then
    echo "Warning : Failed to download colorscheme"
fi

echo "Setting permissions"
chown -R $SUDO_USER:$SUDO_USER /home/$SUDO_USER/.vim

if [[ $? -ne 0 ]]; then
    echo "Warning : Failed to set permissions"
fi

echo "Success : Vim is ready to go"
exit 0
