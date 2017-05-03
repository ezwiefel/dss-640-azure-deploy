#! /bin/sh -x
#
# chkconfig: 2345 80 05
# description: start and stop Oracle Database Enterprise Edition on Oracle Linux 5 and 6
#

# In /etc/oratab, change the autostart field from N to Y for any
# databases that you want autostarted.
#
# Create this file as /etc/init.d/dbora and execute:
#  chmod 750 /etc/init.d/dbora
#  chkconfig --add dbora
#  chkconfig dbora on

# Note: Change the value of ORACLE_HOME to specify the correct Oracle home
# directory for your installation.
# ORACLE_HOME=/u01/app/oracle/product/11.1.0/db_1
ORACLE_HOME=/home/oracle/app/oracle/product/12.1.0/dbhome_1

#
# Note: Change the value of ORACLE to the login name of the oracle owner
ORACLE=oracle

PATH=${PATH}:$ORACLE_HOME/bin
HOST=`hostname`
PLATFORM=`uname`
export ORACLE_HOME PATH

case $1 in
'start')
        echo -n $"Starting Oracle: "
        su $ORACLE -c "$ORACLE_HOME/bin/dbstart $ORACLE_HOME" &
        ;;
'stop')
        echo -n $"Shutting down Oracle: "
        su $ORACLE -c "$ORACLE_HOME/bin/dbshut $ORACLE_HOME" &
        ;;
'restart')
        echo -n $"Shutting down Oracle: "
        su $ORACLE -c "$ORACLE_HOME/bin/dbshut $ORACLE_HOME" &
        sleep 5
        echo -n $"Starting Oracle: "
        su $ORACLE -c "$ORACLE_HOME/bin/dbstart $ORACLE_HOME" &
        ;;
*)
        echo "usage: $0 {start|stop|restart}"
        exit
        ;;
esac

exit