
#!/usr/bin/env bash
#set -x
#set -o pipefail
set -e
d_cur=$(cd "$(dirname $0)"; pwd)
find "$d_cur" -name "bash_*"     |awk '{print "test -f ", $1, " && source", $1}'>> ${HOME}/.bash_profile

d_sbin="/usr/local/sbin"
#udev
fn_rule="90-usbstorage.rules"
d_rules="/etc/udev/rules.d"
[ -f "$d_rules/$fn_rule" ] && rm "$d_rules/$fn_rule"
cp -f $d_cur/udev/$fn_rule "$d_rules/$fn_rule"

fn_exec="udev4usb-storager"
[ -L "$d_sbin/$fn_exec" ] && rm "$d_sbin/$fn_exec"
ln -s $d_cur/udev/$fn_exec "$d_sbin/$fn_exec"
[ -f "$d_rules/$fn_rule" ] && [ -L "$d_sbin/$fn_exec" ] && echo "Done ^_^"

