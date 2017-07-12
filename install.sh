#!/usr/bin/env bash
#set -x
#set -o pipefail
set +e
os=$(uname -s)
source $d_cur/public/func.sh

echo "prepare to install some app from repository"
apps=("vim"
       "git" )
for var in ${apps[@]};do
    echo $var
    insapp $var
done

echo "install bash profile"
export d_cur=$(cd "$(dirname $0)"; pwd)
if [ "$os" == "Darwin" ]
then
    subdir="mac"
elif [ "$os" == "Linux" ]
then
    subdir="ubuntu"
fi

export D_PRIV="$d_cur/$subdir"
export D_PUB=$d_cur/public
mkdir -p ~/.Trash

handle_bashrc
handle_alias
handle_profile
link_apps $D_PRIV
link_apps $D_PUB

##====EOF=======
