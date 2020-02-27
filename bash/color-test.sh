#!/usr/bin/env bash

# colors tests


#Need to solve problems/differences with regard to
#.   echo
#.   sed
#.   grep


# color sequences star	t with 
# the character ESC (ASCII decimal 27 / hex 0x1B / octal 033).
#  followed by a second character in the range ASCII 64 to 95
# (@ to _ / hex 0x40 to 0x5F)

NO_COLOUR="[0m"
BLUE="[0;34m"
RED="[0;31m"
GRAY="[0;37m"
GREEN="[0;32m"
BLUE="[0;34m"
CYAN="[0;36m"
YELLOW="[0;33m"
GRAY="[0;37m"
echo
echo ${RED}RED ${GREEN}GREEN ${YELLOW}YELLOW ${CYAN}CYAN ${BLUE}BLUE ${GRAY}GRAY ${NO_COLOUR}
echo " ----- "

# this is compatible with bash 3.2.+ 
NO_COLOUR=$'\033[0m'

BLACK=$'\033[0;30m'
BOLD_BLACK=$'\033[1;30m'

RED=$'\033[0;31m'
BOLD_RED=$'\033[1;31m'

GREEN=$'\033[0;32m'
BOLD_GREEN=$'\033[1;32m'

YELLOW=$'\033[0;33m'
BOLD_YELLOW=$'\033[1;33m'

BLUE=$'\033[0;34m'
BOLD_BLUE=$'\033[1;34m'

PURPLE=$'\033[0;35m'
BOLD_PURPLE=$'\033[1;35m'

CYAN=$'\033[0;36m'
BOLD_CYAN=$'\033[1;36m'

GRAY=$'\033[0;37m'
BOLD_GRAY=$'\033[1;37m'


echo "Light:" ${BLACK}BLACK ${RED}RED ${GREEN}GREEN ${YELLOW}YELLOW  ${BLUE}BLUE ${PURPLE}PURPLE ${CYAN}CYAN ${GRAY}GRAY ${NO_COLOUR}
echo "Bold :" ${BOLD_BLACK}BLACK ${BOLD_RED}RED ${BOLD_GREEN}GREEN ${BOLD_YELLOW}YELLOW ${BOLD_BLUE}BLUE ${BOLD_PURPLE}PURPLE ${BOLD_CYAN}CYAN ${BOLD_GRAY}GRAY ${NO_COLOUR}

exit 0

