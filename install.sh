#!/usr/bin/env bash
#set -x
#set -o pipefail
set -e
export d_cur=$(cd "$(dirname $0)"; pwd)
source $d_cur/public/func.sh
os=$(uname -s)

argc=$#
[ $argc -eq 1 ] || throw 1 "bad arguments"
[ -d "$d_cur/$1" ] || throw 1 "bad arguments"

echo "# customized " >> ${HOME}/.bash_profile
find "$d_cur/public" -name "bash_*" |awk '{print "test -f ", $1, " && source", $1}' >> ${HOME}/.bash_profile
find "$d_cur/$1" -name "bash_*"     |awk '{print "test -f ", $1, " && source", $1}'>> ${HOME}/.bash_profile

echo "prepare to install some app from repository"
apps=("vim"
       "git" )
for var in ${apps[@]};do
    echo $var
    insapp $var
done

read -p "screen or tmux? : " sel
case "$sel" in
    "tmux"   )  
    env_app=tmux
    ;;
    "screen" )  env_app=screen;;
    * )         env_pp="screen";  echo "screen will be used" ;;
esac
insapp $env_app
find "$d_cur/public" -name "$env_app.rc" |awk '{print "test -f ", $1, " && source", $1}'>> ${HOME}/.bash_profile

export D_PRIV="$d_cur/$1"
export D_PUB=$d_cur/public
mkdir -p ~/.Trash

link_apps $D_PRIV
link_apps $D_PUB

##====EOF=======
