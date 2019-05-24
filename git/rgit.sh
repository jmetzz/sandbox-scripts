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
    echo "$0 -[huvcp] <project: default ya1> <workspace>"
    echo "       -h           : shows this message. Ignores any other arguments."
    echo "       -c  [branch] : checkout a given branch"
    echo "       -u           : fetch & pull the repositories named with the given project"
    echo "       -v           : verbose mode"
    echo "       -p           : also prune when fetching. Only applies if '-u' is also selected, ignored otherwise."
    echo
    echo "Examples:"
    echo "   # Update master branch on lmo components "
    echo "   $rgit.sh -uvc master lmo /Users/jean/kbc/LMO"
    echo
    echo "   # Update develop branch for lmo components"
    echo "   $rgit.sh -u lmo /Users/jean/kbc/LMO"
    echo 
    echo "   # Update develop branch for lmo components and prune branches"
    echo "   $rgit.sh -up lmo /Users/jean/kbc/LMO"
}

function err (){
    local msg=$1
    echo "[ERROR] - ${msg}"
    usage
    exit $2
}


banner() {
    msg="| $* |"
    edge=$(echo "$msg" | sed 's/./~/g')
    echo "$edge"
    echo "$msg"
    echo "$edge"
}


function cloneRepository {
    local repository="$1"
    local artifacts_dir="$2"
    cd $artifacts_dir

    if [ ! -d "./$repository" ]; then
        git clone "${GIT_REMOTE}/${PROJECT}/${repository}.git"
    fi
    echo
    echo
}


function cleanup {
    base_dir="$1"
    cd $base_dir
    jars=$(find ./ -type f -maxdepth 1 | grep -E ".*\.[a-zA-Z0-9]*$" | sed -e 's/.*\(\.[a-zA-Z0-9]*\)$/\1/' | sort | uniq -c | grep .jar)
    if [[ ! -z "$jars" ]]; then
        rm *.jar
    fi
    rm -rf "${base_dir}/artifacts"
    rm -rf "${base_dir}/emperor"
    rm -rf "${base_dir}/aicore"
}


function main(){
    # $WORKSPACE $PROJECT $BRANCH $CHECKOUT $UPDATE
    base_dir="$1"
    project="$2"
    branch="$3"
    checkout="$4"
    update="$5"

    banner "Starting checkout/update branch '$branch' for all '$project' repos" 
    current_dir=$(pwd)

    cd $base_dir
    repos=$(ls -d */ | tr "\n" " " )
    IFS='/ ' read -r -a array <<< "$repos"

    for repo in "${array[@]}"
    do
        if [[ $repo =~ ^"$project".* ]] ; then
            cd $base_dir/$repo
            echo "### Repository ${repo}"

            # In clean repository?
            dirty=$(git status -s)
            [[ ! -z "${is_clean}" ]] && echo "\t Repository ${repo} is dirty --> Make sure it is pristine before update" && echo && continue

            git fetch $PRUNE -q origin 2>/dev/null
            # check if branch exist
            if [[ $checkout == 1 ]]; then
                remote=$(git show-ref refs/remotes/origin/${branch} 2>/dev/null)

                [[ -z ${remote} ]] && \
                    echo "\t Remote branch '${branch}' does not exist for repo '${repo}'" && \
                    echo "----------------------------------------------" && \
                    continue

                echo "\tCheckout branch '${branch}' for repository '${repo}'"
                git checkout $branch
                echo
            fi

            if [[ $update == 1 ]]; then
                echo "\tUpdating repository '${repo}'"

                # Git has some neat shorthands for referring to branches and commits
                # (as documented in git rev-parse --help). In particular,
                # you can use @ for the current branch (assuming you're not in a
                # detached-head state) and @{u} for its upstream branch
                # (eg origin/master). So git merge-base @ @{u} will return the
                # (hash of) the commit at which the current branch and its
                # upstream diverge and git rev-parse @ and git rev-parse @{u}
                # will give you the hashes of the two tips.
                # https://stackoverflow.com/questions/3258243/check-if-pull-needed-in-git#3278427


                LOCAL_HEAD=$(git rev-parse @)
                REMOTE_HEAD=$(git rev-parse @{u})
                BASE=$(git merge-base @ @{u})
                if [ $VERBOSE = 1 ]; then
                    echo "\tlocal head hash '$LOCAL_HEAD'"
                    echo "\tremote head hash '$REMOTE_HEAD'"
                    echo "\tLast common commit hash is '$BASE'"
                    echo
                fi

                if [ $LOCAL_HEAD = $REMOTE_HEAD ]; then
                    [ $VERBOSE = 1 ] && echo "\tAlready up to date"
                elif [ $LOCAL_HEAD = $BASE ]; then
                    [ $VERBOSE = 1 ] && echo "Local repository behind remote: pulling..."
                    git pull
                elif [ $REMOTE_HEAD = $BASE ]; then
                    echo "\tLocal repository is ahead of the remote. You need to push your changes."
                else
                    echo "\tLocal and remote repositories diverged."
                fi

                echo
            fi
            echo "----------------------------------------------"
        elif [[ $VERBOSE == 1 ]]; then
            echo "\t ### Repository ${repo}"
            echo "\t ${repo} is not a '$project' repository"
            echo "\t skipping ..."
            echo "----------------------------------------------"
        fi

    done
    cd $base_dir
}


function ask_YN_confirmation(){
    msg="$1"
    read -p $msg option
    option="$(echo "${option}" | tr -d '[:space:]' | tr '[:lower:]' '[:upper:]')"
    return $option

    # [[ "${option}" != "Y" ]] && echo "Exiting ..." && exit 0
    # if [[ "${option}" != "Y" ]]; then
    #     result=1
    # else
    #     result=0
    # fi
    # return $result
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
        c)
            BRANCH="${OPTARG}"
            CHECKOUT=1
            ;;
        u)
            UPDATE=1
            ;;
        v)
            VERBOSE=1
            ;;
        h)
            usage
            exit 0
            ;;
        p)
            PRUNNE="-p"
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


PROJECT="${remaining_arguments[0]}"
WORKSPACE="${remaining_arguments[1]}"

main $WORKSPACE $PROJECT $BRANCH $CHECKOUT $UPDATE
