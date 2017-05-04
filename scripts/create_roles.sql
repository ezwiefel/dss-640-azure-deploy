CREATE ROLE warehouse_user;

grant create session, create table, create procedure,
      create sequence, create view, create trigger,
      create synonym, create materialized view, query rewrite,
      create any directory, create type, dba, aq_administrator_role, warehouse_user
TO city_jail IDENTIFIED BY cjpass;

grant create session, create table, create procedure,
      create sequence, create view, create trigger,
      create synonym, create materialized view, query rewrite,
      create any directory, create type, dba, aq_administrator_role, warehouse_user
TO just_lee IDENTIFIED BY jlpass;