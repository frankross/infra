#!/bin/sh

### BEGIN INIT INFO
# Provides: dd-agent
# Short-Description: Start and stop dd-agent
# Description: dd-agent is the monitoring Agent component for Datadog
# Required-Start: $remote_fs
# Required-Stop: $remote_fs
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
### END INIT INFO

. /lib/lsb/init-functions
PATH=$PATH:/sbin # add the location of start-stop-daemon on Debian

AGENTPATH="/usr/bin/dd-agent"
AGENTCONF="/etc/dd-agent/datadog.conf"
DOGSTATSDPATH="/usr/bin/dogstatsd"
AGENTUSER="dd-agent"
FORWARDERPATH="/usr/bin/dd-forwarder"
NAME="datadog-agent"
DESC="Datadog Agent"
SUPERVISOR_PIDFILE="/var/run/datadog-supervisord.pid"
SUPERVISOR_FILE="/etc/dd-agent/supervisor.conf"
SUPERVISOR_SOCK="/var/tmp/datadog-supervisor.sock"
SUPERVISORCTL_PATH="/opt/datadog-agent/bin/supervisorctl"
SUPERVISORD_PATH="/opt/datadog-agent/bin/supervisord"
SYSTEM_PATH=/opt/datadog-agent/embedded/bin:/opt/datadog-agent/bin:$PATH

if [ ! -x $AGENTPATH ]; then
    echo "$AGENTPATH not found. Exiting."
    exit 0
fi

check_status() {
    # If the socket exists, we can use supervisorctl
    if [ -e $SUPERVISOR_SOCK ]; then
        # If we're using supervisor, check the number of datadog processes
        # supervisor is currently controlling, and make sure that it's the
        # same as the number of programs specified in the supervisor config
        # file:

        supervisor_processes=$($SUPERVISORCTL_PATH -c $SUPERVISOR_FILE status)

        # Number of RUNNING supervisord programs (ignoring dogstatsd and jmxfetch)
        datadog_supervisor_processes=$(echo "$supervisor_processes" |
                                       grep -Ev 'dogstatsd|jmxfetch' |
                                       grep $NAME |
                                       grep -c RUNNING)

        # Number of expected running supervisord programs (ignoring dogstatsd and jmxfetch)
        supervisor_config_programs=$(grep -Ev 'dogstatsd|jmxfetch' $SUPERVISOR_FILE |
                                     grep -c '\[program:')

        if [ "$datadog_supervisor_processes" -ne "$supervisor_config_programs" ]; then
            echo "$supervisor_processes"
            echo "$DESC (supervisor) is NOT running all child processes"
            return 1
        else
            echo "$DESC (supervisor) is running all child processes"
            return 0
        fi
    else
        echo "$DESC (supervisor) is not running"
        return 1
    fi
}

# Action to take
case "$1" in
    start)
        if [ ! -f $AGENTCONF ]; then
            echo "$AGENTCONF not found. Exiting."
            exit 3
        fi

        check_status > /dev/null
        if [ $? -eq 0 ]; then
            echo "$DESC is already running"
            exit 0
        fi

        su $AGENTUSER -c "$AGENTPATH configcheck" > /dev/null
        if [ $? -ne 0 ]; then
            log_daemon_msg "Invalid check configuration. Please run sudo /etc/init.d/datadog-agent configtest for more details."
            log_daemon_msg "Resuming starting process."
        fi


        log_daemon_msg "Starting $DESC (using supervisord)" "$NAME"
        PATH=$SYSTEM_PATH start-stop-daemon --start --quiet --oknodo --exec $SUPERVISORD_PATH -- -c $SUPERVISOR_FILE --pidfile $SUPERVISOR_PIDFILE
        if [ $? -ne 0 ]; then
            log_end_msg 1
        fi

        # check if the agent is running once per second for 10 seconds
        retries=10
        while [ $retries -gt 1 ]; do
          if check_status > /dev/null; then
              # We've started up successfully. Exit cleanly
              log_end_msg 0
              exit 0
          else
              retries=$(($retries - 1))
              sleep 1
          fi
        done
        # After 10 tries the agent didn't start. Report an error
        log_end_msg 1
        check_status # report what went wrong
        $0 stop
        exit 1
        ;;
    stop)

        log_daemon_msg "Stopping $DESC (stopping supervisord)" "$NAME"
        start-stop-daemon --stop --retry 30 --quiet --oknodo --pidfile $SUPERVISOR_PIDFILE

        log_end_msg $?
        if [ $(ps aux |grep 'opt/datadog-agent' | grep -v service | grep -v 'init.d' | grep -v grep | wc -l) -eq 0 ];then
           echo "Application datadog stopped";else
           sleep 1
           echo "Force killing datadog-agent process"
           ps aux | grep 'opt/datadog-agent'|grep -v "init.d"| grep -v service |grep -v grep | awk '{print $2}' | xargs kill -SIGKILL
        fi

        ;;

    info)
        shift # Shift 'info' out of args so we can pass any
              # addtional options to the real command
              # (right now only dd-agent supports additional flags)
        su $AGENTUSER -c "$AGENTPATH info $@"
        COLLECTOR_RETURN=$?
        su $AGENTUSER -c "$DOGSTATSDPATH info"
        DOGSTATSD_RETURN=$?
        su $AGENTUSER -c "$FORWARDERPATH info"
        FORWARDER_RETURN=$?
        exit $(($COLLECTOR_RETURN+$DOGSTATSD_RETURN+$FORWARDER_RETURN))
        ;;

    status)
        check_status
        ;;

    restart|force-reload)
        $0 stop
        $0 start
        ;;

    configcheck)
        su $AGENTUSER -c "$AGENTPATH configcheck"
        exit $?
        ;;

    configtest)
        su $AGENTUSER -c "$AGENTPATH configcheck"
        exit $?
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
        N=/etc/init.d/$NAME
        echo "Usage: $N {start|stop|restart|info|status|configcheck|configtest|jmx|flare}"
        exit 1
        ;;
esac

exit $?
