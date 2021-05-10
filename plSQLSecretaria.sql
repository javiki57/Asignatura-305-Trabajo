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

 
                                             
--EJERCICIO 5                                           

CREATE PROCEDURE  RELLENA_ASIG_MATRICULA (alumnos_ext TABLE)
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
	1erApellido varchar2(128);
	2oApellido varchar2(128);
	codigo number;
	referencia number;
	curso_actual number;
	grupo_id varchar2(10);
	ingles varchar2(50) defautl null;
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

	WHILE(COUNTER_ALUMNO <= NUM_ALUMNO) THEN 

	--guardamos los parametros del alumno en cuestion
		select NOMBRE into nombre FROM alumnos_ext
			WHERE ROWNUMBER() == COUNTER_ALUMNO;

		select APELLIDO1 into 1erApellido FROM alumnos_ext
			WHERE ROWNUMBER() == COUNTER_ALUMNO;

		select APELLIDO2 into 2oApellido FROM alumnos_ext
			WHERE ROWNUMBER() == COUNTER_ALUMNO;



		SELECT SUBSTR(expediente,1,4) INTO TITULACION FROM alumnos_ext
			WHERE NOMBRE LIKE nombre &&
				APELLIDO1 LIKE  1erApellido &&
				APELLIDO2 LIKE 2oApellido;


		SELECT GRUPOS_ASIGNADOS  into ASIGNATURAS from alumnos_ext
			WHERE NOMBRE LIKE nombre &&
				APELLIDO1 LIKE  1erApellido &&
				APELLIDO2 LIKE 2oApellido;


		select * into NUM from (select count(*) from (normaliza_asignaturas(ASIGNATURAS, TITULACION)));

		WHILE (COUNTER <= NUM) LOOP 

			select * into codigo FROM (normaliza_asignaturas(ASIGNATURAS, TITULACION))
				WHERE ROWNUMBER() == COUNTER;

			SELECT referencia INTO referencia FROM ASIGNATURAS
				WHERE codigo LIKE codigo;

			SELECT * INTO curso_actual FROM (curso_actual());

			SELECT * INTO grupo_id FROM (grupo_id(TITULACION, )) --NO TENGO DE DONDE OBTENER LOS PARAMETROS CURSO Y LETRA

			ingles := NULL;

			-- FALTA INSERTAR LA FILA ENTERA EN ASIGNATURA MATRICULA, PERO NO SE DONDE INSERTARLA


			COUNTER := COUNTER + 1

		END LOOP;

		COUNTER_ALUMNO = COUNTER_ALUMNO + 1;

	END LOOP;
	 
END RELLENA_ASIG_MATRICULA;
