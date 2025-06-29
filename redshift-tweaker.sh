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
		Changes the brightness-night value

	-g, --gamma [VALUE]
		Changes the gamma value

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

setIntParam() {
	if grep "^$1=0\..*$" "$_CONFIG_PATH"; then
		sed -iE "s/^$1=0\..*$/$1=0.$2/" "$_CONFIG_PATH"
	else
		echo "[Error] Param '$1' not found"
		return 1
	fi
}

changeIntParam() {

	# modes :
	# - absolute : set an int value
	# - relative : add or substract to the current value

	# $1 = [mode|none][int]
	key="$1"
	int="$2"
	mode="absolute"
	sign=""
	value=""

	# get mode
	if [[ "$2" == "+"*  || "$2" == "-"*  ]]; then
		mode="relative"
	fi

	# get int value
	if [[ "$mode" == "relative" ]]; then
		sign="${int:0:1}"
		int="${int:1}"
	fi

	if [[ "$mode" == "absolute" ]]; then
		value="$int"
	else
		# mode relative
		if [[ "$sign" != "+" && "$sign" != "-" ]]; then
			echo "[Error] Invalid sign"
			return 1
		fi
		
		# get current value
		value="$(grep "$key" "$_CONFIG_PATH" | cut -d= -f2 | cut -d. -f2 )"

		# add or substract
		if [[ "$sign" == "+" ]]; then
			value="$(( value + int ))"
		else
			value="$(( value - int ))"
		fi

	fi

	# verify integer value before inserting
	if [[ ! "$value" =~ ^[0-9]+$ ]] || (( value < 1 || value > 99 )); then
		echo "[Error] Cannot set param '$key', failed to parse integer value"
		return 1
	fi

	setIntParam "$key" "$value"
	systemctl --user restart redshift.service

	echo "[INFO] Param '$key' sucessfully changed"
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
		changeIntParam "brightness-night" "$2"
		exit 0
	fi

	if [[ "$1" == "--gamma" ||  "$1" == "-g" ]]; then
		changeIntParam "gamma" "$2"
		exit 0
	fi

	echo "[Error] Unrecognized argument '$1'"
	exit 0
}

main "$@"
