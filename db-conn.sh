#!/bin/bash 

#set ohm-db-to-docker-endpoint
#windlfly-9.0.1.Final/standalone/configuration/standalone.xml
#base it on:
#							jndi-name					connection 			IP 	 			Port 
#
#	ohm: 				"java:/jdbc/resinexDev" 		ohmdock 			docker ip 		50000+offset
#	sales: 				"java:/jdbc/salesDB"			ravdock 			docker ip 		50000+offset
#defaults
#	offset: 0
#	host: 10.3.11.62 
#	gaussDev: 			"java:/jdbc/gaussDev"			GAUSSND3 			172.21.0.157	5480
#	ohmsven: 			"java:/jdbc/ohmsven"			ohmsven 			10.3.11.30		50003
#	prdCpy: 			"java:/jdbc/resinexPrdCpy"		prdcpy  			10.3.11.30		50003
BLUE=$'\033[1;34m'
RED=$'\033[1;31m'
GREEN=$'\033[1;32m'
YELLOW=$'\033[1;33m'
BOLD_BLUE=$'\033[1;34m'
PURPLE=$'\033[1;35m'
CYAN=$'\033[1;36m'
GRAY=$'\033[1;37m'
NO_COLOUR=$'\033[0m'

function usage(){
	echo
	echo "${YELLOW}WildFly${NO_COLOUR} datasource connection endpoint and port setup for ${RED}Ohm${NO_COLOUR} and ${BLUE}Blue${NO_COLOUR}."
	echo 
	echo "${YELLOW}Usage:${NO_COLOUR}"
	echo "	db-conn [options]"
	echo 
	echo "${YELLOW}Available options are:${NO_COLOUR}"
	echo "    -H | --host        Docker host ip (default: \$DEFAULT_DOCKER_HOST)"
	echo "    -p | --port        DB connection port (default: 50000)"
	echo "    -n | --number      Docker offset number (defaults: 0)"
	echo "    -s | --server      Single digit Server version number (default: 9)"
	echo "    -c | --connection  Connection name (default: ravdock)"
	echo "    -h | --help        Shows this message"
	echo
	echo "${YELLOW}Requirements:${NO_COLOUR}"
	echo "    1. server path variable "
	echo
	echo "${YELLOW}Examples:${NO_COLOUR}"
	echo "# uses defaults values:"
	echo "    ${YELLOW}>${NO_COLOUR} db-conn "
	echo
	echo "# uses default value for 'host' parameter and sets 'port' to 50002:"
	echo "    ${YELLOW}>${NO_COLOUR} db-conn -n 2"
	echo
	echo "# uses 10.3.11.62 for 'host' parameter and sets 'port' to 50001:"
	echo "    ${YELLOW}>${NO_COLOUR} db-conn -h 10.3.11.62 -n 1"	
}



error () {
	echo "Wrong parameter: $1"
	exit $2
} # >&2


function printConfiguration(){
	local host="$1"
	local port="$2"
	local configFile="$3"
	local connection="$4"

	echo "${YELLOW}Using options:${NO_COLOUR}"
	echo "   Config file path: ${configFile}"
	echo "   host:port as ${host}:${port}"
	echo "   connection name: $connection"
}

function setupConnection(){

	local host="$1"
	local port="$2"
	local configFile="$3"
	local connection="$4"

	printConfiguration $host $port $configFile $connection
	
	pattern="\(.*jdbc\:db2\:\/\/\)\(.*\)\(\/${connection}.*\)"
	TIMESTAMP=$(date +"%Y%m%d%H%M")
	#sed -i_${TIMESTAMP} -e "s/$pattern/\1${HOST}\:${PORT}\3/" ${CONFIG_PATH}
	sed -i_${TIMESTAMP} -e "s/$pattern/\1${host}\:${port}\3/" ${configFile}
}

function reset(){
	SERVER_VERSION=$1
	SERVER_PATH=$(printenv | grep -e "^WILDFLY${SERVER_VERSION}_HOME=" | sed -e 's/\(^.*=\)\(.*\)/\2/')
	CONFIG_PATH="${SERVER_PATH}/standalone/configuration/standalone.xml"

	[[ ! -f $CONFIG_PATH ]] && error "${RED}${CONFIG_PATH}${NO_COLOUR} file does not exist"

	setupConnection $HOST $PORT $CONFIG_PATH "ohmdock"
	setupConnection $HOST $PORT $CONFIG_PATH "ravdock"

}


if [[ $1 == '--help' ]]; then
	usage
	exit 0
fi



HOST=$DEFAULT_DOCKER_HOST
PORT=50000
OFFSET=0
SERVER_VERSION=9
CONNECTION="ravdock"


while [[ $# -gt 0 ]]
do
	key="$1"

	case $key in
	    -H|--host)
		    HOST="$2"
		    shift
	    ;;
	    -p|--port)
		    PORT="$2"
		    shift
	    ;;
	    -s|--server)
			SERVER_VERSION=$2
			shift
		;;
		-n|--number)
            OFFSET="$2"
            if ! [[ "$OFFSET" =~ ^[0-9]+$ ]] ; then
                echo $OFFSET
                error "-n" 5
            fi
            shift
            ;;
        -c|--connection)
			CONNECTION=$2
			shift
			;;
        -h|--help)
			usage
			exit 0
			;;
		--reset)
			SERVER_VERSION="$2"
			if ! [[ "$SERVER_VERSION" =~ ^[0-9]+$ ]] ; then
                error "--reset <server version>" 5
            fi
			echo "${RED}Reseting configuration to default values."
			echo "All other parameters are ignored ${NO_COLOUR}"
			reset "$2"
			exit 0
			;;
        *)
            echo "Wrong parameter"
            error "$1" 3
            ;;
	esac
	shift
done





SERVER_PATH=$(printenv | grep -e "^WILDFLY${SERVER_VERSION}_HOME=" | sed -e 's/\(^.*=\)\(.*\)/\2/')

CONFIG_PATH="${SERVER_PATH}/standalone/configuration/standalone.xml"

[[ ! -f $CONFIG_PATH ]] && error "${RED}${CONFIG_PATH}${NO_COLOUR} file does not exist"

PORT=$(( $PORT + $OFFSET ))



setupConnection $HOST $PORT $CONFIG_PATH $CONNECTION

exit 0;