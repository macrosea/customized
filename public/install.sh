#!/usr/bin/env bash
#set -x
#set -o pipefail
set -e
d_cur=$(cd "$(dirname $0)"; pwd)
source $d_cur/func.sh

find "$d_cur" -name "bash_*" |awk '{print "test -f ", $1, " && source", $1}' >> ${HOME}/.bash_profile

read -p "screen or tmux? : " sel
case "$sel" in
    "tmux"   )  
    env_app=tmux
    ;;
    "screen" )  env_app=screen;;
    * )         env_pp="screen";  echo "screen will be used" ;;
esac
insapp $env_app
find "$d_cur" -name "$env_app.rc" |awk '{print "test -f ", $1, " && source", $1}'>> ${HOME}/.bash_profile

link_apps $d_cur

##====EOF=======
