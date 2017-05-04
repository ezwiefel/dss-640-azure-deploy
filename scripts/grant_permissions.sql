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