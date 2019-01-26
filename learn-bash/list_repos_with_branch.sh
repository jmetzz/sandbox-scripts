#!/bin/bash

if [[ $# != 1 ]]; then
    echo "Usage: list_repos_with_branch.sh pcr1657_merge_11.4"
    exit 1
fi


branch="$1"

YELLOW="^[[1;33m"
LIGHT_GREEN="^[[1;32m"


for repo in $(cat $REPOROOT/ravapps/repo_list.txt); do
    cd $REPOROOT/$repo 2>/dev/null
    if [[ $? -ne 0 ]]; then
        echo "${YELLOW}[WARNING] Repository ${repo} is NOT cloned!${NO_COLOUR}";
        continue
    fi
    
    git fetch -q

    branchPresent=$(git branch -a | grep "remotes/origin/${branch}" | wc -l)
    if [[ branchPresent -eq 1 ]]; then
        echo "${LIGHT_GREEN} $repo"
    fi
done
