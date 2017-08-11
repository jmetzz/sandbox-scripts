#!/bin/bash

error () {
	echo "Wrong pagameter: $1"
	usage
	exit $2
} >&2

usage() {
	echo "Usage:"
	echo "   tunnel.sh [-n number] [-h host] [-u user] [-p password] [-a app] [-v]"
	echo
	echo "Available options are:"
	echo "    -u | --user user name                         defaults to webuser"
	echo "    -h | --host ip address to the target host     defaults to \$DEFAULT_DOCKER_HOST"
	echo "    -p | --port ssh port number                   defaults to 2222"
	echo "    -bl | --bind-local bind origin port           defaults to 9000"
	echo "    -bt | --bind-target bind destination port     defaults to 9000"
    echo "    -v |                                           set verbose mode to true"
	echo
	echo "Example:"
	echo "    tunnel.sh -h 10.3.11.15 -p 2223"
}

if [[ $1 == '--help' ]]; then
	echo "Creates a ssh tunnel to a specified host"
	usage
	exit 0
fi

USER="webuser"
DEST_HOST=$DEFAULT_DOCKER_HOST
SSH_PORT="2222"
BIND_LOCAL_PORT="9000"
BIND_TARGET_PORT="9000"
BIND_TARGET_HOST="localhost"
VERBOSE=0

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
        -p|--port)
            SSH_PORT="$2"
            shift
            ;;
        -bl|--bind-local)
            BIND_LOCAL_PORT="$2"
            shift
            ;;
        -bt|--bind-target)
            BIND_TARGET_PORT="$2"
            shift
            ;;
        -v|--verbose)
            VERBOSE=1
            ;;
        *)
            echo "Wrong parameter"
            exit 3
            ;;
    esac
    shift
done

if [[ $VERBOSE -eq 1 ]]; then
    echo "Running:"
    set -x
fi

ssh -f $USER"@"$DEST_HOST -p $SSH_PORT -L "${BIND_LOCAL_PORT}:${BIND_TARGET_HOST}:${BIND_TARGET_PORT}" -N

set +x
exit 0;