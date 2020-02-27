#!/usr/bin/env bash

DOMAIN="github.com"
USER=$(whoami)

function usage() {
    echo "$0 -[hud]"
    echo "    -u: sets USER local variable. (Defaults to logged in user name.)"
    echo "    -d: sets the domain name for you key. (Default: github.com)"
    echo "    -h: shows this message. Ignores any other arguments."
    echo
}

function err() {
    local msg=$1
    echo "[ERROR] - ${msg}"
    usage
    exit $2
}

banner() {
    msg="| $* |"
    edge=$(echo "$msg" | sed 's/./~/g')
    echo "$edge"
    echo "$msg"
    echo "$edge"
}

function parse_arguments() {
    while [[ $# -gt 0 ]]; do
        key="$1"
        case $key in
        -u | --user)
            USER="$2"
            shift
            ;;
        -d | --domain)
            DOMAIN="$2"
            shift
            ;;
        -h | help)
            usage
            exit 0
            ;;
        *)
            echo "Wrong parameter: '$1'"
            exit 3
            ;;
        esac
        shift
    done
    shift $((OPTIND - 1))
    remaining_arguments=("$@")
    if [[ ${#remaining_arguments[*]} -gt 0 ]]; then
        err "Invalid arguments were given" 3
    fi
}
parse_arguments "$@"

mkdir -p $HOME/.ssh
SSH_KEY_NAME="${USER}_ssh_$(date +%Y%m%d)@$DOMAIN"

ssh-keygen -t rsa -b 4096 -C "${SSH_KEY_NAME}" -f "$HOME/.ssh/${SSH_KEY_NAME}.id_rsa"

cat "$HOME/.ssh/${SSH_KEY_NAME}.id_rsa.pub" | pbcopy

echo
echo
banner "the PUBLIC key was copied to your clipboard"
echo
