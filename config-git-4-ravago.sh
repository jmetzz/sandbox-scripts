#!/bin/bash


if [[ -z ${REPOROOT} ]]
then
    echo "REPOROOT not set"
    exit 1
fi

if [[ -z ${RAVAGO_FULL_NAME} ]]
then
    full_name="Jean Metz"
else
    full_name=${RAVAGO_FULL_NAME}
fi

if [[ -z ${RAVAGO_EMAIL} ]]
then
    email="jean.metz@ravago.com"
else
    email=${RAVAGO_EMAIL}
fi


cd ${REPOROOT}

for i in ./* ; do
  if [ -d "$i" ]; then
    cd $i

    if [[ ! -d ".git" ]]; then
        cd ..      
        continue
    fi

    echo $i

    git config user.name $full_name
    git config user.email $email 
    git config core.autocrlf input
    git config core.filemode false
    git config core.symlinks true
    
    echo $(git config --local -l | grep user.email )
    cd ..
  fi
done




