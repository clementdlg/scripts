#!/usr/bin/env bash

set -xeuo pipefail

_USERNAME="ansible"

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
	local distro="$(cat /etc/os-release | grep "^ID" | cut -d= -f2)"

	if [[ "$distro" != "fedora" && \
		"$distro" != "rhel" && \
		"$distro" != "rocky" ]]; then
		echo "[Exit] Unsupported linux distribution '$distro'."
		return 1
	fi

	dnf install -y openssh

	systemctl enable --now sshd
}

install_python() {
	dnf install -y python3

	if ! python3 --version &>/dev/null; then
		echo "$0 Error: Failed to install python"
		return 1
	fi
}

configure_sshd() {
	local sshd="/etc/ssh/sshd_config"

	# check the config before doing anything
	if ! sshd -t; then
		echo "Error: Invalid sshd_config file. Aborting"
		exit 1
	fi

	# create a backup
	cp "$sshd" "${sshd}.bkp" 

	# disable password authentification
	if grep -E "^PasswordAuthentication (yes|no)$" "$sshd"; then
		sed -i "s/^PasswordAuthentication.*$/PasswordAuthentication no/" "$sshd"
	else
		echo "PasswordAuthentication no" >> "$sshd"
	fi

	# if config is invalid, replace by backup
	if ! sshd -t; then
		mv "${sshd}.bkp" "$sshd"
	fi
}

create_user() {
	useradd -Um "$_USERNAME"
	usermod -aG wheel "$_PASSWORD"
	echo "$_USERNAME:$_PASSWORD" | chpasswd
}

main() {
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
}

main "$@"

# possible improvements :
# - add option to custom username
# - harden ssh further
