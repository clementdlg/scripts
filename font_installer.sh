#!/bin/bash

# help
if [[ ! -n "$1" ]]; then
    echo "This script's purpose is to download and install fonts from a url archive
    You must provide a zip archive download link"
    exit 0
fi

# arg checking
if [[ ! -n "$1" ]]; then
    echo "Error: You must provide a download link"
    exit 1
fi

if ! grep  -E '^http[s]?:[\/]{2}.*[.]zip$' <<< $1 ; then
    echo "Error: You must provide a download link as a zip archive"
    exit 1
fi
link="$1"

# getting the archive name
arch_name="$(echo $link| sed -E 's/^.*\///')"

font_name="$(echo $arch_name| cut -d. -f1)"

# getting the type of archive
type="$(echo $arch_name| cut -d. -f2)"

if [[ $type == "zip" ]]; then
    which unzip >/dev/null
    if [[ $? -ne 0 ]]; then
	echo "Error : This script requires unzip"
	exit 1
    fi
fi

font_path="$HOME/.local/share/fonts/$font_name"
if [[ ! -d $font_path ]]; then
    echo "Creating $font_path"
    mkdir -p $font_path
fi

echo "Downloading font archive to $font_path/$arch_name"
curl -L -o $font_path/$arch_name $link -#
if [[ $? -ne 0 ]]; then
    echo "Error : failed to download the archive"
    exit 1
fi

echo "Extracting to $font_path/$arch_name..."

if [[ $type == "zip" ]]; then
    unzip $font_path/$arch_name -d $font_path/>/dev/null
    if [[ $? -ne 0 ]]; then
	echo "Error : Failed to unzip archive"
	exit 1
    fi
    rm $font_path/$arch_name
fi

echo "Installing $font_name..."
fc-cache -f
if [[ $? -ne 0 ]]; then
    echo "Error : Failed to install $font_name"
    exit 1
fi

echo "Success : $font_name is installed"

