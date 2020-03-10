#!/usr/bin/env sh
#set -x
#set -o pipefail
set -e
d_cur=$(cd "$(dirname $0)"; pwd)
find "$d_cur" -name "zsh_*" |awk '{print "test -f ", $1, " && source", $1}'>> ${d_cur}/profile

echo "#" >> ${HOME}/.zshrc
echo "# add a customized zsh profile" >> ${HOME}/.zshrc
echo "source ${d_cur}/profile" >> ${HOME}/.zshrc