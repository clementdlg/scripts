#!/usr/bin/env bash
set -xeuo pipefail

green="\e[32m"
yellow="\e[33m"
red="\e[31m"
reset="\e[0m"

_CONN_FILE=""
_LOGFILE="/tmp/tmux-session-create.log"

log() {
    local level="$1"
    local msg="$2"
    local timestamp="[$(date +%H:%M:%S)]"

    local label color
    case "$level" in
        e) label="[ERROR]" ; color="$red" ;;
        x) label="[EXIT]"  ; color="$yellow" ;;
        i) label="[INFO]"  ; color="$green" ;;
        *) label="[LOG]"   ; color="$reset" ;;
    esac

    echo -e "$timestamp$color$label$reset $msg"
    echo "$timestamp$label $msg" >> "$_LOGFILE"
}

check_args() {
    if [[ $# -ne 1 ]]; then
        log x "Usage: $0 <connection_file>"
        return 1
    fi

    local file="$1"
    if [[ ! -f "$file" ]]; then
        log e "'$file' does not exist"
        return 1
    fi

    if [[ ! -s "$file" ]]; then
        log e "'$file' is empty"
        return 1
    fi

    _CONN_FILE="$file"
}

validate_line_format() {
    local line="$1"
    [[ "$line" =~ ^#.*$ ]] && return 1  # comment

    local field_count
    field_count="$(awk -F: '{print NF}' <<< "$line")"

    if [[ "$field_count" -ne 6 ]]; then
        log e "Invalid field count in line: $line"
        return 1
    fi
}

parse_line() {
    local line="$1"
    _USER="$(cut -d: -f1 <<< "$line")"
    _HOSTNAME="$(cut -d: -f2 <<< "$line")"
    _IP="$(cut -d: -f3 <<< "$line")"
    _PORT="$(cut -d: -f4 <<< "$line")"
    _PROTOCOL="$(cut -d: -f5 <<< "$line")"
    _OPT="$(cut -d: -f6 <<< "$line")"
}

validate_ssh_fields() {
    [[ -z "$_USER" || -z "$_HOSTNAME" || -z "$_IP" || -z "$_PORT" || -z "$_PROTOCOL" ]] && {
        log e "Empty required field"
        return 1
    }

    if ! [[ "$_IP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        log e "Invalid IP format: $_IP"
        return 1
    fi

    if ! [[ "$_PORT" =~ ^[0-9]+$ && "$_PORT" -ge 1 && "$_PORT" -le 65535 ]]; then
        log e "Invalid port number: $_PORT"
        return 1
    fi

    if [[ "$_PROTOCOL" != "ssh" ]]; then
        log e "Unsupported protocol: $_PROTOCOL"
        return 1
    fi

    if [[ -z "$_OPT" ]]; then
        log e "Opt field cannot be empty"
        return 1
    fi
}

attempt_ssh_connection() {
	local key_path="${_OPT/#\~/$HOME}"

    if [[ ! -f "$key_path" ]]; then
        log e "SSH key not found: $key_path"
        return 1
    fi

    ssh -o ConnectTimeout=5 -i "$key_path" -p "$_PORT" "${_USER}@${_IP}" exit || {
        log e "Cannot connect to $_HOSTNAME ($_IP)"
        return 1
    }

    log i "Successfully connected to $_HOSTNAME ($_IP)"
}

# === Main ===

main() {
    echo "" > "$_LOGFILE"
    check_args "$@" || exit 1

    local line line_nr=0

    while IFS= read -r line || [[ -n "$line" ]]; do
        line_nr=$((line_nr + 1))
        log i "Processing line $line_nr"

        validate_line_format "$line" || continue

        parse_line "$line" || exit 1
        validate_ssh_fields || exit 1
        attempt_ssh_connection || continue
    done < "$_CONN_FILE"

    log i "Done processing all hosts"
}

main "$@"

