--1
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
    VAR_ID VARCHAR2(38);
BEGIN
    SELECT G.ID INTO VAR_ID FROM GRUPO G 
        WHERE G.CURSO=PCURSO AND G.LETRA=PLETRA AND G.TITULACION_CODIGO=PTITULACION;
    RETURN VAR_ID;
END OBTEN_GRUPO_ID;
/
--select * from OBTEN_GRUPO_ID(1041, 1, 'A');


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
subcadena varchar(20);
BEGIN
COUNTER := 0;
pos := instr(pcadena,',');--5
subcadena := substr(pcadena, 1, pos-1);   --"201-A"
    while (COUNTER <= length(pcadena)) loop
         codigo := substr(subcadena,1,3);--"201"
         curso := to_Number(substr(subcadena,1,1));--"2" 
         letra := substr(subcadena,5, 1);--"A"
         if letra is not null then
         id_grupo := OBTEN_GRUPO_ID(Titulacion, curso, letra);
            insert into "SECRETARIA"."TEMP_ASIGNATURAS" values (to_number(codigo), id_grupo);
         else 
            insert into "SECRETARIA"."TEMP_ASIGNTAURAS" values (to_number(codigo), null);
        end if;
        --subcad|
        --|.....|(                     )
        --"207-A,208-B,306-B,402-A,403-B"
        pcadena := substr (pcadena, pos+1);--"208-B,306-B,402-A,403-B"
        --pos := instr(pcadena,',');
        subcadena := substr(pcadena, 1, pos-1);   
    
         COUNTER := COUNTER + pos;
         COMMIT;
         END LOOP;
END normaliza_asignaturas;
/
--EXEC normaliza_asignaturas('207-A,208-,306-B,402-A,403-B');
--EXEC normaliza_asignaturas('105-A,205-B', '1041');
--select count(*) from (select regexp_substr('207-A,208-,306-B,402-,403-','[^,]+', 1, level) from dual
--connect by regexp_substr('207-A,208-,306-B,402-,403-', '[^,]+', 1, level) is not null);

--select regexp_substr('207-A,208-C,306-B,402-D,403-D','[^,]+', 1, level) from dual
--connect by regexp_substr('207-A,208C-,306-B,402-D,403-D', '[^,]+', 1, level) is not null;

--EJERCICIO 5                                           
CREATE OR REPLACE PROCEDURE  RELLENA_ASIG_MATRICULA
AS 


	nombre varchar2(128);
    Apellido1 varchar2(128);
	Apellido2 varchar2(128);
	codigoAsig number;
	referencia2 number;
	expediente varchar2(128);

	grupo_id varchar2(10);
	CURSO VARCHAR2(10);
	LETRA VARCHAR2(1);
	ingles varchar2(50) default null;
	COUNTER number;
	COUNTER_ALUMNO number;
	NUM number;
	NUM_ALUMNO number;
	ASIGNATURAS varchar2(128);
	TITULACION varchar2(50); 

    CURSOR cursor_alumnos is select * from alumnos_ext;
    CURSOR cursor_asignaturas IS SELECT * FROM TEMP_ASIGNATURAS;

	BEGIN

	--COUNTER := 1;
	--COUNTER_ALUMNO := 1;
    
	--SELECT * into NUM_ALUMNO FROM (SELECT COUNT(*) FROM alumnos_ext);

	--WHILE(COUNTER_ALUMNO <= NUM_ALUMNO) LOOP 
    FOR cada_alumno in cursor_alumnos LOOP 
    
		normaliza_asignaturas(cada_alumno.grupos_asignados,SUBSTR(cada_alumno.expediente,1,4));

		--select count(*) into NUM from TEMP_ASIGNATURAS;

		FOR cada_asignatura in cursor_asignaturas LOOP

			--select cada_alumno.NEXPEDIENTE into expediente FROM alumnos_ext;

			--select cada_asignatura.codigo into codigoAsig FROM (TEMP_ASIGNATURAS);

			SELECT REFERENCIA into referencia2 FROM ASIGNATURAS
				WHERE CODIGO LIKE cada_asignatura.codigo;

			--SELECT cada_asignatura.GRUPO INTO CURSO FROM TEMP_ASIGNATURAS;

			--SELECT cada_asignatura.grupo_id INTO grupo_id FROM (TEMP_ASIGNATURAS);
            
            INSERT INTO ASIGNATURA_MATRICULA VALUES(referencia2, curso_actual() ,cada_alumno.expediente, cada_asignatura.grupo_id );
        commit;

		END LOOP;

		
        
	END LOOP;
	 
END RELLENA_ASIG_MATRICULA;
/

