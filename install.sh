#!/usr/bin/env bash
#set -x
#set -o pipefail
set -e
d_cur=$(cd "$(dirname $0)"; pwd)
source $d_cur/public/func.sh
os=$(uname -s)
echo $os

argc=$#
[ $argc -eq 1 ] || throw 1 "bad arguments"
[ -d "$d_cur/$1" ] || throw 1 "bad arguments"

echo "# customized " >> ${HOME}/.bash_profile

echo "prepare to install some app from repository"
sudo apt-get update

apps=("vim"
       "git" )
for var in ${apps[@]};do
    echo $var
    insapp $var
done

bash $d_cur/public/install.sh
bash $d_cur/$1/install.sh

##====EOF=======
