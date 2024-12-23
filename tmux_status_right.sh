#!/bin/env bash

if [[ -z "$1" ]]; then
	# current directory must be passed
	exit 0
fi

# format
fseparator="#[fg=#94b6ff]#[bg=#1c1c2e]"
tseparator="#[fg=#94b6ff]#[bg=#1c1c2e]"

# git branch
git -C "$1" rev-parse --is-inside-work-tree &> /dev/null
if [[ $? -eq 0 ]]; then
	branch=$(git -C "$1"  rev-parse --abbrev-ref HEAD)
	git="#[bg=#94b6ff]#[fg=#1c1c2e] $branch"
	git="$fseparator$git$tseparator"
fi

# ip
ip=$(~/scripts/get_private_ip.sh)
if [[ "$ip" != "disconnected" ]]; then
	ip_symbol="󰈀"
else
	ip_symbol=""
fi

ip="#[bg=#94b6ff]#[fg=#1c1c2e]$ip_symbol $ip"

# output
echo "$git$fseparator$ip$tseparator"
