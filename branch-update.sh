#!/bin/bash

BLUE=$'\033[0;34m'
MAGENTA=$'\033[0;35m'
RED=$'\033[0;31m'
LIGHT_RED=$'\033[1;31m'
LIGHT_GRAY=$'\033[0;37m'
LIGHT_GREEN=$'\033[1;32m'
LIGHT_BLUE=$'\033[1;34m'
LIGHT_CYAN=$'\033[1;36m'
YELLOW=$'\033[1;33m'
WHITE=$'\033[1;37m'
NO_COLOUR=$'\033[0m'

function usage() {
    echo "$0 <-m> <-e> [branch]"
    echo
    echo "   -m      - run maintenance as well: prune and gc"
    echo "   -e      - include ESB/Mule repos"
    echo
    echo "runs git fetch && git rebase for a given branch for repositories in the directory REPOROOT (currently ${REPOROOT})."
}


if [[ -z ${REPOROOT} ]]
then
    echo "REPOROOT not set"
    exit 1
fi

if [[ ! -d ${REPOROOT} ]]
then
    echo "Workspace directory does not exist (${REPOROOT})."
    exit 1
fi

#set -o pipefail

MAINTENANCE=0
INCLUDE_MULE_REPOS=0

while getopts "meh" option; do
    case "${option}" in
        m)
            MAINTENANCE=1
            ;;
        e)
            INCLUDE_MULE_REPOS=1
            ;;
        -h)
            usage
            exit 0
            ;;
    esac
done

shift $((OPTIND-1))

if [[ $# -ne 1 ]]
then
    usage
    exit 1
fi

targetBranch=$1

# check for existing, clone if not, clean/reset/pull if exists
for repo in $(cat $REPOROOT/ravapps/repo_list.txt); do

	 # also handle mule repos when parameter -m is set, else skip them
    if [[ $INCLUDE_MULE_REPOS == 0 ]] ; then 
        if [[ $repo == *-esb ]] || [[ $repo == edi-* ]] || [[ $repo == "services" ]] ; then
            continue
        fi
    fi

	if [[ ! -d ${REPOROOT}/${repo} ]]; then
		echo "${repo} does not exist. skipping ..."
		continue
	fi
	cd ${REPOROOT}/${repo}

	echo "Updating repository ${LIGHT_BLUE}${repo}${NO_COLOUR}"

	# checkout branch
	git checkout $targetBranch 2>/tmp/checkout.err
	CHECKOUT_FAILED=$(cat /tmp/checkout.err | grep -q "error: pathspec"; echo $?)
	[[ ${CHECKOUT_FAILED} -eq 0 ]] && echo "${LIGHT_RED}Unable to checkout branch ${RED}${targetBranch}${LIGHT_RED} (does it exists?)${NO_COLOUR}" && continue
		
	# check for changes in the local branch
	CHANGES=$(git status -s | wc -l | sed -e 's,^\ *,,gm')
	if [[ ${CHANGES} -ne 0 ]]; then
		git status -s | grep -e ^[DAMUR];
		echo "${LIGHT_RED}Branch $targetBranch still contains ${RED}${CHANGES}${LIGHT_RED}  uncommitted changes.${NO_COLOUR}";
		echo "${LIGHT_RED}Please stash/remove changes on branch ${RED}${targetBranch}${LIGHT_RED} before branching.${NO_COLOUR}"
		continue;
	fi

	# check for unpushed commits
	UNPUSHED=$(git status -bs | grep ahead | sed s/\\[ahead\ /\\]/ | cut -d ']' -f 2)
	if [ "${UNPUSHED}" != "" ] && [ "${UNPUSHED}" != "0" ]; then
		echo "${LIGHT_RED}Please push branch ${RED}${targetBranch}${LIGHT_RED} by executing${NO_COLOUR}"
		echo "${LIGHT_RED}git push orgin ${RED}${targetBranch}${NO_COLOUR}"
		continue;
	fi
	echo "${LIGHT_GREEN}All set :)${NO_COLOUR}"	
	
	echo "  * fetch"
    git fetch -q
    (( $? != 0 )) && exit 1
    echo "  * rebase ${targetBranch}"
    git rebase -q "origin/${targetBranch}"
    (( $? != 0 )) && exit 1

 	if [[ ${MAINTENANCE} == 1 ]]; then
        echo "  * prune"
        git fetch -pq
        echo "  * gc"
        git gc -q
    fi

    echo -n "  * [GIT] ${LIGHT_BLUE}${repo}${NO_COLOUR} commit# "
    echo "${YELLOW}"
    git rev-parse HEAD
    echo "${NO_COLOUR}"
    echo

done