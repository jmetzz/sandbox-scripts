#!/usr/bin/env bash

usage() {
	echo
	echo "Usage:"
	echo "    $0 <options> branch-1 branch-2"
	echo
    echo "Options:"
    echo "   -h|--help        show usage message"
	echo "   -i|--invert      uses branch names in inverted order"


	echo
	echo "Behaviour:"
	echo "    List the commits present in branch-2 that are not in branch-1."
	echo
}

function err (){
    local msg=$1
    echo "[ERROR] - ${msg}"
    usage
    exit $2
}


function checkBranchesExist(){
	git fetch -q origin 2>/dev/null
	from=$(git show-ref refs/remotes/origin/${1} 2>/dev/null)
	to=$(git show-ref refs/remotes/origin/${2} 2>/dev/null)
	[[ -z ${from} ]] && echo "Remote '${1}' branch does not exits" && exit 1;
	[[ -z ${to} ]]  && echo "Remote '${2}' branch does not exits" && exit 1;
}

INVERSE=0

if [ $# -lt 2 ]; then
    usage
    exit 1
fi

while getopts ":hi" opt; do
    case "${opt}" in
        h)
            usage
            exit 0
            ;;
        i)
            INVERSE=1
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
if [[ ${#remaining_arguments[*]} -ne 2 ]]; then
    err "Missing arguments" 3
fi

#BRANCH_1=`git rev-parse --abbrev-ref HEAD`
BRANCH_1="${remaining_arguments[0]}"
BRANCH_2="${remaining_arguments[1]}"


checkBranchesExist ${BRANCH_1} ${BRANCH_2}

if [[ $INVERSE -eq 1 ]]; then
    git rev-list --pretty ${BRANCH_2}..${BRANCH_1}
else
    git rev-list --pretty ${BRANCH_1}..${BRANCH_2}
fi

