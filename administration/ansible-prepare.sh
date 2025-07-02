#!/usr/bin/env bash

set -xeuo pipefail

_USERNAME="ansible"
unique_str="$(date +%H%M%S)"

usage() {
cat <<EOF
NAME : ansible-prepare
SYNOPSIS :
	ansible-prepare [-p <PASSWORD> ] [--help]

DESCRIPTION
	This script is used to prepare a host to be managed using Ansible

	--help
		display this screen

	-p <PASSWORD>
		Define password for ansible's dedicated user 

AUTHOR
	Clément de la Genière
	2025
EOF
}

install_ssh() {
	if ! dnf --version &>/dev/null; then
		echo "[Exit] This script only supports installing packages using dnf."
		return 1
	fi

	if ! ssh -V &>/dev/null; then
		echo "[Info] Installing openssh"
		dnf install -y openssh >/dev/null
	fi

	systemctl enable --now sshd
}

install_python() {
	if python3 --version &>/dev/null; then
		echo "[Info] python3 already installed. Skipping."
		return 0
	fi

	echo "[Info] Installing python3"
	dnf install -y python3 >/dev/null
}

configure_sshd() {
	local sshd="/etc/ssh/sshd_config"
	local backup="${sshd}.bkp-$unique_str"

	# check the config before doing anything
	if ! sshd -t &>/dev/null; then
		echo "Error: Invalid sshd_config file. Aborting"
		return 1
	fi

	# create a backup
	cp "$sshd" "$backup" 

	# disable password authentification
	if grep -E "^PasswordAuthentication (yes|no)$" "$sshd"; then
		sed -i "s/^PasswordAuthentication.*$/PasswordAuthentication no/" "$sshd"
	else
		echo "PasswordAuthentication no" >> "$sshd"
	fi

	# if config is invalid, replace by backup
	if ! sshd -t &>/dev/null; then
		mv "$backup" "$sshd"
		return 1
	fi

	# remove backup
	rm "$backup"

	echo "[Info] Disabled PasswordAuthentication for sshd"
}

create_user() {
	if grep "$_USERNAME" /etc/passwd; then
		echo "[Info] User named '$_USERNAME' already exists. Skipping."
		return 0
	fi

	useradd -Um "$_USERNAME"
	usermod -aG wheel "$_PASSWORD"
	echo "$_USERNAME:$_PASSWORD" | chpasswd

	echo "[Info] Created user '$_USERNAME'"
}

main() {
	if [[ $EUID -ne 0 ]]; then
		echo "[Error] Run this script with root privileges"
		exit 0
	fi

	if [[ $# -eq 0 || $# -eq 1 && "$1" == "--help" ]]; then
		usage
		exit 0
	fi

	if [[ $# -ne 2 || "$1" != "-p" || -z "$2" ]]; then
		echo "$0 Error : You must specify a password for ansible user"
		exit 0
	fi

	_PASSWORD="$2"

	install_ssh
	install_python
	configure_sshd
	create_user

	echo "[Exit] Execution sucessful"
}

main "$@"

# possible improvements :
# - add option to custom username
# - harden ssh further
