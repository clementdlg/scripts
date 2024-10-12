#!/usr/bin/env bash
# set -xe

# checking argument
if [[ -z "$1" ]]; then
    echo "Error : Missing argument. You need to specify a <file>.ova !"
    exit 1
fi

if [[ ! -f "$1" ]]; then 
    echo "Error : File doesn't exist !"
    exit 1
fi

if [[ "$1" != *".ova" ]]; then
    echo "Error : '$1' is not recognized as a .ova file !"
    exit 1
fi

inputf="$1"
dirname=$(dirname "$inputf")
name=$(basename "$inputf")

# checking that qemu-img is installed
which qemu-img &>/dev/null
if [[ $? -ne 0 ]]; then
    echo "Error : qemu-img is not installed !"
    exit 1
fi

# create temp directory
workdir="/tmp/ova-converter"
mkdir -p /tmp/ova-converter

# extracting the OVA
tar xf "$inputf" -C "$workdir"
if [[ $? -ne 0 ]]; then
    echo "Error : Extraction of the OVA failed, cleaning and aborting"
    # rm -rf "$workdir"
    exit 1
fi

# creating an array containing the disk names
disks=($workdir/*.vmdk)

# converting all the disks
for disk in "${disks[@]}"; do
    output_name=$(basename "$disk")
    output_name=${output_name%.*}
    convert=$(qemu-img convert -f vmdk -O qcow2 "$disk" "$dirname/$output_name.qcow2" 2>&1)

    if [[ $? -ne 0 ]]; then
	echo "Error : the qemu-img has returned :"
	echo "$convert"
	# rm -rf "$workdir"
	exit 1
    fi
done

echo "Success : The following disk(s) have been converted to qcow2 format : ${disks[@]}"
# rm -rf "$workdir"
exit 0
