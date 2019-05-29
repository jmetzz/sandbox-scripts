#!/bin/sh


# Set defaults
BRANCH="develop"
CHECKOUT=0
UPDATE=0
VERBOSE=0
PRUNE=""
PROJECT="ya1"
WORKSPACE=""

function usage {
    echo "$0 -[h] <project> <workspace>"
    echo "       -h           : shows this message. Ignores any other arguments."
    echo
}

function err (){
    local msg=$1
    echo "[ERROR] - ${msg}"
    usage
    exit $2
}


banner() {
    msg="| $* |"
    edge=$(echo "$msg" | gsed 's/./~/g')
    echo "$edge"
    echo "$msg"
    echo "$edge"
}


function status_single_repo(){
    repo="$1"
    cd $repo

    if [[ ! -d .git ]]; then
        echo "Not in a git managed directory"
        return
    fi

    git fetch -q

    behind=$(git status | head -n2 | grep 'Your branch is behind' | gsed s/\ by\ /,/gm | cut -d ',' -f 2 | gsed -e 's,\([0-9]*\)\ commits\?,-\1,gm')
    git status | head -n 3 | grep -q 'different commits\? each, respectively' && behind=$(git status | head -n 3 | grep 'different commits\? each, respectively' | gsed -e 's,\ have\ ,\@,gm' -e 's,\ and\ ,\@,gm' -e 's,\ different\ ,\@,gm' | cut -d '@' -f 3 | gsed -e 's,^,-,gm')
    printf "%-10s" "${behind}"

    ahead=$(git status | head -n2 | grep 'Your branch is ahead' | gsed s/\ by\ /,/gm | cut -d ',' -f 2 | gsed -e 's,\([0-9]*\)\ commits\?\.,+\1,gm')
    git status | head -n 3 | grep -q 'different commits\? each, respectively' && ahead=$(git status | head -n 3 | grep 'different commits\? each, respectively' | gsed -e 's,\ have\ ,\@,gm' -e 's,\ and\ ,\@,gm' -e 's,\ different\ ,\@,gm' | cut -d '@' -f 2 | gsed -e 's,^,+,gm')
    git rev-parse --abbrev-ref --symbolic-full-name @{upstream} 2>/dev/null >/dev/null || ahead="+"
    printf "%-10s" "${ahead}"

    conflicts=$(git status -s | grep -e "^[DAMUR ][DAMUR ]" | wc -l | gsed -e 's,^\ *,,gm' -e 's,^\([^0].*\),~\1,gm' -e 's,^0,,gm')
    printf "%-12s" "${conflicts}"

    stash=$(git stash list | wc -l | gsed -e 's,^\ *,,gm' -e 's,^\([^0].*\),\@\1,gm' -e 's,^0,,gm')
    printf "%-10s" "${stash}"

    status=$(git status --porcelain)
    flags=
    if [[ ${status} == *\?\?* ]]
    then
        flags="${flags}*"
    fi
    if [[ ${status} == *\ M* ]]
    then
        flags="${flags}M"
    fi
    if [[ ${status} == *\ D* ]]
    then
        flags="${flags}D"
    fi
    printf "%-12s" "${flags}"

    current_branch=$(git branch | grep  "^* " | cut -c3-)
    printf "%-41s " ${current_branch}

}

function main(){
    # $WORKSPACE $PROJECT
    base_dir="$1"
    project="$2"
    current_dir=$(pwd)
    cd $base_dir

    echo "Pristine status meaning:"
    echo "   *: untracked"
    echo "   M: Modified"
    echo "   D: Deleted"
    banner "                                        | behind | ahead | conflicts | stashes | Pristine | current branch                   "

    repos=$(ls -d */ | tr "\n" " " )
    IFS='/ ' read -r -a array <<< "$repos"
    for repo in "${array[@]}"
    do
        if [[ $repo =~ ^"$project".* ]]; then
            printf "* %-40s|" ${repo}
            repo_path=$base_dir/$repo
            status_single_repo $repo_path
            echo
         fi
    done
    banner "Status checked!                                                                                                              "
    cd $base_dir
}


if [[ -z ${GIT_REMOTE} ]]; then
    echo "GIT_REMOTE environment var is not defined"
    exit 1
fi

if [ $# -lt 1 ]; then
    usage
    exit 1
fi

while getopts ":huvpc:" opt; do
    case "${opt}" in
        h)
            usage
            exit 0
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
    err "Missing required arguments" 3
fi

PROJECT="${remaining_arguments[0]}"
WORKSPACE="${remaining_arguments[1]}"

main $WORKSPACE $PROJECT
