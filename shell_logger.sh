#!/bin/env bash

# INFO : run this script using the `source` command

echo "INFO : everyting you do in this shell is now logged"

# preparing the file
date=$(date +%H-%M-%S)
logfile="$HOME/logs/success_hist_$date.log"

mkdir -p $HOME/logs
echo "date:USER:PWD:last_cmd" > $logfile

function logger() {
    # if last command was successful
    if [[ $? -eq 0 ]]; then

	# retrieve 
	last_cmd=$(history 1 | sed 's/^\ [0-9]*\ \ //')

	# write log
	echo "$(date +%H-%M-%S):$USER:$PWD:$last_cmd" >> $logfile

	# check for file editing
	# if is_editor "$last_cmd" ; then
	if [[ $last_cmd == "vim"* || $last_cmd == "nvim"* || $last_cmd == "nano"* ]]; then

	    # get edited file
	    file_path=$(echo $last_cmd | awk '{ print $NF }')

	    # loggin the content of the file
	    echo "\`\`\`$PWD/$file_path" >> $logfile
	    cat $file_path >> $logfile
	    echo '```' >> $logfile
	fi
    fi
}

# function is_editor {
#     local command=$1
#     editors=("vi" "vim" "nvim" "nano" "ed")
#
#     for editor in "${#editors[@]}"; do
# 	if [[ $command == editor* ]]; then
# 	    return 1
# 	fi
#     done
#     return 0
# }

export PROMPT_COMMAND=logger
