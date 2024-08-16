#!/bin/bash

# help
if [[ ! -n "$1" ]]; then
    echo "This script is part of KRem's Auto Bootstrap Script (KRABS)

Its purpose is to configure display manager
You must run it as root and pass a file path of the background image as an argument
    Accepted extensions are .jpg and .png
    Example : ./script '/path/to/image.png'"
    exit 0
fi

# check if running as root
if [[ $EUID -ne 0 || ! -n $SUDO_USER ]]; then
    echo "Error: Run this script using sudo"
    exit 1
fi
$user=$SUDO_USER

# arg checking
if [[ ! -f "$1" ]]; then
    echo "Error : '$1' invalid image path'"
    exit 1
fi

# extension checking
ext=$(echo "$1" | sed 's/.*\.//')
if [[ $ext != "png" && $ext != "jpg" ]] ;then
    echo "Error : .$ext file is invalid"
    exit 1
fi

img="$1"

# check lightdm is installed
if ! which lightdm ; then
    echo "Installing lightdm"
    dnf install lightdm -y >/dev/null
fi

if ! which lightdm-gtk-greeter ; then
    echo "Installing lightdm-gtk-greeter"
    dnf install lightdm-gtk-greeter -y >/dev/null
fi

# check if papirus is installed
if ! rpm -q 'epapirus-icon-theme' ; then
    echo "Installing  rpm -q 'epapirus-icon-theme' >/dev/null"
    dnf install lightdm-gtk-greeter -y >/dev/null
fi

# configure services
echo "Configuring service and target"
systemctl enable lightdm.service >/dev/null
systemctl set-default graphical.target >/dev/null

# background image
cp "$img" /usr/share/backgrounds/
chmod 644 "/usr/share/backgrounds/$img"

# config files
echo "setting up .conf files"

echo "[Seat:*]
autologin-user=$user
autologin-session=xfce
greeter-session=lightdm-gtk-greeter" > /etc/lightdm/lightdm.conf

echo "[greeter]
theme-name = Adwaita-dark
icon-theme-name = ePapirus-Dark
font-name = Sans 12
background = $img
clock-format = %H:%M
indicators = ~host;~spacer;~clock;~spacer;~layout;~separator;~session;~power" > /etc/lightdm/lightdm-gtk-greeter.conf


# rename override background
if [[ -f "/usr/share/backgrounds/xfce/xfce-shapes.svg" ]]; then
    mv /usr/share/backgrounds/xfce/{,_}xfce-shapes.svg
fi

echo "Lightdm is successfully configured"
