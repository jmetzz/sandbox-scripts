#!/bin/bash

# Allow overriding the date function for unit testing.
function my_date() {
  date "$@"
}

# Simple wrapper around "echo" so that it's easy to add log messages with a
# date/time prefix.
function loginfo() {
  echo "$(my_date): ${@}"
}

# Simple wrapper around "echo" controllable with ${VERBOSE_MODE}.
function logdebug() {
  if (( ${VERBOSE_MODE} )); then
    loginfo ${@}
  fi
}

# Simple wrapper to pass errors to stderr.
function logerror() {
  loginfo ${@} >&2
}

function prompt() {
  local msg="$1"
  read -p "${msg}" PROMPT_RESPONSE
}


prompt "Type something: "
echo $PROMPT_RESPONSE