#!/usr/bin/env bash

# Description : this is a PoC for automated error handling in bash script via `set -e` and `trap cleanup ERR`

set -e # exit on error

date=$(date +%s)
file="/tmp/script-$date"

function cleanup() { # used to undo steps in case of later failure
        echo "removing file '$file'"
        rm "$file"
}

trap cleanup ERR # trigger the cleanup on error

main() {
	# successful step
	echo "creating '$file'"
	touch "$file" 
	ls -al "$file"

	# failing step
	mkdir /dir/that/doesnt/exists 

	# good ending
	echo "finish, no errors, $file has been created"
	ls -al "$file"
}

main "$@"
