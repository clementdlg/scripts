# check privileges
if [[ $EUID -ne 0 ]]; then
    echo "Error: Run this script with root priviledges"
    exit 1
fi

# WILL BE REMOVED
dnf install git -y 
git clone https://github.com/0xKrem/scripts 

if [[ $? -ne 0 ]]; then
    echo "Error: Can not clone repo 0xKrem/scripts"
    exit 1
fi

source scripts/shell_logger.sh

# edit dnf config
echo "fastestmirror=true" >> /etc/dnf/dnf.conf
echo "max_parallel_downloads=20" >> /etc/dnf/dnf.conf

# ./pkg_installer.sh

# setup dotfiles
sudo -u krem mkdir /home/krem/.config
sudo -u krem git clone https://github.com/0xKrem/dotfiles.git /home/krem/.config
if [[ $? -ne 0 ]]; then
    echo "Error: Can not clone repo 0xKrem/dotfiles"
    exit 1
fi

rm -f .bashrc .bash_profile
sudo -u ln -s .config/bash/bashrc .bashrc
sudo -u ln -s .config/bash/bash_profile .bash_profile

# configure theme and fonts
sudo -u krem mkdir -p /home/krem/.local/share/{themes/skeuos-gtk,fonts}
sudo -u krem git clone --branch master --depth 1 https://github.com/daniruiz/skeuos-gtk.git /home/krem/.local/share/themes/skeuos-gtk
if [[ $? -ne 0 ]]; then
    echo "Error: Can not clone repo daniruiz/skeuos-gtk"
    exit 1
fi

sudo -u krem mv skeuos-gtk/themes/Skeuos-Blue-Dark .
20-24-11:root:/home/krem/.local/share/themes:sudo -u krem rm -fr skeuos-gtk/
20-24-14:root:/home/krem/.local/share/themes:ls
20-24-27:root:/home/krem/.local/share/themes:mkdir -p /home/krem.local/share/fonts
20-25-04:root:/home/krem/.local/share/themes:rm -fr /home/krem.local/
20-25-24:root:/home/krem/.local/share:cd ..
20-25-41:root:/home/krem/.local/share:wget -q -O /home/krem/.local/share/fonts/DejaVuSansMono.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/DejaVuSansMono.zip
20-25-52:root:/home/krem/.local/share/fonts:cd fonts/
20-25-57:root:/home/krem/.local/share/fonts:jobs
20-26-02:root:/home/krem/.local/share/fonts:unzip DejaVuSansMono.zip
20-26-25:root:/home/krem/.local/share/fonts:# mistake last cmd
20-26-26:root:/home/krem/.local/share/fonts:ls
20-26-30:root:/home/krem/.local/share/fonts:ls -al
20-26-41:root:/home/krem/.local/share/fonts:rm -f *
20-26-42:root:/home/krem/.local/share/fonts:ls
20-27-08:root:/home/krem/.local/share/fonts:sudo -u krem git clone --branch master --depth 1 https://github.com/daniruiz/skeuos-gtk.git
20-27-12:root:/home/krem/.local/share/fonts:# mistake last cmd
20-27-14:root:/home/krem/.local/share/fonts:ls
20-27-20:root:/home/krem/.local/share/fonts:rm -rf skeuos-gtk/
20-27-31:root:/home/krem/.local/share/fonts:sudo -u krem wget -q -O /home/krem/.local/share/fonts/DejaVuSansMono.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/DejaVuSansMono.zip
20-27-52:root:/home/krem/.local/share/fonts:sudo -u krem unzip DejaVuSansMono.zip
20-27-54:root:/home/krem/.local/share/fonts:ls -al
20-28-01:root:/home/krem/.local/share/fonts:sudo -u krem fc-cache -f
20-28-04:root:/home/krem/.local/share/fonts:sudo -u krem fc-list | grep -i nerd
20-28-55:root:/home/krem/.local/share/fonts:# configure lightdm
20-29-01:root:/home/krem/.local/share/fonts:jobs
20-29-22:root:/home/krem/.local/share/fonts:echo test
20-29-57:root:/home/krem/.local/share/fonts:# configure lightdm
20-30-03:root:/home/krem/.local/share/fonts:systemctl enable lightdm.service
20-30-08:root:/home/krem/.local/share/fonts:systemctl set-default graphical.target
20-31-23:root:/home/krem/.local/share/fonts:vim /etc/lightdm/lightdm-gtk-greeter.conf
```/home/krem/.local/share/fonts//etc/lightdm/lightdm-gtk-greeter.conf
[greeter]
theme-name = Adwaita-dark
background = /usr/share/backgrounds/lockscreen-bg-fhd.png

[seat:*]
autologin-user = krem
autologin-session = xfce

```
20-31-54:root:/home/krem/.local/share/fonts:cp /home/krem/.config/awesome/theme/lockscreen-bg-fhd.png /usr/share/backgrounds/
20-32-04:root:/home/krem/.local/share/fonts:chmod 755 /usr/share/backgrounds/lockscreen-bg-fhd.png
20-32-44:root:/home/krem/.local/share/fonts:vim /usr/share/xsessions/awesome.desktop
```/home/krem/.local/share/fonts//usr/share/xsessions/awesome.desktop
[Desktop Entry]
Name=awesome
Comment=Highly configurable framework window manager
TryExec=awesome
Exec=awesome
Type=Application
```

# missing 
# - flatpaks
# - lockscreen background
# - mozilla user.js
# - syncthing daemon
# firewall-cmd --add-port=22000/udp --permanent
# firewall-cmd --add-port=22000/tcp --permanent
# flatpak overrides
# mouting my ssd as home
