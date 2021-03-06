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

SET serveroutput ON;

--Ejercicio 1
create or replace FUNCTION CURSO_ACTUAL RETURN VARCHAR2 AS 
Curso varchar2(50);
Anio_Actual varchar2(10);
begin
    Anio_Actual := substr(sysdate, 7);
    if (to_number(substr(sysdate, 4,2)) = 10) and (to_number(substr(sysdate, 1,2)) >= 5) then 
        CURSO_ACTUAL.Curso := (to_number(Anio_Actual)|| '/'|| to_number(Anio_Actual)+1);
    elsif (to_number(substr(sysdate, 4,2)) > 10) then 
        CURSO_ACTUAL.Curso := (to_number(Anio_Actual)|| '/'|| to_Number(Anio_Actual)+1);
    else 
        CURSO_ACTUAL.Curso := (to_number(Anio_Actual)-1|| '/'|| to_number(Anio_Actual));
    end if;
    return Curso;
end CURSO_ACTUAL;
/

--Ejercicio 2
CREATE OR REPLACE FUNCTION OBTEN_GRUPO_ID (PTitulacion VARCHAR2, PCurso Number, PLetra VARCHAR2) RETURN VARCHAR2 AS
VAR_ID VARCHAR2(10);
BEGIN
    SELECT G.ID INTO VAR_ID FROM GRUPO G WHERE G.CURSO=PCURSO AND G.LETRA=PLETRA AND G.TITULACION_CODIGO=PTITULACION;
    RETURN VAR_ID;
END OBTEN_GRUPO_ID;
/

--Ejercicio 3
CREATE GLOBAL TEMPORARY TABLE "SECRETARIA"."TEMP_ASIGNATURAS"("CODIGO" NUMBER, GRUPO VARCHAR2(10)) ON COMMIT DELETE ROWS ;
 
--Ejercicio 4
CREATE OR REPLACE PROCEDURE NORMALIZA_ASIGNATURAS(pcadena VARCHAR2, Titulacion VARCHAR2 DEFAULT NULL) AS
cont NUMBER;
pos NUMBER;
subcadena VARCHAR2(5);
codigo NUMBER;
letra VARCHAR(1);
curso NUMBER;
cadena_restada varchar2(100);
BEGIN
    cont := 1;
    cadena_restada := pcadena;
     
    WHILE cont<=LENGTH(pcadena) LOOP
         pos := INSTR(cadena_restada,',');
         if pos = 0 then
            subcadena := SUBSTR(cadena_restada,1,length(cadena_restada));
            letra := SUBSTR(subcadena,length(cadena_restada),1);
        else
            subcadena := SUBSTR(cadena_restada,1,pos-1);
            letra := SUBSTR(subcadena,pos-1,1);
        end if;
        codigo := TO_NUMBER(SUBSTR(subcadena,1,3));
        IF LETRA='-' THEN
            INSERT INTO TEMP_ASIGNATURAS VALUES(codigo,null);
        ELSE
            curso := TO_NUMBER(SUBSTR(subcadena,1,1));
            INSERT INTO TEMP_ASIGNATURAS VALUES(codigo,OBTEN_GRUPO_ID(Titulacion,curso,letra));
        END IF;
        cont := cont + pos + 1;
        cadena_restada := substr(cadena_restada,pos+1, LENGTH(cadena_restada)- (pos));
        
    END LOOP;    
END NORMALIZA_ASIGNATURAS;
/

--Ejercicio 5                                           
create or replace PROCEDURE  RELLENA_ASIG_MATRICULA AS 
referencia2 number;
CURSOR cursor_alumnos is select * from alumnos_ext;
CURSOR cursor_asignaturas IS SELECT * FROM TEMP_ASIGNATURAS;
BEGIN
    FOR cada_alumno in cursor_alumnos LOOP 
        normaliza_asignaturas(cada_alumno.grupos_asignados,to_number(SUBSTR(cada_alumno.nexpediente,1,4)));
        FOR cada_asignatura in cursor_asignaturas LOOP
            SELECT REFERENCIA into referencia2 FROM ASIGNATURA WHERE CODIGO=cada_asignatura.codigo;
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
    grupoAntiguo varchar2(5);
    var_grupo varchar2(10);
    asig_nombre varchar2(100);
    titulacion number(5);
    asig_ref varchar2(10);
    BEGIN 
    	IF INSERTING THEN
        	SELECT grupo_id INTO grupoAux FROM GRUPO WHERE ID = :NEW.GRUPO_ID;
                UPDATE GRUPOS_POR_ASIGNATURA SET NUM_ALUMNOS=NUM_ALUMNOS+1, NUM_ALUMNOS_REAL=NUM_ALUMNOS_REAL+1 WHERE GRUPO_ID=:NEW.GRUPO_ID and asignatura_referencia = :new.asignatura_referencia;
                if grupoAux is not null then 
	                SELECT NOMBRE INTO asig_nombre FROM ASIGNATURA WHERE REFERENCIA = :NEW.ASIGNATURA_REFERENCIA;
	                SELECT TITULACION_CODIGO INTO titulacion FROM GRUPO WHERE ID = grupoAux;
	                SELECT REFERENCIA INTO asig_ref FROM ASIGNATURA WHERE TITULACION_CODIGO = titulacion AND NOMBRE = asig_nombre;
	                    UPDATE GRUPOS_POR_ASIGNATURA SET NUM_ALUMNOS_REAL=NUM_ALUMNOS_REAL+1 where  ASIGNATURA_REFERENCIA = asig_ref AND GRUPO_ID = grupoAux;
                end if;
     	ELSIF DELETING THEN
        	SELECT grupo_id INTO grupoAux FROM GRUPO WHERE ID = :NEW.GRUPO_ID;
                UPDATE GRUPOS_POR_ASIGNATURA SET NUM_ALUMNOS=NUM_ALUMNOS-1, NUM_ALUMNOS_REAL=NUM_ALUMNOS_REAL-1 WHERE GRUPO_ID=:NEW.GRUPO_ID AND ASIGNATURA_REFERENCIA = :NEW.ASIGNATURA_REFERENCIA;
                if grupoAux is not null then 
                	SELECT NOMBRE INTO asig_nombre FROM ASIGNATURA WHERE REFERENCIA = :NEW.ASIGNATURA_REFERENCIA;
	                SELECT TITULACION_CODIGO INTO titulacion FROM GRUPO WHERE ID = grupoAux;
	                SELECT REFERENCIA INTO asig_ref FROM ASIGNATURA WHERE TITULACION_CODIGO = titulacion AND NOMBRE = asig_nombre;

                    UPDATE GRUPOS_POR_ASIGNATURA SET NUM_ALUMNOS_REAL=NUM_ALUMNOS_REAL-1 where ASIGNATURA_REFERENCIA = asig_ref AND GRUPO_ID = grupoAux;
                end if;
       	ELSIF UPDATING THEN
            	if :NEW.GRUPO_ID IS NOT NULL THEN
                    SELECT grupo_id INTO grupoAux FROM GRUPO WHERE ID = :NEW.GRUPO_ID;
                else
                    grupoAux := null;
                end if;
	            	
                if :OLD.GRUPO_ID IS NOT NULL THEN
                    SELECT grupo_id INTO grupoAntiguo FROM GRUPO WHERE ID = :OLD.GRUPO_ID;
                else
                    grupoAntiguo := null;
                end if;
	                UPDATE GRUPOS_POR_ASIGNATURA SET NUM_ALUMNOS=NUM_ALUMNOS-1, NUM_ALUMNOS_REAL=NUM_ALUMNOS_REAL-1 WHERE GRUPO_ID=:OLD.GRUPO_ID and asignatura_referencia = :new.asignatura_referencia;
	                UPDATE GRUPOS_POR_ASIGNATURA SET NUM_ALUMNOS=NUM_ALUMNOS+1, NUM_ALUMNOS_REAL=NUM_ALUMNOS_REAL+1 WHERE GRUPO_ID=:NEW.GRUPO_ID and asignatura_referencia = :new.asignatura_referencia;

	                if grupoAux is not null then 

	                	SELECT NOMBRE INTO asig_nombre FROM ASIGNATURA WHERE REFERENCIA = :NEW.ASIGNATURA_REFERENCIA;
	                	SELECT TITULACION_CODIGO INTO titulacion FROM GRUPO WHERE ID = grupoAux;
	                	SELECT REFERENCIA INTO asig_ref FROM ASIGNATURA WHERE TITULACION_CODIGO = titulacion AND NOMBRE = asig_nombre;

	                    UPDATE GRUPOS_POR_ASIGNATURA SET NUM_ALUMNOS_REAL=NUM_ALUMNOS_REAL+1 where asignatura_referencia = asig_ref AND GRUPOS_POR_ASIGNATURA.grupo_id = grupoAux;
	                end if;

	            if grupoAntiguo IS NOT NULL THEN

	            	SELECT NOMBRE INTO asig_nombre FROM ASIGNATURA WHERE REFERENCIA = :OLD.ASIGNATURA_REFERENCIA;
	                SELECT TITULACION_CODIGO INTO titulacion FROM GRUPO WHERE ID = grupoAntiguo;
	                SELECT REFERENCIA INTO asig_ref FROM ASIGNATURA WHERE TITULACION_CODIGO = titulacion AND NOMBRE = asig_nombre;

	                UPDATE GRUPOS_POR_ASIGNATURA SET NUM_ALUMNOS_REAL=NUM_ALUMNOS_REAL-1 where asignatura_referencia = asig_ref AND GRUPOS_POR_ASIGNATURA.grupo_id = grupoAntiguo;
	            END IF;

           END IF;
END ACTUALIZAR_ALUMNOS;
/

--e
create or replace package PK_ASIGNACION_GRUPOS as 
procedure PR_ASIGNA_ASIGNADOS;
procedure PR_ASIGNA_INGLES_NUEVO;
procedure PR_ASIGNA_TARDE_NUEVO;
procedure PR_ASIGNA_RESTO_NUEVO;
procedure PR_ASIGNA_INGLES_ANTIGUO;
procedure PR_ASIGNA_RESTO_ANTIGUO;
end PK_ASIGNACION_GRUPOS;
/
create or replace package body PK_ASIGNACION_GRUPOS as
    procedure PR_ASIGNA_ASIGNADOS is 
    cursor alumnoCursor is select AE.grupos_asignados, NI.expediente from nuevo_ingreso NI join alumnos_ext AE on NI.documento = AE.documento where AE.grupos_asignados is not null;
    cursor asignaturaCursor is select * from temp_asignaturas;
    pcadena varchar2(200);
    subcadena varchar2(20);
    letra varchar2(1);
    tieneGrupo Integer;
    begin
        for al in alumnoCursor loop
            normaliza_asignaturas(al.grupos_asignados, substr(al.expediente,1,4));
            tieneGrupo := 0;
            for unAsig in asignaturaCursor loop
                if unAsig.grupo is not null then
                    letra := substr(unAsig.grupo, length(unAsig.grupo) - 1,1);
                    tieneGrupo := 1;
                end if;
            end loop;
            for unAsig in asignaturaCursor loop
                if tieneGrupo = 1 then
                    letra := substr(unAsig.grupo,4,1);
                    if letra is null then 
                        insert into errores values(sysdate, 'No tiene letra del grupo', unAsig.codigo, CURSO_ACTUAL(),null, null,al.expediente, to_number(substr(al.expediente,1,4)));
                    else
                        update ASIGNATURAS_MATRICULA set grupo_id = unAsig.grupo 
                            WHERE MATRICULA_EXPEDIENTES_NEXP=al.expediente AND ASIGNATURA_REFERENCIA=(SELECT REFERENCIA FROM ASIGNATURA WHERE CODIGO = unAsig.codigo and titulacion_codigo = to_number(substr(al.expediente,1,4)));
                    end if;
                else
                    update ASIGNATURAS_MATRICULA set grupo_id = null
                            WHERE MATRICULA_EXPEDIENTES_NEXP=al.expediente AND ASIGNATURA_REFERENCIA=(SELECT REFERENCIA FROM ASIGNATURA WHERE CODIGO = unAsig.codigo and titulacion_codigo = to_number(substr(al.expediente,1,4)));
                end if;
            end loop;
        end loop;
    end PR_ASIGNA_ASIGNADOS;
    
    --g
   procedure PR_ASIGNA_INGLES_NUEVO is
        cursor alumnos_nuevos is select asig_ingles, expediente from nuevo_ingreso where asig_ingles is not null;
        var_letra varchar2(4);
        var_curso number;
        var_titulacion number;
        var_asig number;
        var_refer number;
        grupoEspanol varchar2(20);
        grupoIngles varchar2(20);
        contador number(8);
        asignatura varchar2(20);
        fallo exception;
        codigo_error number;
        LETRA VARCHAR2(1);
    begin 

        for unalumno in alumnos_nuevos loop
            begin
            contador := 1;
            SELECT id INTO grupoEspanol FROM GRUPO WHERE sustituye_ingles='si' AND TITULACION_CODIGO = to_number(substr(unalumno.expediente,1,4)) AND CURSO = 1;
            update asignaturas_matricula AM set grupo_id=grupoEspanol where matricula_expedientes_nexp = unalumno.EXPEDIENTE AND ASIGNATURA_REFERENCIA IN (SELECT REFERENCIA FROM ASIGNATURA A WHERE AM.ASIGNATURA_REFERENCIA = A.REFERENCIA AND A.CURSO = 1 AND A.TITULACION_CODIGO = to_number(substr(unalumno.expediente,1,4)));

            normaliza_asignaturas(unalumno.asig_ingles, to_number(substr(unalumno.expediente,1,4)));
            for v_asignatura in (select * from temp_asignaturas) loop  
           
                SELECT id into grupoIngles FROM GRUPO WHERE TITULACION_CODIGO = to_number(substr(unalumno.expediente,1,4)) AND CURSO = 1 AND LETRA = LETRA_GRUPO_INGLES(to_number(substr(unalumno.expediente,1,4)), v_asignatura.codigo);
                
                SELECT REFERENCIA into var_refer FROM ASIGNATURA WHERE TITULACION_CODIGO = to_number(substr(unalumno.expediente,1,4)) AND CODIGO = v_asignatura.codigo;
                update asignaturas_matricula AM set grupo_id=grupoIngles where matricula_expedientes_nexp = unalumno.EXPEDIENTE AND ASIGNATURA_REFERENCIA IN (SELECT REFERENCIA FROM ASIGNATURA WHERE CURSO = 1 AND TITULACION_CODIGO = to_number(substr(unalumno.expediente,1,4)) AND codigo = v_asignatura.codigo);
            end loop;

            if grupoIngles is null then raise fallo; end if; 
            exception
             when fallo then 
                DBMS_OUTPUT.put_line ('ERROR: No se ha encontrado grupo de ingles.');  
             when others then 
                codigo_error := sqlcode;
             DBMS_OUTPUT.put_line ('Error desconocido. ' || codigo_error);
            end;  
        end loop;
    end PR_ASIGNA_INGLES_NUEVO;

    --h
    procedure PR_ASIGNA_TARDE_NUEVO is
    cursor inglesTarde is select NI.asig_ingles, M.TURNO_PREFERENTE, M.EXPEDIENTES_NUM_EXPEDIENTE from nuevo_ingreso NI join matricula M on NI.EXPEDIENTE = M.expedientes_num_expediente where NI.ASIG_INGLES is null and M.turno_preferente='Tarde';
    grupoTarde varchar2(20);
    fallo exception;
    codigo_error number;
    begin
    for alumno in inglesTarde loop
        begin
            select id into grupoTarde from grupo where TURNO_MANNANA_TARDE= 'TARDE' and titulacion_codigo = to_number(substr(alumno.expedientes_num_expediente,1,4)) and curso = 1; 
            
            update asignaturas_matricula set grupo_id=grupoTarde where matricula_expedientes_nexp = alumno.EXPEDIENTES_NUM_EXPEDIENTE;
            if grupoTarde = null then raise fallo; end if; 
        exception
            when fallo then DBMS_OUTPUT.put_line ('ERROR: No se ha encontrado grupo de tarde.');
            when others then 
                codigo_error := sqlcode;
             DBMS_OUTPUT.put_line ('Error desconocido. ' || codigo_error);
            end;  
    end loop;
        
    end PR_ASIGNA_TARDE_NUEVO;

    --i
   procedure PR_ASIGNA_RESTO_NUEVO is
    cursor nuevoAlumno is select M.*, NI.* from nuevo_ingreso NI, matricula M where NI.ASIG_INGLES is null AND M.TURNO_PREFERENTE != 'Tarde' order by M.fecha_de_matricula asc;
    var_grupo VARCHAR2(10);
    var_g2 VARCHAR2(10);
    plazas NUMBER;
    plazas_g2 NUMBER;
    alumnos_g1 number;
    alumnos_g2 number;
    grupoA number(1);
    begin
        select id into var_grupo from grupo where curso=1 and turno_mannana_tarde!='TARDE' and ingles='no' and plazas_nuevo_ingreso is not null;
        select id into var_g2 from grupo where curso=1 and turno_mannana_tarde!='TARDE' and ingles='no' and plazas_nuevo_ingreso is not null and id!=var_grupo;
       
        grupoA := 1;
        SELECT COUNT(*) into alumnos_g1 FROM asignaturas_matricula WHERE grupo_id = var_grupo;
        SELECT COUNT(*) into alumnos_g2 FROM asignaturas_matricula WHERE grupo_id = var_grupo;
        select plazas_nuevo_ingreso into plazas from grupo where id=var_grupo;
        select plazas_nuevo_ingreso into plazas_g2 from grupo where id=var_g2;
        for unAlumno in nuevoAlumno loop
            
            if (alumnos_g1<plazas  AND grupoA = 1) OR (alumnos_g2 >= plazas_g2) then
                update asignaturas_matricula set grupo_id=var_grupo where unAlumno.curso_academico=MATRICULA_CURSO_ACADEMICO and unAlumno.expediente=MATRICULA_EXPEDIENTES_NEXP;
                alumnos_g1 := alumnos_g1+1;
                grupoA := 0;
            elsif alumnos_g2 <plazas_g2 then
                
                update asignaturas_matricula set grupo_id=var_grupo where unAlumno.curso_academico=MATRICULA_CURSO_ACADEMICO and unAlumno.expediente=MATRICULA_EXPEDIENTES_NEXP;
                alumnos_g2 := alumnos_g2 + 1;
                grupoA := 1;
            end if;
        end loop;
    end PR_ASIGNA_RESTO_NUEVO;
    
    --k
   procedure PR_ASIGNA_INGLES_ANTIGUO is
        cursor alumnos_nuevos is select asig_ingles, expediente from nuevo_ingreso where asig_ingles is not null;
        var_curso number;
        var_refer number;
        grupoEspanol varchar2(20);
        grupoIngles varchar2(20);
        contador number(8);
        asignatura varchar2(20);
        fallo exception;
        codigo_error number;
        encontrado1 number;
        encontrado2 number;
    begin 
        for unalumno in alumnos_nuevos loop
            begin
                encontrado1:=0;
                encontrado2:=0;
                contador := 1;
                while((contador<=length(unalumno.asig_ingles)) or (encontrado1 = 1 and encontrado2=1)) loop
                    if (encontrado1=0 and substr(unalumno.asig_ingles, contador,1)='1') then
                        SELECT id INTO grupoEspanol FROM GRUPO WHERE sustituye_ingles='si' AND TITULACION_CODIGO = to_number(substr(unalumno.expediente,1,4)) AND CURSO = 1;
                        update asignaturas_matricula AM set grupo_id=grupoEspanol where matricula_expedientes_nexp = unalumno.EXPEDIENTE AND ASIGNATURA_REFERENCIA IN (SELECT REFERENCIA FROM ASIGNATURA A WHERE AM.ASIGNATURA_REFERENCIA = A.REFERENCIA AND A.CURSO = 1 AND A.TITULACION_CODIGO = to_number(substr(unalumno.expediente,1,4)));
                        SELECT id into grupoIngles FROM GRUPO WHERE TITULACION_CODIGO = to_number(substr(unalumno.expediente,1,4)) AND CURSO = 1 AND LETRA = LETRA_GRUPO_INGLES(to_number(substr(unalumno.expediente,1,4)), asignatura);
                        encontrado1:=1;
                    end if;
                    if (encontrado2=0 and substr(unalumno.asig_ingles, contador,1)='2') then
                        SELECT id INTO grupoEspanol FROM GRUPO WHERE sustituye_ingles='si' AND TITULACION_CODIGO = to_number(substr(unalumno.expediente,1,4)) AND CURSO = 2;
                        update asignaturas_matricula AM set grupo_id=grupoEspanol where matricula_expedientes_nexp = unalumno.EXPEDIENTE AND ASIGNATURA_REFERENCIA IN (SELECT REFERENCIA FROM ASIGNATURA A WHERE AM.ASIGNATURA_REFERENCIA = A.REFERENCIA AND A.CURSO = 2 AND A.TITULACION_CODIGO = to_number(substr(unalumno.expediente,1,4)));
                        SELECT id into grupoIngles FROM GRUPO WHERE TITULACION_CODIGO = to_number(substr(unalumno.expediente,1,4)) AND CURSO = 2 AND LETRA = LETRA_GRUPO_INGLES(to_number(substr(unalumno.expediente,1,4)), asignatura);
                        encontrado2:=2;
                    end if;
                    contador := contador + 4;
                end loop;

                normaliza_asignaturas(unalumno.asig_ingles, to_number(substr(unalumno.expediente,1,4)));
            for v_asignatura in (select * from temp_asignaturas) loop
                  SELECT REFERENCIA into var_refer FROM ASIGNATURA WHERE TITULACION_CODIGO = to_number(substr(unalumno.expediente,1,4)) AND CODIGO = v_asignatura.codigo;
                  update asignaturas_matricula AM set grupo_id=grupoIngles where matricula_expedientes_nexp = unalumno.EXPEDIENTE AND ASIGNATURA_REFERENCIA IN (SELECT REFERENCIA FROM ASIGNATURA WHERE TITULACION_CODIGO = to_number(substr(unalumno.expediente,1,4)) AND codigo = v_asignatura.codigo);
            end loop;
            if grupoIngles is null then raise fallo; end if; 
            exception
             when fallo then 
                DBMS_OUTPUT.put_line ('ERROR: No se ha encontrado grupo de ingles.');  
             when others then 
                codigo_error := sqlcode;
             DBMS_OUTPUT.put_line ('Error desconocido. ' || codigo_error);
            end;  
        end loop;
    end PR_ASIGNA_INGLES_ANTIGUO;
    
--l
    procedure PR_ASIGNA_RESTO_ANTIGUO is 
        cursor alumAntiguos is select en.expediente, en.preferencias from encuesta_nueva en join asignaturas_matricula AM on en.expediente = am.matricula_expedientes_nexp where AM.grupo_id is null and en.expediente not in (select expediente from errores);
        begin 
            for alumno in alumAntiguos loop
                normaliza_asignaturas(alumno.preferencias, to_number(substr(alumno.expediente,1,4)));
                for v_asignatura in (select * from temp_asignaturas) loop
                    update asignaturas_matricula set grupo_id = v_asignatura.grupo where asignatura_referencia in (select referencia from asignatura 
                        where codigo = v_asignatura.codigo and titulacion_codigo = to_number(substr(alumno.expediente,1,4)));
                end loop;
            end loop;
    end PR_ASIGNA_RESTO_ANTIGUO;
    
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
        VAR_CURSO := SUBSTR(CASIGNATURA,1,1);
        SELECT LETRA INTO VAR_LETRA FROM GRUPO WHERE CURSO=VAR_CURSO AND TITULACION_CODIGO=CTITULACION AND INGLES like 'si';
    ELSE 
        VAR_LETRA := 'NULL';
    END IF;
    RETURN VAR_LETRA;
END LETRA_GRUPO_INGLES;
/

--j
CREATE TABLE ENCUESTA_NUEVA (
    DOCUMENTO	VARCHAR2(20 BYTE),
    EXPEDIENTE	VARCHAR2(100 BYTE),
    ARCHIVO	VARCHAR2(100 BYTE),
    ASIG_INGLES	VARCHAR2(200 BYTE)
    );

--m
create or replace procedure PR_ASIGNA as 
begin 
    
    PK_ASIGNACION_GRUPOS.PR_ASIGNA_ASIGNADOS;
    PK_ASIGNACION_GRUPOS.PR_ASIGNA_INGLES_NUEVO;
    PK_ASIGNACION_GRUPOS.PR_ASIGNA_TARDE_NUEVO;
    PK_ASIGNACION_GRUPOS.PR_ASIGNA_RESTO_NUEVO;
    PK_ASIGNACION_GRUPOS.PR_ASIGNA_INGLES_ANTIGUO;
    PK_ASIGNACION_GRUPOS.PR_ASIGNA_RESTO_ANTIGUO;
    
end PR_ASIGNA;
/    

--n
CREATE OR REPLACE VIEW V_ASIGNATURAS AS
SELECT ASIG.TITULACION_CODIGO, AM.MATRICULA_EXPEDIENTES_NEXP, AL.DOCUMENTO, AL.APELLIDO1 ||', '|| AL.NOMBRE "NOMBRE", SUBSTR(AM.GRUPO_ID,3,1) "CURSO", ASIG.CODIGO, SUBSTR(AM.GRUPO_ID,4,1) "LETRA"
    FROM ASIGNATURA ASIG, ASIGNATURAS_MATRICULA AM, ALUMNOS_EXT AL WHERE ASIG.REFERENCIA = AM.ASIGNATURA_REFERENCIA AND AL.NEXPEDIENTE = AM.MATRICULA_EXPEDIENTES_NEXP;

