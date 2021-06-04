--a
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
--n
CREATE VIEW V_ASIGNATURAS AS
SELECT ASIG.TITULACION_CODIGO, AM.MATRICULA_EXPEDIENTES_NEXP, AL.DOCUMENTO, AL.APELLIDO1 ||', '|| AL.NOMBRE "nombre", SUBSTR(AM.GRUPO_ID,3) "curso",
ASIG.CODIGO, SUBSTR(AM.GRUPO_ID,4) "letra"
    FROM ASIGNATURA ASIG, ASIGNATURAS_MATRICULA AM, ALUMNOS_EXT AL
        WHERE ASIG.REFERENCIA = AM.ASIGNATURA_REFERENCIA AND
        AL.NEXPEDIENTE = AM.MATRICULA_EXPEDIENTES_NEXP;

select * from V_ASIGNATURAS;
