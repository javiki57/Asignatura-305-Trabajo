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
    SELECT G.ID INTO VAR_ID FROM GRUPO G, GRUPO_POR_ASIGNATURA GPA, ASIGNATURA A 
        WHERE G.CURSO=PCURSO AND G.LETRA=PLETRA AND G.ID=GPA.GRUPO_ID AND
        GPA.ASIGNATURA_REFERENCIA=A.REFERENCIA AND A.TITULACION_CODIGO=PTITULACION;
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
NUM number;
COUNTER number; 
curso number;
BEGIN
COUNTER := 1;
select * into NUM from(select count(*) from (select regexp_substr('pcadena','[^,]+', 1, level) from dual connect by regexp_substr('pcadena', '[^,]+', 1, level) is not null));--numero de grupos que hay en la cadena.    
   
    while ( COUNTER <= NUM ) loop
         select * into codigo from(select regexp_substr(pcadena,'[^,]+', 1, level) from dual where rownum= COUNTER  connect by regexp_substr(pcadena, '[^,]+', 1, level) is not null);
         codigo := substr(codigo,1,3);
         curso := to_Number(substr(codigo,1,1)); 
         select * into letra from (select regexp_substr(pcadena,'[^,]+', 1, level) from dual where rownum= COUNTER  connect by regexp_substr(pcadena, '[^,]+', 1, level) is not null);
         letra := substr(letra,5, 1);
         id_grupo := OBTEN_GRUPO_ID(Titulacion, curso, letra);
         
         insert into "SECRETARIA"."TEMP_ASIGNATURAS" values (to_number(codigo), id_grupo);
         
         COUNTER := COUNTER + 1; 
         END LOOP;

END normaliza_asignaturas;
/
--EXEC normaliza_asignaturas('207-A,208-,306-B,402-A,403-B');
--select count(*) from (select regexp_substr('207-A,208-,306-B,402-,403-','[^,]+', 1, level) from dual
--connect by regexp_substr('207-A,208-,306-B,402-,403-', '[^,]+', 1, level) is not null);

--select regexp_substr('207-A,208-C,306-B,402-D,403-D','[^,]+', 1, level) from dual
--connect by regexp_substr('207-A,208C-,306-B,402-D,403-D', '[^,]+', 1, level) is not null;

--EJERCICIO 5                                           
CREATE OR REPLACE PROCEDURE  RELLENA_ASIG_MATRICULA (alumnos_ext TABLE)
AS 
	--
	--	  OOOOO       JJJJJJJJJ	    OOOOO
	--	OO     OO         J	      OO     OO
	--	O       O         J       O       O
	--	O       O         J       O       O
	--	O       O         J       O       O
	--	O       O         J       O       O
	--	OO     OO   J    JJ       OO     OO
	--	  OOOOO	 	 JJJJ           OOOOO
	--	
	--
	-- HABRÍA QUE AÑADIR UNA REPETICION POR CADA ALUMNO
	-- Y POSIBLEMENTE USAR OTRO PARAMETRO PARA EL PROCEDIMIENTO

	nombre varchar2(128);
    Apellido1 varchar2(128);
	Apellido2 varchar2(128);
	codigoAsig number;
	referencia2 number;
	expediente varchar2(128);
	--curso_actual number;
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


	BEGIN

	COUNTER := 1;
	COUNTER_ALUMNO := 1;

	SELECT * into NUM_ALUMNO FROM (SELECT COUNT(*) FROM alumnos_ext);

	WHILE(COUNTER_ALUMNO <= NUM_ALUMNO) LOOP --THEN 

	--guardamos los parametros del alumno en cuestion
		select NOMBRE into nombre FROM alumnos_ext
			WHERE ROWNUMBER() = COUNTER_ALUMNO;

		select APELLIDO1 into Apellido1 FROM alumnos_ext
			WHERE ROWNUMBER() = COUNTER_ALUMNO;

		select APELLIDO2 into Apellido2 FROM alumnos_ext
			WHERE ROWNUMBER() = COUNTER_ALUMNO;



		SELECT SUBSTR(expediente,1,4) INTO TITULACION FROM alumnos_ext
			WHERE NOMBRE LIKE nombre AND
				APELLIDO1 LIKE  Apellido1 AND
				APELLIDO2 LIKE Apellido2;


		SELECT GRUPOS_ASIGNADOS  into ASIGNATURAS from alumnos_ext
			WHERE NOMBRE LIKE nombre AND
				APELLIDO1 LIKE  Apellido1 AND
				APELLIDO2 LIKE Apellido2;

		exec normaliza_asignaturas(ASIGNATURA,TITULACION);

		select * into NUM from (select count(*) from (TEMP_ASIGNATURAS));

		WHILE (COUNTER <= NUM) LOOP 

			select NEXPEDIENTE into expediente FROM alumnos_ext
				WHERE NOMBRE LIKE nombre AND
				APELLIDO1 LIKE  Apellido1 AND
				APELLIDO2 LIKE Apellido2;

			select * into codigoAsig FROM (TEMP_ASIGNATURAS)
				WHERE ROWNUMBER() = COUNTER;

			SELECT REFERENCIA into referencia2 FROM ASIGNATURAS
				WHERE CODIGO LIKE codigoAsig;

			SELECT referencia INTO referencia FROM ASIGNATURAS
				WHERE codigo LIKE codigoAsig;

			--SELECT * INTO curso_actual FROM (curso_actual());

			SELECT GRUPO INTO CURSO FROM TEMP_ASIGNATURAS
				WHERE CODIGO LIKE codigoAsig; 

			SELECT * INTO grupo_id FROM (TEMP_ASIGNATURAS)
				WHERE codigo LIKE codigoAsig;



			COUNTER := COUNTER + 1

		END LOOP;

		INSERT ASIGNATURA_MATRICULA VALUES(referencia2, curso_actual() ,expediente, grupo_id )

		COUNTER_ALUMNO = COUNTER_ALUMNO + 1;

	END LOOP;
	 
END RELLENA_ASIG_MATRICULA;
