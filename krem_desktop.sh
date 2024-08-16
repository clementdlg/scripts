# SCOPE :
# - only for fedora
# - only for me
# - only what i already have
# - modular and error handling
# - can be ran multiple time without sideeffects


# exit if a command fails
set -e

# check if running as root
if [[ $EUID -ne 0 || ! -n $SUDO_USER ]]; then
    echo "Error: Run this script using sudo"
    exit 1
fi

$user=$SUDO_USER
home="/home/$user"
$PWD=$home
dnf="/etc/dnf/dnf.conf"
dotfiles="https://github.com/0xKrem/dotfiles.git"
dotconf="$home/.config"
theme_dir="$home/.local/share/themes"
lockscreen_bg="$dotconf/awesome/theme/lockscreen-bg-fhd.png"
gtk_theme="https://github.com/daniruiz/skeuos-gtk.git"
awesome_session="/usr/share/xsessions/awesome.desktop"

# edit dnf config
if ! grep 'fastestmirror=true' ; then

    if grep 'fastestmirror=false' $dnf; then
	sed -i 's/fastestmirror=false/fastestmirror=true/' $dnf
    else
	echo "fastestmirror=true" >> $dnf
    fi
fi

if ! grep 'max_parallel_downloads=20' $dnf; then

    if grep -E 'max_parallel_downloads=[0-9]+$' $dnf; then
	sed -i -E 's/max_parallel_downloads=[0-9]+$/max_parallel_downloads=20/' $dnf
    else
	echo "max_parallel_downloads=20" >> $dnf
    fi
fi

# install packets
./KRABS/modules/pkg_installer.sh

# setup dotfiles
sudo -u $user mkdir $dotconf
sudo -u $user git clone $dotfiles $dotconf
if [[ $? -ne 0 ]]; then
    echo "Error: Can not clone $dotfiles"
    exit 1
fi

# setup lightdm
./KRABS/modules/lightdm_conf.sh $lockscreen_bg

# create awesome session
if [[ ! -f $awesome_session ]]; then
    echo "[Desktop Entry]
    Name=awesome
    Comment=Highly configurable framework window manager
    TryExec=awesome
    Exec=awesome
    Type=Application" > $awesome_session 
fi

# symlinks
rm -f $home/{.bashrc,.bash_profile}
sudo -u $user ln -s $dotconf/bash/bashrc .bashrc
sudo -u $user ln -s $dotconf/bash/bash_profile .bash_profile

# configure theme and fonts
sudo -u $user mkdir -p $theme_dir
sudo -u $user git clone --branch master --depth 1 $gtk_theme $theme_dir/skeuos-gtk

if [[ $? -ne 0 ]]; then
    echo "Error: Can not clone $gtk_theme"
    exit 1
fi
sudo -u $user mv $theme_dir/skeuos-gtk/themes/Skeuos-Blue-Dark $theme_dir
rm -fr skeuos-gtk/

# install fonts
chmod 744 font_installer.sh
chown krem:krem font_installer.sh
sudo -u $user ./$home/KRABS/modules/font_installer.sh

# firewall
    # syncthing
firewall-cmd --add-port=22000/udp --permanent
firewall-cmd --add-port=22000/tcp --permanent

# missing 
# - better bootstap command using curl
# - flatpaks
# - mozilla user.js
# - syncthing daemon
# flatpak overrides
# mounting my ssd as home
# btrfs snapper
