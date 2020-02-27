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


function checkBranchesExist(){
	git fetch -q origin 2>/dev/null
	from=$(git show-ref refs/remotes/origin/${1} 2>/dev/null)
	to=$(git show-ref refs/remotes/origin/${2} 2>/dev/null)
	[[ -z ${from} ]] && echo "Remote '${1}' branch does not exits" && exit 1;
	[[ -z ${to} ]]  && echo "Remote '${2}' branch does not exits" && exit 1;
}

inverse=0

while [[ $# -gt 2 ]]
do
	key="$1"

	case $key in
		-i|--inverse)
			inverse=1
			;;
		-h|--help)
			usage
			exit 0
			;;
		*)
			echo "Wrong option"
			usage
			exit 1
			;;
	esac
	shift
done


#BRANCH_1=`git rev-parse --abbrev-ref HEAD`
BRANCH_1="$1"
BRANCH_2="$2"


checkBranchesExist ${BRANCH_1} ${BRANCH_2}

if [[ $inverse -eq 1 ]]; then
    git rev-list --pretty ${BRANCH_2}..${BRANCH_1}
else
    git rev-list --pretty ${BRANCH_1}..${BRANCH_2}
fi

