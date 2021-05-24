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
FOR EACH ROW
    BEGIN 
        if grupo_id is not null then
            IF INSERTING THEN
                UPDATE GRUPOS_POR_ASIGNATURA SET NUM_ALUMNOS=NUM_ALUMNOS+1, NUM_ALUMNOS_REAL=NUM_ALUMNOS_REAL+1 WHERE GRUPO_ID=:NEW.GRUPO_ID;
            ELSIF DELETING THEN
                UPDATE GRUPOS_POR_ASIGNATURA SET NUM_ALUMNOS=NUM_ALUMNOS-1, NUM_ALUMNOS_REAL=NUM_ALUMNOS_REAL-1 WHERE GRUPO_ID=:NEW.GRUPO_ID;
            ELSE
                UPDATE GRUPOS_POR_ASIGNATURA SET NUM_ALUMNOS=:OLD.NUM_ALUMNOS-1, NUM_ALUMNOS_REAL=:OLD.NUM_ALUMNOS_REAL-1 WHERE GRUPO_ID=:OLD.GRUPO_ID;
                UPDATE GRUPOS_POR_ASIGNATURA SET NUM_ALUMNOS=:NEW.NUM_ALUMNOS+1, NUM_ALUMNOS_REAL=:NEW.NUM_ALUMNOS_REAL+1 WHERE GRUPO_ID=:NEW.GRUPO_ID;
            END IF;
        else
            IF UPDATIN THEN
                UPDATE GRUPOS_POR_ASIGNATURA SET NUM_ALUMNOS=:NEW.NUM_ALUMNOS+1, NUM_ALUMNOS_REAL=:NEW.NUM_ALUMNOS_REAL+1 WHERE GRUPO_ID=:NEW.GRUPO_ID;
            END IF;
        end if;
END ACTUALIZAR_ALUMNOS;
/ 
--e (EN DESARROLLO)
create or replace package body PK_ASIGNACION_GRUPOS as
procedure PR_ASIGNA_ASIGNADOS is 
    cursor alumnoCursor is select nuevo_ingreso.documento, alumnosext.documento from nuevo_ingreso inner join alumnosext 
        on nuevo_ingreso.documento = alumnoext.documento;
    cursor asignaturaCursor is select * from asignatura_matricula;
    pos number;
    pcadena varchar2(200);
    subcadena varchar2(20);
    letra varchar2(1);
    Acodigo varchar2(5);
    begin
        for al in alumnoCursor loop
            
            pcadena := al.alumnosext.grupos_asignados;
            pos := instr(pcadena,',');--5
            subcadena := substr(pcadena, 1, pos-1);   --"201-A"
            exec normaliza_asignaturas(grupo_asignado, substr(al.expediente,1,4));--llamada al procedimiento de edu
            --VAMOS A MODIFICAR ESTO PARA SACAR LOS DATOS DEL PROCEDIMIENTO
            
            for unAsig in asignaturaCursor loop
                Acodigo := substr(subcadena, 1,3); --devuelve el codigo de la asignatura (201 por ejemplo)
                letra := substr(subcadena, 5); --letra o null
                if letra is null then 
                    insert into errores values(sysdate, 'No tiene letra del grupo', Acodigo, CURSO_ACTUAL(),null, null,al.expediente, substr(al.expediente,1,4));
                    
                else
                    grupo := obten_grupo_id(substr(al.expediente,1,4), substr(subcadena,1), letra); 
                    unAsig.grupo_id := (grupo);
                    --asignatura_matricula.grupo_id := 1; --COMO SE MODIFICA EL GRUPO_ID??? QUE ESTA ALMACENANDO GRUPO_ID EXACATAMENTE???
                    --insert into asignatura_matricula.
                    
                end if;
            end loop;
            
        end loop;
    end;      
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
        --fata terminarlo
    END IF;
    RETURN VAR_LETRA;
END LETRA_GRUPO_INGLES;
/  






