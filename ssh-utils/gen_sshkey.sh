#!/usr/bin/env bash

DOMAIN="dummy.com"

function usage {
    echo "$0 -[hd]"
    echo "       -h  : shows this message. Ignores any other arguments."
    echo "       -d  : sets the domain name for you key. (Example: dummy.com)"
    echo
}

function err (){
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


if [ $# -lt 1 ]; then
    echo 'Missing domain argument'
    echo
    usage
    exit 1
fi


while getopts ":hd:" opt; do
    case "${opt}" in
        d)
            DOMAIN="${OPTARG}"
            ;;
        h)
            usage
            exit 0
            ;;
        :)
            err "Option -$OPTARG requires an argument." 2
            ;;
        \?)
            err "Invalid option: -$OPTARG" 1
            usage
            ;;
    esac
done
shift $((OPTIND-1))



remaining_arguments=( "$@" )
if [[ ${#remaining_arguments[*]} -gt 0 ]]; then
    err "Invalid arguments were given" 3
fi


mkdir -p $HOME/.ssh
SSH_KEY_NAME="$(whoami)_ssh_$(date +%Y%m%d)@$DOMAIN"
ssh-keygen -t rsa -b 4096 -C "${SSH_KEY_NAME}" -f "$HOME/.ssh/${SSH_KEY_NAME}.id_rsa"

cat "$HOME/.ssh/${SSH_KEY_NAME}.id_rsa.pub" | pbcopy

echo
echo
banner "the PUBLIC key was copied to your clipboard"
echo
