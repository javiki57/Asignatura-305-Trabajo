/*
Paula Cuenca García
Eduard Nicolás Cybulkiewicz
Roberto Navarro García
Jesús Javier Quirante Pérez
Pedro Sánchez Machuca
*/


/*-------------------------------------------------------------------------------
---------------------------------------------------------------------------------
------------------------------PRIMERA PARTE--------------------------------------
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------*/

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



/*-------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------SEGUNDA PARTE-----------------------------------
--------------------------------------------------------------------------------
---------------------------------------------------------------------------------*/

CREATE TABLE NUEVO_INGRESO (
    DOCUMENTO	VARCHAR2(20 BYTE),
    EXPEDIENTE	VARCHAR2(100 BYTE),
    ARCHIVO	VARCHAR2(100 BYTE),
    ASIG_INGLES	VARCHAR2(200 BYTE)
    );
    
--b
CREATE TABLE ERRORES(
    FECHA DATE,
    MOTIVO varchar2(100),
    CODIGO_ASIGNATURA VARCHAR2(20 BYTE),
    CURSO_ACADEMICO VARCHAR2(10 BYTE),
    GRUPO VARCHAR2(10 BYTE),
    INGLES VARCHAR2(2 BYTE),
    EXPEDIENTE NUMBER,
    TITULACION NUMBER
    );

--c
ALTER TABLE GRUPOS_POR_ASIGNATURA ADD (NUM_ALUMNOS NUMBER(38), NUM_ALUMNOS_REAL NUMBER(38));

--d
create or replace TRIGGER ACTUALIZAR_ALUMNOS AFTER INSERT OR UPDATE OR DELETE ON ASIGNATURAS_MATRICULA
FOR EACH ROW
    declare
    grupoAux varchar2(5);
    var_grupo varchar2(10);
    BEGIN 
        select grupo_id into var_grupo from asignaturas_matricula where ASIGNATURA_REFERENCIA=:new.asignatura_referencia;
        select grupo_id into grupoAux from GRUPO where GRUPO.id = :new.grupo_id;
        if var_grupo is not null then
            IF INSERTING THEN
                UPDATE GRUPOS_POR_ASIGNATURA SET NUM_ALUMNOS=NUM_ALUMNOS+1, NUM_ALUMNOS_REAL=NUM_ALUMNOS_REAL+1 WHERE GRUPO_ID=:NEW.GRUPO_ID and asignatura_referencia = :new.asignatura_referencia;
                if grupoAux is not null then 
                    UPDATE GRUPOS_POR_ASIGNATURA SET NUM_ALUMNOS_REAL=NUM_ALUMNOS_REAL+1 where GRUPOS_POR_ASIGNATURA.grupo_id = grupoAux;
                end if;
            ELSIF DELETING THEN
                UPDATE GRUPOS_POR_ASIGNATURA SET NUM_ALUMNOS=NUM_ALUMNOS-1, NUM_ALUMNOS_REAL=NUM_ALUMNOS_REAL-1 WHERE GRUPO_ID=:NEW.GRUPO_ID and asignatura_referencia = :new.asignatura_referencia;
                if grupoAux is not null then 
                    UPDATE GRUPOS_POR_ASIGNATURA SET NUM_ALUMNOS_REAL=NUM_ALUMNOS_REAL-1 where GRUPOS_POR_ASIGNATURA.grupo_id = grupoAux;
                end if;
            ELSE
                UPDATE GRUPOS_POR_ASIGNATURA SET NUM_ALUMNOS=NUM_ALUMNOS-1, NUM_ALUMNOS_REAL=NUM_ALUMNOS_REAL-1 WHERE GRUPO_ID=:OLD.GRUPO_ID and asignatura_referencia = :new.asignatura_referencia;
                UPDATE GRUPOS_POR_ASIGNATURA SET NUM_ALUMNOS=NUM_ALUMNOS+1, NUM_ALUMNOS_REAL=NUM_ALUMNOS_REAL+1 WHERE GRUPO_ID=:NEW.GRUPO_ID and asignatura_referencia = :new.asignatura_referencia;

                if grupoAux is not null then 
                    UPDATE GRUPOS_POR_ASIGNATURA SET NUM_ALUMNOS_REAL=NUM_ALUMNOS_REAL+1 where GRUPOS_POR_ASIGNATURA.grupo_id = grupoAux;
                    select grupo_id into grupoAux from GRUPO where GRUPO.id = :old.grupo_id;
                    UPDATE GRUPOS_POR_ASIGNATURA SET NUM_ALUMNOS_REAL=NUM_ALUMNOS_REAL-1 where GRUPOS_POR_ASIGNATURA.grupo_id = grupoAux;
                end if;
            END IF;
        else
            IF UPDATING THEN
                UPDATE GRUPOS_POR_ASIGNATURA SET NUM_ALUMNOS=NUM_ALUMNOS+1, NUM_ALUMNOS_REAL=NUM_ALUMNOS_REAL+1 WHERE GRUPO_ID=:NEW.GRUPO_ID and asignatura_referencia = :new.asignatura_referencia;
            END IF;
        end if;
END ACTUALIZAR_ALUMNOS;
/ 

--e
create or replace package PK_ASIGNACION_GRUPOS as 
procedure PR_ASIGNA_ASIGNADOS;
procedure PR_ASIGNA_INGLES_NUEVO;
procedure PR_ASIGNA_TARDE_NUEVO;
end PK_ASIGNACION_GRUPOS;
/
create or replace package body PK_ASIGNACION_GRUPOS as
procedure PR_ASIGNA_ASIGNADOS is 
    cursor alumnoCursor is select AE.grupos_asignados, NI.expediente from nuevo_ingreso NI inner join alumnos_ext AE on NI.documento = AE.documento
        where AE.grupos_asignados is not null;
    cursor asignaturaCursor is select * from temp_asignaturas;
    pcadena varchar2(200);
    subcadena varchar2(20);
    letra varchar2(1);
    begin
        for al in alumnoCursor loop
            normaliza_asignaturas(al.grupos_asignados, substr(al.expediente,1,4));--llamada al procedimiento de edu

            for unAsig in asignaturaCursor loop
                letra := substr(unAsig.grupo,4);
                if letra is null then 
                    insert into errores values(sysdate, 'No tiene letra del grupo', unAsig.codigo, CURSO_ACTUAL(),null, null,al.expediente, substr(al.expediente,1,4));
                else
                    update ASIGNATURAS_MATRICULA set grupo_id = unAsig.grupo 
                        WHERE MATRICULA_EXPEDIENTES_NEXP LIKE al.expediente AND ASIGNATURA_REFERENCIA LIKE 
                            (SELECT REFERENCIA FROM ASIGNATURA WHERE CODIGO LIKE unAsig.codigo);
                end if;
            end loop;

        end loop;
    end PR_ASIGNA_ASIGNADOS;
    
    --g
    procedure PR_ASIGNA_INGLES_NUEVO is
        cursor alumnos_nuevos is select asig_ingles, expediente from nuevo_ingreso;
        var_letra varchar2(4);
        var_curso number;
        var_titulacion number;
        var_asig number;
        var_refer number;
    begin 
        for unalumno in alumnos_nuevos loop
            if unalumno.asig_ingles is not null then
                select titulacion_codigo into var_titulacion from expedientes where num_expediente=unalumno.expediente;
                var_asig := substr(unalumno.asig_ingles,1,3);
                var_letra := letra_grupo_ingles(var_titulacion,var_asig);
                var_curso := substr(var_asig,1);
                select referencia into var_refer from asignatura where codigo=var_asig;
                update asignaturas_matricula set grupo_id=var_curso||var_letra where matricula_expedientes_nexp=unalumno.expediente and asignatura_referencia=var_refer;
            end if;
        end loop;
    end PR_ASIGNA_INGLES_NUEVO;

    --h
    procedure PR_ASIGNA_TARDE_NUEVO is
    cursor inglesTarde is select NI.asig_ingles, M.TURNO_PREFERENTE from nuevo_ingreso NI, matricula M where ASIG_INGLES is null;
    grupoTarde varchar2(20);
    begin
    for alumno in inglesTarde loop
        if alumno.turno_preferente='Tarde' then
            select id into grupoTarde from grupo where TURNO_MANNANA_TARDE=alumno.turno_preferente; 
            update ASIGNATURAS_MATRICULA set grupo_id = grupoTarde;
        end if;
    end loop;
    end PR_ASIGNA_TARDE_NUEVO;

end PK_ASIGNACION_GRUPOS;
/
       
-- f
create or replace FUNCTION LETRA_GRUPO_INGLES (CTITULACION NUMBER,CASIGNATURA NUMBER) 
RETURN VARCHAR2 AS
VAR_LETRA VARCHAR2(4);
VAR_IDIOM VARCHAR2(70);
VAR_CURSO NUMBER;
BEGIN
    VAR_LETRA := NULL;
    SELECT IDIOMAS_DE_IMPARTICION INTO VAR_IDIOM FROM ASIGNATURA WHERE CODIGO=CASIGNATURA AND TITULACION_CODIGO=CTITULACION;
    IF VAR_IDIOM IS NOT NULL THEN
        VAR_CURSO := SUBSTR(CASIGNATURA,1);
        SELECT LETRA INTO VAR_LETRA FROM GRUPO WHERE CURSO=VAR_CURSO AND TITULACION_CODIGO=CTITULACION AND INGLES='si';
    END IF;
    RETURN VAR_LETRA;
END LETRA_GRUPO_INGLES;
/

--m
create or replace procedure PR_ASIGNA as 
begin 
    PK_ASIGNACION_GRUPOS.PR_ASIGNA_ASIGNADOS;
    PK_ASIGNACION_GRUPOS.PR_ASIGNA_INGLES_NUEVO;
    PK_ASIGNACION_GRUPOS.PR_ASIGNA_TARDE_NUEVO;
end PR_ASIGNA;
/    

--exec PR_ASIGNA();
--n
CREATE OR REPLACE VIEW V_ASIGNATURAS AS
SELECT ASIG.TITULACION_CODIGO, AM.MATRICULA_EXPEDIENTES_NEXP, AL.DOCUMENTO, AL.APELLIDO1 ||', '|| AL.NOMBRE "nombre", SUBSTR(AM.GRUPO_ID,3) "curso",
ASIG.CODIGO, SUBSTR(AM.GRUPO_ID,4) "letra"
    FROM ASIGNATURA ASIG, ASIGNATURAS_MATRICULA AM, ALUMNOS_EXT AL
        WHERE ASIG.REFERENCIA = AM.ASIGNATURA_REFERENCIA AND
        AL.NEXPEDIENTE = AM.MATRICULA_EXPEDIENTES_NEXP;

select * from V_ASIGNATURAS;
