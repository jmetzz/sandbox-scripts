#!/bin/bash

#BLUE="echo [0;34m"
# ${BLUE}
# echo "should be BLUE"

# GREEN="echo -ne \033[0m\033[32m"
# ${GREEN}
# echo "should be GREEN"

# RED="\x1b\[0;31m"
# echo "${RED} should be RED"

# YELLOW="echo -ne [0;34m"
# echo "${YELLOW} should be YELLOW"

echo $BASH_VERSION

LOCAL_BLUE='\x1b[0;34m'
echo "${LOCAL_BLUE} should be LOCAL_BLUE"
