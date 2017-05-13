#!/bin/bash

# Start Oracle Database

sys_pass=$1
system_pass=$1

db_user=$2
db_pass=$3

dbca -silent \
     -createDatabase \
     -templateName General_Purpose.dbc \
     -gdbname orcl \
     -sid orcl \
     -responseFile NO_VALUE \
     -characterSet AL32UTF8 \
     -memoryPercentage 40 \
     -emConfiguration LOCAL \
     -SysPassword $sys_pass \
     -SystemPassword $system_pass

oraenv
echo 'export ORACLE_HOME=/u01/app/oracle/product/12.1.0/dbhome_1' >> /home/oracle/.bashrc
echo 'export PATH=$PATH:$ORACLE_HOME/bin' >> /home/oracle/.bashrc
echo 'export ORACLE_SID=orcl' >> /home/oracle/.bashrc
source /home/oracle/.bashrc
lsnrctl start

# Configure DB script - include create schemas and provision users
wget https://raw.githubusercontent.com/ezwiefel/dss-640-azure-deploy/dev_branch/scripts/configure_db.sql -O /home/oracle/configure_db.sql

sqlplus sys/$sys_pass as sysdba @/home/oracle/configure_db.sql $sys_pass $db_user $db_pass

# Configure auto startup and shutdown of Oracle DB
echo "$sys_pass" | sudo -S -k wget https://raw.githubusercontent.com/ezwiefel/dss-640-azure-deploy/master/scripts/dbora.sh -O /etc/init.d/dbora
echo "$sys_pass" | sudo -S -k chmod 750 /etc/init.d/dbora
echo "$sys_pass" | sudo -S -k chkconfig --add dbora
echo "$sys_pass" | sudo -S -k chkconfig dbora on 

echo '# /etc/oratab
orcl:/u01/app/oracle/product/12.1.0/dbhome_1:Y' > /etc/oratab