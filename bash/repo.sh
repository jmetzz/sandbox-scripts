#!/bin/bash

repo=$(basename `git rev-parse --show-toplevel`)
echo $repo
