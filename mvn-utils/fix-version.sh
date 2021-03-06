#!/usr/bin/env bash

usage() {
    echo "Fix maven version based on the currenc branch name. Always add SNAPSHOT at the end."
    echo "Usage:"
    echo "   fix-version"
    echo "   fix-version --help shows this message"
}

if [[ $1 == '--help' ]]; then
    usage
    exit 0
fi

current=$(git rev-parse --abbrev-ref HEAD)

if [[ $current -eq "" ]]; then
    echo "invalid git repository"
    exit 1
else
    setpomversion "${current}-SNAPSHOT"
    exit 0
fi
