#!/usr/bin/env bash
set -xeuo pipefail

SCAN_TIMEOUT=6

is_installed() {
	[[ -z "$1" ]] && return 1

	if ! which "$1" &>/dev/null; then
		echo "error : $1 is not installed"
		return 1
	fi
	return 0
}

notify() {
	local message="$1"
	[[ -z "$message" ]] && return

	icon="/usr/share/icons/Papirus/64x64/devices/bluetooth.svg"
	notify-send -i "$icon" "Bluetooth Applet" "$message"
}

silent() {
	"$@" &>/dev/null
}

paired() {
	local devices="$(bluetoothctl devices Paired | awk '{$1=$2=""; print substr($0,3)}')"

	printf "%s\n" "$devices" | rofi show -dmenu -p "Connect a device"
}

connected() {
	# show list
	local devices="$(bluetoothctl devices Connected | awk '{$1=$2=""; print substr($0,3)}')"
	printf "%s\n" "$devices" | rofi show -dmenu -p "Disconnect a device"

	notify "Disconnecting $devices"

	# disconnection
	local mac=$(bluetoothctl devices | grep "$device" | cut -f2 -d' ')
	silent bluetoothctl disconnect "$mac"
}

rm_devices() {
	local devices="$(bluetoothctl devices | awk '{$1=$2=""; print substr($0,3)}')"

	local device=$(printf "%s\n" "$devices" | rofi show -dmenu -p "Remove a device")

	local mac=$(bluetoothctl devices | grep "$device" | cut -f2 -d' ')

	notify "Removing $device"

	silent bluetoothctl remove "$mac"
}

scan() {
	notify "Scanning for devices..."

	silent bluetoothctl -t $SCAN_TIMEOUT scan on

	local devices="$(bluetoothctl devices | awk '{$1=$2=""; print substr($0,3)}')"

	printf "%s\n" "$devices" | rofi show -dmenu -p "Connect a device"
}

connect_device() {
	local device="$1"
	[[ -z "$device" ]] && return 1

	local mac=$(bluetoothctl devices | grep "$device" | cut -f2 -d' ')

	notify "Attempting to connect to $device"

	silent bluetoothctl connect "$mac"
}

menu_enabled() {
	# check if already connected to a wifi
	# local current="$(nmcli -t -f NAME,TYPE connection show --active | grep '802-11' | cut -f1 -d:)"

	# menu items
	# local disconnect="󰂲 Disconnect '$current'"
	local connect_menu="󰂱 Connected devices"
	local paired_menu=" Paired devices"
	local scan_menu="󰂰 Scan devices"
	local remove_menu=" Remove devices"
	local disable=" Disable Bluetooth"
	local editor="󰘙 Blueman Manager"

	# menu
	local menu="$connect_menu\n$paired_menu\n$scan_menu\n$remove_menu\n$disable\n$editor\n"

	# add disconnect item
	# if [[ ! -z "$current" ]]; then
	# 	menu="$disconnect\n$menu"
	# fi

	local choice=$(printf "$menu" | rofi -dmenu -p "Bluetooth Applet:" )

	case "$choice" in
		"$connect_menu")
			connected
			;;
		"$paired_menu")
			local device=$(paired)
			connect_device "$device"
			;;
		"$scan_menu")
			local device=$(scan)
			connect_device "$device"
			;;
		"$remove_menu")
			rm_devices
			;;
		"$disable")
			silent bluetoothctl power off
			notify "Bluetooth has been disabled"
			;;
		"$editor")
			silent blueman-manager & ;;
	esac
}

menu_disabled() {
	local enable=" Enable Bluetooth"
	local editor="󰘙 Blueman Manager"
	choice=$(printf "$enable\n$editor\n" | rofi -dmenu -p "Bluetooth Applet:" )

	case "$choice" in
		"$enable")
			silent bluetoothctl power on
			notify "Bluetooth has been enabled"
			;;
		"$editor")
			silent blueman-manager & ;;
	esac
}

main() { 
	is_installed bluetoothctl
	is_installed blueman-manager
	is_installed rofi
	is_installed notify-send

	if bluetoothctl show | grep -q "Powered: yes"; then
		menu_enabled
	else
		menu_disabled
	fi
}
main
