#!/bin/env bash

if [[ -z "$1" ]]; then
	return
fi

git -C "$1" rev-parse --is-inside-work-tree &> /dev/null
if [[ $? -ne 0 ]]; then
	exit 0
fi

branch=$(git -C "$1"  rev-parse --abbrev-ref HEAD)

separator="#[fg=#94b6ff]#[bg=#1c1c2e]"
text="#[bg=#94b6ff]#[fg=#1c1c2e] $branch"
echo "$separator$text"
