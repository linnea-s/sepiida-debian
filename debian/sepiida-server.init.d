#!/bin/sh
### BEGIN INIT INFO
# Provides:          sepiida-server
# Required-Start:    $remote_fs
# Required-Stop:     $remote_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Sepiida support tool server
### END INIT INFO

PATH=/sbin:/bin:/usr/sbin:/usr/bin

rundir=/var/run/sepiida-server
pidfile=$rundir/sepiida-server.pid
logfile=/var/log/sepiida-server.log
application=/usr/sbin/sepiida-server
twistd=/usr/bin/twistd
user=sepiida-server
group=daemon
name=sepiida-server

. /lib/lsb/init-functions

#[ -r /etc/default/sepiida-server ] && . /etc/default/sepiida-server

test -x $twistd || exit 0
test -r $application || exit 0

case "$1" in
    start)
	log_daemon_msg "Starting sepiida-server" "$name"
	[ ! -d $rundir ] && mkdir $rundir
	[ ! -f $logfile ] && touch $logfile
	chown $user $rundir $logfile 
	[ -f $pidfile ] && chown $user $pidfile
	uid=$(getent passwd $user | cut -d: -f3)
	gid=$(getent group $group | cut -d: -f3)
	start-stop-daemon --start --quiet --exec $twistd -- \
	    --pidfile=$pidfile 	--rundir=$rundir --python=$application \
	    --logfile=$logfile --uid=$uid --gid=$gid
	log_end_msg $?
    ;;

    stop)
	log_daemon_msg "Stopping sepiida-server" "$name"
	start-stop-daemon --stop --quiet --pidfile $pidfile --retry 5
	log_end_msg $?
    ;;

    restart)
	$0 stop
	$0 start
    ;;
    
    force-reload)
        $0 restart
    ;;

    *)
	log_success_msg "Usage: /etc/init.d/sepiida-server {start|stop|restart|force-reload}"
	exit 1
    ;;
esac

exit 0
