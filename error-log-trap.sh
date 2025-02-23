#!/usr/bin/env bash

# Description: using `set -e` and function-scoped `trap` to print custom error messages on failure.

set -e  # Exit on error

function task1() {
    trap 'echo "[ERROR] task1 failed!"' ERR
    echo "Running task1..."
    touch /tmp/success-file
}

function task2() {
    trap 'echo "[ERROR] task2 failed!"' ERR
    echo "Running task2..."
    ls /nonexistent/directory  # This will fail
}

function task3() {
    trap 'echo "[ERROR] task3 failed!"' ERR
    echo "Running task3..."
    echo "Task 3 completed successfully!"
}

function main() {
    task1
    task2  # This will trigger task2's trap and exit
    task3  # This will never execute due to set -e
}

main "$@"

