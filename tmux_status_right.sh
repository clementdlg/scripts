#!/bin/env bash

# format
colo="#[bg=#94b6ff]#[fg=#1c1c2e]"
s=""
e=""

# git branch
git -C "$1" rev-parse --is-inside-work-tree &> /dev/null
if [[ $? -eq 0 ]]; then
	branch=$(git -C "$1"  rev-parse --abbrev-ref HEAD)
	git=" $branch"
	git="$s$git$e"
fi

# directory
sess="$2"
sess=" $sess"
sess="$s$sess$e"

# wireguard
wga=$(wg show 2>&1)
res="$?"
if [[ -n $wga && $res -ne 127 ]]; then
	wg="󰞉 wireguard"
	wg="$s$wg$e"
fi

# hostname
host="$s󰇄 $(hostname)$e"

# hostname
user="$s $(whoami)$e"

# output
echo "$colo$wg$git$user$host$sess"
