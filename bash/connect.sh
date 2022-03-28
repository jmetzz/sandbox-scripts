#!/usr/bin/env bash

error () {
	echo "Wrong parameter: $1"
	usage
	exit $2
} >&2

usage() {
	echo "Usage:"
	echo "   sshc [-h host] [-n off-set] [-u user] [-v]"
	echo
	echo "Establish connection options are:"
	echo "    -u | --user user name (default: webuser)"
	echo "    -h | --host ip address to the target host (default: \$DEFAULT_DOCKER_HOST)"
	echo "    -n | --off-set integer sets host address according to convention (docker number); Can not be used with -h"
    echo "    -v   set verbose mode to true"
    echo
	echo "  Examples:"
	echo "    sshc -h 10.3.11.15 -n 2"
    echo "    sshc -n 1"
    echo
}

USER="webuser"
DEST_HOST=$DEFAULT_DOCKER_HOST
SSH_PORT=2222
VERBOSE=0
OFF_SET=0

while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
        -u|--user)
            USER="$2"
            shift
            ;;
        -h|--host)
            DEST_HOST="$2"
            shift
            ;;
        -n|--off-set)
            OFF_SET="$2"
            if ! [[ "$OFF_SET" =~ ^[0-9]+$ ]] ; then
                echo $OFF_SET
                error "-n" 5
            fi
            SSH_PORT=$(( $SSH_PORT + $OFF_SET ))
            shift
            ;;
        -v|--verbose)
            VERBOSE=1
            ;;
        *)
            echo "Wrong parameter"
            error "$1" 3
            ;;
    esac
    shift
done

if [[ $VERBOSE -eq 1 ]]; then
    echo "Running:"
    set -x
fi

ssh $USER"@"$DEST_HOST -p $SSH_PORT 
set +x
exit 0;