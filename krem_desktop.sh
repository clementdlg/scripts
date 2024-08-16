# check privileges
if [[ $EUID -ne 0 ]]; then
    echo "Error: Run this script with root privileges"
    exit 1
fi

# LOGGING
# WILL BE REMOVED
dnf install git -y 
git clone https://github.com/0xKrem/scripts 
if [[ $? -ne 0 ]]; then
    echo "Error: Can not clone repo 0xKrem/scripts"
    exit 1
fi
source scripts/shell_logger.sh

# edit dnf config
if ! grep 'fastestmirror=true' /etc/dnf/dnf.conf; then

    if grep 'fastestmirror=false' /etc/dnf/dnf.conf; then
	sed -i 's/fastestmirror=false/fastestmirror=true/' /etc/dnf/dnf.conf
    else
	echo "fastestmirror=true" >> /etc/dnf/dnf.conf
    fi
fi

if ! grep 'max_parallel_downloads=20' /etc/dnf/dnf.conf; then

    if grep -E 'max_parallel_downloads=[0-9]+$' /etc/dnf/dnf.conf ; then
	sed -i -E 's/max_parallel_downloads=[0-9]+$/max_parallel_downloads=20/' /etc/dnf/dnf.conf
    else
	echo "max_parallel_downloads=20" >> /etc/dnf/dnf.conf
    fi
fi


# ./pkg_installer.sh

# setup dotfiles
sudo -u krem mkdir /home/krem/.config
sudo -u krem git clone https://github.com/0xKrem/dotfiles.git /home/krem/.config
if [[ $? -ne 0 ]]; then
    echo "Error: Can not clone repo 0xKrem/dotfiles"
    exit 1
fi

rm -f .bashrc .bash_profile
sudo -u krem ln -s .config/bash/bashrc .bashrc
sudo -u krem ln -s .config/bash/bash_profile .bash_profile

# configure theme and fonts
sudo -u krem mkdir -p /home/krem/.local/share/{themes/skeuos-gtk,fonts}
sudo -u krem git clone --branch master --depth 1 https://github.com/daniruiz/skeuos-gtk.git /home/krem/.local/share/themes/skeuos-gtk
if [[ $? -ne 0 ]]; then
    echo "Error: Can not clone repo daniruiz/skeuos-gtk"
    exit 1
fi

sudo -u krem mv skeuos-gtk/themes/Skeuos-Blue-Dark .
sudo -u krem rm -fr skeuos-gtk/

# ./font_installer.sh

# configure lightdm
systemctl enable lightdm.service
systemctl set-default graphical.target

echo "[Seat:*]
autologin-user=krem
autologin-session=xfce
greeter-session=lightdm-gtk-greeter" > /etc/lightdm/lightdm.conf

echo "[greeter]
theme-name = Adwaita-dark
icon-theme-name = ePapirus-Dark
font-name = Sans 12
background = /usr/share/backgrounds/lockscreen-bg-fhd.png" > /etc/lightdm/lightdm-gtk-greeter.conf

# background image
cp /home/krem/.config/awesome/theme/lockscreen-bg-fhd.png /usr/share/backgrounds/
chmod 644 /usr/share/backgrounds/lockscreen-bg-fhd.png

# remove override background
mv /usr/share/backgrounds/xfce/{xfce,_xfce}-shapes.svg

# create awesome session
echo "[Desktop Entry]
Name=awesome
Comment=Highly configurable framework window manager
TryExec=awesome
Exec=awesome
Type=Application" > /usr/share/xsessions/awesome.desktop

# missing 
# - flatpaks
# - lockscreen background
# - mozilla user.js
# - syncthing daemon
# firewall-cmd --add-port=22000/udp --permanent
# firewall-cmd --add-port=22000/tcp --permanent
# flatpak overrides
# mouting my ssd as home
#
#chmod 755 /home/krem/.config/awesome/theme/lockscreen-bg-fhd.png
