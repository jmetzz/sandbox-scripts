#!/usr/bin/env bash

repo=$(basename `git rev-parse --show-toplevel`)
echo $repo
