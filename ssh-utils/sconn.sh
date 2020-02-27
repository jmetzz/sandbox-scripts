#!/usr/bin/env bash

error () {
     echo "Wrong parameter: $1"
     usage
     exit $2
} >&2

usage() {
    echo "Usage:"
    echo "   sconn connect [-n number] [-h host] [-u user] [-p password] [-a app] [-v]"
    echo "   sconn list"
    echo "   sconn spyport <port>"
    echo "   sconn halt <control socket path>"
    echo
    echo "Establish connection options are:"
    echo "    -u | --user user name (default: \$GFK_USER_NAME)"
    echo "    -h | --host ip address to the target host (default: \$DEV1)"
    echo "    -p | --port ssh port number (default: 22)"
    echo "    -bl | --bind-local bind origin port (default: 9000)"
    echo "    -bt | --bind-target bind destination port (default: 9000)"
    echo "    -s | --socket control socket for connection sharing (default: '%h%p%r')"
    echo "    -n | --off-set integer sets host address according to ravago convention (docker number)"
    echo "                   Can not be used with -h"
    echo "    -k set connect with ssh private key instead of password."
    echo "           Depends on \$PRIVATE_KEY environment var which should point to the key file"
    echo "    -v   set verbose mode to true"
    echo
    echo "    Examples:"
    echo "      sconn connect -h 10.3.11.15 -p 2223"
    echo "      sconn connect -n 2"
    echo
    echo "List open tunnels:"
    echo "    sconn tunnel list"
    echo
    echo "Check connection:"
    echo "    sconn spyport 22"
    echo
    echo "Close tunnel connection options are:"
    echo "    -s | --socket  control socket for connection sharing (default: 'host-sshport-user')"
    echo
    echo "    Example:"
    echo "      sconn tunnel halt /tmp/10.3.11.62-2223-username"

}

USER=$GFK_USER_NAME
DEST_HOST=$DEV1
SSH_KEY=$PRIVATE_KEY

SSH_PORT=22
BIND_LOCAL_PORT="9000"
BIND_TARGET_PORT="9000"
BIND_TARGET_HOST="localhost"
USE_PRIVATE_KEY=0
VERBOSE=0
OFF_SET=0
SOCKET="/tmp/$DEST_HOST-$SSH_PORT-$USER"

function checkConnection(){
    if [ $# -ne 1 ]; then
        usage
        exit 1
    fi

    port=$1
    nc -z localhost $port || echo 'no tunnel open' ; exit 0;
    echo "tunnel active on port $1"; exit 0;    
    #https://apple.stackexchange.com/questions/117644/how-can-i-list-my-open-network-ports-with-netstat
}

function listTunnels(){
    lsof -PiTCP -sTCP:LISTEN | grep ssh
}

function closeConnection(){
    if [[ ! -z "$1" ]]; then
        SOCKET="$1"
    fi
    ssh -S $SOCKET -O exit "localhost"
    exit 0;
}

function parseArgs(){
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
            -n|--off-set)
                OFF_SET="$2"
                if ! [[ "$OFF_SET" =~ ^[0-9]+$ ]] ; then
                    echo $OFF_SET
                    error "-n" 5
                fi
                SSH_PORT=$(( $SSH_PORT + $OFF_SET ))
                shift
                ;;
            -k)
              USE_PRIVATE_KEY=1
              ;;
            *)
                echo "Wrong parameter"
                error "$1" 3
                ;;
        esac
        shift
    done
}

function connect(){
    parseArgs "${@}"
    if [[ $USE_PRIVATE_KEY == 1 ]]; then
        LOGIN_MODE="-i ${SSH_KEY}"
    else
        LOGIN_MODE=""
    fi
    ssh $LOGIN_MODE $USER"@"$DEST_HOST -p $SSH_PORT
}

function createTunnel(){
    parseArgs "${@}"

    if [[ $VERBOSE -eq 1 ]]; then
        echo "Running:"
        set -x
    fi

    #ssh -i $SSH_KEY -f -N -M -S "$SOCKET" -L "${BIND_LOCAL_PORT}:${BIND_TARGET_HOST}:${BIND_TARGET_PORT}" $USER"@"$DEST_HOST -p $SSH_PORT
    if [[ $USE_PRIVATE_KEY == 1 ]]; then
        echo "Using ssh private key '${SSH_KEY}'"
        echo "If your private ssh key file name is 'id_rsa' you don't need to use this option"
        LOGIN_MODE="-i ${SSH_KEY}"
    else
        LOGIN_MODE=""
    fi

    echo "Creating tunnel with socket control: ${SOCKET}"
    ssh $LOGIN_MODE -f -N -M -S "$SOCKET" -L "${BIND_LOCAL_PORT}:${BIND_TARGET_HOST}:${BIND_TARGET_PORT}" $USER"@"$DEST_HOST -p $SSH_PORT
    exit 0
}


main() {
    if [ $# -lt 1 ]; then
        usage
        exit 1
    fi

    subtask=$1

    case $subtask in
        connect)
            connect "${@:2}"
            ;;
        spyport)
            checkConnection "${@:2}"
            ;;
        tunnel)
            createTunnel "${@:2}"
            ;;
        halt)
            closeConnection "${@:2}"
            ;;
        list)
            listTunnels
            ;;
        help)
            echo "Creates a ssh tunnel to a specified host"
            usage
            exit 0
            ;;
        *)
            echo "Wrong option"
            usage
            exit 1
            ;;
    esac
}


main "$@"





