--Eduard Nicolás Cybulkiewicz
--Pedro Sánchez Machuca
--Javier Quirante Perez
--Paula Cuenca García 
--Roberto Navarro García 

--Desde system:
create user secretaria identified by secretaria;

create tablespace TS_SECRETARIA
DATAFILE 'autoracle.dbf'
SIZE 10M
AUTOEXTEND ON;


alter user secretaria default tablespace TS_SECRETARIA
quota unlimited on TS_SECRETARIA;

grant resource to secretaria;
grant create session to secretaria;

create tablespace TS_INDICES
DATAFILE 'secretaria.dbf'
SIZE 50M
AUTOEXTEND ON;

alter user secretaria default tablespace TS_INDICES
quota unlimited on TS_INDICES;

create or replace directory directorio_EXT as 'C:\Users\alumnos\Oracle';
grant write, read on directory directorio_EXT to secretaria;

--Desde SECRETARIA:
--Script de borrado:
DROP TABLE ALUMNO CASCADE CONSTRAINTS;
DROP TABLE ASIGNATURA CASCADE CONSTRAINTS;
DROP TABLE ASIGNATURA_MATRICULA CASCADE CONSTRAINTS;
DROP TABLE CENTRO CASCADE CONSTRAINTS;
DROP TABLE CLASE CASCADE CONSTRAINTS;
DROP TABLE ENCUESTA CASCADE CONSTRAINTS;
DROP TABLE EXPEDIENTE CASCADE CONSTRAINTS;
DROP TABLE GRUPO CASCADE CONSTRAINTS;
DROP TABLE GRUPO_POR_ASIGNATURA CASCADE CONSTRAINTS;
DROP TABLE MATRICULA CASCADE CONSTRAINTS;
DROP TABLE OP CASCADE CONSTRAINTS;
DROP TABLE RELATION_14 CASCADE CONSTRAINTS;
DROP TABLE RELATION_2 CASCADE CONSTRAINTS;
DROP TABLE RELATION_24 CASCADE CONSTRAINTS;
DROP TABLE TITULACION CASCADE CONSTRAINTS;

--Script de crear tablas:
-- Generado por Oracle SQL Developer Data Modeler 20.4.1.406.0906
--   en:        2021-04-16 11:18:08 CEST
--   sitio:      Oracle Database 11g
--   tipo:      Oracle Database 11g



-- predefined type, no DDL - MDSYS.SDO_GEOMETRY

-- predefined type, no DDL - XMLTYPE

CREATE TABLE alumno (
    id                          VARCHAR2(128) NOT NULL,
    dni                         VARCHAR2(128) NOT NULL,
    nombre_completo             VARCHAR2(128) NOT NULL,
    email_institucional         VARCHAR2(128) NOT NULL,
    email_personal              VARCHAR2(128),
    telefono                    INTEGER,
    movil                       INTEGER,
    direccion_notificiacion     VARCHAR2(128),
    codigo_postal_notificacion  INTEGER,
    fecha_nacimiento            DATE
);

ALTER TABLE alumno ADD CONSTRAINT alumno_pk PRIMARY KEY ( id ) USING INDEX TABLESPACE TS_INDICES;

ALTER TABLE alumno ADD CONSTRAINT alumno_dni_un UNIQUE ( dni );

CREATE TABLE asignatura (
    referencia                       INTEGER NOT NULL,
    codigo                           INTEGER NOT NULL,
    creditos                         INTEGER NOT NULL,
    ofertada                         CHAR(1) NOT NULL,
    nombre                           VARCHAR2(128) NOT NULL,
    curso                            INTEGER,
    caracter                         VARCHAR2(128),
    duracion                         INTEGER,
    "Undiad_Temporal(Cuatrimestre)"  INTEGER,
    idiomas_de_imparticion           VARCHAR2(128),
    titulacion_codigo                INTEGER NOT NULL,
    departamento                     VARCHAR2(128)
);

ALTER TABLE asignatura ADD CONSTRAINT asignatura_pk PRIMARY KEY ( referencia ) USING INDEX TABLESPACE TS_INDICES;

CREATE TABLE asignatura_matricula (
    asignatura_referencia      INTEGER NOT NULL,
    matricula_curso_academico  INTEGER NOT NULL,
    matricula_num_exp          INTEGER NOT NULL,
    grupo_id                   INTEGER
);

ALTER TABLE asignatura_matricula
    ADD CONSTRAINT asignatura_matricula_pk PRIMARY KEY ( asignatura_referencia,
                                                         matricula_curso_academico,
                                                         matricula_num_exp ) USING INDEX TABLESPACE TS_INDICES;

CREATE TABLE centro (
    id               INTEGER NOT NULL,
    nombre           VARCHAR2(128) NOT NULL,
    direccion        VARCHAR2(128) NOT NULL,
    tlf_conserjeria  INTEGER
);

ALTER TABLE centro ADD CONSTRAINT centro_pk PRIMARY KEY ( id ) USING INDEX TABLESPACE TS_INDICES;

ALTER TABLE centro ADD CONSTRAINT centro_nombre_un UNIQUE ( nombre );

CREATE TABLE clase (
    dia                    DATE NOT NULL,
    hora_inicio            DATE NOT NULL,
    hora_fin               DATE,
    asignatura_referencia  INTEGER NOT NULL,
    grupo_id               INTEGER NOT NULL
);

ALTER TABLE clase
    ADD CONSTRAINT clase_pk PRIMARY KEY ( dia,
                                          hora_inicio,
                                          grupo_id ) USING INDEX TABLESPACE TS_INDICES;

CREATE TABLE encuesta (
    fecha_de_envio             DATE NOT NULL,
    expediente_num_expediente  INTEGER NOT NULL
);

ALTER TABLE encuesta ADD CONSTRAINT encuesta_pk PRIMARY KEY ( fecha_de_envio ) USING INDEX TABLESPACE TS_INDICES;

CREATE TABLE expediente (
    num_expediente               INTEGER NOT NULL,
    activo                       CHAR(1),
    nota_media_provisional       NUMBER,
    titulacion_codigo            INTEGER NOT NULL,
    alumno_id                    VARCHAR2(128) NOT NULL,
    creditos_superados           INTEGER,
    creditos_formacion_basica    INTEGER,
    creditos_optativos           INTEGER,
    creditos_practicas_externas  INTEGER,
    creditos_tfg                 INTEGER,
    creditos_cf                  INTEGER
);

ALTER TABLE expediente ADD CONSTRAINT expediente_pk PRIMARY KEY ( num_expediente ) USING INDEX TABLESPACE TS_INDICES;

CREATE TABLE grupo (
    id                  INTEGER NOT NULL,
    curso               INTEGER NOT NULL,
    letra               CHAR(1) NOT NULL,
    turno_manana_tarde  VARCHAR2(128) NOT NULL,
    ingles              CHAR(1) NOT NULL,
    visible             CHAR(1),
    asignar             CHAR(1),
    plazas              INTEGER,
    grupo_id            INTEGER,
    titulacion_codigo   INTEGER NOT NULL
);

ALTER TABLE grupo ADD CONSTRAINT grupo_pk PRIMARY KEY ( id ) USING INDEX TABLESPACE TS_INDICES;

ALTER TABLE grupo ADD CONSTRAINT grupo_letra_curso_un UNIQUE ( letra,
                                                               curso );

CREATE TABLE grupo_por_asignatura (
    curso_academico        INTEGER NOT NULL,
    oferta                 INTEGER,
    asignatura_referencia  INTEGER NOT NULL,
    grupo_id               INTEGER NOT NULL
);

ALTER TABLE grupo_por_asignatura
    ADD CONSTRAINT grupo_por_asignatura_pk PRIMARY KEY ( curso_academico,
                                                         asignatura_referencia,
                                                         grupo_id ) USING INDEX TABLESPACE TS_INDICES;

CREATE TABLE matricula (
    curso_academico            INTEGER NOT NULL,
    estado                     VARCHAR2(128) NOT NULL,
    num_archivo                INTEGER,
    turno_preferente           VARCHAR2(128),
    fecha_de_matricula         DATE NOT NULL,
    nuevo_ingreso              CHAR(1),
    listado_asignaturas        VARCHAR2(128),
    expediente_num_expediente  INTEGER NOT NULL
);

ALTER TABLE matricula ADD CONSTRAINT matricula_pk PRIMARY KEY ( curso_academico,
                                                                expediente_num_expediente ) USING INDEX TABLESPACE TS_INDICES;

CREATE TABLE op (
    referencia  INTEGER NOT NULL,
    plazas      INTEGER,
    mencion     VARCHAR2(128)
);

ALTER TABLE op ADD CONSTRAINT op_pk PRIMARY KEY ( referencia ) USING INDEX TABLESPACE TS_INDICES;

CREATE TABLE relation_14 (
    encuesta_fecha        DATE NOT NULL,
    gp_por_asig_curso     INTEGER NOT NULL,
    gp_asig_referencia    INTEGER NOT NULL,
    gp_por_asig_grupo_id  INTEGER NOT NULL
);

ALTER TABLE relation_14
    ADD CONSTRAINT relation_14_pk PRIMARY KEY ( encuesta_fecha,
                                                gp_por_asig_curso,
                                                gp_asig_referencia,
                                                gp_por_asig_grupo_id ) USING INDEX TABLESPACE TS_INDICES;

CREATE TABLE relation_2 (
    titulacion_codigo  INTEGER NOT NULL,
    centro_id          INTEGER NOT NULL
);

ALTER TABLE relation_2 ADD CONSTRAINT relation_2_pk PRIMARY KEY ( titulacion_codigo,
                                                                  centro_id ) USING INDEX TABLESPACE TS_INDICES;

CREATE TABLE relation_24 (
    titulacion_codigo  INTEGER NOT NULL,
    op_referencia      INTEGER NOT NULL
);

ALTER TABLE relation_24 ADD CONSTRAINT relation_24_pk PRIMARY KEY ( titulacion_codigo,
                                                                    op_referencia ) USING INDEX TABLESPACE TS_INDICES;

CREATE TABLE titulacion (
    codigo    INTEGER NOT NULL,
    nombre    VARCHAR2(128) NOT NULL,
    creditos  INTEGER NOT NULL
);

ALTER TABLE titulacion ADD CONSTRAINT titulacion_pk PRIMARY KEY ( codigo ) USING INDEX TABLESPACE TS_INDICES;

ALTER TABLE asignatura_matricula
    ADD CONSTRAINT asign_matricula_matricula_fk FOREIGN KEY ( matricula_curso_academico,
                                                              matricula_num_exp )
        REFERENCES matricula ( curso_academico,
                               expediente_num_expediente );

ALTER TABLE asignatura_matricula
    ADD CONSTRAINT asignatura_matricula_asig_fk FOREIGN KEY ( asignatura_referencia )
        REFERENCES asignatura ( referencia );

ALTER TABLE asignatura_matricula
    ADD CONSTRAINT asignatura_matricula_grupo_fk FOREIGN KEY ( grupo_id )
        REFERENCES grupo ( id );

ALTER TABLE asignatura
    ADD CONSTRAINT asignatura_titulacion_fk FOREIGN KEY ( titulacion_codigo )
        REFERENCES titulacion ( codigo );

ALTER TABLE clase
    ADD CONSTRAINT clase_asignatura_fk FOREIGN KEY ( asignatura_referencia )
        REFERENCES asignatura ( referencia );

ALTER TABLE clase
    ADD CONSTRAINT clase_grupo_fk FOREIGN KEY ( grupo_id )
        REFERENCES grupo ( id );

ALTER TABLE encuesta
    ADD CONSTRAINT encuesta_expediente_fk FOREIGN KEY ( expediente_num_expediente )
        REFERENCES expediente ( num_expediente );

ALTER TABLE expediente
    ADD CONSTRAINT exp_titulacion_fk FOREIGN KEY ( titulacion_codigo )
        REFERENCES titulacion ( codigo );

ALTER TABLE expediente
    ADD CONSTRAINT expediente_alumno_fk FOREIGN KEY ( alumno_id )
        REFERENCES alumno ( id );

ALTER TABLE grupo_por_asignatura
    ADD CONSTRAINT grupo_asign_asig_fk FOREIGN KEY ( asignatura_referencia )
        REFERENCES asignatura ( referencia );

ALTER TABLE grupo
    ADD CONSTRAINT grupo_grupo_fk FOREIGN KEY ( grupo_id )
        REFERENCES grupo ( id );

ALTER TABLE grupo_por_asignatura
    ADD CONSTRAINT grupo_por_asig_grupo_fk FOREIGN KEY ( grupo_id )
        REFERENCES grupo ( id );

ALTER TABLE grupo
    ADD CONSTRAINT grupo_titulacion_fk FOREIGN KEY ( titulacion_codigo )
        REFERENCES titulacion ( codigo );

ALTER TABLE matricula
    ADD CONSTRAINT matricula_expediente_fk FOREIGN KEY ( expediente_num_expediente )
        REFERENCES expediente ( num_expediente );

ALTER TABLE op
    ADD CONSTRAINT op_asignatura_fk FOREIGN KEY ( referencia )
        REFERENCES asignatura ( referencia );

ALTER TABLE relation_14
    ADD CONSTRAINT relation_14_encuesta_fk FOREIGN KEY ( encuesta_fecha )
        REFERENCES encuesta ( fecha_de_envio );

ALTER TABLE relation_14
    ADD CONSTRAINT relation_14_gp_por_asig_fk FOREIGN KEY ( gp_por_asig_curso,
                                                            gp_asig_referencia,
                                                            gp_por_asig_grupo_id )
        REFERENCES grupo_por_asignatura ( curso_academico,
                                          asignatura_referencia,
                                          grupo_id );

ALTER TABLE relation_2
    ADD CONSTRAINT relation_2_centro_fk FOREIGN KEY ( centro_id )
        REFERENCES centro ( id );

ALTER TABLE relation_2
    ADD CONSTRAINT relation_2_titulacion_fk FOREIGN KEY ( titulacion_codigo )
        REFERENCES titulacion ( codigo );

ALTER TABLE relation_24
    ADD CONSTRAINT relation_24_op_fk FOREIGN KEY ( op_referencia )
        REFERENCES op ( referencia );

ALTER TABLE relation_24
    ADD CONSTRAINT relation_24_titulacion_fk FOREIGN KEY ( titulacion_codigo )
        REFERENCES titulacion ( codigo );
        

-- Informe de Resumen de Oracle SQL Developer Data Modeler: 
-- 
-- CREATE TABLE                            15
-- CREATE INDEX                             0
-- ALTER TABLE                             39
-- CREATE VIEW                              0
-- ALTER VIEW                               0
-- CREATE PACKAGE                           0
-- CREATE PACKAGE BODY                      0
-- CREATE PROCEDURE                         0
-- CREATE FUNCTION                          0
-- CREATE TRIGGER                           0
-- ALTER TRIGGER                            0
-- CREATE COLLECTION TYPE                   0
-- CREATE STRUCTURED TYPE                   0
-- CREATE STRUCTURED TYPE BODY              0
-- CREATE CLUSTER                           0
-- CREATE CONTEXT                           0
-- CREATE DATABASE                          0
-- CREATE DIMENSION                         0
-- CREATE DIRECTORY                         0
-- CREATE DISK GROUP                        0
-- CREATE ROLE                              0
-- CREATE ROLLBACK SEGMENT                  0
-- CREATE SEQUENCE                          0
-- CREATE MATERIALIZED VIEW                 0
-- CREATE MATERIALIZED VIEW LOG             0
-- CREATE SYNONYM                           0
-- CREATE TABLESPACE                        0
-- CREATE USER                              0
-- 
-- DROP TABLESPACE                          0
-- DROP DATABASE                            0
-- 
-- REDACTION POLICY                         0
-- 
-- ORDS DROP SCHEMA                         0
-- ORDS ENABLE SCHEMA                       0
-- ORDS ENABLE OBJECT                       0
-- 
-- ERRORS                                   0
-- WARNINGS                                 0

--Script de creacion de la tabla de alumnos externa
create table alumnosEXT (DOCUMENTO	varchar2(100),
NOMBRE	varchar2(100),
APELLIDO1	varchar2(100),
APELLIDO2	varchar2(100),
NEXPEDIENTE	varchar2(100),
NARCHIVO	varchar2(100),
EMAIL_INSTITUCIONAL	varchar2(100),
EMAIL_PERSONAL	varchar2(100),
TELEFONO	varchar2(100),
MOVIL	varchar2(100),
DIRECCION_NOTIFICACION	varchar2(100),
LOCALIDAD_NOTIFICACION	varchar2(100),
PROVINCIA_NOTIFICACION	varchar2(100),
CP_NOTIFICACION	varchar2(100),
FECHA_MATRICULA	varchar2(100),
TURNO_PREFERENTE	varchar2(100),
GRUPOS_ASIGNADOS	varchar2(200),
NOTA_MEDIA	varchar2(100),
CREDITOS_SUPERADOS	varchar2(100),
CREDITOS_FB	varchar2(100),
CREDITOS_OB	varchar2(100),
CREDITOS_OP	varchar2(100),
CREDITOS_CF	varchar2(100),
CREDITOS_PE	varchar2(100),
CREDITOS_TF	varchar2(100)) organization external 
( default directory directorio_ext
 access parameters
 ( records delimited by newline
 skip 4
 fields terminated by ';'
 )
 location ('alumnos.csv'));

select * from alumnosEXT;

CREATE SEQUENCE SECRETARIA.SEQUENCE_ALUMNO_ID MINVALUE 1 INCREMENT BY 1;

--insertar los datos desde las tablas externas a alumno
INSERT INTO ALUMNO select SEQUENCE_ALUMNO_ID.NEXTVAL,
DOCUMENTO, NOMBRE ||' '|| APELLIDO1 ||' '|| APELLIDO2, EMAIL_INSTITUCIONAL, EMAIL_PERSONAL, TELEFONO, MOVIL, DIRECCION_NOTIFICACION, CP_NOTIFICACION FROM ALUMNOSEXT;

--CREACION DE TODOS LOS INDICES

CREATE INDEX idx_titulacion_codigo
    ON titulacion(upper(codigo))
        TABLESPACE TS_INDICES;

CREATE INDEX idx_asignatura_referencia
    ON asignatura(upper(referencia))
        TABLESPACE TS_INDICES;

CREATE INDEX idx_centro_id
    ON centro(upper(id))
        TABLESPACE TS_INDICES;

CREATE INDEX idx_centro_nombre
    ON centro(upper(nombre))
        TABLESPACE TS_INDICES;

CREATE INDEX idx_op_referencia
    ON op(upper(referencia))
        TABLESPACE TS_INDICES;

CREATE INDEX idx_expediente
    ON expediente(upper(num_expediente))
        TABLESPACE TS_INDICES;

CREATE INDEX idx_alumno_id
    ON alumno(upper(id))
        TABLESPACE TS_INDICES;

CREATE INDEX idx_alumno_dni
    ON alumno(upper(dni))
        TABLESPACE TS_INDICES;

CREATE INDEX idx_encuesta_fecha
    ON encuesTa(upper(fecha_de_envio)) -- MODIFICAR FECHA DE ENVIO
        TABLESPACE TS_INDICES;

CREATE INDEX idx_grupo_asig_curso
    ON grupo_por_asignatura(upper(curso_academico))
        TABLESPACE TS_INDICES;
    
CREATE INDEX idx_grupo_asig_referencia
    ON grupo_por_asignatura(upper(asignatura_referencia))
        TABLESPACE TS_INDICES;

CREATE INDEX idx_grupo_asig_id
    ON grupo_por_asignatura(upper(grupo_id))
        TABLESPACE TS_INDICES;

CREATE INDEX idx_clase_dia
    ON clase(upper(dia)) 
        TABLESPACE TS_INDICES; --MODIFICAR DIA

CREATE INDEX idx_clase_hora
    ON clase(upper(hora_inicio)) 
        TABLESPACE TS_INDICES;
    
CREATE INDEX idx_clase_grupo_id
    ON clase(upper(grupo_id)) 
        TABLESPACE TS_INDICES;

CREATE INDEX idx_matricula_curso
    ON matricula(upper(curso_academico)) 
        TABLESPACE TS_INDICES; 
        
CREATE INDEX idx_matricula_exp
    ON matricula(upper(expediente_num_expediente)) 
        TABLESPACE TS_INDICES; 

CREATE INDEX idx_grupo_id
    ON grupo(upper(id)) 
        TABLESPACE TS_INDICES;

CREATE INDEX idx_grupo_curso
    ON grupo(upper(curso)) 
        TABLESPACE TS_INDICES;

CREATE INDEX idx_grupo_letra
    ON grupo(upper(letra)) 
        TABLESPACE TS_INDICES;

CREATE INDEX idx_asig_matricula_referencia
    ON asignatura_matricula(upper(asignatura_referencia)) 
        TABLESPACE TS_INDICES;
        
CREATE INDEX idx_asig_matricula_curso
    ON asignatura_matricula(upper(matricula_curso_academico)) 
        TABLESPACE TS_INDICES;
        
CREATE INDEX idx_asig_matricula_exp
    ON asignatura_matricula(upper(matricula_num_exp)) 
        TABLESPACE TS_INDICES;
        
CREATE INDEX idx_rel_14_encuesta
    ON relation_14(upper(encuesta_fecha)) 
        TABLESPACE TS_INDICES;
        
CREATE INDEX idx_rel_14_curso
    ON relation_14(upper(gp_por_asig_curso)) 
        TABLESPACE TS_INDICES;
        

CREATE INDEX idx_rel_14_referencia
    ON relation_14(upper(gp_asig_referencia)) 
        TABLESPACE TS_INDICES;
        
CREATE INDEX idx_rel_14_id
    ON relation_14(upper(gp_por_asig_grupo_id)) 
        TABLESPACE TS_INDICES;
                
CREATE INDEX idx_rel_2_id
    ON relation_2(upper(centro_id)) 
        TABLESPACE TS_INDICES;
                        
CREATE INDEX idx_rel_2_codigo
    ON relation_2(upper(titulacion_codigo)) 
        TABLESPACE TS_INDICES;
                                
CREATE INDEX idx_rel_24_codigo
    ON relation_24(upper(titulacion_codigo)) 
        TABLESPACE TS_INDICES;
          
CREATE INDEX idx_rel_24_referencia
    ON relation_24(upper(op_referencia)) 
        TABLESPACE TS_INDICES;

--Consultas para comprobar en que tablespace esta la tabla alumno y los indices
SELECT TABLE_NAME, TABLESPACE_NAME FROM USER_TABLES WHERE TABLE_NAME = 'ALUMNO';
SELECT INDEX_NAME, TABLESPACE_NAME FROM USER_INDEXES;

--Crear tres indices de tipo bitmap
create bitmap index idx_curso ON asignatura(curso) tablespace TS_INDICES;
create bitmap index idx_caracter ON asignatura(caracter) tablespace TS_INDICES;
create bitmap index idx_duracion ON asignatura(duracion) tablespace TS_INDICES;
SELECT * FROM USER_INDEXES WHERE INDEX_TYPE='BITMAP';
