#!/usr/bin/env bash

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

usage() {
    echo "Usage:"
    echo "    sconn <subtask [options]>"
    echo
    echo "    Examples:"
    echo "        sconn connect [-u user] [-h host] [-p port number] [-k] [-v] [-H|help]"
    echo "        sconn spyport <ssh port>"
    echo "        sconn tunnel [create | list | halt] <options>"
    echo "        sconn halt <control socket path>"
    echo "        sconn help"
    echo
    echo "    Check connection:"
    echo "        sconn spyport 22"
    echo
    echo "    Close tunnel connection options are:"
    echo "        -s | --socket  control socket for connection sharing (default: 'host-sshport-user')"
    echo
    echo "    Example:"
    echo "      sconn tunnel halt /tmp/10.3.11.62-2223-username"

}

usage_connect() {
    echo
    echo "Establish a ssh connection."
    echo "Usage:"
    echo "   sconn connect [-u user] [-h host] [-p port number] [-k] [-v] [-H|help]"
    echo "    -u | --user: user name (default: \$GFK_USER_NAME)"
    echo "    -h | --host: ip address to the target host (default: \$DEV1)"
    echo "    -p | --port: ssh port number (default: 22)"
    echo "    -k set connect with ssh private key instead of password."
    echo "           Depends on \$PRIVATE_KEY environment var which should point to the key file."
    echo "    -H   show this message"
    echo "    -v   set verbose mode to true"
    echo
    echo "    Examples:"
    echo "      sconn connect -h \$DEV_SERVER -p 2223"
    echo "      sconn connect -k"
    echo "      sconn.sh connect -u jean.metz -h ce1 -k"
    echo
}

usage_tunnel() {
    echo
    echo "Manages ssh tunnels to a specified host"
    echo "Usage:"
    echo "    sconn.sh tunnel <subtask [options]>"
    echo
    echo "  Sub-tasks are: create, list, halt, and [-H|help]"
    echo
    echo "  Examples:"
    echo "      sconn tunnel create -u jean.metz -h ce1 -k"
    echo "      sconn tunnel create -k"
    echo "      sconn tunnel list"
    echo "      sconn tunnel halt <control socket path>"
    echo
}

function checkConnection() {
    if [ $# -ne 1 ]; then
        echo "Checks connection ssh connection in a specific port:"
        echo "Usage:"
        echo "    sconn spyport <port>"
        echo
        echo "    Example:"
        echo "        sconn spyport 22"
        echo
        exit 1
    fi

    port="$1"
    nc -z localhost $port || echo 'no tunnel open'
    exit 0
    echo "tunnel active on port $1"
    exit 0
    #https://apple.stackexchange.com/questions/117644/how-can-i-list-my-open-network-ports-with-netstat
}

function connect() {
    while [[ $# -gt 0 ]]; do
        key="$1"
        case $key in
        -u | --user)
            USER="$2"
            shift
            ;;
        -h | --host)
            DEST_HOST="$2"
            shift
            ;;
        -p | --port)
            SSH_PORT="$2"
            shift
            ;;
        -v | --verbose)
            VERBOSE=1
            ;;
        -k)
            USE_PRIVATE_KEY=1
            ;;
        -H | help)
            usage_connect
            exit 0
            ;;
        *)
            echo "Wrong parameter: '$1'"
            exit 3
            ;;
        esac
        shift
    done

    if [[ $VERBOSE -eq 1 ]]; then
        echo "Running:"
        set -x
    fi

    if [[ $USE_PRIVATE_KEY == 1 ]]; then
        LOGIN_MODE="-i ${SSH_KEY}"
    else
        LOGIN_MODE=""
    fi
    ssh $LOGIN_MODE $USER"@"$DEST_HOST -p $SSH_PORT
}

function createTunnel() {
    while [[ $# -gt 0 ]]; do
        key="$1"
        case $key in
        -u | --user)
            USER="$2"
            shift
            ;;
        -h | --host)
            DEST_HOST="$2"
            shift
            ;;
        -p | --port)
            SSH_PORT="$2"
            shift
            ;;
        -bl | --bind-local)
            BIND_LOCAL_PORT="$2"
            shift
            ;;
        -bt | --bind-target)
            BIND_TARGET_PORT="$2"
            shift
            ;;
        -v | --verbose)
            VERBOSE=1
            ;;
        -k)
            USE_PRIVATE_KEY=1
            ;;
        -H | help)
            echo
            echo "Creates ssh tunnels"
            echo "Usage:"
            echo "    sconn tunnel create [-u user] [-h host] [-v] [-k] [-H | help]"
            echo "      -u | --user user name (default: \$GFK_USER_NAME)"
            echo "      -h | --host ip address to the target host (default: \$DEV1)"
            echo "      -p | --port ssh port number (default: 22)"
            echo "      -bl | --bind-local bind origin port (default: 9000)"
            echo "      -bt | --bind-target bind destination port (default: 9000)"
            echo "      -s | --socket control socket for connection sharing (default: '%h%p%r')"
            echo "      -k set connect with ssh private key instead of password."
            echo "           Depends on \$PRIVATE_KEY environment var which should point to the key file"
            echo "      -v   set verbose mode to true"
            echo
            exit 0
            ;;
        *)
            echo "Wrong parameter: '$1'"
            exit 3
            ;;
        esac
        shift
    done

    if [[ $VERBOSE -eq 1 ]]; then
        echo "Running:"
        set -x
    fi

    #ssh -i $SSH_KEY -f -N -M -S "$SOCKET" -L "${BIND_LOCAL_PORT}:${BIND_TARGET_HOST}:${BIND_TARGET_PORT}" $USER"@"$DEST_HOST -p $SSH_PORT
    if [[ $USE_PRIVATE_KEY == 1 ]]; then
        LOGIN_MODE="-i ${SSH_KEY}"
    else
        LOGIN_MODE=""
    fi

    CURRENTDATE=`date +"%Y-%m-%d_%T"`
    SOCKET="${SOCKET}_${CURRENTDATE}"

    echo "Creating tunnel with socket control: ${SOCKET}"
    echo "    Connection: $USER"@"$DEST_HOST -p $SSH_PORT"
    echo "    Port forward: -L ${BIND_LOCAL_PORT}:${BIND_TARGET_HOST}:${BIND_TARGET_PORT}"
    if [[ $USE_PRIVATE_KEY == 1 ]]; then
        echo "    Login mode: using private ssh key"
        echo "        file: '${SSH_KEY}'"
        echo "        If your private ssh key file name is 'id_rsa' you don't need to use this option."
    fi
    echo "    Control socket: $SOCKET"
    ssh $LOGIN_MODE -f -N -M -S "${SOCKET}" -L "${BIND_LOCAL_PORT}:${BIND_TARGET_HOST}:${BIND_TARGET_PORT}" $USER"@"$DEST_HOST -p $SSH_PORT
}

function listTunnels() {
    lsof -PiTCP -sTCP:LISTEN | grep ssh
}

function closeConnection() {
    if [[ ! -z "$1" ]]; then
        SOCKET="$1"
    fi
    ssh -S $SOCKET -O exit "localhost"
}

function tunnel() {

    if [ $# -lt 1 ]; then
        usage_tunnel
        exit 1
    fi

    subtask=$1
    case $subtask in
    create)
        createTunnel "${@:2}"
        exit 0
        ;;
    halt)
        closeConnection "${@:2}"
        echo "Tunnels still open:"
        listTunnels
        echo
        echo "<< End of list."
        exit 0
        ;;
    list)
        echo "Checking for existing ssh tunnels >>"
        listTunnels
        echo
        echo "<< End of list."
        echo
        exit 0
        ;;
    -H | help)
        usage_tunnel
        exit 0
        ;;
    *)
        echo "Wrong option"
        usage_tunnel
        exit 1
        ;;
    esac
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
        tunnel "${@:2}"
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
