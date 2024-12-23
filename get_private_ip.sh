#!/bin/env bash

my_ip=$(ip route get 8.8.8.8 2>/dev/null)

if [[ $? -eq 0 ]]; then
	echo $my_ip | awk '{ print $7 }'
else
	echo "disconnected"
fi
