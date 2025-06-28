#!/usr/bin/env bash

# Description : The purpose for this script is to allow to adjust the brightness setting for redshift systemd daemon

set -xeuo pipefail
# global variables
_CONFIG_PATH=""

printHelp() {
	cat <<EOF
NAME : redshift-tweaker
SYNOPSIS :
	redshift-tweaker [--setting] [VALUE]

DESCRIPTION
	Tweak the configuration of redshift and restart it automatically to apply the modification in real time

	--help
		display this screen

	-b, --brightness [VALUE]
		Changes the brightness

	VALUE
		Can be in the form of an integer. Can also be using integer increments or decrements.
		Example : \"redshift-tweaker -b +2\"
	
AUTHOR
	Clément de la Genière. 2025
EOF
}

checkConfig() {
	# need a config file
	config_name="redshift.conf"

	echo "debug : config path = $_CONFIG_PATH"

	if [[ -f "$XDG_CONFIG_HOME/redshift/$config_name" ]]; then
		_CONFIG_PATH="$XDG_CONFIG_HOME/redshift/$config_name"
		return 0
	fi

	if [[ -f "$HOME/.config/$config_name" ]]; then
		_CONFIG_PATH="$HOME/.config/redshift/$config_name"
		return 0
	fi

	if [[ -n "$_CONFIG_PATH" ]]; then
		echo "Error : redshift configuration is not found. Aborting"
		return 1
	fi
}

modifyBrightness() {
	sed -iE "s/^brightness-night=0\..*$/brightness-night=0.$1/" "$_CONFIG_PATH"
}

changeBrightness() {

	# modes :
	# - absolute : set an int value
	# - relative : add or substract to the current value

	# $1 = [mode|none][int]
	mode="absolute"
	sign=""
	int="$1"

	# get mode
	if [[ "$1" == "+"*  || "$1" == "-"*  ]]; then
		mode="relative"
	fi

	# get int value
	if [[ "$mode" == "relative" ]]; then
		sign="${int:0:1}"
		int="${int:1}"
	fi

	if [[ ! "$int" =~ ^[0-9]+$ ]] || (( int < 0 || int > 99 )); then
		echo "[Error] Cannot set brightness, failed to parse integer"
		exit 1
	fi

	if [[ "$mode" == "absolute" ]]; then
		modifyBrightness "$int"
	else
		if [[ "$sign" != "+" && "$sign" != "-" ]]; then
			echo "[Error] Invalid sign"
			exit 1
		fi
		
		value="$(grep "brightness-night" "$_CONFIG_PATH" | cut -d= -f2 | cut -d. -f2 )"

		if [[ "$sign" == "+" ]]; then
			value="$(( value + int ))"
		else
			value="$(( value - int ))"
		fi

		modifyBrightness "$value"
	fi

	systemctl --user restart redshift.service

	echo "[INFO] Brightness sucessfully changed"
}

main() {

	# redshift must be installed
	if ! redshift -V &>/dev/null; then
		echo "Error : redshift package must be installed on the system. Aborting"
		exit 0
	fi

	# display help screen
	if [[ $# -eq 0 || $# -eq 1 && "$1" == "--help" ]]; then
		printHelp
		exit 0
	fi

	# rest of the program needs at least two arguments
	if [[ $# -lt 2 ]]; then
		exit 1
	fi

	# setting config file
	checkConfig

	if [[ "$1" == "--brightness" ||  "$1" == "-b" ]]; then
		changeBrightness "$2"
	fi
}

main "$@"
