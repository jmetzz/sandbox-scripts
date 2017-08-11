#!/bin/bash

usage() {
	echo "Usage:"
	echo "   delta.sh branch-a branch-b"
}

if [[ $1 == '--help' ]]; then
	echo "Shows the delta between two given branches for the current repository"
	usage
	exit 0
fi

if [[ $# != 2 ]]; then
	echo "Wrong number of parameters given"
	usage
	exit 1
fi


srcpcr=$1
destpcr=$2
repo=$(basename `git rev-parse --show-toplevel`)

BLUE="[0;34m"
MAGENTA="[0;35m"
RED="[0;31m"
LIGHT_RED="[1;31m"
LIGHT_GRAY="[0;37m"
LIGHT_GREEN="[1;32m"
LIGHT_BLUE="[1;34m"
LIGHT_CYAN="[1;36m"
YELLOW="[1;33m"
WHITE="[1;37m"
NO_COLOUR="[0m"


echo "${WHITE}*** Showing delta between branches ${srcpcr} and ${destpcr}${NO_COLOUR}"


git fetch -q

git show-ref "refs/remotes/origin/${destpcr}" 2>/dev/null | grep -q -v '^$'

current_branch=$(git branch | grep -e ^\* | cut -d ' ' -f 2)
cur_branch_ok=1


# For paths with merge conflicts, X and Y show the modification states
# of each side of the merge. For paths that do not have merge conflicts,
# X shows the status of the index, and Y shows the status of the work tree. 
# For untracked paths, XY are ??.
conflicts=$(git status -s |  grep -e ^[DAMUR][DAMUR] | wc -l | tr -d ' ')
if [[ "${conflicts}" != "0" ]]; then
 echo "${RED}[ERROR] Current branch ${current_branch} has ${conflicts} CONFLICTS!${NO_COLOUR}"
 cur_branch_ok=0
fi

uncommittedchanges=$(git status -s |  grep -e ^[DAMUR]\  | wc -l | tr -d ' ')	
if [[ "${uncommittedchanges}" != "0" ]]; then
 echo "${RED}[ERROR] Current branch ${LIGHT_RED}${current_branch}${RED} has ${LIGHT_RED}${uncommittedchanges} Uncommitted changes!${NO_COLOUR}"
 cur_branch_ok=0
fi

newfiles=$(git status -s |  grep -e ^\?\? | wc -l | tr -d ' ')
if [[ "${newfiles}" != "0" ]]; then
  echo "${RED}[ERROR] Current branch ${LIGHT_RED}${current_branch}${RED} has ${LIGHT_RED}${newfiles} Unstaged files!${NO_COLOUR}"
  cur_branch_ok=0
fi


if [[ "${cur_branch_ok}" == 0 ]]; then
  echo "${YELLOW}[WARNING] Not able to check delta due to errors in the current branch : ${WHITE}${current_branch}.${NO_COLOUR}"
  exit 1
fi


echo "${LIGHT_GREEN}[INFO]${NO_COLOUR} Checking out repository ${WHITE}${repo}${NO_COLOUR} : branch ${WHITE}${destpcr}${NO_COLOUR}"
git checkout ${destpcr} 2>/dev/null >/dev/null
      

behind=$(git status | head -n2 | grep 'Your branch is behind' | sed s/\ by\ /,/gm | cut -d ',' -f 2 | sed -e 's,\([0-9]*\)\ commits\?,-\1,gm')
git status | head -n 3 | grep -q 'different commits\? each, respectively' && behind=$(git status | head -n 3 | grep 'different commits\? each, respectively' | sed -e 's,\ have\ ,\@,gm' -e 's,\ and\ ,\@,gm' -e 's,\ different\ ,\@,gm' | cut -d '@' -f 3)
ahead=$(git status | head -n2 | grep 'Your branch is ahead' | sed s/\ by\ /,/gm | cut -d ',' -f 2 | sed -e 's,\([0-9]*\)\ commits\?\.,+\1,gm')
git status | head -n 3 | grep -q 'different commits\? each, respectively' && ahead=$(git status | head -n 3 | grep 'different commits\? each, respectively' | sed -e 's,\ have\ ,\@,gm' -e 's,\ and\ ,\@,gm' -e 's,\ different\ ,\@,gm' | cut -d '@' -f 2)
if [[ "${ahead}" != "" ]]; then
 echo "${YELLOW}[WARNING] Branch ${LIGHT_RED}${destpcr}${YELLOW} has ${LIGHT_RED}${ahead}${YELLOW} unpushed commits!${NO_COLOUR}"
fi


if [[ "${repo}" == "ohm" || "${repo}" == "job-initiator" || "${repo}" == "automatic-booker" || "${repo}" == "automatic-booker-profil" ]]; then
     deltafrombranch=$(set -o pipefail; git branch -a | grep -e "^.\ remotes/origin/${srcpcr}$" | sed -e 's,.*/\([^/]*\)$,\1,gm' | sed s,^rav\-,ohm-,gm)
else
     deltafrombranch=$(set -o pipefail; git branch -a | grep -e "^.\ remotes/origin/${srcpcr}$" | sed -e 's,.*/\([^/]*\)$,\1,gm' | sed s,^ohm\-,rav-,gm)
fi
      
if [[ "$?" == "0" ]]; then

	localdelta=$(git diff origin/${destpcr} $destpcr | wc -l | tr -d ' ')

	if [[ "${localdelta}" != "0" ]]; then
		linesremoved=$(git merge-tree $(git merge-base origin/${deltafrombranch} ${destpcr}) ${destpcr} origin/${deltafrombranch} 2>&1 | grep -v '<version>' | grep -e "^-\s" | wc -l | tr -d ' ')
		linesadded=$(git merge-tree $(git merge-base origin/${deltafrombranch} ${destpcr}) ${destpcr} origin/${deltafrombranch} 2>&1 | grep -v '<version>' | grep -e "^+\s" | wc -l | tr -d ' ')
		files=$(git merge-tree $(git merge-base origin/${deltafrombranch} ${destpcr}) ${destpcr} origin/${deltafrombranch} 2>&1 | grep "^\ *\(our\|result\)\ \ *[0-9][0-9]*\ \ *[a-z0-9][a-z0-9]*\ \(.*\)" | sed  "s~^\ *\(our\|result\)\ \ *[0-9][0-9]*\ \ *[a-z0-9][a-z0-9]*\ \(.*\)~\2~gm" | sort -u | wc -l | tr -d ' ')	
		commits=$(git rev-list --count ${destpcr}..origin/${deltafrombranch} 2>&1)


		if [[ "${commits}" == "0" ]]; then
		      echo -n "${LIGHT_GREEN}[INFO]${NO_COLOUR} Merge for repository ${WHITE}${repo}${NO_COLOUR} not needed from origin/${WHITE}${deltafrombranch}${NO_COLOUR} into local branch ${WHITE}${destpcr}${NO_COLOUR}"
		else
		   if [[ ${linesremoved} == 0 && ${linesadded} == 0 ]]; then
		      echo -n "${YELLOW}[WARNING] Merge for repository ${MAGENTA}${repo}${YELLOW} needed from origin/${LIGHT_RED}${deltafrombranch}${YELLOW} into local branch ${LIGHT_RED}${destpcr}${YELLOW} because"
		      echo -n ${commits} | sed -e "s~^\([0-9][0-9]*\)\$~\ ${LIGHT_RED}\1${YELLOW}\ commits\ changed~gm"
		      echo -n ${files} | sed -e "s~^\([0-9][0-9]*\)\$~\ ${LIGHT_RED}\1${YELLOW}\ files,\ but\ containing\ only\ \<version\>\ changes~gm"
		   else
		      echo -n "${RED}[WARNING] Merge for repository ${MAGENTA}${repo}${RED} needed from origin/${LIGHT_RED}${deltafrombranch}${RED} into local branch ${LIGHT_RED}${destpcr}${RED} because"
		      echo -n ${commits} | sed -e "s~^\([0-9][0-9]*\)\$~\ ${LIGHT_RED}\1${RED}\ commits\ changed~gm"
		      echo -n ${files} | sed -e "s~^\([0-9][0-9]*\)\$~\ ${LIGHT_RED}\1${RED}\ files~gm"
		      echo -n ${linesremoved} | sed -e "s,^0$,,gm" -e "s~^\([0-9][0-9]*\)\$~,\ removing ${LIGHT_RED}\1${RED}\ lines${SANE}~gm"
		      echo -n ${linesadded} | sed -e "s,^0$,,gm" -e "s~^\([0-9][0-9]*\)\$~,\ adding ${LIGHT_RED}\1${RED}\ lines~gm"
		   fi
		fi
		echo ${NO_COLOUR}
	fi

	linesremoved=$(git merge-tree $(git merge-base origin/${deltafrombranch} origin/${destpcr}) origin/${destpcr} origin/${deltafrombranch} 2>&1 | grep -v '<version>' | grep -e "^-\s" | wc -l | tr -d ' ')
	linesadded=$(git merge-tree $(git merge-base origin/${deltafrombranch} origin/${destpcr}) origin/${destpcr} origin/${deltafrombranch} 2>&1 | grep -v '<version>' | grep -e "^+\s" | wc -l | tr -d ' ')
	files=$(git merge-tree $(git merge-base origin/${deltafrombranch} origin/${destpcr}) origin/${destpcr} origin/${deltafrombranch} 2>&1 | grep "^\ *\(our\|result\)\ \ *[0-9][0-9]*\ \ *[a-z0-9][a-z0-9]*\ \(.*\)" | sed  "s~^\ *\(our\|result\)\ \ *[0-9][0-9]*\ \ *[a-z0-9][a-z0-9]*\ \(.*\)~\2~gm" | sort -u | wc -l | tr -d ' ')
	commits=$(git rev-list --count origin/${destpcr}..origin/${deltafrombranch} 2>&1)
	if [[ "${commits}" == "0" ]]; then
		echo -n "${LIGHT_GREEN}[INFO]${NO_COLOUR} Merge for repository ${WHITE}${repo}${NO_COLOUR} not needed from origin/${WHITE}${deltafrombranch}${NO_COLOUR} into origin/${WHITE}${destpcr}${NO_COLOUR}"
	else
		if [[ ${linesremoved} == 0 && ${linesadded} == 0 ]]; then
		   echo -n "${YELLOW}[WARNING] Merge for repository ${MAGENTA}${repo}${YELLOW} needed from origin/${LIGHT_RED}${deltafrombranch}${YELLOW} into origin/${LIGHT_RED}${destpcr}${YELLOW} because"
		   echo -n ${commits} | sed -e "s~^\([0-9][0-9]*\)\$~\ ${LIGHT_RED}\1${YELLOW}\ commits\ changed~gm"
		   echo -n ${files} | sed -e "s~^\([0-9][0-9]*\)\$~\ ${LIGHT_RED}\1${YELLOW}\ files,\ but\ containing\ only\ \<version\>\ changes~gm"
		else
		   echo -n "${RED}[WARNING] Merge for repository ${MAGENTA}${repo}${RED} needed from origin/${LIGHT_RED}${deltafrombranch}${RED} into origin/${LIGHT_RED}${destpcr}${RED} because"
		   echo -n ${commits} | sed -e "s~^\([0-9][0-9]*\)\$~\ ${LIGHT_RED}\1${RED}\ commits\ changed~gm"
		   echo -n ${files} | sed -e "s~^\([0-9][0-9]*\)\$~\ ${LIGHT_RED}\1${RED}\ files~gm"
		   echo -n ${linesremoved} | sed -e "s,^0$,,gm" -e "s~^\([0-9][0-9]*\)\$~,\ removing ${LIGHT_RED}\1${RED}\ lines${SANE}~gm"
		   echo -n ${linesadded} | sed -e "s,^0$,,gm" -e "s~^\([0-9][0-9]*\)\$~,\ adding ${LIGHT_RED}\1${RED}\ lines~gm"
		fi
	fi
	echo ${NO_COLOUR}
else
	echo "${YELLOW}[WARNING] Skipping the repository ${WHITE}${repo}${YELLOW} because the branch ${WHITE}${srcpcr} does not exist.${NO_COLOUR}"      
fi








