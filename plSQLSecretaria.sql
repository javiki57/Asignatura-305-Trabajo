--1 NO FUNCIONA TODAVIA 
create or replace FUNCTION CURSO_ACTUAL RETURN VARCHAR2 AS Curso varchar2(50);
Anio_Actual varchar2(10);
begin

Anio_Actual := substr(sysdate, 7);
if (to_number(substr(sysdate, 4,2)) = 10) and (to_number(substr(sysdate, 1,2)) >= 5) then CURSO_ACTUAL.Curso := (to_number(Anio_Actual), '/', to_number(Anio_Actual)+1);
    elsif (to_number(substr(sysdate, 4,2)) > 10) then CURSO_ACTUAL.Curso := (to_number(Anio_Actual), '/', to_Number(Anio_Actual)+1);
        else CURSO_ACTUAL.Curso := (to_number(Anio_Actual)-1, '/', to_number(Anio_Actual));
end if;
return Curso;
end CURSO_ACTUAL;
--Ejercicio 2










--Ejercicio 3
CREATE GLOBAL TEMPORARY TABLE "SECRETARIA"."TEMP_ASIGNATURAS"("CODIGO" NUMBER, GRUPO VARCHAR2(10)) ON COMMIT DELETE ROWS ;
  
--Ejercicio 4
create or replace procedure normaliza_asignaturas (pcadena varchar2, Titulacion varchar2 default null) 
AS
codigo number;
letra varchar2(30);
id_codigo varchar2(30);
id_grupo varchar2(30); 
NUM number;
COUNTER number; 
BEGIN
COUNTER := 1;
select * into NUM from(select count(*) from (select regexp_substr('pcadena','[^,]+', 1, level) from dual connect by regexp_substr('pcadena', '[^,]+', 1, level) is not null));--numero de grupos que hay en la cadena.    
   
    while ( COUNTER <= NUM ) loop
         select * into codigo from(select regexp_substr(pcadena,'[^,]+', 1, level) from dual where rownum= COUNTER  connect by regexp_substr(pcadena, '[^,]+', 1, level) is not null);
         codigo := substr(codigo,1,3);
         select * into letra from (select regexp_substr(pcadena,'[^,]+', 1, level) from dual where rownum= COUNTER  connect by regexp_substr(pcadena, '[^,]+', 1, level) is not null);
         letra := substr(letra,5, 1);
         id_grupo := OBTENER_GRUPO_ID(Titulacion, substr(codigo,1,1), letra);
         
         insert into "SECRETARIA"."TEMP_ASIGNATURAS" values (codigo, id_grupo);
         
         COUNTER := COUNTER + 1; 
         END LOOP;

END normaliza_asignaturas;
/

--select count(*) from (select regexp_substr('207-A,208-,306-B,402-,403-','[^,]+', 1, level) from dual
--connect by regexp_substr('207-A,208-,306-B,402-,403-', '[^,]+', 1, level) is not null);

--select regexp_substr('207-A,208-C,306-B,402-D,403-D','[^,]+', 1, level) from dual
--connect by regexp_substr('207-A,208C-,306-B,402-D,403-D', '[^,]+', 1, level) is not null;


