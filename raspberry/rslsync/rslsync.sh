#!/bin/sh
# /etc/init.d/rslsync
#set -x
### BEGIN INIT INFO
# Provides: rslsync daemon
# Required-Start:       $remote_fs $syslog
# Required-Stop:        $remote_fs $syslog
# Default-Start:        2 3 4 5
# Default-Stop:         0 1 6
# Short-Description:    Resilio Sync server daemon
# Description:          This service is used to support the Resilio Sync.
# Placed in /etc/init.d/
### END INIT INFO
# Original Author: Nicolas Bernaerts <nicolas.bernaerts@laposte.net>
# Current Author: FOOLMAN <macrosea@gmail.com>
. /lib/lsb/init-functions

# description variables
PATH=/sbin:/usr/sbin:/bin:/usr/bin:/usr/local/sbin
DESC="Resilio Sync server"
DAEMON_NAME="rslsync"
DAEMON_USER="ubuntu"
DAEMON_PATH="/usr/local/sbin/${DAEMON_NAME}"
DAEMON_OPTS=""
DAEMON_DESC=$(get_lsb_header_val $0 "Short-Description")
DAEMON_PID="/home/${DAEMON_USER}/.sync/sync.pid"
#DAEMON_PID="/var/run/resilio/resilio_sh.pid"
DAEMON_LOG="/home/${DAEMON_USER}/.sync/sync.log"
# Exit if rslsync program is not installed
if [ ! -x "${DAEMON_PATH}" ] ; then
    echo "Binary ${DAEMON_PATH} does not exist. Aborting"
    exit 0
fi
# Exit if rslsync user home directory doesn't exist, is "pi" in this script.
if [ ! -d "/home/${DAEMON_USER}" ]; then
    echo "User /home/${DAEMON_USER} does not exist. Aborting"
    exit 0
fi

if [ ! -f /media/hdd-ST380011A/external.flag-file-no-move ]; then
   echo "Storage not found"
   exit 0
fi

# Function that starts the daemon/service
# 0 - daemon started
# 1 - daemon already running
# 2 - daemon could not be started
do_start() {
    local result
    pidofproc -p "${DAEMON_PID}" "${DAEMON_PATH}" > /dev/null
    if [ $? -eq 0 ]; then
        log_warning_msg "${DAEMON_NAME} is already started"
        result=0
    else
        log_daemon_msg "Starting ${DAEMON_DESC}" "${DAEMON_NAME}"
        touch "${DAEMON_LOG}"
        chown $DAEMON_USER "${DAEMON_LOG}"
        chmod u+rw "${DAEMON_LOG}"
        if [ -z "${DAEMON_USER}" ]; then
            start-stop-daemon --start --quiet \
                --exec "${DAEMON_PATH}" -- --config /etc/rslsync.conf
            result=$?
        else
            start-stop-daemon --start --quiet \
                --chuid "${DAEMON_USER}" \
                --exec "${DAEMON_PATH}" -- --config /etc/rslsync.conf
            result=$?
        fi
        log_end_msg $result
    fi
    return $result
}
# Function that stops the daemon/service
# 0 - daemon stopped
# 1 - daemon already stopped
# 2 - daemon could not be stopped
do_stop() {
    # Stop the daemon
    local result
    pidofproc -p "${DAEMON_PID}" "${DAEMON_PATH}" > /dev/null
    if [ $? -ne 0 ]; then
        log_warning_msg "${DAEMON_NAME} is not started"
        result=0
    else
        log_daemon_msg "Stopping ${DAEMON_DESC}" "${DAEMON_NAME}"
        killproc -p "${DAEMON_PID}" "${DAEMON_PATH}"
        result=$?
        log_end_msg $result
        # remove pid file
        rm -f "${DAEMON_PID}"
    fi
    return $result
}
do_restart() {
    local result
    do_stop
    result=$?
    if [ $result -eq 0 ]; then
        do_start
        result=$?
    fi
    return $result
}
do_status() {
    local result
    status_of_proc -p "${DAEMON_PID}" "${DAEMON_PATH}" "${DAEMON_NAME}"
    result=$?
    return $result
}
do_usage() {
    echo $"Usage: $0 {start | stop | restart | status}"
    exit 1
}
# deal with different parameters : start, stop & status
case "$1" in
    start)   do_start;   exit $? ;;
    stop)    do_stop;    exit $? ;;
    restart) do_restart; exit $? ;;
    status)  do_status;  exit $? ;;
    *)       do_usage;   exit  1 ;;
esac
