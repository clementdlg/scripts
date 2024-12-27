#!/bin/env bash
if [[ $EUID -ne 0 ]]; then
	echo "Error: Run this script as root"
	exit 1
fi

echo "Installing build tools..."

distro=$(cat /etc/os-release | grep '^ID' | cut -d= -f2)
if [[ $distro == "fedora" ]]; then
	tools=(
		"ninja-build"
		"cmake"
		"gcc"
		"make"
		"unzip"
		"gettext"
		"curl"
		"glibc-gconv-extra"
		"git"
	)

	cmd="dnf install $tool -y &>/dev/null"

elif [[ $distro == "debian" ]]; then

	tools=(
		"ninja-build"
		"gettext"
		"cmake"
		"unzip"
		"curl"
		"build-essential"
		"git"
	)

	cmd="apt install $tool -y &>/dev/null"
else
	echo "Only Fedora and Debian are supported yet"
	exit 1
fi

for tool in "${tools[@]}"; do
	$cmd

	if [[ $? -ne 0 ]];then
		echo "Error while trying to install $tool" >&2
		exit 1
	fi
done

workdir="/tmp/neovim/"
mkdir -p $workdir

echo "Cloning git repo"
git clone https://github.com/neovim/neovim "$workdir"

if [[ $? -ne 0 ]]; then
	echo "Error: git clone failed"
	exit 1
fi

# still dont know how to avoid using cd with make
cd "$workdir"


# select type of build
make CMAKE_BUILD_TYPE=Release

# select the right branch
git checkout stable

echo "Building..."
make install >/dev/null 2> nvim_build.log

if [[ $? -ne 0 ]]; then
	echo "Error: Failed to build, more info in $workdir/nvim_build.log"
	tail -5 "$workdir/nvim_build.log"
fi

echo "Build successful! Cleaning..."
rm -rf "$workdir"
