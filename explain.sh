# explain.sh register an explain function
explain () {
    local BLUE="[0;34m"
    local RED="[0;31m"
    local LIGHT_RED="[1;31m"
    local LIGHT_GRAY="[0;37m"
    local LIGHT_GREEN="[1;32m"
    local LIGHT_BLUE="[1;34m"
    local MAGENTA="[1;35m"
    local LIGHT_CYAN="[1;36m"
    local YELLOW="[1;33m"
    local WHITE="[1;37m"
    local NO_COLOUR="[0m"

   if [[ "$#" -gt 0 ]]; then
      cmd="$@"
      curl -Gs "https://explainshell.com/explain?cmd=$cmd" \
      | grep -A20 "help-box" | grep -B20 '</pre>' | grep -v -e 't[dr]>' | tr -d '\t' | sed -e "s,^\ \+,,gm" -e "s,<pre[^>]*>\(.*\)\$,${WHITE}\1${LIGHT_GREEN},gm" -e "s,</pre>,${NO_COLOUR},gm" -e "s, <u>\([^<]*\)</u>,${YELLOW}\ \1${LIGHT_GREEN},gm" -e "s,<b>\([^<]*\)</b>,${LIGHT_CYAN}\1${LIGHT_GREEN},gm" -e "s,<u>\([^<]*\)</u>,${LIGHT_BLUE}\1${LIGHT_GREEN},gm"
      echo "${NO_COLOUR}"
   else
      echo "Usage:"
      echo "explain curl -Ls"
      return
   fi
}

echo "run once: . ./explain.sh"
echo "then you can use: explain curl -Ls"
echo "or run register the funtion on your shell start up file"


