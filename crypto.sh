#!/bin/env bash
crypto="$1"
fiat="$2"

if [[ ! -n "$1" ]]; then
	echo "Error: You must pass a crypto name as first argument"
	exit 1
fi
if [[ ! -n "$2" ]]; then
	echo "Error: You must pass a currency name as 2nd argument"
	exit 1
fi

precision="3"
baseurl="https://api.coingecko.com"

url="$baseurl/api/v3/simple/price?ids=$crypto&vs_currencies=$fiat&precision=$precision"

header="accept: application/json"
auth="x-cg-demo-api-key: $COINGECKO_API_KEY"

req=$(curl -s --request GET \
		--url "$url" \
		--header "$header" \
		--header "$auth")

parsed=$(echo $req | jq ".$crypto.$fiat")

if [[ "$parsed" == "null" ]]; then
	echo "Error: pair $crypto/$fiat not found"
	exit 1
else
	echo "$1 price is $parsed $fiat"
fi
