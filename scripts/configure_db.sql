REM ----------------------------------------------------------------
REM configure_db.sql  
REM
REM    NAME
REM      configure_db.sql - Create Database for DSS 640 - Enterprise Data
REM
REM    DESCRIPTION
REM      The location of the Sample Schema directories are specific to
REM      your Oracle installation. This script connects the directory
REM      objects inside your demo database with the appropriate paths
REM      in your file system.
REM
REM    NOTES
REM      Run this script as SYS
REM      Pass parameters for SYS Username, DBUserName and DBPassword
REM

DEFINE sys_pass = &1
DEFINE db_user = &2
DEFINE db_pass = &3

REM =======================================================
REM               Create DB Users and Roles
REM =======================================================
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

grant create session, create table, create procedure,
      create sequence, create view, create trigger,
      create synonym, create materialized view, query rewrite,
      create any directory, create type, dba, aq_administrator_role, warehouse_user
to &db_user identified by "&db_pass";

REM =======================================================
REM               Create City Jail Data
REM =======================================================

CONNECT city_jail/cjpass

-- City Jail Creation Script
DROP TABLE aliases CASCADE CONSTRAINTS;
DROP TABLE criminals CASCADE CONSTRAINTS;
DROP TABLE crimes CASCADE CONSTRAINTS;
DROP TABLE appeals CASCADE CONSTRAINTS;
DROP TABLE officers CASCADE CONSTRAINTS;
DROP TABLE crime_officers CASCADE CONSTRAINTS;
DROP TABLE crime_charges CASCADE CONSTRAINTS;
DROP TABLE crime_codes CASCADE CONSTRAINTS;
DROP TABLE prob_officers CASCADE CONSTRAINTS;
DROP TABLE sentences CASCADE CONSTRAINTS;
DROP SEQUENCE appeals_id_seq;
DROP TABLE prob_contact CASCADE CONSTRAINTS;

CREATE TABLE aliases
(
  alias_id    NUMBER(6),
  criminal_id NUMBER(6),
  alias       VARCHAR2(10)
);

CREATE TABLE criminals
(
  criminal_id NUMBER(6),
  last        VARCHAR2(15),
  first       VARCHAR2(10),
  street      VARCHAR2(30),
  city        VARCHAR2(20),
  state       CHAR(2),
  zip         CHAR(5),
  phone       CHAR(10),
  v_status    CHAR(1) DEFAULT 'N',
  p_status    CHAR(1) DEFAULT 'N'
);

CREATE TABLE crimes
(
  crime_id        NUMBER(9),
  criminal_id     NUMBER(6),
  classification  CHAR(1),
  date_charged    DATE,
  status          CHAR(2),
  hearing_date    DATE,
  appeal_cut_date DATE
);

CREATE TABLE sentences
(
  sentence_id NUMBER(6),
  criminal_id NUMBER(9),
  type        CHAR(1),
  prob_id     NUMBER(5),
  start_date  DATE,
  end_date    DATE,
  violations  NUMBER(3)
);

CREATE TABLE prob_officers
(
  prob_id NUMBER(5),
  last    VARCHAR2(15),
  first   VARCHAR2(10),
  street  VARCHAR2(30),
  city    VARCHAR2(20),
  state   CHAR(2),
  zip     CHAR(5),
  phone   CHAR(10),
  email   VARCHAR2(30),
  status  CHAR(1) DEFAULT 'A',
  mgr_id  NUMBER(5)
);

CREATE TABLE officers
(
  officer_id NUMBER(8),
  last       VARCHAR2(15),
  first      VARCHAR2(10),
  precinct   CHAR(4),
  badge      VARCHAR2(14),
  phone      CHAR(10),
  status     CHAR(1) DEFAULT 'A'
);

CREATE TABLE crime_codes
(
  crime_code       NUMBER(3),
  code_description VARCHAR2(30)
);

ALTER TABLE crimes
  MODIFY (classification DEFAULT 'U');
ALTER TABLE crimes
  ADD (date_recorded DATE DEFAULT SYSDATE);
ALTER TABLE prob_officers
  ADD (pager# CHAR(10));
ALTER TABLE aliases
  MODIFY (alias VARCHAR2(20) );
ALTER TABLE criminals
  ADD CONSTRAINT criminals_id_pk PRIMARY KEY (criminal_id);
ALTER TABLE criminals
  ADD CONSTRAINT criminals_vstatus_ck CHECK (v_status IN ('Y', 'N'));
ALTER TABLE criminals
  ADD CONSTRAINT criminals_pstatus_ck CHECK (p_status IN ('Y', 'N'));
ALTER TABLE aliases
  ADD CONSTRAINT aliases_id_pk PRIMARY KEY (alias_id);
ALTER TABLE aliases
  ADD CONSTRAINT appeals_criminalid_fk FOREIGN KEY (criminal_id)
REFERENCES criminals (criminal_id);
ALTER TABLE aliases
  MODIFY (criminal_id NOT NULL);
ALTER TABLE crimes
  ADD CONSTRAINT crimes_id_pk PRIMARY KEY (crime_id);
ALTER TABLE crimes
  ADD CONSTRAINT crimes_class_ck CHECK (classification IN ('F', 'M', 'O', 'U'));
ALTER TABLE crimes
  ADD CONSTRAINT crimes_status_ck CHECK (status IN ('CL', 'CA', 'IA'));
ALTER TABLE crimes
  ADD CONSTRAINT crimes_criminalid_fk FOREIGN KEY (criminal_id)
REFERENCES criminals (criminal_id);
ALTER TABLE crimes
  MODIFY (criminal_id NOT NULL);
ALTER TABLE prob_officers
  ADD CONSTRAINT probofficers_id_pk PRIMARY KEY (prob_id);
ALTER TABLE prob_officers
  ADD CONSTRAINT probofficers_status_ck CHECK (status IN ('A', 'I'));
ALTER TABLE sentences
  ADD CONSTRAINT sentences_id_pk PRIMARY KEY (sentence_id);
ALTER TABLE sentences
  ADD CONSTRAINT sentences_crimeid_fk FOREIGN KEY (criminal_id)
REFERENCES criminals (criminal_id);
ALTER TABLE sentences
  MODIFY (criminal_id NOT NULL);
ALTER TABLE sentences
  ADD CONSTRAINT sentences_probid_fk FOREIGN KEY (prob_id)
REFERENCES prob_officers (prob_id);
ALTER TABLE sentences
  ADD CONSTRAINT sentences_type_ck CHECK (type IN ('J', 'H', 'P'));
ALTER TABLE officers
  ADD CONSTRAINT officers_id_pk PRIMARY KEY (officer_id);
ALTER TABLE officers
  ADD CONSTRAINT officers_status_ck CHECK (status IN ('A', 'I'));
ALTER TABLE crime_codes
  ADD CONSTRAINT crimecodes_code_pk PRIMARY KEY (crime_code);

CREATE TABLE appeals
(
  appeal_id    NUMBER(5),
  crime_id     NUMBER(9) NOT NULL,
  filing_date  DATE,
  hearing_date DATE,
  status       CHAR(1) DEFAULT 'P',
  CONSTRAINT appeals_id_pk PRIMARY KEY (appeal_id),
  CONSTRAINT appeals_crimeid_fk FOREIGN KEY (crime_id)
  REFERENCES crimes (crime_id),
  CONSTRAINT appeals_status_ck CHECK (status IN ('P', 'A', 'D'))
);
CREATE TABLE crime_officers
(
  crime_id   NUMBER(9),
  officer_id NUMBER(8),
  CONSTRAINT crimeofficers_cid_oid_pk PRIMARY KEY (crime_id, officer_id),
  CONSTRAINT crimeofficers_crimeid_fk FOREIGN KEY (crime_id)
  REFERENCES crimes (crime_id),
  CONSTRAINT crimeofficers_officerid_fk FOREIGN KEY (officer_id)
  REFERENCES officers (officer_id)
);
CREATE TABLE crime_charges
(
  charge_id     NUMBER(10),
  crime_id      NUMBER(9) NOT NULL,
  crime_code    NUMBER(3) NOT NULL,
  charge_status CHAR(2),
  fine_amount   NUMBER(7, 2),
  court_fee     NUMBER(7, 2),
  amount_paid   NUMBER(7, 2),
  pay_due_date  DATE,
  CONSTRAINT crimecharges_id_pk PRIMARY KEY (charge_id),
  CONSTRAINT crimecharges_crimeid_fk FOREIGN KEY (crime_id)
  REFERENCES crimes (crime_id),
  CONSTRAINT crimecharges_code_fk FOREIGN KEY (crime_code)
  REFERENCES crime_codes (crime_code),
  CONSTRAINT crimecharges_status_ck CHECK (charge_status IN ('PD', 'GL', 'NG'))
);

INSERT INTO crime_codes
VALUES (301, 'Agg Assault');
INSERT INTO crime_codes
VALUES (302, 'Auto Theft');
INSERT INTO crime_codes
VALUES (303, 'Burglary-Business');
INSERT INTO crime_codes
VALUES (304, 'Criminal Mischief');
INSERT INTO crime_codes
VALUES (305, 'Drug Offense');
INSERT INTO crime_codes
VALUES (306, 'Bomb Threat');
INSERT INTO prob_officers (prob_id, last, first, city, status, mgr_id)
VALUES (100, 'Peek', 'Susan', 'Virginia Beach', 'A', NULL);
INSERT INTO prob_officers (prob_id, last, first, city, status, mgr_id)
VALUES (102, 'Speckle', 'Jeff', 'Virginia Beach', 'A', 100);
INSERT INTO prob_officers (prob_id, last, first, city, status, mgr_id)
VALUES (104, 'Boyle', 'Chris', 'Virginia Beach', 'A', 100);
INSERT INTO prob_officers (prob_id, last, first, city, status, mgr_id)
VALUES (106, 'Taps', 'George', 'Chesapeake', 'A', NULL);
INSERT INTO prob_officers (prob_id, last, first, city, status, mgr_id)
VALUES (108, 'Ponds', 'Terry', 'Chesapeake', 'A', 106);
INSERT INTO prob_officers (prob_id, last, first, city, status, mgr_id)
VALUES (110, 'Hawk', 'Fred', 'Chesapeake', 'I', 106);
INSERT INTO officers (officer_id, last, first, precinct, badge, phone, status)
VALUES (111112, 'Shocks', 'Pam', 'OCVW', 'E5546A33', '7574446767', 'A');
INSERT INTO officers (officer_id, last, first, precinct, badge, phone, status)
VALUES (111113, 'Busey', 'Gerry', 'GHNT', 'E5577D48', '7574446767', 'A');
INSERT INTO officers (officer_id, last, first, precinct, badge, phone, status)
VALUES (111114, 'Gants', 'Dale', 'SBCH', 'E5536N02', '7574446767', 'A');
INSERT INTO officers (officer_id, last, first, precinct, badge, phone, status)
VALUES (111115, 'Hart', 'Leigh', 'WAVE', 'E5511J40', '7574446767', 'A');
INSERT INTO officers (officer_id, last, first, precinct, badge, phone, status)
VALUES (111116, 'Sands', 'Ben', 'OCVW', 'E5588R00', '7574446767', 'I');
COMMIT;
INSERT INTO criminals (criminal_id, last, first, street, city, state, zip, phone, v_status, p_status)
VALUES (1020, 'Phelps', 'Sam', '1105 Tree Lane', 'Virginia Beach', 'VA', '23510',
        7576778484, 'Y', 'N');
INSERT INTO crimes (crime_id, criminal_id, classification, date_charged, status,
                    hearing_date, appeal_cut_date)
VALUES (10085, 1020, 'F', '03-SEP-08', 'CA', '15-SEP-08', '15-DEC-08');
INSERT INTO crime_charges (charge_id, crime_id, crime_code, charge_status,
                           fine_amount, court_fee, amount_paid, pay_due_date)
VALUES (5000, 10085, 301, 'GL', 3000, 200, 40, '15-OCT-08');
INSERT INTO crime_charges (charge_id, crime_id, crime_code, charge_status,
                           fine_amount, court_fee, amount_paid, pay_due_date)
VALUES (5001, 10085, 305, 'GL', 1000, 100, NULL, '15-OCT-08');
INSERT INTO sentences (sentence_id, criminal_id, type, prob_id, start_date,
                       end_date, violations)
VALUES (1000, 1020, 'J', NULL, '15-SEP-08', '15-SEP-10', 0);
INSERT INTO aliases (alias_id, criminal_id, alias)
VALUES (100, 1020, 'Bat');
INSERT INTO crime_officers (crime_id, officer_id)
VALUES (10085, 111112);
INSERT INTO criminals (criminal_id, last, first, street, city, state, zip, phone, v_status, p_status)
VALUES (1021, 'Sums', 'Tammy', '22 E. Ave', 'Virginia Beach', 'VA', '23510',
        7575453390, 'N', 'Y');
INSERT INTO crimes (crime_id, criminal_id, classification, date_charged, status,
                    hearing_date, appeal_cut_date)
VALUES (10086, 1021, 'M', '20-OCT-08', 'CL', '05-DEC-08', NULL);
INSERT INTO crime_charges (charge_id, crime_id, crime_code, charge_status,
                           fine_amount, court_fee, amount_paid, pay_due_date)
VALUES (5002, 10086, 304, 'GL', 200, 100, 25, '15-FEB-09');
INSERT INTO sentences (sentence_id, criminal_id, type, prob_id, start_date,
                       end_date, violations)
VALUES (1001, 1021, 'P', 102, '05-DEC-08', '05-JUN-09', 0);
INSERT INTO crime_officers (crime_id, officer_id)
VALUES (10086, 111114);

INSERT INTO criminals (criminal_id, last, first, street, city, state, zip, phone, v_status, p_status)
VALUES (1022, 'Caulk', 'Dave', '8112 Chester Lane', 'Chesapeake', 'VA', '23320',
        7578403690, 'N', 'Y');
INSERT INTO crimes (crime_id, criminal_id, classification, date_charged, status,
                    hearing_date, appeal_cut_date)
VALUES (10087, 1022, 'M', '30-OCT-08', 'IA', '05-DEC-08', '15-MAR-09');
INSERT INTO crime_charges (charge_id, crime_id, crime_code, charge_status,
                           fine_amount, court_fee, amount_paid, pay_due_date)
VALUES (5003, 10087, 305, 'GL', 100, 50, 150, '15-MAR-09');
INSERT INTO sentences (sentence_id, criminal_id, type, prob_id, start_date,
                       end_date, violations)
VALUES (1002, 1022, 'P', 108, '20-MAR-09', '20-AUG-09', 0);
INSERT INTO crime_officers (crime_id, officer_id)
VALUES (10087, 111115);
INSERT INTO aliases (alias_id, criminal_id, alias)
VALUES (101, 1022, 'Cabby');
INSERT INTO appeals (appeal_id, crime_id, filing_date, hearing_date, status)
VALUES (7500, 10087, '10-DEC-08', '20-DEC-08', 'A');
INSERT INTO appeals (appeal_id, crime_id, filing_date, hearing_date, status)
VALUES (7501, 10086, '15-DEC-08', '20-DEC-08', 'A');
INSERT INTO appeals (appeal_id, crime_id, filing_date, hearing_date, status)
VALUES (7502, 10085, '20-SEP-08', '28-OCT-08', 'A');
INSERT INTO criminals (criminal_id, last, first, street, city, state, zip, phone, v_status, p_status)
VALUES (1023, 'Dabber', 'Pat', NULL, 'Chesapeake', 'VA', '23320',
        NULL, 'N', 'N');
INSERT INTO crimes (crime_id, criminal_id, classification, date_charged, status,
                    hearing_date, appeal_cut_date)
VALUES (10088, 1023, 'O', '05-NOV-08', 'CA', NULL, NULL);
INSERT INTO crime_charges (charge_id, crime_id, crime_code, charge_status,
                           fine_amount, court_fee, amount_paid, pay_due_date)
VALUES (5004, 10088, 306, 'PD', NULL, NULL, NULL, NULL);
INSERT INTO crime_officers (crime_id, officer_id)
VALUES (10088, 111115);

INSERT INTO criminals (criminal_id, last, first, street, city, state, zip, phone, v_status, p_status)
VALUES (1025, 'Cat', 'Tommy', NULL, 'Norfolk', 'VA', '26503',
        NULL, 'N', 'Y');
INSERT INTO crimes (crime_id, criminal_id, classification, date_charged, status,
                    hearing_date, appeal_cut_date)
VALUES (10089, 1025, 'M', '22-OCT-08', 'CA', '25-NOV-08', '15-FEB-09');
INSERT INTO crime_charges (charge_id, crime_id, crime_code, charge_status,
                           fine_amount, court_fee, amount_paid, pay_due_date)
VALUES (5005, 10089, 305, 'GL', 100, 50, NULL, '15-FEB-09');
INSERT INTO sentences (sentence_id, criminal_id, type, prob_id, start_date,
                       end_date, violations)
VALUES (1004, 1025, 'P', 106, '20-DEC-08', '20-MAR-09', 0);
INSERT INTO crime_officers (crime_id, officer_id)
VALUES (10089, 111115);
INSERT INTO crime_officers (crime_id, officer_id)
VALUES (10089, 111116);

INSERT INTO criminals (criminal_id, last, first, street, city, state, zip, phone, v_status, p_status)
VALUES (1026, 'Simon', 'Tim', NULL, 'Norfolk', 'VA', '26503',
        NULL, 'N', 'Y');
INSERT INTO crimes (crime_id, criminal_id, classification, date_charged, status,
                    hearing_date, appeal_cut_date)
VALUES (10090, 1026, 'M', '22-OCT-08', 'CA', '25-NOV-08', '15-FEB-09');
INSERT INTO crime_charges (charge_id, crime_id, crime_code, charge_status,
                           fine_amount, court_fee, amount_paid, pay_due_date)
VALUES (5006, 10090, 305, 'GL', 100, 50, NULL, '15-FEB-09');
INSERT INTO sentences (sentence_id, criminal_id, type, prob_id, start_date,
                       end_date, violations)
VALUES (1005, 1026, 'P', 106, '20-DEC-08', '20-MAR-09', 0);
INSERT INTO crime_officers (crime_id, officer_id)
VALUES (10090, 111115);

INSERT INTO criminals (criminal_id, last, first, street, city, state, zip, phone, v_status, p_status)
VALUES (1027, 'Pints', 'Reed', NULL, 'Norfolk', 'VA', '26505',
        NULL, 'N', 'Y');
INSERT INTO crimes (crime_id, criminal_id, classification, date_charged, status,
                    hearing_date, appeal_cut_date)
VALUES (10091, 1027, 'M', '24-OCT-08', 'CA', '28-NOV-08', '15-FEB-09');
INSERT INTO crime_charges (charge_id, crime_id, crime_code, charge_status,
                           fine_amount, court_fee, amount_paid, pay_due_date)
VALUES (5007, 10091, 305, 'GL', 100, 50, 20, '15-FEB-09');
INSERT INTO sentences (sentence_id, criminal_id, type, prob_id, start_date,
                       end_date, violations)
VALUES (1006, 1027, 'P', 106, '20-DEC-08', '20-MAR-09', 0);
INSERT INTO crime_officers (crime_id, officer_id)
VALUES (10091, 111115);

INSERT INTO criminals (criminal_id, last, first, street, city, state, zip, phone, v_status, p_status)
VALUES (1028, 'Mansville', 'Nancy', NULL, 'Norfolk', 'VA', '26505',
        NULL, 'N', 'Y');
INSERT INTO crimes (crime_id, criminal_id, classification, date_charged, status,
                    hearing_date, appeal_cut_date)
VALUES (10092, 1028, 'M', '24-OCT-08', 'CA', '28-NOV-08', '15-FEB-09');
INSERT INTO crime_charges (charge_id, crime_id, crime_code, charge_status,
                           fine_amount, court_fee, amount_paid, pay_due_date)
VALUES (5008, 10092, 305, 'GL', 100, 50, 25, '15-FEB-09');
INSERT INTO sentences (sentence_id, criminal_id, type, prob_id, start_date,
                       end_date, violations)
VALUES (1007, 1028, 'P', 106, '20-DEC-08', '20-MAR-09', 0);
INSERT INTO crime_officers (crime_id, officer_id)
VALUES (10092, 111115);

INSERT INTO criminals (criminal_id, last, first, street, city, state, zip, phone, v_status, p_status)
VALUES (1024, 'Perry', 'Cart', NULL, 'Norfolk', 'VA', '26501',
        NULL, 'N', 'Y');
INSERT INTO crimes (crime_id, criminal_id, classification, date_charged, status,
                    hearing_date, appeal_cut_date)
VALUES (10093, 1024, 'M', '22-OCT-08', 'CA', '25-NOV-08', '15-FEB-09');
INSERT INTO crime_charges (charge_id, crime_id, crime_code, charge_status,
                           fine_amount, court_fee, amount_paid, pay_due_date)
VALUES (5009, 10093, 305, 'GL', 100, 50, NULL, '15-FEB-09');
INSERT INTO sentences (sentence_id, criminal_id, type, prob_id, start_date,
                       end_date, violations)
VALUES (1003, 1024, 'P', 106, '20-DEC-08', '20-MAR-09', 1);
INSERT INTO crime_officers (crime_id, officer_id)
VALUES (10093, 111115);

INSERT INTO criminals (criminal_id, last, first, street, city, state, zip, phone, v_status, p_status)
VALUES (1029, 'Statin', 'Penny', NULL, 'Norfolk', 'VA', '26505',
        NULL, 'N', 'Y');
INSERT INTO crimes (crime_id, criminal_id, classification, date_charged, status,
                    hearing_date, appeal_cut_date)
VALUES (10094, 1029, 'M', '26-OCT-08', 'CA', '26-NOV-08', '17-FEB-09');
INSERT INTO crime_charges (charge_id, crime_id, crime_code, charge_status,
                           fine_amount, court_fee, amount_paid, pay_due_date)
VALUES (5010, 10094, 305, 'GL', 50, 50, NULL, '17-FEB-09');
INSERT INTO sentences (sentence_id, criminal_id, type, prob_id, start_date,
                       end_date, violations)
VALUES (1008, 1029, 'P', 106, '20-DEC-08', '05-FEB-09', 1);
INSERT INTO crime_officers (crime_id, officer_id)
VALUES (10094, 111115);

INSERT INTO criminals (criminal_id, last, first, street, city, state, zip, phone, v_status, p_status)
VALUES (1030, 'Panner', 'Lee', NULL, 'Norfolk', 'VA', '26505',
        NULL, 'N', 'Y');
INSERT INTO crimes (crime_id, criminal_id, classification, date_charged, status,
                    hearing_date, appeal_cut_date)
VALUES (25344031, 1030, 'M', '26-OCT-08', 'CA', '26-NOV-08', '17-FEB-09');
INSERT INTO crime_charges (charge_id, crime_id, crime_code, charge_status,
                           fine_amount, court_fee, amount_paid, pay_due_date)
VALUES (5011, 25344031, 305, 'GL', 50, 50, NULL, '17-FEB-09');
INSERT INTO sentences (sentence_id, criminal_id, type, prob_id, start_date,
                       end_date, violations)
VALUES (1009, 1030, 'P', 106, '20-DEC-08', '05-FEB-09', 1);
INSERT INTO crime_officers (crime_id, officer_id)
VALUES (25344031, 111115);

INSERT INTO crimes (crime_id, criminal_id, classification, date_charged, status,
                    hearing_date, appeal_cut_date)
VALUES (25344060, 1030, 'M', '18-NOV-08', 'CL', '26-NOV-08', NULL);
INSERT INTO crime_charges (charge_id, crime_id, crime_code, charge_status,
                           fine_amount, court_fee, amount_paid, pay_due_date)
VALUES (5012, 25344060, 305, 'GL', 50, 50, 100, '17-FEB-09');
INSERT INTO sentences (sentence_id, criminal_id, type, prob_id, start_date,
                       end_date, violations)
VALUES (1010, 1030, 'P', 106, '06-FEB-09', '06-JUL-09', 0);
INSERT INTO crime_officers (crime_id, officer_id)
VALUES (25344060, 111116);
COMMIT;

CREATE SEQUENCE appeals_id_seq
START WITH 7505
NOCACHE
NOCYCLE;

CREATE TABLE prob_contact
(
  prob_cat NUMBER(2),
  low_amt  NUMBER(5),
  high_amt NUMBER(5),
  con_freq VARCHAR2(20)
);
INSERT INTO prob_contact
VALUES (10, 1, 80, 'Weekly');
INSERT INTO prob_contact
VALUES (20, 81, 160, 'Every 2 weeks');
INSERT INTO prob_contact
VALUES (30, 161, 500, 'Monthly');
COMMIT;

-- Grant warehouse_user to city_jail
GRANT ALL ON city_jail.aliases TO warehouse_user;
GRANT ALL ON city_jail.criminals TO warehouse_user;
GRANT ALL ON city_jail.crimes TO warehouse_user;
GRANT ALL ON city_jail.appeals TO warehouse_user;
GRANT ALL ON city_jail.officers TO warehouse_user;
GRANT ALL ON city_jail.crime_officers TO warehouse_user;
GRANT ALL ON city_jail.crime_charges TO warehouse_user;
GRANT ALL ON city_jail.crime_codes TO warehouse_user;
GRANT ALL ON city_jail.prob_officers TO warehouse_user;
GRANT ALL ON city_jail.sentences TO warehouse_user;
GRANT ALL ON city_jail.prob_contact TO warehouse_user;

REM =======================================================
REM               Create Just Lee Data
REM =======================================================

CONNECT just_lee/jlpass

DROP TABLE CUSTOMERS CASCADE CONSTRAINTS;
DROP TABLE ORDERS CASCADE CONSTRAINTS;
DROP TABLE PUBLISHER CASCADE CONSTRAINTS;
DROP TABLE AUTHOR CASCADE CONSTRAINTS;
DROP TABLE BOOKS CASCADE CONSTRAINTS;
DROP TABLE ORDERITEMS CASCADE CONSTRAINTS;
DROP TABLE BOOKAUTHOR CASCADE CONSTRAINTS;
DROP TABLE PROMOTION CASCADE CONSTRAINTS;
DROP TABLE ACCTMANAGER CASCADE CONSTRAINTS;
DROP TABLE ACCTBONUS CASCADE CONSTRAINTS;


CREATE TABLE Customers
(
  Customer# NUMBER(4),
  LastName  VARCHAR2(10) NOT NULL,
  FirstName VARCHAR2(10) NOT NULL,
  Address   VARCHAR2(20),
  City      VARCHAR2(12),
  State     VARCHAR2(2),
  Zip       VARCHAR2(5),
  Referred  NUMBER(4),
  Region    CHAR(2),
  Email     VARCHAR2(30),
  CONSTRAINT customers_customer#_pk PRIMARY KEY (customer#),
  CONSTRAINT customers_region_ck
  CHECK (region IN ('N', 'NW', 'NE', 'S', 'SE', 'SW', 'W', 'E'))
);

INSERT INTO CUSTOMERS
VALUES (1001, 'MORALES', 'BONITA', 'P.O. BOX 651', 'EASTPOINT', 'FL', '32328', NULL, 'SE', 'bm225@sat.net');
INSERT INTO CUSTOMERS
VALUES (1002, 'THOMPSON', 'RYAN', 'P.O. BOX 9835', 'SANTA MONICA', 'CA', '90404', NULL, 'W', NULL);
INSERT INTO CUSTOMERS
VALUES (1003, 'SMITH', 'LEILA', 'P.O. BOX 66', 'TALLAHASSEE', 'FL', '32306', NULL, 'SE', NULL);
INSERT INTO CUSTOMERS
VALUES (1004, 'PIERSON', 'THOMAS', '69821 SOUTH AVENUE', 'BOISE', 'ID', '83707', NULL, 'NW', 'tpier55@sat.net');
INSERT INTO CUSTOMERS
VALUES (1005, 'GIRARD', 'CINDY', 'P.O. BOX 851', 'SEATTLE', 'WA', '98115', NULL, 'NW', 'cing101@zep.net');
INSERT INTO CUSTOMERS
VALUES (1006, 'CRUZ', 'MESHIA', '82 DIRT ROAD', 'ALBANY', 'NY', '12211', NULL, 'NE', 'cruztop@axe.com');
INSERT INTO CUSTOMERS
VALUES (1007, 'GIANA', 'TAMMY', '9153 MAIN STREET', 'AUSTIN', 'TX', '78710', 1003, 'SW', 'treetop@zep.net');
INSERT INTO CUSTOMERS
VALUES (1008, 'JONES', 'KENNETH', 'P.O. BOX 137', 'CHEYENNE', 'WY', '82003', NULL, 'N', 'kenask@sat.net');
INSERT INTO CUSTOMERS
VALUES (1009, 'PEREZ', 'JORGE', 'P.O. BOX 8564', 'BURBANK', 'CA', '91510', 1003, 'W', 'jperez@canet.com');
INSERT INTO CUSTOMERS
VALUES (1010, 'LUCAS', 'JAKE', '114 EAST SAVANNAH', 'ATLANTA', 'GA', '30314', NULL, 'SE', NULL);
INSERT INTO CUSTOMERS
VALUES (1011, 'MCGOVERN', 'REESE', 'P.O. BOX 18', 'CHICAGO', 'IL', '60606', NULL, 'N', 'reesemc@sat.net');
INSERT INTO CUSTOMERS
VALUES (1012, 'MCKENZIE', 'WILLIAM', 'P.O. BOX 971', 'BOSTON', 'MA', '02110', NULL, 'NE', 'will2244@axe.net');
INSERT INTO CUSTOMERS
VALUES (1013, 'NGUYEN', 'NICHOLAS', '357 WHITE EAGLE AVE.', 'CLERMONT', 'FL', '34711', 1006, 'SE', 'nguy33@sat.net');
INSERT INTO CUSTOMERS
VALUES (1014, 'LEE', 'JASMINE', 'P.O. BOX 2947', 'CODY', 'WY', '82414', NULL, 'N', 'jaslee@sat.net');
INSERT INTO CUSTOMERS
VALUES (1015, 'SCHELL', 'STEVE', 'P.O. BOX 677', 'MIAMI', 'FL', '33111', NULL, 'SE', 'sschell3@sat.net');
INSERT INTO CUSTOMERS
VALUES (1016, 'DAUM', 'MICHELL', '9851231 LONG ROAD', 'BURBANK', 'CA', '91508', 1010, 'W', NULL);
INSERT INTO CUSTOMERS
VALUES (1017, 'NELSON', 'BECCA', 'P.O. BOX 563', 'KALMAZOO', 'MI', '49006', NULL, 'N', 'becca88@digs.com');
INSERT INTO CUSTOMERS
VALUES (1018, 'MONTIASA', 'GREG', '1008 GRAND AVENUE', 'MACON', 'GA', '31206', NULL, 'SE', 'greg336@sat.net');
INSERT INTO CUSTOMERS
VALUES (1019, 'SMITH', 'JENNIFER', 'P.O. BOX 1151', 'MORRISTOWN', 'NJ', '07962', 1003, 'NE', NULL);
INSERT INTO CUSTOMERS
VALUES (1020, 'FALAH', 'KENNETH', 'P.O. BOX 335', 'TRENTON', 'NJ', '08607', NULL, 'NE', 'Kfalah@sat.net');

CREATE TABLE Orders
(
  Order#     NUMBER(4),
  Customer#  NUMBER(4),
  OrderDate  DATE NOT NULL,
  ShipDate   DATE,
  ShipStreet VARCHAR2(18),
  ShipCity   VARCHAR2(15),
  ShipState  VARCHAR2(2),
  ShipZip    VARCHAR2(5),
  ShipCost   NUMBER(4, 2),
  CONSTRAINT orders_order#_pk PRIMARY KEY (order#),
  CONSTRAINT orders_customer#_fk FOREIGN KEY (customer#)
  REFERENCES customers (customer#)
);

INSERT INTO ORDERS
VALUES
  (1000, 1005, TO_DATE('31-MAR-09', 'DD-MON-YY'), TO_DATE('02-APR-09', 'DD-MON-YY'), '1201 ORANGE AVE', 'SEATTLE', 'WA',
   '98114', 2.00);
INSERT INTO ORDERS
VALUES
  (1001, 1010, TO_DATE('31-MAR-09', 'DD-MON-YY'), TO_DATE('01-APR-09', 'DD-MON-YY'), '114 EAST SAVANNAH', 'ATLANTA',
   'GA', '30314', 3.00);
INSERT INTO ORDERS
VALUES
  (1002, 1011, TO_DATE('31-MAR-09', 'DD-MON-YY'), TO_DATE('01-APR-09', 'DD-MON-YY'), '58 TILA CIRCLE', 'CHICAGO', 'IL',
   '60605', 3.00);
INSERT INTO ORDERS
VALUES
  (1003, 1001, TO_DATE('01-APR-09', 'DD-MON-YY'), TO_DATE('01-APR-09', 'DD-MON-YY'), '958 MAGNOLIA LANE', 'EASTPOINT',
   'FL', '32328', 4.00);
INSERT INTO ORDERS
VALUES
  (1004, 1020, TO_DATE('01-APR-09', 'DD-MON-YY'), TO_DATE('05-APR-09', 'DD-MON-YY'), '561 ROUNDABOUT WAY', 'TRENTON',
   'NJ', '08601', NULL);
INSERT INTO ORDERS
VALUES
  (1005, 1018, TO_DATE('01-APR-09', 'DD-MON-YY'), TO_DATE('02-APR-09', 'DD-MON-YY'), '1008 GRAND AVENUE', 'MACON', 'GA',
   '31206', 2.00);
INSERT INTO ORDERS
VALUES
  (1006, 1003, TO_DATE('01-APR-09', 'DD-MON-YY'), TO_DATE('02-APR-09', 'DD-MON-YY'), '558A CAPITOL HWY.', 'TALLAHASSEE',
   'FL', '32307', 2.00);
INSERT INTO ORDERS
VALUES
  (1007, 1007, TO_DATE('02-APR-09', 'DD-MON-YY'), TO_DATE('04-APR-09', 'DD-MON-YY'), '9153 MAIN STREET', 'AUSTIN', 'TX',
   '78710', 7.00);
INSERT INTO ORDERS
VALUES (1008, 1004, TO_DATE('02-APR-09', 'DD-MON-YY'), TO_DATE('03-APR-09', 'DD-MON-YY'), '69821 SOUTH AVENUE', 'BOISE',
        'ID', '83707', 3.00);
INSERT INTO ORDERS
VALUES (1009, 1005, TO_DATE('03-APR-09', 'DD-MON-YY'), TO_DATE('05-APR-09', 'DD-MON-YY'), '9 LIGHTENING RD.', 'SEATTLE',
        'WA', '98110', NULL);
INSERT INTO ORDERS
VALUES
  (1010, 1019, TO_DATE('03-APR-09', 'DD-MON-YY'), TO_DATE('04-APR-09', 'DD-MON-YY'), '384 WRONG WAY HOME', 'MORRISTOWN',
   'NJ', '07960', 2.00);
INSERT INTO ORDERS
VALUES
  (1011, 1010, TO_DATE('03-APR-09', 'DD-MON-YY'), TO_DATE('05-APR-09', 'DD-MON-YY'), '102 WEST LAFAYETTE', 'ATLANTA',
   'GA', '30311', 2.00);
INSERT INTO ORDERS
VALUES (1012, 1017, TO_DATE('03-APR-09', 'DD-MON-YY'), NULL, '1295 WINDY AVENUE', 'KALMAZOO', 'MI', '49002', 6.00);
INSERT INTO ORDERS
VALUES
  (1013, 1014, TO_DATE('03-APR-09', 'DD-MON-YY'), TO_DATE('04-APR-09', 'DD-MON-YY'), '7618 MOUNTAIN RD.', 'CODY', 'WY',
   '82414', 2.00);
INSERT INTO ORDERS
VALUES
  (1014, 1007, TO_DATE('04-APR-09', 'DD-MON-YY'), TO_DATE('05-APR-09', 'DD-MON-YY'), '9153 MAIN STREET', 'AUSTIN', 'TX',
   '78710', 3.00);
INSERT INTO ORDERS
VALUES (1015, 1020, TO_DATE('04-APR-09', 'DD-MON-YY'), NULL, '557 GLITTER ST.', 'TRENTON', 'NJ', '08606', 2.00);
INSERT INTO ORDERS
VALUES (1016, 1003, TO_DATE('04-APR-09', 'DD-MON-YY'), NULL, '9901 SEMINOLE WAY', 'TALLAHASSEE', 'FL', '32307', 2.00);
INSERT INTO ORDERS
VALUES (1017, 1015, TO_DATE('04-APR-09', 'DD-MON-YY'), TO_DATE('05-APR-09', 'DD-MON-YY'), '887 HOT ASPHALT ST', 'MIAMI',
        'FL', '33112', 3.00);
INSERT INTO ORDERS
VALUES (1018, 1001, TO_DATE('05-APR-09', 'DD-MON-YY'), NULL, '95812 HIGHWAY 98', 'EASTPOINT', 'FL', '32328', NULL);
INSERT INTO ORDERS
VALUES (1019, 1018, TO_DATE('05-APR-09', 'DD-MON-YY'), NULL, '1008 GRAND AVENUE', 'MACON', 'GA', '31206', 2.00);
INSERT INTO ORDERS
VALUES (1020, 1008, TO_DATE('05-APR-09', 'DD-MON-YY'), NULL, '195 JAMISON LANE', 'CHEYENNE', 'WY', '82003', 2.00);

CREATE TABLE Publisher
(
  PubID   NUMBER(2),
  Name    VARCHAR2(23),
  Contact VARCHAR2(15),
  Phone   VARCHAR2(12),
  CONSTRAINT publisher_pubid_pk PRIMARY KEY (pubid)
);

INSERT INTO PUBLISHER
VALUES (1, 'PRINTING IS US', 'TOMMIE SEYMOUR', '000-714-8321');
INSERT INTO PUBLISHER
VALUES (2, 'PUBLISH OUR WAY', 'JANE TOMLIN', '010-410-0010');
INSERT INTO PUBLISHER
VALUES (3, 'AMERICAN PUBLISHING', 'DAVID DAVIDSON', '800-555-1211');
INSERT INTO PUBLISHER
VALUES (4, 'READING MATERIALS INC.', 'RENEE SMITH', '800-555-9743');
INSERT INTO PUBLISHER
VALUES (5, 'REED-N-RITE', 'SEBASTIAN JONES', '800-555-8284');

CREATE TABLE Author
(
  AuthorID VARCHAR2(4),
  Lname    VARCHAR2(10),
  Fname    VARCHAR2(10),
  CONSTRAINT author_authorid_pk PRIMARY KEY (authorid)
);

INSERT INTO AUTHOR
VALUES ('S100', 'SMITH', 'SAM');
INSERT INTO AUTHOR
VALUES ('J100', 'JONES', 'JANICE');
INSERT INTO AUTHOR
VALUES ('A100', 'AUSTIN', 'JAMES');
INSERT INTO AUTHOR
VALUES ('M100', 'MARTINEZ', 'SHEILA');
INSERT INTO AUTHOR
VALUES ('K100', 'KZOCHSKY', 'TAMARA');
INSERT INTO AUTHOR
VALUES ('P100', 'PORTER', 'LISA');
INSERT INTO AUTHOR
VALUES ('A105', 'ADAMS', 'JUAN');
INSERT INTO AUTHOR
VALUES ('B100', 'BAKER', 'JACK');
INSERT INTO AUTHOR
VALUES ('P105', 'PETERSON', 'TINA');
INSERT INTO AUTHOR
VALUES ('W100', 'WHITE', 'WILLIAM');
INSERT INTO AUTHOR
VALUES ('W105', 'WHITE', 'LISA');
INSERT INTO AUTHOR
VALUES ('R100', 'ROBINSON', 'ROBERT');
INSERT INTO AUTHOR
VALUES ('F100', 'FIELDS', 'OSCAR');
INSERT INTO AUTHOR
VALUES ('W110', 'WILKINSON', 'ANTHONY');

CREATE TABLE Books
(
  ISBN     VARCHAR2(10),
  Title    VARCHAR2(30),
  PubDate  DATE,
  PubID    NUMBER(2),
  Cost     NUMBER(5, 2),
  Retail   NUMBER(5, 2),
  Discount NUMBER(4, 2),
  Category VARCHAR2(12),
  CONSTRAINT books_isbn_pk PRIMARY KEY (isbn),
  CONSTRAINT books_pubid_fk FOREIGN KEY (pubid)
  REFERENCES publisher (pubid)
);

INSERT INTO BOOKS
VALUES
  ('1059831198', 'BODYBUILD IN 10 MINUTES A DAY', TO_DATE('21-JAN-05', 'DD-MON-YY'), 4, 18.75, 30.95, NULL, 'FITNESS');
INSERT INTO BOOKS
VALUES ('0401140733', 'REVENGE OF MICKEY', TO_DATE('14-DEC-05', 'DD-MON-YY'), 1, 14.20, 22.00, NULL, 'FAMILY LIFE');
INSERT INTO BOOKS
VALUES ('4981341710', 'BUILDING A CAR WITH TOOTHPICKS', TO_DATE('18-MAR-06', 'DD-MON-YY'), 2, 37.80, 59.95, 3.00,
        'CHILDREN');
INSERT INTO BOOKS
VALUES ('8843172113', 'DATABASE IMPLEMENTATION', TO_DATE('04-JUN-03', 'DD-MON-YY'), 3, 31.40, 55.95, NULL, 'COMPUTER');
INSERT INTO BOOKS
VALUES ('3437212490', 'COOKING WITH MUSHROOMS', TO_DATE('28-FEB-04', 'DD-MON-YY'), 4, 12.50, 19.95, NULL, 'COOKING');
INSERT INTO BOOKS
VALUES ('3957136468', 'HOLY GRAIL OF ORACLE', TO_DATE('31-DEC-05', 'DD-MON-YY'), 3, 47.25, 75.95, 3.80, 'COMPUTER');
INSERT INTO BOOKS
VALUES ('1915762492', 'HANDCRANKED COMPUTERS', TO_DATE('21-JAN-05', 'DD-MON-YY'), 3, 21.80, 25.00, NULL, 'COMPUTER');
INSERT INTO BOOKS
VALUES ('9959789321', 'E-BUSINESS THE EASY WAY', TO_DATE('01-MAR-06', 'DD-MON-YY'), 2, 37.90, 54.50, NULL, 'COMPUTER');
INSERT INTO BOOKS
VALUES
  ('2491748320', 'PAINLESS CHILD-REARING', TO_DATE('17-JUL-04', 'DD-MON-YY'), 5, 48.00, 89.95, 4.50, 'FAMILY LIFE');
INSERT INTO BOOKS
VALUES ('0299282519', 'THE WOK WAY TO COOK', TO_DATE('11-SEP-04', 'DD-MON-YY'), 4, 19.00, 28.75, NULL, 'COOKING');
INSERT INTO BOOKS
VALUES ('8117949391', 'BIG BEAR AND LITTLE DOVE', TO_DATE('08-NOV-05', 'DD-MON-YY'), 5, 5.32, 8.95, NULL, 'CHILDREN');
INSERT INTO BOOKS
VALUES ('0132149871', 'HOW TO GET FASTER PIZZA', TO_DATE('11-NOV-06', 'DD-MON-YY'), 4, 17.85, 29.95, 1.50, 'SELF HELP');
INSERT INTO BOOKS
VALUES
  ('9247381001', 'HOW TO MANAGE THE MANAGER', TO_DATE('09-MAY-03', 'DD-MON-YY'), 1, 15.40, 31.95, NULL, 'BUSINESS');
INSERT INTO BOOKS
VALUES ('2147428890', 'SHORTEST POEMS', TO_DATE('01-MAY-05', 'DD-MON-YY'), 5, 21.85, 39.95, NULL, 'LITERATURE');


CREATE TABLE ORDERITEMS
(
  Order#   NUMBER(4),
  Item#    NUMBER(2),
  ISBN     VARCHAR2(10),
  Quantity NUMBER(3)    NOT NULL,
  PaidEach NUMBER(5, 2) NOT NULL,
  CONSTRAINT orderitems_pk PRIMARY KEY (order#, item#),
  CONSTRAINT orderitems_order#_fk FOREIGN KEY (order#)
  REFERENCES orders (order#),
  CONSTRAINT orderitems_isbn_fk FOREIGN KEY (isbn)
  REFERENCES books (isbn),
  CONSTRAINT oderitems_quantity_ck CHECK (quantity > 0)
);

INSERT INTO ORDERITEMS
VALUES (1000, 1, '3437212490', 1, 19.95);
INSERT INTO ORDERITEMS
VALUES (1001, 1, '9247381001', 1, 31.95);
INSERT INTO ORDERITEMS
VALUES (1001, 2, '2491748320', 1, 85.45);
INSERT INTO ORDERITEMS
VALUES (1002, 1, '8843172113', 2, 55.95);
INSERT INTO ORDERITEMS
VALUES (1003, 1, '8843172113', 1, 55.95);
INSERT INTO ORDERITEMS
VALUES (1003, 2, '1059831198', 1, 30.95);
INSERT INTO ORDERITEMS
VALUES (1003, 3, '3437212490', 1, 19.95);
INSERT INTO ORDERITEMS
VALUES (1004, 1, '2491748320', 2, 85.45);
INSERT INTO ORDERITEMS
VALUES (1005, 1, '2147428890', 1, 39.95);
INSERT INTO ORDERITEMS
VALUES (1006, 1, '9959789321', 1, 54.50);
INSERT INTO ORDERITEMS
VALUES (1007, 1, '3957136468', 3, 72.15);
INSERT INTO ORDERITEMS
VALUES (1007, 2, '9959789321', 1, 54.50);
INSERT INTO ORDERITEMS
VALUES (1007, 3, '8117949391', 1, 8.95);
INSERT INTO ORDERITEMS
VALUES (1007, 4, '8843172113', 1, 55.95);
INSERT INTO ORDERITEMS
VALUES (1008, 1, '3437212490', 2, 19.95);
INSERT INTO ORDERITEMS
VALUES (1009, 1, '3437212490', 1, 19.95);
INSERT INTO ORDERITEMS
VALUES (1009, 2, '0401140733', 1, 22.00);
INSERT INTO ORDERITEMS
VALUES (1010, 1, '8843172113', 1, 55.95);
INSERT INTO ORDERITEMS
VALUES (1011, 1, '2491748320', 1, 85.45);
INSERT INTO ORDERITEMS
VALUES (1012, 1, '8117949391', 1, 8.95);
INSERT INTO ORDERITEMS
VALUES (1012, 2, '1915762492', 2, 25.00);
INSERT INTO ORDERITEMS
VALUES (1012, 3, '2491748320', 1, 85.45);
INSERT INTO ORDERITEMS
VALUES (1012, 4, '0401140733', 1, 22.00);
INSERT INTO ORDERITEMS
VALUES (1013, 1, '8843172113', 1, 55.95);
INSERT INTO ORDERITEMS
VALUES (1014, 1, '0401140733', 2, 22.00);
INSERT INTO ORDERITEMS
VALUES (1015, 1, '3437212490', 1, 19.95);
INSERT INTO ORDERITEMS
VALUES (1016, 1, '2491748320', 1, 85.45);
INSERT INTO ORDERITEMS
VALUES (1017, 1, '8117949391', 2, 8.95);
INSERT INTO ORDERITEMS
VALUES (1018, 1, '3437212490', 1, 19.95);
INSERT INTO ORDERITEMS
VALUES (1018, 2, '8843172113', 1, 55.95);
INSERT INTO ORDERITEMS
VALUES (1019, 1, '0401140733', 1, 22.00);
INSERT INTO ORDERITEMS
VALUES (1020, 1, '3437212490', 1, 19.95);

CREATE TABLE BOOKAUTHOR
(
  ISBN     VARCHAR2(10),
  AuthorID VARCHAR2(4),
  CONSTRAINT bookauthor_pk PRIMARY KEY (isbn, authorid),
  CONSTRAINT bookauthor_isbn_fk FOREIGN KEY (isbn)
  REFERENCES books (isbn),
  CONSTRAINT bookauthor_authorid_fk FOREIGN KEY (authorid)
  REFERENCES author (authorid)
);

INSERT INTO BOOKAUTHOR
VALUES ('1059831198', 'S100');
INSERT INTO BOOKAUTHOR
VALUES ('1059831198', 'P100');
INSERT INTO BOOKAUTHOR
VALUES ('0401140733', 'J100');
INSERT INTO BOOKAUTHOR
VALUES ('4981341710', 'K100');
INSERT INTO BOOKAUTHOR
VALUES ('8843172113', 'P105');
INSERT INTO BOOKAUTHOR
VALUES ('8843172113', 'A100');
INSERT INTO BOOKAUTHOR
VALUES ('8843172113', 'A105');
INSERT INTO BOOKAUTHOR
VALUES ('3437212490', 'B100');
INSERT INTO BOOKAUTHOR
VALUES ('3957136468', 'A100');
INSERT INTO BOOKAUTHOR
VALUES ('1915762492', 'W100');
INSERT INTO BOOKAUTHOR
VALUES ('1915762492', 'W105');
INSERT INTO BOOKAUTHOR
VALUES ('9959789321', 'J100');
INSERT INTO BOOKAUTHOR
VALUES ('2491748320', 'R100');
INSERT INTO BOOKAUTHOR
VALUES ('2491748320', 'F100');
INSERT INTO BOOKAUTHOR
VALUES ('2491748320', 'B100');
INSERT INTO BOOKAUTHOR
VALUES ('0299282519', 'S100');
INSERT INTO BOOKAUTHOR
VALUES ('8117949391', 'R100');
INSERT INTO BOOKAUTHOR
VALUES ('0132149871', 'S100');
INSERT INTO BOOKAUTHOR
VALUES ('9247381001', 'W100');
INSERT INTO BOOKAUTHOR
VALUES ('2147428890', 'W105');

CREATE TABLE promotion
(
  Gift      VARCHAR2(15),
  Minretail NUMBER(5, 2),
  Maxretail NUMBER(5, 2)
);

INSERT INTO promotion
VALUES ('BOOKMARKER', 0, 12);
INSERT INTO promotion
VALUES ('BOOK LABELS', 12.01, 25);
INSERT INTO promotion
VALUES ('BOOK COVER', 25.01, 56);
INSERT INTO promotion
VALUES ('FREE SHIPPING', 56.01, 999.99);

CREATE TABLE acctmanager
(
  amid    CHAR(4),
  amfirst VARCHAR2(12) NOT NULL,
  amlast  VARCHAR2(12) NOT NULL,
  amedate DATE         DEFAULT SYSDATE,
  amsal   NUMBER(8, 2),
  amcomm  NUMBER(7, 2) DEFAULT 0,
  region  CHAR(2),
  CONSTRAINT acctmanager_amid_pk PRIMARY KEY (amid),
  CONSTRAINT acctmanager_region_ck
  CHECK (region IN ('N', 'NW', 'NE', 'S', 'SE', 'SW', 'W', 'E'))
);

CREATE TABLE acctbonus
(
  amid   CHAR(4),
  amsal  NUMBER(8, 2),
  region CHAR(2),
  CONSTRAINT acctbonus_amid_pk PRIMARY KEY (amid)
);

CREATE TABLE testing
(
  id      NUMBER(2),
  tvalue  VARCHAR2(10),
  descrip VARCHAR2(50)
);
INSERT INTO testing
VALUES (1, '%ccAccT', 'Value starts with special character');
INSERT INTO testing
VALUES (2, NULL, 'Value is NULL');
INSERT INTO testing
VALUES (3, 'bccAccT', 'Value starts with a lowercase b');
INSERT INTO testing
VALUES (4, '1ccAccT', 'Value starts with a number');
INSERT INTO testing
VALUES (5, 'BccAccT', 'Value starts with an uppercase B');
INSERT INTO testing
VALUES (6, 'CccAccT', 'Value starts with an uppercase C');
INSERT INTO testing
VALUES (7, ' ccAccT', 'Value starts with a blank character');
COMMIT;

CREATE TABLE warehouses
(
  wh_id    NUMBER(2),
  location VARCHAR(12)
);
INSERT INTO warehouses
VALUES (10, 'Boston');
INSERT INTO warehouses
VALUES (20, 'Norfolk');
INSERT INTO warehouses
VALUES (30, 'San Diego');
COMMIT;
CREATE TABLE Publisher2
(
  ID      NUMBER(2),
  Name    VARCHAR2(23),
  Contact VARCHAR2(15),
  Phone   VARCHAR2(12),
  CONSTRAINT publisher2_pubid_pk PRIMARY KEY (id)
);
INSERT INTO PUBLISHER2
VALUES (1, 'PRINTING IS US', 'TOMMIE SEYMOUR', '000-714-8321');
INSERT INTO PUBLISHER2
VALUES (2, 'PUBLISH OUR WAY', 'JANE TOMLIN', '010-410-0010');
INSERT INTO PUBLISHER2
VALUES (3, 'AMERICAN PUBLISHING', 'DAVID DAVIDSON', '800-555-1211');
INSERT INTO PUBLISHER2
VALUES (4, 'READING MATERIALS INC.', 'RENEE SMITH', '800-555-9743');
INSERT INTO PUBLISHER2
VALUES (5, 'REED-N-RITE', 'SEBASTIAN JONES', '800-555-8284');
COMMIT;
CREATE TABLE Publisher3
(
  ID      NUMBER(2),
  Name    VARCHAR2(23),
  Contact VARCHAR2(15),
  Phone   VARCHAR2(12),
  CONSTRAINT publisher3_pubid_pk PRIMARY KEY (id)
);
INSERT INTO PUBLISHER3
VALUES (2, 'PUBLISH OUR WAY', 'JANE TOMLIN', '010-410-0010');
INSERT INTO PUBLISHER3
VALUES (3, 'AMERICAN PUB', 'DAVID DAVIDSON', '800-555-1211');
INSERT INTO PUBLISHER3
VALUES (6, 'PRINTING HERE', 'SAM HUNT', '000-714-8321');
INSERT INTO PUBLISHER3
VALUES (7, 'PRINT THERE', 'CINDY TIKE', '010-410-0010');
COMMIT;
CREATE TABLE Employees (
  EMPNO    NUMBER(4),
  LNAME    VARCHAR2(20),
  FNAME    VARCHAR2(15),
  JOB      VARCHAR2(9),
  HIREDATE DATE,
  DEPTNO   NUMBER(2) NOT NULL,
  MTHSAL   NUMBER(7, 2),
  MGR      NUMBER(4),
  CONSTRAINT employees_empno_PK PRIMARY KEY (EMPNO)
);
INSERT INTO employees VALUES (7839, 'KING', 'BEN', 'GTECH2', TO_DATE('17-NOV-91', 'DD-MON-YY'), 10, 6000, NULL);
INSERT INTO employees VALUES (8888, 'JONES', 'LARRY', 'MTech2', TO_DATE('17-NOV-98', 'DD-MON-YY'), 10, 4200, 7839);
INSERT INTO employees VALUES (7344, 'SMITH', 'SAM', 'GTech1', TO_DATE('17-NOV-95', 'DD-MON-YY'), 20, 4900, 7839);
INSERT INTO employees VALUES (7355, 'POTTS', 'JIM', 'GTech1', TO_DATE('17-NOV-95', 'DD-MON-YY'), 20, 4900, 7839);
INSERT INTO employees VALUES (8844, 'STUART', 'SUE', 'MTech1', TO_DATE('17-NOV-98', 'DD-MON-YY'), 10, 3700, 8888);
COMMIT;
ALTER TABLE employees
  ADD (region CHAR(2));

COMMIT;

CREATE TABLE suppliers
(
  sup_name    VARCHAR2(20),
  description VARCHAR2(100)
);
INSERT INTO suppliers
VALUES ('Second Hand Reads',
        'wholesaler of used books only, located in Chicago, 634.555-8787');
INSERT INTO suppliers
VALUES ('Leftovers',
        'Physical store location, located in Seattle, willing to fill referred sales, sales@leftovers.com');
INSERT INTO suppliers
VALUES ('Read Again',
        'Chain of used book store fronts, seeking online sales partner, located in western U.S., 919-555-3333');
INSERT INTO suppliers
VALUES ('Bind Savers', 'Used book wholsaler, stock includes international titles, 402-555-2323');
INSERT INTO suppliers
VALUES ('Book Recyclers', 'Used book chain, located in Canada, large volume of sales, 888.555.5204');
INSERT INTO suppliers
VALUES ('Page Shock', 'Book wholsaler for specialty books and graphic novels, help@pageshock.com');
INSERT INTO suppliers
VALUES ('RePage', 'Used book vendor, only wholesales, Wash D.C., 555-0122');
COMMIT;
CREATE TABLE contacts
(
  name VARCHAR2(40)
);
INSERT INTO contacts
VALUES ('LaFodant,Mike,934-555-3493');
INSERT INTO contacts
VALUES ('Harris,Annette,727-555-2739');
INSERT INTO contacts
VALUES ('Crew,Ben,352-555-3638');
COMMIT;

-- Grant warehouse_user to just_lee
GRANT ALL ON just_lee.CUSTOMERS TO warehouse_user;
GRANT ALL ON just_lee.ORDERS TO warehouse_user;
GRANT ALL ON just_lee.PUBLISHER TO warehouse_user;
GRANT ALL ON just_lee.AUTHOR TO warehouse_user;
GRANT ALL ON just_lee.BOOKS TO warehouse_user;
GRANT ALL ON just_lee.ORDERITEMS TO warehouse_user;
GRANT ALL ON just_lee.BOOKAUTHOR TO warehouse_user;
GRANT ALL ON just_lee.PROMOTION TO warehouse_user;
GRANT ALL ON just_lee.ACCTMANAGER TO warehouse_user;
GRANT ALL ON just_lee.ACCTBONUS TO warehouse_user;

EXIT