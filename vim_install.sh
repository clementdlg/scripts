#!/bin/bash
#set -e
#set -x

PATH=/usr/bin:/usr/local/bin:/usr/sbin:/usr/local/sbin

# check privileges
if [[ $EUID -ne 0 ]]; then
    echo "Error: Run this script as sudo"
    exit 1
fi


# get package manager
distro=$(lsb-release -i | awk '{ print $3 }')
if [[ $distro == 'Fedora' ]]; then
    pkgm="dnf"
    echo "Package Manager is DNF"

elif [[ $distro == 'Debian' || $distro == 'Ubuntu' ]]; then
    pkgm="apt"
    echo "Package Manager is APT"
else
    echo "Error : Unsupported distribution"
    exit 1
fi

# check if vim is installed
which vim >/dev/null 
if [[ $? -ne 0 ]]; then
    echo "Installing Vim"
    $pkgm install vim -y >/dev/null

    which vim >/dev/null 

    if [[ $? -ne 0 ]]; then
	echo "Error : Vim couldn't get installed"
	exit 1
    fi
else
   echo "Vim already installed" 
fi


echo "Creating directories"
mkdir -p /home/$SUDO_USER/.vim/{colors,undo.d}

if [[ $? -ne 0 ]]; then
    echo "Error : Failed creating /home/$SUDO_USER/.vim"
    exit
fi

echo "Downloading dotfiles"
wget -O /home/$SUDO_USER/.vim/vimrc https://raw.githubusercontent.com/0xKrem/dotfiles/master/vimrc_merged >/dev/null
if [[ $? -ne 0 ]]; then
    echo "Error : Failed to download vimrc from github"
    exit
fi

wget -O /home/$SUDO_USER/.vim/colors/tokyonight.vim https://raw.githubusercontent.com/0xKrem/dotfiles/master/vim/colors/tokyonight.vim >/dev/null
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
