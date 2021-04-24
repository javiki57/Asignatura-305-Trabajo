--Desde system, comprobamos si existe el tablespace TS_SECRETARIA
select * from user_tablespaces;

/*En caso de que no, lo creamos con:
create tablespace TS_SECRETARIA
DATAFILE 'autoracle.dbf'
SIZE 10M
AUTOEXTEND ON;
*/

--Creamos el usuario secretar�a asignandole el tablespace TS_SECRETARIA.
CREATE USER secretaria 
    IDENTIFIED BY secret
    DEFAULT TABLESPACE TS_SECRETARIA
    QUOTA 2M ON TS_SECRETARIA;

--Le damos permiso para crear tablas, vistas y vistas materializadas
GRANT
    CONNECT,
    CREATE TABLE,
    CREATE VIEW,
    CREATE PROCEDURE,
    CREATE SEQUENCE,
    CREATE MATERIALIZED VIEW
        TO secretaria;
        

--Creamos el TS_INDICES
create tablespace TS_INDICES
DATAFILE 'sedcretaria.dbf'
SIZE 50M
AUTOEXTEND ON;

--Asignamos la quota al usuario secretaria
ALTER USER secretaria
    QUOTA unlimited on TS_SECRETARIA;

ALTER USER secretaria
    QUOTA unlimited on TS_INDICES;
    
--Comprobamos que hemos creado los tablespaces correctamente
select * from user_tablespaces;

--Comprobar consultando  el  diccionario  de  datos  que  el  tablespace  por  defecto  del  usuario  SECRETARIA  es  TS_SECRETARIA.
select USERNAME, DEFAULT_TABLESPACE from dba_users WHERE DEFAULT_TABLESPACE='TS_SECRETARIA';
--Comprobar consultando el diccionario de datos los datafiles que tienen asociado TS_SECRETARIA y TS_INDICES
select * from v$datafile;
        