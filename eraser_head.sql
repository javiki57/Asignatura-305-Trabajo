select 'DROP TABLE ' || table_name || ' CASCADE CONSTRAINTS;' from user_tables;