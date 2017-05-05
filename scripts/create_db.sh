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

wget https://raw.githubusercontent.com/ezwiefel/dss-640-azure-deploy/master/scripts/create_roles.sql -O /home/oracle/create_roles.sql

echo exit | sqlplus sys/$sys_pass as sysdba @/home/oracle/create_roles.sql

wget https://raw.githubusercontent.com/ezwiefel/dss-640-azure-deploy/master/scripts/city_jail_creation.sql -O /home/oracle/city_jail_creation.sql
wget https://raw.githubusercontent.com/ezwiefel/dss-640-azure-deploy/master/scripts/just_lee_creation.sql -O /home/oracle/just_lee_creation.sql

echo exit | sqlplus city_jail/cjpass @/home/oracle/city_jail_creation.sql
echo exit | sqlplus just_lee/jlpass @/home/oracle/just_lee_creation.sql

wget https://raw.githubusercontent.com/ezwiefel/dss-640-azure-deploy/master/scripts/grant_permissions.sql -O /home/oracle/grant_permissions.sql
echo exit | sqlplus sys/$sys_pass as sysdba @/home/oracle/grant_permissions.sql

# Create DB user and grant warehouse_user role
echo exit | sqlplus sys/$sys_pass as sysdba << EOF
grant create session, create table, create procedure,
      create sequence, create view, create trigger,
      create synonym, create materialized view, query rewrite,
      create any directory, create type, dba, aq_administrator_role, warehouse_user
to $db_user identified by $db_pass;
EOF


# Configure auto startup and shutdown of Oracel DB
echo "$sys_pass" | sudo -S -k wget https://raw.githubusercontent.com/ezwiefel/dss-640-azure-deploy/master/scripts/dbora.sh -O /etc/init.d/dbora
echo "$sys_pass" | sudo -S -k chmod 750 /etc/init.d/dbora
echo "$sys_pass" | sudo -S -k chkconfig --add dbora
echo "$sys_pass" | sudo -S -k chkconfig dbora on 

echo '# /etc/oratab
orcl:/u01/app/oracle/product/12.1.0/dbhome_1:Y' > /etc/oratab