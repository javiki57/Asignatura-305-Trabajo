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