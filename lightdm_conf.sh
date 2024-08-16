# check lightdm is installed
if ! which lightdm ; then
    echo "Installing lightdm..."
    dnf install lightdm -y >/dev/null
fi

if ! which lightdm-gtk-greeter ; then
    echo "Installing lightdm-gtk-greeter..."
    dnf install lightdm-gtk-greeter -y >/dev/null
fi
# configure services
echo "Configuring service and target"
systemctl enable lightdm.service >/dev/null
systemctl set-default graphical.target >/dev/null

# background image

cp /home/krem/.config/awesome/theme/lockscreen-bg-fhd.png /usr/share/backgrounds/
chmod 644 /usr/share/backgrounds/lockscreen-bg-fhd.png

# config files
echo "[Seat:*]
autologin-user=krem
autologin-session=xfce
greeter-session=lightdm-gtk-greeter" > /etc/lightdm/lightdm.conf

echo "[greeter]
theme-name = Adwaita-dark
icon-theme-name = ePapirus-Dark
font-name = Sans 12
background = /usr/share/backgrounds/lockscreen-bg-fhd.png" > /etc/lightdm/lightdm-gtk-greeter.conf

# remove override background
mv /usr/share/backgrounds/xfce/{xfce,_xfce}-shapes.svg
