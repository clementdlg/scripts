#!/usr/bin/env bash

# this script is used to connect to VMs running the Spice server

# viewer command
viewer="flatpak run org.remmina.Remmina -c"

# menu command
which rofi &>/dev/null
rofi="$?"

if [[ $rofi -ne 0 ]]; then
	echo "Error : Rofi must be installed" >&2
	exit 1
fi

menu="rofi show -dmenu"

# running vms
running=$(virsh list | tail -n +3 | head -n -1 | awk '{print $2}')

# if no vms are active, exit
if [[ -z "$running" ]]; then
	exit 0
fi

# getting vm name
vm=$(printf "%s\n" $running | $menu)

# vm must not be empty
if [[ -z "$vm" ]]; then
	exit 0
fi

# getting spice address
spice=$(virsh domdisplay --domain "$vm")

# opening display
$viewer $spice &>/dev/null
