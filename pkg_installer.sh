# check privileges
if [[ $EUID -ne 0 ]]; then
    echo "Error: Run this script with root privileges"
    exit 1
fi

packages=(
    "@xfce-desktop-environment"
    "vim"
    "tmux"
    "picom"
    "htop"
    "wget"
    "unzip"
    "tar"
    "lightdm"
    "lightdm-gtk"
    "rofi"
    "neovim"
    "flatpak"
    "syncthing"
    "firefox"
    "default-fonts-core-emoji"
    "alacritty"
    "vlc"
    "btop"
    "timeshift"
    "flameshot"
    "thunar"
    "NetworkManager"
    "ripgrep"
    "flameshot"
    "qbittorrent"
    "virt-manager"
    "libvirt-client-qemu"
    "libvirt-daemon-qemu"
    "qemu-kvm"
    "light"
    "network-manager-applet"
    "blueman"
    "battray"
    "volumeicon"
    "epapirus-icon-theme"
)

for pkg in "${packages[@]}"; do
    dnf install $pkg -y 
done
