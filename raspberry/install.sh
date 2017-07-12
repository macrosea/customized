#!/usr/bin/env bash
#set -x
#set -o pipefail
set -e
d_cur=$(cd "$(dirname $0)"; pwd)
find "$d_cur" -name "bash_*"     |awk '{print "test -f ", $1, " && source", $1}'>> ${HOME}/.bash_profile

d_sbin="/usr/local/sbin"
