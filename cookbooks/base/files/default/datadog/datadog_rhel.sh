#!/bin/sh
###############################################################################
# datadog-agent
#
# Inspired by Boxed Ice <hello@boxedice.com>
# Forked by Datadog, Inc. <package@datadoghq.com>
#
# Licensed under Simplified BSD License (see LICENSE)
#
###############################################################################
#
# chkconfig: 345 85 15
# description: Datadog Monitoring Agent

### BEGIN INIT INFO
# Provides: datadog-agent
# Short-Description: Start and start datadog-agent
# Description: datadog-agent is the monitoring agent component for Datadog
# Required-Start:
# Required-Stop:
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
### END INIT INFO

AGENTPATH="/opt/datadog-agent/agent/agent.py"
AGENTCONF="/etc/dd-agent/datadog.conf"
DOGSTATSDPATH="/opt/datadog-agent/agent/dogstatsd.py"
AGENTUSER="dd-agent"
PIDPATH="/var/run/dd-agent/"
FORWARDERPATH="/usr/bin/dd-forwarder"
SUPERVISORD_PATH="PATH=/opt/datadog-agent/embedded/bin:/opt/datadog-agent/bin:$PATH /opt/datadog-agent/bin/supervisord"
SUPERVISORCTL_PATH="/opt/datadog-agent/bin/supervisorctl"
SUPERVISOR_CONF="/etc/dd-agent/supervisor.conf"
SUPERVISOR_SOCK="/var/tmp/datadog-supervisor.sock"

# Source function library.
. /etc/rc.d/init.d/functions

PROG="datadog-agent"
PIDFILE=$PIDPATH/$PROG.pid
SUPERVISOR_PIDFILE=/var/run/datadog-supervisord.pid
LOCKFILE=/var/lock/subsys/$PROG

check_status() {
    # run checks to determine if the service is running or use generic status

    # if the sock exists, we can use supervisorctl
    if [ -e $SUPERVISOR_SOCK ]; then

        s=`$SUPERVISORCTL_PATH -c $SUPERVISOR_CONF status`

        # number of RUNNING supervisord programs (ignoring dogstatsd and jmxfetch)
  p=`echo "$s" | grep -Ev 'dogstatsd|jmxfetch' | grep -c RUNNING`

        # number of expected running supervisord programs (ignoring dogstatsd and jmxfetch)
  c=`grep -Ev 'dogstatsd|jmxfetch' $SUPERVISOR_CONF | grep -c '\[program:'`
        if [ "$p" -ne "$c" ]; then
            echo "$s"
            echo -n "Datadog Agent (supervisor) is NOT running all child processes"; failure; echo
            return 1
        else
            echo -n "Datadog Agent (supervisor) is running all child processes"; success; echo
            return 0
        fi
    else

        # if no sock, use the rc status function
        status -p $SUPERVISOR_PIDFILE $PROG
        RETVAL=$?
        if [ $RETVAL -eq 0 ]; then
            echo -n "Datadog Agent (supervisor) is running."; success; echo
        else
            echo -n "Datadog Agent (supervisor) is NOT running."; failure; echo
        fi
        return $RETVAL
    fi

    if [ -f "$LOCKFILE" ]; then
        echo -n 'Datadog Agent is running'; success; echo
        return 0
    else
        echo -n 'Datadog Agent is NOT running'; failure; echo
        return 1
    fi
}

grab_status() {
    GRABSTATUS=`check_status &>/dev/null`
}

start() {
    if [ ! -f $AGENTCONF ]; then
        echo "$AGENTCONF not found. Exiting."
        exit 3
    fi

    su $AGENTUSER -c "$AGENTPATH configcheck" > /dev/null
    if [ $? -ne 0 ]; then
        echo -n $'\n'"Invalid check configuration. Please run sudo /etc/init.d/datadog-agent configtest for more details."
        echo -n $'\n'"Resuming starting process."$'\n'
    fi

    # no need to test for status before daemon,
    # the daemon function does the right thing
    echo -n "Starting Datadog Agent (using supervisord):"
    daemon --pidfile=$SUPERVISOR_PIDFILE $SUPERVISORD_PATH -c $SUPERVISOR_CONF > /dev/null
    # check if the agent is running once per second for 10 seconds
    retries=10
    while [ $retries -gt 1 ]; do
        if grab_status; then
            touch $LOCKFILE
            success; echo
            return 0
        else
            retries=$(($retries - 1))
            sleep 1
        fi
    done
    # after 10 tries the agent didn't start. Report the error and stop
    echo; check_status # check status will show us the error and take care of calling `failure`
    stop
    return 1
}

stop() {
    # no need to test for status before killproc,
    # it does the right thing. and testing supervisorctl status
    # before killproc can lead to states where you cannot stop!
    echo -n 'Stopping Datadog Agent (using killproc on supervisord): '
    killproc -p $SUPERVISOR_PIDFILE
    rm -f $LOCKFILE
    if [ $(ps aux |grep 'opt/datadog-agent' | grep -v service | grep -v 'init.d' | grep -v grep | wc -l) -eq 0 ];then
       echo "Application datadog stopped";else
       sleep 1
       echo "Force killing datadog-agent process"
       ps aux | grep 'opt/datadog-agent'| grep -v "init.d"| grep -v service |grep -v grep | awk '{print $2}' | xargs kill -SIGKILL
    fi
    echo
    return 0
}

restart() {
    stop
    start
}

info() {
    shift # Shift 'info' out of the args so we can pass any
          # additional options to the real command
          # (right now only dd-agent supports additional flags)
    su $AGENTUSER -c "$AGENTPATH info $@"
    COLLECTOR_RETURN=$?
    su $AGENTUSER -c "$DOGSTATSDPATH info"
    DOGSTATSD_RETURN=$?
    su $AGENTUSER -c "$FORWARDERPATH info"
    FORWARDER_RETURN=$?
    exit $(($FORWARDER_RETURN+$COLLECTOR_RETURN+DOGSTATSD_RETURN))
}

configcheck() {
    su $AGENTUSER -c "$AGENTPATH configcheck"
    exit $?
}


case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        restart
        ;;
    status)
        check_status
        ;;
    info)
        info "$@"
        ;;
    configcheck)
        configcheck
        ;;

    configtest)
        configcheck
        ;;

    jmx)
        shift
        su $AGENTUSER -c "$AGENTPATH jmx $@"
        exit $?
        ;;

    flare)
        shift
        $AGENTPATH flare $@
        exit $?
        ;;

    *)
        echo "Usage: $0 {start|stop|restart|info|status|configcheck|configtest|jmx}"
        exit 2
esac
exit $?
