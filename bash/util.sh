#!/usr/bin/env bash


## Print helpers

# test for color support, inspired by:
# http://unix.stackexchange.com/questions/9957/how-to-check-if-bash-can-print-colors
if [ -t 1 ]; then
    ncolors=$(tput colors)
    if test -n "$ncolors" && test $ncolors -ge 8; then
        bold="$(tput bold)"
        normal="$(tput sgr0)"
        red="$(tput setaf 1)"
        redbg="$(tput setab 1)"
        green="$(tput setaf 2)"
        greenbg="$(tput setab 2)"
    fi
fi


_print_success() {
    TEXT="$1"
    echo "    [ ${green}${bold}OK${normal} ] $TEXT"
}

_print_failure() {
    TEXT="$1"
    echo "    [${red}${bold}FAIL${normal}] $TEXT"
}

_print_report_failure() {
    TEXT="$1"
    echo -e "${redbg}$TEXT${normal}"
}
_print_report_success() {
    TEXT="$1"
    echo -e "${greenbg}$TEXT${normal}"
}

_print_url() {
    TEXT="$1"
    echo "> $TEXT"
}

# Assertion helpers
_success() {
    REASON="$1"
    _print_success "$REASON"
    (( SMOKE_TESTS_RUN++ ))
}


_fail() {
    REASON="$1"
    (( SMOKE_TESTS_FAILED++ ))
    (( SMOKE_TESTS_RUN++ ))
    _smoke_print_failure "$REASON"
}


assert_bash_ok() {
  if [[ $1 -eq 0 ]]; then
    _success "Bash return ok"
  else
    _fail "Bash return error"
  fi
}

assert_equal() {
  if [ "$1" = "$2" ]; then
    _success "$1 = $2"
  else
    _fail "$1 != $2"
  fi
}

title() {
  echo ""
  message "${bold}$1${normal}"
  echo ""
}

message() {
  TEXT="$1"
  echo "$TEXT"
}
