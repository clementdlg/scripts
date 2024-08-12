#!/bin/env bash

function logger() {
    if [[ $? -eq 0 ]]; then
	last_cmd=$(history 1 | sed 's/^\ [0-9]*\ \ //')
	echo $last_cmd >> ~/success_history.log
    fi
}
export PROMPT_COMMAND=logger
