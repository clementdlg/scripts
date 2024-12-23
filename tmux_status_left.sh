#!/bin/env bash
# check if session exist
if [[ -z "$1"]]; then
	exit
fi
echo $1

# tmux list-windows -F "#I:#W"
