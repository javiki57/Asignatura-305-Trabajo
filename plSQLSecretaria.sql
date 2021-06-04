--Ejercicio 1
create or replace FUNCTION CURSO_ACTUAL RETURN VARCHAR2 AS Curso varchar2(50);
Anio_Actual varchar2(10);
begin

Anio_Actual := substr(sysdate, 7);
if (to_number(substr(sysdate, 4,2)) = 10) and (to_number(substr(sysdate, 1,2)) >= 5) then CURSO_ACTUAL.Curso := (to_number(Anio_Actual)|| '/'|| to_number(Anio_Actual)+1);
    elsif (to_number(substr(sysdate, 4,2)) > 10) then CURSO_ACTUAL.Curso := (to_number(Anio_Actual)|| '/'|| to_Number(Anio_Actual)+1);
        else CURSO_ACTUAL.Curso := (to_number(Anio_Actual)-1|| '/'|| to_number(Anio_Actual));
end if;
return Curso;
end CURSO_ACTUAL;
/


--Ejercicio 2
CREATE OR REPLACE FUNCTION OBTEN_GRUPO_ID 
    (PTitulacion VARCHAR2, PCurso Number, PLetra VARCHAR2) 
    RETURN VARCHAR2 AS
    VAR_ID VARCHAR2(10);
BEGIN
    SELECT G.ID INTO VAR_ID FROM GRUPO G 
        WHERE G.CURSO=PCURSO AND G.LETRA=PLETRA AND G.TITULACION_CODIGO=PTITULACION;
    RETURN VAR_ID;
END OBTEN_GRUPO_ID;
/


--Ejercicio 3
CREATE GLOBAL TEMPORARY TABLE "SECRETARIA"."TEMP_ASIGNATURAS"("CODIGO" NUMBER, GRUPO VARCHAR2(10)) ON COMMIT DELETE ROWS ;
  
--Ejercicio 4
create or replace procedure normaliza_asignaturas (pcadena varchar2, Titulacion varchar2 default null) 
AS
codigo varchar2(30);
letra varchar2(30);
id_codigo varchar2(30);
id_grupo varchar2(30); 
COUNTER number; 
curso number;
pos number;
cadenita varchar2(100);
subcadena varchar2(20);
BEGIN
COUNTER := 0;
pos := instr(pcadena,',');--5
subcadena := substr(pcadena, 1, pos-1);   --"201-A"
    while (COUNTER <= length(pcadena)) loop
         codigo := substr(subcadena,1,3);--"201"
         --DBMS_OUTPUT.put_line (codigo);
         curso := to_number(substr(subcadena,1,1));--"2" 
         letra := substr(subcadena,5, 1);--"A"
         if letra is not null then
         id_grupo := OBTEN_GRUPO_ID(Titulacion, curso, letra);
            insert into "TEMP_ASIGNATURAS" values (to_number(codigo), id_grupo);
         else 
            insert into "TEMP_ASIGNATURAS" values (to_number(codigo), null);
        end if;
        --subcad|
        --|.....|(                     )
        --"207-A,208-B,306-B,402-A,403-B"
        cadenita := substr (pcadena, pos+1);--"208-B,306-B,402-A,403-B"
        pos := instr(cadenita,',');
        subcadena := substr(cadenita, 1, pos-1);   

         COUNTER := COUNTER + pos;
         COMMIT;
         END LOOP;
END normaliza_asignaturas;
/
--EXEC normaliza_asignaturas('101-A,102-A,105-,202-A,205-A', 1041);
--EXEC normaliza_asignaturas('105-A,205-B', '1041');
--select count(*) from (select regexp_substr('207-A,208-,306-B,402-,403-','[^,]+', 1, level) from dual
--connect by regexp_substr('207-A,208-,306-B,402-,403-', '[^,]+', 1, level) is not null);

--select regexp_substr('207-A,208-C,306-B,402-D,403-D','[^,]+', 1, level) from dual
--connect by regexp_substr('207-A,208C-,306-B,402-D,403-D', '[^,]+', 1, level) is not null;

--Ejercicio 5                                           
create or replace PROCEDURE  RELLENA_ASIG_MATRICULA
AS 
    referencia2 number;
	CURSOR cursor_alumnos is select * from alumnos_ext;
    CURSOR cursor_asignaturas IS SELECT * FROM TEMP_ASIGNATURAS;

    BEGIN
    FOR cada_alumno in cursor_alumnos LOOP 

        normaliza_asignaturas(cada_alumno.grupos_asignados,SUBSTR(cada_alumno.nexpediente,1,4));
        FOR cada_asignatura in cursor_asignaturas LOOP



            SELECT REFERENCIA into referencia2 FROM ASIGNATURA
                WHERE CODIGO LIKE cada_asignatura.codigo;


            INSERT INTO ASIGNATURAS_MATRICULA VALUES(referencia2, curso_actual(), cada_asignatura.grupo, null, null, cada_alumno.nexpediente );
            commit;
        END LOOP;

    END LOOP;


END RELLENA_ASIG_MATRICULA;
/

exec RELLENA_ASIG_MATRICULA();

