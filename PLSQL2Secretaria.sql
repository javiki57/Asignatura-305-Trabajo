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
    CURSO_ACADEMICO VARCHAR2(10 BYTE), --ESTO ES EL CURSO_ACTUAL QUE SE LLAMA DESDE LA FUNCION 1 DEL ANTERIOR SCRIPT??
    GRUPO VARCHAR2(10 BYTE),
    INGLES VARCHAR2(4 BYTE),
    EXPEDIENTE NUMBER,
    TITULACION NUMBER
    );

--c
ALTER TABLE GRUPOS_POR_ASIGNATURA ADD (NUM_ALUMNOS NUMBER(200), NUM_ALUMNOS_REAL NUMBER(200));

--d

CREATE OR REPLACE TRIGGER ACTUALIZAR_ALUMNOS AFTER INSERT OR UPDATE OR DELETE ON ASIGNATURAS_MATRICULA
FOR EACH ROW --No se si esta bien, falta lo de el grupo_id not null (ESTO ESTA SOLUCIONADO CREO)
    BEGIN 
        if grupo_id is not null then
            IF INSERTING THEN
                UPDATE GRUPOS_POR_ASIGNATURA SET NUM_ALUMNOS=NUM_ALUMNOS+1, NUM_ALUMNOS_REAL=NUM_ALUMNOS_REAL+1 WHERE GRUPO_ID=:NEW.GRUPO_ID;
            ELSIF DELETING THEN
                UPDATE GRUPOS_POR_ASIGNATURA SET NUM_ALUMNOS=NUM_ALUMNOS-1, NUM_ALUMNOS_REAL=NUM_ALUMNOS_REAL-1 WHERE GRUPO_ID=:NEW.GRUPO_ID;
            ELSE
                UPDATE GRUPOS_POR_ASIGNATURA SET GRUPO_ID=:NEW.GRUPO_ID WHERE GRUPO_ID=:OLD.GRUPO_ID; --aqui no habria que igualar tambien el numero de alumnos??
            END IF;
        end if;
END ACTUALIZAR_ALUMNOS;
/

--e,g,h
create or replace package PK_ASIGNACION_GRUPOS as 
procedure PR_ASIGNA_ASIGNADOS;
procedure PR_ASIGNA_INGLES_NUEVO;
procedure PR_ASIGNA_TARDE_NUEVO;
end PK_ASIGNACION_GRUPOS;
/
create or replace package body PK_ASIGNACION_GRUPOS as
procedure PR_ASIGNA_ASIGNADOS is 
    cursor alumnoCursor is select nuevo_ingreso.documento, alumnosext.documento from nuevo_ingreso inner join alumnosext 
        on nuevo_ingreso.documento = alumnoext.documento;
    cursor asignaturaCursor is select * from temp_asignaturas;
    pcadena varchar2(200);
    subcadena varchar2(20);
    letra varchar2(1);
    begin
        for al in alumnoCursor loop
            normaliza_asignaturas(al.grupo_asignado, substr(al.expediente,1,4));--llamada al procedimiento de edu
            
            for unAsig in asignaturaCursor loop
                letra := substr(unAsig.grupo_id,4);
                if letra is null then 
                    insert into errores values(sysdate, 'No tiene letra del grupo', unAsig.codigo, CURSO_ACTUAL(),null, null,al.expediente, substr(al.expediente,1,4));
                else
                    update  ASIGNATURA_MATRICULA set grupo_id = unAsig.grupo_id 
                        WHERE MATRICULA_EXPEDIENTES_NEXP LIKE al.expediente AND ASIGNATURA_REFERENCIA LIKE 
                            (SELECT REFERENCIA FROM ASIGNATURA WHERE CODIGO LIKE unAsig.codigo);
                end if;
            end loop;
            
        end loop;
    end PR_ASIGNA_ASIGNADOS;
    
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
                select titulacion_codigo into var_titulacion from expedientes where num_expdiente=unalumno.expediente;
                var_asig := substr(alumnos_nuevos.asig_ingles,1,3);
                var_letra := letra_grupo_ingles(var_titulacion,var_asig);
                var_curso := substr(var_asig,1);
                select referencia into var_refer from asignaturas where codigo=var_asig;
                update asignaturas_matricula set grupo_id=var_curso||var_letra where matriculas_expedientes=unalumno.expediente and asignatura_referencia=var_refer;
            end if;
        end loop;
    end PR_ASIGNA_INGLES_NUEVO;
    /*
    --h (NO ES OBLIGATORIO)
    procedure PR_ASIGNA_TARDE_NUEVO is
    cursor inglesTarde is select * from nuevo_ingreso;
    turno varchar2(20);
    grupoTarde varchar2(20);
    begin
    for alumno in inglesTarde loop
        if alumno.asig_ingles is null then
             select turno_preferente into turno from matricula where EXPEDIENTES_NUM_EXPEDIENTE 
                    like (select documento from alumnos_ext where nexpediente like alumno.expediente);
        
            if turno = 'tarde' then
                select id into grupoTarde from grupo where TURNO_MANNANA_TARDE
                    like turno; --or TURNO_MANNANA_TARDE like 'MAÑANA-TARDE'; (esto puede tener sentido pero no se si esta bien)
                update ASIGNATURAS_MATRICULA set grupo_id= --terminar esto 
            end if;
            
        end if;
    end loop;
    end PR_ASIGNA_TARDE_NUEVO;
    */
    
end PK_ASIGNACION_GRUPOS;
/
       
-- f
CREATE OR REPLACE FUNCTION LETRA_GRUPO_INGLES (NUMBER CTITULACION, NUMBER CASIGNATURA) 
RETURN VARCHAR2 AS
VAR_LETRA VARCHAR2(4);
VAR_IDIOM VARCHAR2(70);
VAR_CURSO NUMBER;
BEGIN
    VAR_LETRA := NULL;
    SELECT IDIOMAS_DE_IMPARTICION INTO VAR_IDIOM FROM ASIGNATURAS WHERE CODIGO=CASIGNATURA AND TITULACION_CODIGO=CTITULACION;
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
    PR_ASIGNA_ASIGNADOS;
    PR_ASIGNA_INGLES_NUEVO;
    PR_ASIGNA_TARDE_NUEVO;
    --El resto de procedimientos que hay que llamar son opcionales y no están hechos
    
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
    




