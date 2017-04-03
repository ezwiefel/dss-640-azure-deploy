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

sqlplus sys/$sys_pass as sysdba << !
grant create session, create table, create procedure,
      create sequence, create view, create trigger,
      create synonym, create materialized view, query rewrite,
      create any directory, create type, dba, aq_administrator_role
to $db_user identified by $db_pass;