-- SQL Manager for PostgreSQL 5.9.5.52424
-- ---------------------------------------
-- Host      : localhost
-- Database  : puntodeventa
-- Version   : PostgreSQL 11.5, compiled by Visual C++ build 1914, 64-bit



SET check_function_bodies = false;
--
-- Definition for function fn_producto_iu (OID = 32788) : 
--
SET search_path = public, pg_catalog;
CREATE FUNCTION public.fn_producto_iu (
  nombre character varying,
  codigo character varying,
  precio integer,
  imagen character varying,
  idcat integer,
  idun integer,
  cambioimagen boolean
)
RETURNS varchar
AS 
$body$
DECLARE

	_nombreproducto		ALIAS FOR $1;
    _codigodebarras		ALIAS FOR $2;
    _precio				ALIAS FOR $3;
    _imagen				ALIAS FOR $4;
    _idcategoria		ALIAS FOR $5;
    _idunidad			ALIAS FOR $6;
    _cambioimagen		ALIAS FOR $7;

    __existe VARCHAR;

BEGIN

	SELECT COUNT(a.idproducto) INTO __existe
    FROM public.producto AS a
    WHERE a.codigodebarras = _codigodebarras
    LIMIT 1;
    
    IF (__existe = '0') THEN
    
    	INSERT INTO 
          public.producto
        (
          nombreproducto,
          codigodebarras,
          precio,
          imagen,
          idcategoria,
          idunidad
        )
        VALUES (
          _nombreproducto,
          _codigodebarras,
          _precio,
          _imagen,
          _idcategoria,
          _idunidad
        );
        RETURN '0';

    END IF;
	
    IF (__existe = '1') THEN
    
    	IF (_cambioimagen = TRUE) THEN
    
            UPDATE 
              public.producto 
            SET 
              nombreproducto = _nombreproducto,
              precio = _precio,
              idcategoria = _idcategoria,
              idunidad = _idunidad,
              imagen = _imagen,
              activo = true
            WHERE 
              codigodebarras = _codigodebarras
            ;
            RETURN '1';
            
        ELSE
        
        	UPDATE 
              public.producto 
            SET 
              nombreproducto = _nombreproducto,
              precio = _precio,
              idcategoria = _idcategoria,
              idunidad = _idunidad,
              activo = true
            WHERE 
              codigodebarras = _codigodebarras
            ;
            RETURN '1';
            
            
        END IF;

    END IF;
    
    --RETURN '2';
    
EXCEPTION
    WHEN others THEN
		RETURN '2';

END;
$body$
LANGUAGE plpgsql;
--
-- Definition for function fn_producto_d (OID = 32790) : 
--
CREATE FUNCTION public.fn_producto_d (
  character varying
)
RETURNS varchar
AS 
$body$
DECLARE
  _codigodebarras ALIAS FOR $1;
  
  __existe VARCHAR;
  
BEGIN
	IF (_codigodebarras IS NULL) THEN
    	RETURN '1'; -- codigo nulo
    END IF;
    
    SELECT COUNT(a.idproducto) INTO __existe
    FROM public.producto AS a
    WHERE a.codigodebarras = _codigodebarras
    LIMIT 1;
    
    IF (__existe = '0') THEN
    	RETURN '2'; -- no existe codigo
    END IF;
    
    
	--DELETE FROM public.producto WHERE codigodebarras = _codigodebarras;
    UPDATE 
      public.producto 
    SET 
      activo = FALSE
    WHERE 
      codigodebarras = _codigodebarras
    ;
    RETURN '0';
    
END;
$body$
LANGUAGE plpgsql;
--
-- Structure for table producto (OID = 24588) : 
--
CREATE TABLE public.producto (
    idproducto integer DEFAULT nextval('producto_id_seq'::regclass) NOT NULL,
    nombreproducto varchar(30) NOT NULL,
    codigodebarras varchar(30) NOT NULL,
    precio integer NOT NULL,
    imagen varchar(100),
    idcategoria smallint DEFAULT 999,
    idunidad smallint DEFAULT 1,
    activo boolean DEFAULT true NOT NULL
)
WITH (oids = false);
--
-- Structure for table categoria (OID = 24594) : 
--
CREATE TABLE public.categoria (
    idcategoria smallint NOT NULL,
    nombrecategoria varchar(30) NOT NULL
)
WITH (oids = false);
--
-- Structure for table unidad (OID = 32782) : 
--
CREATE TABLE public.unidad (
    idunidad smallint NOT NULL,
    nombreunidad varchar(30) NOT NULL
)
WITH (oids = false);
--
-- Structure for table usuario (OID = 32794) : 
--
CREATE TABLE public.usuario (
    "Cod_usuario" serial NOT NULL,
    "Nombre" varchar(30) NOT NULL,
    "User" varchar(20) NOT NULL,
    "Password" text NOT NULL,
    "Tipo_usuario" varchar(10) NOT NULL
)
WITH (oids = false);
--
-- Data for table public.categoria (OID = 24594) (LIMIT 0,16)
--
INSERT INTO categoria (idcategoria, nombrecategoria)
VALUES (5, 'Dulces');

INSERT INTO categoria (idcategoria, nombrecategoria)
VALUES (6, 'Bebidas');

INSERT INTO categoria (idcategoria, nombrecategoria)
VALUES (7, 'Abarrotes');

INSERT INTO categoria (idcategoria, nombrecategoria)
VALUES (3, 'Lácteos');

INSERT INTO categoria (idcategoria, nombrecategoria)
VALUES (4, 'Galletas');

INSERT INTO categoria (idcategoria, nombrecategoria)
VALUES (1, 'Panes');

INSERT INTO categoria (idcategoria, nombrecategoria)
VALUES (8, 'Cervezas');

INSERT INTO categoria (idcategoria, nombrecategoria)
VALUES (9, 'Cereales');

INSERT INTO categoria (idcategoria, nombrecategoria)
VALUES (10, 'Pasteles');

INSERT INTO categoria (idcategoria, nombrecategoria)
VALUES (11, 'Aseo');

INSERT INTO categoria (idcategoria, nombrecategoria)
VALUES (12, 'Higiene');

INSERT INTO categoria (idcategoria, nombrecategoria)
VALUES (99, 'Otros');

INSERT INTO categoria (idcategoria, nombrecategoria)
VALUES (13, 'Mascotas');

INSERT INTO categoria (idcategoria, nombrecategoria)
VALUES (14, 'Congelados');

INSERT INTO categoria (idcategoria, nombrecategoria)
VALUES (15, 'Helados');

INSERT INTO categoria (idcategoria, nombrecategoria)
VALUES (2, 'Cecinas');

--
-- Data for table public.unidad (OID = 32782) (LIMIT 0,3)
--
INSERT INTO unidad (idunidad, nombreunidad)
VALUES (1, 'kg.');

INSERT INTO unidad (idunidad, nombreunidad)
VALUES (2, 'unidad');

INSERT INTO unidad (idunidad, nombreunidad)
VALUES (3, 'pack');

--
-- Definition for index producto_pkey (OID = 24592) : 
--
ALTER TABLE ONLY producto
    ADD CONSTRAINT producto_pkey
    PRIMARY KEY (idproducto);
--
-- Definition for index categoria_pkey (OID = 24597) : 
--
ALTER TABLE ONLY categoria
    ADD CONSTRAINT categoria_pkey
    PRIMARY KEY (idcategoria);
--
-- Definition for index producto_codigodebarras_key (OID = 32778) : 
--
ALTER TABLE ONLY producto
    ADD CONSTRAINT producto_codigodebarras_key
    UNIQUE (codigodebarras);
--
-- Definition for index unidad_pkey (OID = 32785) : 
--
ALTER TABLE ONLY unidad
    ADD CONSTRAINT unidad_pkey
    PRIMARY KEY (idunidad);
--
-- Definition for index usuario_pkey (OID = 32801) : 
--
ALTER TABLE ONLY usuario
    ADD CONSTRAINT usuario_pkey
    PRIMARY KEY ("Cod_usuario");
--
-- Definition for index usuario_User_key (OID = 32803) : 
--
ALTER TABLE ONLY usuario
    ADD CONSTRAINT "usuario_User_key"
    UNIQUE ("User");
--
-- Definition for index categoria_producto_fk (OID = 32805) : 
--
ALTER TABLE ONLY producto
    ADD CONSTRAINT categoria_producto_fk
    FOREIGN KEY (idcategoria) REFERENCES categoria(idcategoria);
--
-- Comments
--
COMMENT ON SCHEMA public IS 'standard public schema';
