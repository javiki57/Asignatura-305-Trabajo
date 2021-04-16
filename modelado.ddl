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
    móvil                       INTEGER,
    dirección_notificiacion     VARCHAR2(128),
    código_postal_notificación  INTEGER,
    fecha_nacimiento            DATE
);

ALTER TABLE alumno ADD CONSTRAINT alumno_pk PRIMARY KEY ( id );

ALTER TABLE alumno ADD CONSTRAINT alumno_dni_un UNIQUE ( dni );

CREATE TABLE asignatura (
    referencia                       INTEGER NOT NULL,
    código                           INTEGER NOT NULL,
    créditos                         INTEGER NOT NULL,
    ofertada                         CHAR(1) NOT NULL,
    nombre                           VARCHAR2(128) NOT NULL,
    curso                            INTEGER,
    carácter                         VARCHAR2(128),
    duración                         INTEGER,
    "Undiad_Temporal(Cuatrimestre)"  INTEGER,
    idiomas_de_impartición           VARCHAR2(128),
    titulación_código                INTEGER NOT NULL,
    departamento                     VARCHAR2(128)
);

ALTER TABLE asignatura ADD CONSTRAINT asignatura_pk PRIMARY KEY ( referencia );

CREATE TABLE asignatura_matricula (
    asignatura_referencia      INTEGER NOT NULL,
    matrícula_curso_académico  INTEGER NOT NULL,
    matrícula_num_exp          INTEGER NOT NULL,
    grupo_id                   INTEGER
);

ALTER TABLE asignatura_matricula
    ADD CONSTRAINT asignatura_matricula_pk PRIMARY KEY ( asignatura_referencia,
                                                         matrícula_curso_académico,
                                                         matrícula_num_exp );

CREATE TABLE centro (
    id               INTEGER NOT NULL,
    nombre           VARCHAR2(128) NOT NULL,
    dirección        VARCHAR2(128) NOT NULL,
    tlf_conserjería  INTEGER
);

ALTER TABLE centro ADD CONSTRAINT centro_pk PRIMARY KEY ( id );

ALTER TABLE centro ADD CONSTRAINT centro_nombre_un UNIQUE ( nombre );

CREATE TABLE clase (
    día                    DATE NOT NULL,
    hora_inicio            DATE NOT NULL,
    hora_fin               DATE,
    asignatura_referencia  INTEGER NOT NULL,
    grupo_id               INTEGER NOT NULL
);

ALTER TABLE clase
    ADD CONSTRAINT clase_pk PRIMARY KEY ( día,
                                          hora_inicio,
                                          grupo_id );

CREATE TABLE encuesta (
    fecha_de_envío             DATE NOT NULL,
    expediente_num_expediente  INTEGER NOT NULL
);

ALTER TABLE encuesta ADD CONSTRAINT encuesta_pk PRIMARY KEY ( fecha_de_envío );

CREATE TABLE expediente (
    num_expediente               INTEGER NOT NULL,
    activo                       CHAR(1),
    nota_media_provisional       NUMBER,
    titulación_código            INTEGER NOT NULL,
    alumno_id                    VARCHAR2(128) NOT NULL,
    créditos_superados           INTEGER,
    créditos_formación_básica    INTEGER,
    créditos_optativos           INTEGER,
    créditos_prácticas_externas  INTEGER,
    créditos_tfg                 INTEGER,
    créditos_cf                  INTEGER
);

ALTER TABLE expediente ADD CONSTRAINT expediente_pk PRIMARY KEY ( num_expediente );

CREATE TABLE grupo (
    id                  INTEGER NOT NULL,
    curso               INTEGER NOT NULL,
    letra               CHAR(1) NOT NULL,
    turno_mañana_tarde  VARCHAR2(128) NOT NULL,
    inglés              CHAR(1) NOT NULL,
    visible             CHAR(1),
    asignar             CHAR(1),
    plazas              INTEGER,
    grupo_id            INTEGER,
    titulación_código   INTEGER NOT NULL
);

ALTER TABLE grupo ADD CONSTRAINT grupo_pk PRIMARY KEY ( id );

ALTER TABLE grupo ADD CONSTRAINT grupo_letra_curso_un UNIQUE ( letra,
                                                               curso );

CREATE TABLE grupo_por_asignatura (
    curso_académico        INTEGER NOT NULL,
    oferta                 INTEGER,
    asignatura_referencia  INTEGER NOT NULL,
    grupo_id               INTEGER NOT NULL
);

ALTER TABLE grupo_por_asignatura
    ADD CONSTRAINT grupo_por_asignatura_pk PRIMARY KEY ( curso_académico,
                                                         asignatura_referencia,
                                                         grupo_id );

CREATE TABLE matrícula (
    curso_académico            INTEGER NOT NULL,
    estado                     VARCHAR2(128) NOT NULL,
    num_archivo                INTEGER,
    turno_preferente           VARCHAR2(128),
    fecha_de_matrícula         DATE NOT NULL,
    nuevo_ingreso              CHAR(1),
    listado_asignaturas        VARCHAR2(128),
    expediente_num_expediente  INTEGER NOT NULL
);

ALTER TABLE matrícula ADD CONSTRAINT matrícula_pk PRIMARY KEY ( curso_académico,
                                                                expediente_num_expediente );

CREATE TABLE op (
    referencia  INTEGER NOT NULL,
    plazas      INTEGER,
    mención     VARCHAR2(128)
);

ALTER TABLE op ADD CONSTRAINT op_pk PRIMARY KEY ( referencia );

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
                                                gp_por_asig_grupo_id );

CREATE TABLE relation_2 (
    titulación_código  INTEGER NOT NULL,
    centro_id          INTEGER NOT NULL
);

ALTER TABLE relation_2 ADD CONSTRAINT relation_2_pk PRIMARY KEY ( titulación_código,
                                                                  centro_id );

CREATE TABLE relation_24 (
    titulación_código  INTEGER NOT NULL,
    op_referencia      INTEGER NOT NULL
);

ALTER TABLE relation_24 ADD CONSTRAINT relation_24_pk PRIMARY KEY ( titulación_código,
                                                                    op_referencia );

CREATE TABLE titulación (
    código    INTEGER NOT NULL,
    nombre    VARCHAR2(128) NOT NULL,
    créditos  INTEGER NOT NULL
);

ALTER TABLE titulación ADD CONSTRAINT titulación_pk PRIMARY KEY ( código );

ALTER TABLE asignatura_matricula
    ADD CONSTRAINT asign_matricula_matrícula_fk FOREIGN KEY ( matrícula_curso_académico,
                                                              matrícula_num_exp )
        REFERENCES matrícula ( curso_académico,
                               expediente_num_expediente );

ALTER TABLE asignatura_matricula
    ADD CONSTRAINT asignatura_matricula_asig_fk FOREIGN KEY ( asignatura_referencia )
        REFERENCES asignatura ( referencia );

ALTER TABLE asignatura_matricula
    ADD CONSTRAINT asignatura_matricula_grupo_fk FOREIGN KEY ( grupo_id )
        REFERENCES grupo ( id );

ALTER TABLE asignatura
    ADD CONSTRAINT asignatura_titulación_fk FOREIGN KEY ( titulación_código )
        REFERENCES titulación ( código );

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
    ADD CONSTRAINT exp_titulación_fk FOREIGN KEY ( titulación_código )
        REFERENCES titulación ( código );

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
    ADD CONSTRAINT grupo_titulación_fk FOREIGN KEY ( titulación_código )
        REFERENCES titulación ( código );

ALTER TABLE matrícula
    ADD CONSTRAINT matrícula_expediente_fk FOREIGN KEY ( expediente_num_expediente )
        REFERENCES expediente ( num_expediente );

ALTER TABLE op
    ADD CONSTRAINT op_asignatura_fk FOREIGN KEY ( referencia )
        REFERENCES asignatura ( referencia );

ALTER TABLE relation_14
    ADD CONSTRAINT relation_14_encuesta_fk FOREIGN KEY ( encuesta_fecha )
        REFERENCES encuesta ( fecha_de_envío );

ALTER TABLE relation_14
    ADD CONSTRAINT relation_14_gp_por_asig_fk FOREIGN KEY ( gp_por_asig_curso,
                                                            gp_asig_referencia,
                                                            gp_por_asig_grupo_id )
        REFERENCES grupo_por_asignatura ( curso_académico,
                                          asignatura_referencia,
                                          grupo_id );

ALTER TABLE relation_2
    ADD CONSTRAINT relation_2_centro_fk FOREIGN KEY ( centro_id )
        REFERENCES centro ( id );

ALTER TABLE relation_2
    ADD CONSTRAINT relation_2_titulación_fk FOREIGN KEY ( titulación_código )
        REFERENCES titulación ( código );

ALTER TABLE relation_24
    ADD CONSTRAINT relation_24_op_fk FOREIGN KEY ( op_referencia )
        REFERENCES op ( referencia );

ALTER TABLE relation_24
    ADD CONSTRAINT relation_24_titulación_fk FOREIGN KEY ( titulación_código )
        REFERENCES titulación ( código );



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
