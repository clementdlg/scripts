#!/bin/env bash
if [[ $EUID -ne 0 ]]; then
	echo "Error: Run this script as root"
	exit 1
fi

echo "Installing build tools..."

distro=$(cat /etc/os-release | grep '^ID' | cut -d= -f2)
if [[ $distro == "fedora" || $distro == "rhel" ]]; then
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

	install="dnf install -y"

elif [[ $distro == "debian" || $distro == "ubuntu" ]]; then

	tools=(
		"ninja-build"
		"gettext"
		"cmake"
		"unzip"
		"curl"
		"build-essential"
		"git"
	)

	install="apt install -y"
else
	echo "Error : Unsupported distro '$distro'"
	echo "Currently supported distro : Fedora, RHEL, Debian, Ubuntu"
	exit 1
fi

for tool in "${tools[@]}"; do
	$install $tool &>/dev/null

	if [[ $? -ne 0 ]];then
		echo "Error while trying to install $tool"
		exit 1
	fi
done

workdir="/tmp/neovim/"
mkdir -p $workdir

echo "Cloning git repo"
git clone --branch stable --single-branch https://github.com/neovim/neovim "$workdir" &>/dev/null

if [[ $? -ne 0 ]]; then
	echo "Error: git clone failed"
	exit 1
fi

# still dont know how to avoid using cd with make
cd "$workdir"

# select the right branch
# git checkout stable &>/dev/null


echo "Setting up build configuration..."
# select type of build
make CMAKE_BUILD_TYPE=Release &>/dev/null

echo "Building..."
make install 2> "$workdir/nvim_build.log" >/dev/null

if [[ $? -ne 0 ]]; then
	echo "Error: Failed to build, more info in $workdir/nvim_build.log"
	tail -5 "$workdir/nvim_build.log"
	exit 1
fi

echo "Build successful! Cleaning"
rm -rf "$workdir"
