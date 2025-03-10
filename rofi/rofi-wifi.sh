#!/usr/bin/env bash
set -euo pipefail

# globals
disable="󰖪  Disable Wi-Fi"
enable="󰖩  Enable Wi-Fi"

function isInstalled() {
	[[ -z "$1" ]] && return 1

	if ! which "$1" &>/dev/null; then
		echo "error : $1 is not installed"
		return 1
	fi
	return 0
}
notify() {
	message="$1"
	[[ -z "$message" ]] && return

	icon="/usr/share/icons/Papirus/64x64/devices/network-wireless.svg"
	notify-send -i "$icon" "Wifi Applet" "$message"
}

get_wifi_list() {
	local wifi_list="$(nmcli --fields "SIGNAL,SSID" device wifi list)"

	printf "%s\n" "$wifi_list" \
		| sed 1d \
		| head -15 \
		| awk '$2 != "--"' \
		| awk '{ \
		if ($1 >= 0 && $1 < 25) $1 = "󰤯 "; \
		else if ($1 >= 25 && $1 < 50) $1 = "󰤟 "; \
		else if ($1 >= 50 && $1 < 75) $1 = "󰤢 "; \
		else if ($1 >= 75 && $1 <= 100) $1 = "󰤨 "; \
		print}'
}

toggle_wifi() {
	local connected=$(nmcli --colors=no radio wifi)
	if [[ "$connected" == "enabled" ]]; then
		local toggle="$disable"
	else
		local toggle="$enable"
	fi
	echo "$toggle"
}

main() {
	notify "Scanning Wi-Fi networks..."

	isInstalled nmcli
	isInstalled nm-applet
	isInstalled rofi
	isInstalled notify-send

	list=$(get_wifi_list)

	# printf "%s\n" "$list" # debug

	choice=$(echo -e "$list" | uniq | rofi -dmenu -i -p "Wi-Fi SSID: " )

	read -r choice_clean <<< "${choice:2}"
	
	# check if network is known
	if nmcli -g NAME connection | grep $choice_clean; then
		nmcli connection up id "$choice_clean"
	else
		password=$(rofi -dmenu -p "Password: ")
		nmcli device wifi connect "$choice_clean" password "$password"
	fi

	notify "Successfully connected to '$choice_clean'"
}

main

# printf "Wi-Fi list\nDisconnect from 'current'\nDisable Wi-Fi\nConnect to hidden Wi-Fi\nConnection Editor\n" | rofi -dmenu

