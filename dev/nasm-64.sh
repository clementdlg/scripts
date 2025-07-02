#!/bin/env bash


# check if argument exists
if [[ -z $1 ]]; then
    echo "Error: You need to specify a file to assemble"
    exit 1
fi

file="$1"

# check file exists
if [[ ! -e $file ]]; then
    echo "Error: File doesn't exist"
    exit 1
fi

name=$(echo $file | sed 's/\..*$//')

# check if tools are installed
which nasm >/dev/null
if [[ $? -ne 0 ]]; then
    echo "Error: 'nasm' must be installed"
    exit 1
fi

which ld >/dev/null
if [[ $? -ne 0 ]]; then
    echo "Error: 'binutils' must be installed"
    exit 1
fi

output=$(nasm -felf64 -o "$name.o" "$file")
# if [[ -z $output ]]; then
#     echo "Info : Linking passed"
# fi

ld -o "$name" "$name.o" -e main
if [[ $? -eq 0 ]]; then
    echo "Info : assembling passed"
fi
