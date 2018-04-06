#!/bin/bash

error () {
     echo "Wrong parameter: $1"
     usage
     exit $2
} >&2

usage() {
    echo "Usage:"
    echo "   tunnel connect [-n number] [-h host] [-u user] [-p password] [-a app] [-v]"
    echo "   tunnel list"
    echo "   tunnel spy <port>"
    echo "   tunnel halt <control socket path>"
    echo
    echo "Establish connection options are:"
    echo "    -u | --user user name (default: webuser)"
    echo "    -h | --host ip address to the target host (default: \$DEFAULT_DOCKER_HOST)"
    echo "    -p | --port ssh port number (default: 2222)"
    echo "    -bl | --bind-local bind origin port (default: 9000)"
    echo "    -bt | --bind-target bind destination port (default: 9000)"
    echo "    -s | --socket control socket for connection sharing (default: '%h%p%r')"
    echo "    -n | --off-set integer sets host address according to ravago convention (docker number); Can not be used with -h"
    echo "    -v   set verbose mode to true"
    echo
    echo "    Examples:"
    echo "      tunnel connect -h 10.3.11.15 -p 2223"
    echo "      tunnel connect -n 2"
    echo
    echo "List open tunnels:"
    echo "    tunnel list"
    echo
    echo "Check connection:"
    echo "    tunnel spy 60000"
    echo
    echo "Close connection options are:"
    echo "    -s | --socket  control socket for connection sharing (default: 'host-sshport-user')"
    echo
    echo "    Example:"
    echo "      tunnel halt /tmp/10.3.11.62-2223-webuser"

}

USER="webuser"
DEST_HOST=$DEFAULT_DOCKER_HOST
SSH_PORT=2222
BIND_LOCAL_PORT="9000"
BIND_TARGET_PORT="9000"
BIND_TARGET_HOST="localhost"
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
    set -x
    if [[ ! -z "$1" ]]; then
        SOCKET="$1"
    fi

    ssh -S $SOCKET -O exit "localhost"
    set +x
    exit 0;
}

function establishConnection(){

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

    # ssh switches meaning:
    #   -N  Do not execute a remote command.  
    #         This is useful for just forwarding ports (protocol version 2 only).
    #   -f Requests ssh to go to background just before command execution.  
    #         This is useful if ssh is going to ask for passwords or passphrases, 
    #         but the user wants it in the background. 
    #   -M  Places the ssh client into “master” mode for connection sharing.  Multiple -M options places ssh
    #         into “master” mode with confirmation required before slave connections are accepted.  
    #         Refer to the description of ControlMaster in ssh_config(5) for details.
    #   -S ctl_path
    #         Specifies the location of a control socket for connection sharing, or the string “none” to disable
    #         connection sharing.  Refer to the description of ControlPath and ControlMaster in ssh_config(5) for
    #         details.
    #         The ctl_path is a path to a file the master instance of ssh client will create for inter-process
    #         communication with other ssh client instances that want to share master instance's connection.
    #         The created file will actually represent a unix domain socket. It can be named and located whatever
    #         and wherever you want it, e.g. /tmp/session1 (though it is recommended to name it using
    #         %patterns -- see ControlPath description bellow)
    #    
    #         ControlPath
    #             Specify the path to the control socket used for connection sharing as described in the ControlMaster
    #             section above or the string ``none'' to disable connection sharing. In the path, `%L' will be
    #             substituted by the first component of the local host name, `%l' will be substituted by the localhost
    #             name (including any domain name), `%h' will be substituted by the target host name, `%n' will be
    #             substituted by the original target host name specified on the command line, `%p' the destination
    #             port, `%r' by the remote login username, `%u' by the username and `%i' by the numeric user ID (uid)
    #             of the user running ssh(1), and `%C' by a hash of the concatenation: %l%h%p%r.  It is recommended
    #             that any ControlPath used for opportunistic connection sharing include at least %h, %p, and %r
    #             (or alternatively %C) and be placed in a directory that is not writable by other users.
    #             This ensures that shared connections are uniquely identified.
    #
    # -L [bind_address:]port:host:hostport
    #         Specifies that the given port on the local (client) host is to be forwarded to the given host and
    #         port on the remote side.  This works by allocating a socket to listen to port on the local side,
    #         optionally bound to the specified bind_address.  Whenever a connection is made to this port, the
    #         connection is forwarded over the secure channel, and a connection is made to host port hostport
    #         from the remote machine.  Port forwardings can also be specified in the configuration file.  IPv6
    #         addresses can be specified by enclosing the address in square brackets.  Only the superuser can
    #         forward privileged ports.  By default, the local port is bound in accordance with the GatewayPorts
    #         setting.  However, an explicit bind_address may be used to bind the connection to a specific
    #         address.  The bind_address of “localhost” indicates that the listening port be bound for local use
    #         only, while an empty address or ‘*’ indicates that the port should be available from all
    #         interfaces.

    set -x
    ssh -f -N -M -S $SOCKET -L "${BIND_LOCAL_PORT}:${BIND_TARGET_HOST}:${BIND_TARGET_PORT}" $USER"@"$DEST_HOST -p $SSH_PORT
    set +x
    exit 0;
}


main() {
    if [ $# -lt 1 ]; then
        usage
        exit 1
    fi

    subtask=$1

    case $subtask in
        spy)
            checkConnection "${@:2}"
            ;;
        connect)
            establishConnection "${@:2}"
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





