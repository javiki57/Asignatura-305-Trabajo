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
    m�vil                       INTEGER,
    direcci�n_notificiacion     VARCHAR2(128),
    c�digo_postal_notificaci�n  INTEGER,
    fecha_nacimiento            DATE
);

ALTER TABLE alumno ADD CONSTRAINT alumno_pk PRIMARY KEY ( id ) USING INDEX TABLESPACE TS_INDICES;;

ALTER TABLE alumno ADD CONSTRAINT alumno_dni_un UNIQUE ( dni );

CREATE TABLE asignatura (
    referencia                       INTEGER NOT NULL,
    c�digo                           INTEGER NOT NULL,
    cr�ditos                         INTEGER NOT NULL,
    ofertada                         CHAR(1) NOT NULL,
    nombre                           VARCHAR2(128) NOT NULL,
    curso                            INTEGER,
    car�cter                         VARCHAR2(128),
    duraci�n                         INTEGER,
    "Undiad_Temporal(Cuatrimestre)"  INTEGER,
    idiomas_de_impartici�n           VARCHAR2(128),
    titulaci�n_c�digo                INTEGER NOT NULL,
    departamento                     VARCHAR2(128)
);

ALTER TABLE asignatura ADD CONSTRAINT asignatura_pk PRIMARY KEY ( referencia ) USING INDEX TABLESPACE TS_INDICES;

CREATE TABLE asignatura_matricula (
    asignatura_referencia      INTEGER NOT NULL,
    matr�cula_curso_acad�mico  INTEGER NOT NULL,
    matr�cula_num_exp          INTEGER NOT NULL,
    grupo_id                   INTEGER
);

ALTER TABLE asignatura_matricula
    ADD CONSTRAINT asignatura_matricula_pk PRIMARY KEY ( asignatura_referencia,
                                                         matr�cula_curso_acad�mico,
                                                         matr�cula_num_exp ) USING INDEX TABLESPACE TS_INDICES;

CREATE TABLE centro (
    id               INTEGER NOT NULL,
    nombre           VARCHAR2(128) NOT NULL,
    direcci�n        VARCHAR2(128) NOT NULL,
    tlf_conserjer�a  INTEGER
);

ALTER TABLE centro ADD CONSTRAINT centro_pk PRIMARY KEY ( id ) USING INDEX TABLESPACE TS_INDICES;

ALTER TABLE centro ADD CONSTRAINT centro_nombre_un UNIQUE ( nombre );

CREATE TABLE clase (
    d�a                    DATE NOT NULL,
    hora_inicio            DATE NOT NULL,
    hora_fin               DATE,
    asignatura_referencia  INTEGER NOT NULL,
    grupo_id               INTEGER NOT NULL
);

ALTER TABLE clase
    ADD CONSTRAINT clase_pk PRIMARY KEY ( d�a,
                                          hora_inicio,
                                          grupo_id ) USING INDEX TABLESPACE TS_INDICES;

CREATE TABLE encuesta (
    fecha_de_env�o             DATE NOT NULL,
    expediente_num_expediente  INTEGER NOT NULL
);

ALTER TABLE encuesta ADD CONSTRAINT encuesta_pk PRIMARY KEY ( fecha_de_env�o ) USING INDEX TABLESPACE TS_INDICES;

CREATE TABLE expediente (
    num_expediente               INTEGER NOT NULL,
    activo                       CHAR(1),
    nota_media_provisional       NUMBER,
    titulaci�n_c�digo            INTEGER NOT NULL,
    alumno_id                    VARCHAR2(128) NOT NULL,
    cr�ditos_superados           INTEGER,
    cr�ditos_formaci�n_b�sica    INTEGER,
    cr�ditos_optativos           INTEGER,
    cr�ditos_pr�cticas_externas  INTEGER,
    cr�ditos_tfg                 INTEGER,
    cr�ditos_cf                  INTEGER
);

ALTER TABLE expediente ADD CONSTRAINT expediente_pk PRIMARY KEY ( num_expediente ) USING INDEX TABLESPACE TS_INDICES;

CREATE TABLE grupo (
    id                  INTEGER NOT NULL,
    curso               INTEGER NOT NULL,
    letra               CHAR(1) NOT NULL,
    turno_ma�ana_tarde  VARCHAR2(128) NOT NULL,
    ingl�s              CHAR(1) NOT NULL,
    visible             CHAR(1),
    asignar             CHAR(1),
    plazas              INTEGER,
    grupo_id            INTEGER,
    titulaci�n_c�digo   INTEGER NOT NULL
);

ALTER TABLE grupo ADD CONSTRAINT grupo_pk PRIMARY KEY ( id ) USING INDEX TABLESPACE TS_INDICES;

ALTER TABLE grupo ADD CONSTRAINT grupo_letra_curso_un UNIQUE ( letra,
                                                               curso );

CREATE TABLE grupo_por_asignatura (
    curso_acad�mico        INTEGER NOT NULL,
    oferta                 INTEGER,
    asignatura_referencia  INTEGER NOT NULL,
    grupo_id               INTEGER NOT NULL
);

ALTER TABLE grupo_por_asignatura
    ADD CONSTRAINT grupo_por_asignatura_pk PRIMARY KEY ( curso_acad�mico,
                                                         asignatura_referencia,
                                                         grupo_id ) USING INDEX TABLESPACE TS_INDICES;

CREATE TABLE matr�cula (
    curso_acad�mico            INTEGER NOT NULL,
    estado                     VARCHAR2(128) NOT NULL,
    num_archivo                INTEGER,
    turno_preferente           VARCHAR2(128),
    fecha_de_matr�cula         DATE NOT NULL,
    nuevo_ingreso              CHAR(1),
    listado_asignaturas        VARCHAR2(128),
    expediente_num_expediente  INTEGER NOT NULL
);

ALTER TABLE matr�cula ADD CONSTRAINT matr�cula_pk PRIMARY KEY ( curso_acad�mico,
                                                                expediente_num_expediente ) USING INDEX TABLESPACE TS_INDICES;

CREATE TABLE op (
    referencia  INTEGER NOT NULL,
    plazas      INTEGER,
    menci�n     VARCHAR2(128)
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
    titulaci�n_c�digo  INTEGER NOT NULL,
    centro_id          INTEGER NOT NULL
);

ALTER TABLE relation_2 ADD CONSTRAINT relation_2_pk PRIMARY KEY ( titulaci�n_c�digo,
                                                                  centro_id ) USING INDEX TABLESPACE TS_INDICES;

CREATE TABLE relation_24 (
    titulaci�n_c�digo  INTEGER NOT NULL,
    op_referencia      INTEGER NOT NULL
);

ALTER TABLE relation_24 ADD CONSTRAINT relation_24_pk PRIMARY KEY ( titulaci�n_c�digo,
                                                                    op_referencia ) USING INDEX TABLESPACE TS_INDICES;

CREATE TABLE titulaci�n (
    c�digo    INTEGER NOT NULL,
    nombre    VARCHAR2(128) NOT NULL,
    cr�ditos  INTEGER NOT NULL
);

ALTER TABLE titulaci�n ADD CONSTRAINT titulaci�n_pk PRIMARY KEY ( c�digo ) USING INDEX TABLESPACE TS_INDICES;

ALTER TABLE asignatura_matricula
    ADD CONSTRAINT asign_matricula_matr�cula_fk FOREIGN KEY ( matr�cula_curso_acad�mico,
                                                              matr�cula_num_exp )
        REFERENCES matr�cula ( curso_acad�mico,
                               expediente_num_expediente );

ALTER TABLE asignatura_matricula
    ADD CONSTRAINT asignatura_matricula_asig_fk FOREIGN KEY ( asignatura_referencia )
        REFERENCES asignatura ( referencia );

ALTER TABLE asignatura_matricula
    ADD CONSTRAINT asignatura_matricula_grupo_fk FOREIGN KEY ( grupo_id )
        REFERENCES grupo ( id );

ALTER TABLE asignatura
    ADD CONSTRAINT asignatura_titulaci�n_fk FOREIGN KEY ( titulaci�n_c�digo )
        REFERENCES titulaci�n ( c�digo );

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
    ADD CONSTRAINT exp_titulaci�n_fk FOREIGN KEY ( titulaci�n_c�digo )
        REFERENCES titulaci�n ( c�digo );

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
    ADD CONSTRAINT grupo_titulaci�n_fk FOREIGN KEY ( titulaci�n_c�digo )
        REFERENCES titulaci�n ( c�digo );

ALTER TABLE matr�cula
    ADD CONSTRAINT matr�cula_expediente_fk FOREIGN KEY ( expediente_num_expediente )
        REFERENCES expediente ( num_expediente );

ALTER TABLE op
    ADD CONSTRAINT op_asignatura_fk FOREIGN KEY ( referencia )
        REFERENCES asignatura ( referencia );

ALTER TABLE relation_14
    ADD CONSTRAINT relation_14_encuesta_fk FOREIGN KEY ( encuesta_fecha )
        REFERENCES encuesta ( fecha_de_env�o );

ALTER TABLE relation_14
    ADD CONSTRAINT relation_14_gp_por_asig_fk FOREIGN KEY ( gp_por_asig_curso,
                                                            gp_asig_referencia,
                                                            gp_por_asig_grupo_id )
        REFERENCES grupo_por_asignatura ( curso_acad�mico,
                                          asignatura_referencia,
                                          grupo_id );

ALTER TABLE relation_2
    ADD CONSTRAINT relation_2_centro_fk FOREIGN KEY ( centro_id )
        REFERENCES centro ( id );

ALTER TABLE relation_2
    ADD CONSTRAINT relation_2_titulaci�n_fk FOREIGN KEY ( titulaci�n_c�digo )
        REFERENCES titulaci�n ( c�digo );

ALTER TABLE relation_24
    ADD CONSTRAINT relation_24_op_fk FOREIGN KEY ( op_referencia )
        REFERENCES op ( referencia );

ALTER TABLE relation_24
    ADD CONSTRAINT relation_24_titulaci�n_fk FOREIGN KEY ( titulaci�n_c�digo )
        REFERENCES titulaci�n ( c�digo );


--CREACION DE TODOS LOS INDICES

CREATE INDEX idx_titulacion_codigo
    ON titulación(upper(código))
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
    ON encuesTa(upper(fecha_de_envío)) -- MODIFICAR FECHA DE ENVIO
        TABLESPACE TS_INDICES;

CREATE INDEX idx_grupo_asig_curso
    ON grupo_por_asignatura(upper(curso_académico))
        TABLESPACE TS_INDICES;
    
CREATE INDEX idx_grupo_asig_referencia
    ON grupo_por_asignatura(upper(asignatura_referencia))
        TABLESPACE TS_INDICES;

CREATE INDEX idx_grupo_asig_id
    ON grupo_por_asignatura(upper(grupo_id))
        TABLESPACE TS_INDICES;

CREATE INDEX idx_clase_dia
    ON clase(upper(día)) 
        TABLESPACE TS_INDICES; --MODIFICAR DIA

CREATE INDEX idx_clase_hora
    ON clase(upper(hora_inicio)) 
        TABLESPACE TS_INDICES;
    
CREATE INDEX idx_clase_grupo_id
    ON clase(upper(grupo_id)) 
        TABLESPACE TS_INDICES;

CREATE INDEX idx_matricula_curso
    ON matrícula(upper(curso_académico)) 
        TABLESPACE TS_INDICES; 
        
CREATE INDEX idx_matricula_exp
    ON matrícula(upper(expediente_num_expediente)) 
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
    ON asignatura_matricula(upper(matrícula_curso_académico)) 
        TABLESPACE TS_INDICES;
        
CREATE INDEX idx_asig_matricula_exp
    ON asignatura_matricula(upper(matrícula_num_exp)) 
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
    ON relation_2(upper(titulación_código)) 
        TABLESPACE TS_INDICES;
                                
CREATE INDEX idx_rel_24_codigo
    ON relation_24(upper(titulación_código)) 
        TABLESPACE TS_INDICES;
          
CREATE INDEX idx_rel_24_referencia
    ON relation_24(upper(op_referencia)) 
        TABLESPACE TS_INDICES;
        


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
