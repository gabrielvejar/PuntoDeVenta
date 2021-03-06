﻿-- SQL Manager for PostgreSQL 5.9.5.52424
-- ---------------------------------------
-- Host      : localhost
-- Database  : puntodeventa
-- Version   : PostgreSQL 11.5, compiled by Visual C++ build 1914, 64-bit



SET search_path = public, pg_catalog;
DROP FUNCTION IF EXISTS public.fn_caja_cierre_i (integer, integer, integer, integer, integer, integer, integer, integer);
DROP TABLE IF EXISTS public.caja_cierre;
DROP VIEW IF EXISTS public.vw_total_gastos;
DROP VIEW IF EXISTS public.vw_ventas_totales;
DROP VIEW IF EXISTS public.vw_efectivo_apertura;
DROP VIEW IF EXISTS public.vw_gastos;
DROP FUNCTION IF EXISTS public.fn_gastos_caja_i_sin_custodia (integer, integer, varchar, integer, integer);
DROP FUNCTION IF EXISTS public.fn_gastos_caja_i (integer, integer, varchar, integer, boolean, integer, integer);
DROP TABLE IF EXISTS public.gastos_caja;
DROP TABLE IF EXISTS public.tipo_gasto;
DROP TABLE IF EXISTS public.dinero_custodia_movimientos;
DROP TABLE IF EXISTS public.dinero_custodia;
DROP VIEW IF EXISTS public.vw_detalle_venta_temp;
DROP FUNCTION IF EXISTS public.fn_venta_temporal_anular (integer);
DROP FUNCTION IF EXISTS public.fn_venta_i (integer, integer, integer, integer, integer);
DROP FUNCTION IF EXISTS public.fn_venta_temporal_pagar (integer);
DROP FUNCTION IF EXISTS public.fn_verificar_caja_apertura (integer);
DROP FUNCTION IF EXISTS public.fn_verificar_caja_apertura ();
DROP FUNCTION IF EXISTS public.fn_caja_apertura_i (date, integer, integer);
DROP VIEW IF EXISTS public.vw_ventas_temporales_impagas;
DROP FUNCTION IF EXISTS public.fn_venta_temporal_i (integer);
DROP FUNCTION IF EXISTS public.fn_venta_detalle_d (id_detalle integer);
DROP FUNCTION IF EXISTS public.fn_venta_temporal_d (integer);
DROP FUNCTION IF EXISTS public.fn_venta_detalle_u (integer, integer, integer, numeric, integer, integer, integer);
DROP FUNCTION IF EXISTS public.fn_gastos_caja_d (integer);
DROP FUNCTION IF EXISTS public.fn_gastos_caja_u (integer, integer, varchar, integer, integer);
DROP FUNCTION IF EXISTS public.fn_promocion_u (integer, integer, integer, integer, integer, varchar);
DROP FUNCTION IF EXISTS public.fn_promocion_i (integer, integer, integer, integer);
DROP FUNCTION IF EXISTS public.fn_venta_detalle_i (integer, integer, numeric, integer, integer, integer);
DROP TABLE IF EXISTS public.venta_detalle;
DROP TABLE IF EXISTS public.promociones;
DROP TABLE IF EXISTS public.venta;
DROP TABLE IF EXISTS public.venta_temporal;
DROP TABLE IF EXISTS public.caja_apertura;
DROP TABLE IF EXISTS public.tipo_pago;
DROP TABLE IF EXISTS public.usuario;
DROP FUNCTION IF EXISTS public.fn_producto_d (varchar);
DROP FUNCTION IF EXISTS public.fn_producto_iu (nombre varchar, codigo varchar, precio integer, imagen varchar, idcat integer, idun integer, cambioimagen boolean);
DROP TABLE IF EXISTS public.unidad;
DROP TABLE IF EXISTS public.producto;
DROP TABLE IF EXISTS public.categoria;
SET check_function_bodies = false;
--
-- Definition for function fn_producto_iu (OID = 32788) : 
--
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
-- Definition for function fn_venta_detalle_i (OID = 32989) : 
--
CREATE FUNCTION public.fn_venta_detalle_i (
  integer,
  integer,
  numeric,
  integer,
  integer,
  integer
)
RETURNS void
AS 
$body$
DECLARE

	__id_venta_temp 	ALIAS FOR $1;
	__id_producto 		ALIAS FOR $2;
	__cantidad 			ALIAS FOR $3;
	__id_usuario 		ALIAS FOR $4;
	__monto 			ALIAS FOR $5;
	__id_promocion 		ALIAS FOR $6;

BEGIN

	IF (__id_promocion = 0) THEN
    	__id_promocion = NULL;
    END IF;

    INSERT INTO 
      public.venta_detalle
    (
      id_venta_temp,
      idproducto,
      cantidad,
      id_usuario,
      "time",
  	  monto,
      id_promocion
    )
    VALUES (
      __id_venta_temp,
      __id_producto,
      __cantidad,
      __id_usuario,
      now(),
      __monto,
      __id_promocion
    );

END;
$body$
LANGUAGE plpgsql;
--
-- Definition for function fn_promocion_i (OID = 32993) : 
--
CREATE FUNCTION public.fn_promocion_i (
  integer,
  integer,
  integer,
  integer
)
RETURNS void
AS 
$body$
DECLARE

	__id_producto	 	ALIAS FOR $1;
	__cantidad	 		ALIAS FOR $2;
	__tipo_descuento	ALIAS FOR $3;
	__descuento 		ALIAS FOR $4;

BEGIN

    INSERT INTO 
      public.promociones
    (
      idproducto,
      cantidad,
      tipo_descuento,
      descuento,
      activo
    )
    VALUES (
      __id_producto,
      __cantidad,
      __tipo_descuento,
      __descuento,
      't'
    );


END;
$body$
LANGUAGE plpgsql;
--
-- Definition for function fn_promocion_u (OID = 32994) : 
--
CREATE FUNCTION public.fn_promocion_u (
  integer,
  integer,
  integer,
  integer,
  integer,
  character varying
)
RETURNS void
AS 
$body$
DECLARE

	__id_promocion	 	ALIAS FOR $1;
	__id_producto	 	ALIAS FOR $2;
	__cantidad	 		ALIAS FOR $3;
	__tipo_descuento	ALIAS FOR $4;
	__descuento 		ALIAS FOR $5;
    __activo 			ALIAS FOR $6;

BEGIN

    UPDATE 
      public.promociones 
    SET 
      idproducto 		= __id_producto,
      cantidad 			= __cantidad,
      tipo_descuento 	= __tipo_descuento,
      descuento 		= __descuento,
      activo 			= __activo
    WHERE 
      id_promocion 		= __id_promocion
    ;

END;
$body$
LANGUAGE plpgsql;
--
-- Definition for function fn_gastos_caja_u (OID = 32996) : 
--
CREATE FUNCTION public.fn_gastos_caja_u (
  integer,
  integer,
  character varying,
  integer,
  integer
)
RETURNS void
AS 
$body$
DECLARE

	__id_gasto	 		ALIAS FOR $1;
	__id_apertura 		ALIAS FOR $2;
	__descripcion 		ALIAS FOR $3;
	__monto 			ALIAS FOR $4;
	__id_usuario 		ALIAS FOR $5;
    
BEGIN

    UPDATE 
      public.gastos_caja 
    SET 
      id_apertura = __id_apertura,
      descripcion = __descripcion,
      monto = __monto,
      id_usuario = __id_usuario,
      "time" = now()
    WHERE 
      id_gasto = __id_gasto
    ;

END;
$body$
LANGUAGE plpgsql;
--
-- Definition for function fn_gastos_caja_d (OID = 32997) : 
--
CREATE FUNCTION public.fn_gastos_caja_d (
  integer
)
RETURNS void
AS 
$body$
DECLARE

  __id_gasto ALIAS FOR $1;
  
BEGIN

    DELETE FROM 
      public.gastos_caja 
    WHERE 
      id_gasto = __id_gasto
    ;
    
END;
$body$
LANGUAGE plpgsql;
--
-- Definition for function fn_venta_detalle_u (OID = 32998) : 
--
CREATE FUNCTION public.fn_venta_detalle_u (
  integer,
  integer,
  integer,
  numeric,
  integer,
  integer,
  integer
)
RETURNS void
AS 
$body$
DECLARE

	__id_detalle 		ALIAS FOR $1;
	__id_venta_temp 	ALIAS FOR $2;
	__id_producto 		ALIAS FOR $3;
	__cantidad 			ALIAS FOR $4;
	__id_usuario 		ALIAS FOR $5;
	__monto 			ALIAS FOR $6;
	__id_promocion 		ALIAS FOR $7;

BEGIN

    UPDATE 
      public.venta_detalle 
    SET 
      id_venta_temp = __id_venta_temp,
      idproducto = __id_producto,
      cantidad = __cantidad,
      id_usuario = __id_usuario,
      monto = __monto,
      id_promocion = __id_promocion
    WHERE 
      id_detalle = __id_detalle
    ;

END;
$body$
LANGUAGE plpgsql;
--
-- Definition for function fn_venta_temporal_d (OID = 33000) : 
--
CREATE FUNCTION public.fn_venta_temporal_d (
  integer
)
RETURNS void
AS 
$body$
DECLARE

  	__id_venta_temp 	ALIAS FOR $1;
  
BEGIN

    DELETE FROM 
      public.venta_detalle 
    WHERE 
      id_venta_temp = __id_venta_temp
    ;

    DELETE FROM 
      public.venta_temporal 
    WHERE 
      id_venta_temp = __id_venta_temp
    ;
    


END;
$body$
LANGUAGE plpgsql;
--
-- Definition for function fn_venta_detalle_d (OID = 33001) : 
--
CREATE FUNCTION public.fn_venta_detalle_d (
  id_detalle integer
)
RETURNS void
AS 
$body$
DECLARE

	__id_detalle 	ALIAS FOR $1;

BEGIN
    
    DELETE FROM 
      public.venta_detalle 
    WHERE 
      venta_detalle.id_detalle = __id_detalle
    ;

END;
$body$
LANGUAGE plpgsql;
--
-- Definition for function fn_venta_temporal_i (OID = 33010) : 
--
CREATE FUNCTION public.fn_venta_temporal_i (
  integer
)
RETURNS integer
AS 
$body$
DECLARE

	_id_usuario ALIAS FOR $1;
  
BEGIN

	INSERT INTO public.venta_temporal(id_usuario) VALUES (_id_usuario);

	RETURN currval('public.venta_temporal_id_venta_temp_seq');
    
    --RETURN QUERY SELECT currval('public.venta_temporal_id_venta_temp_seq') as id_venta_temporal, currval('public.venta_temporal_id_diario_seq') as id_diario;

END;
$body$
LANGUAGE plpgsql;
--
-- Definition for function fn_caja_apertura_i (OID = 33034) : 
--
CREATE FUNCTION public.fn_caja_apertura_i (
  date,
  integer,
  integer
)
RETURNS varchar
AS 
$body$
DECLARE

	__fecha			 	ALIAS FOR $1;
	__efectivo	 		ALIAS FOR $2;
	__id_usuario 		ALIAS FOR $3;
    
    
    
BEGIN


    INSERT INTO 
      public.caja_apertura
    (
      fecha,
      efectivo,
      id_usuario,
      time_creado,
      cerrado
    )
    VALUES (
      __fecha,
      __efectivo,
      __id_usuario,
      now(),
      'f'
    );
    
    RETURN '0';


END;
$body$
LANGUAGE plpgsql;
--
-- Definition for function fn_verificar_caja_apertura (OID = 33035) : 
--
CREATE FUNCTION public.fn_verificar_caja_apertura (
)
RETURNS varchar
AS 
$body$
DECLARE
	_existe VARCHAR;
BEGIN
        
SELECT 
  id_apertura 
  INTO _existe
FROM 
  public.caja_apertura 
  WHERE cerrado IS NOT TRUE
  LIMIT 1;
  
IF _existe IS NOT NULL THEN
	RETURN _existe; -- id_apertura
END IF;

RETURN '0'; -- no hay caja abierta
  
  
END;
$body$
LANGUAGE plpgsql;
--
-- Definition for function fn_verificar_caja_apertura (OID = 33038) : 
--
CREATE FUNCTION public.fn_verificar_caja_apertura (
  integer
)
RETURNS varchar
AS 
$body$
DECLARE
	__id_apertura		ALIAS FOR $1;
	__existe VARCHAR;
BEGIN

IF (__id_apertura IS NULL) THEN
	RETURN '2'; -- id apertura nulo
END IF;
        
SELECT 
  id_apertura 
  INTO __existe
FROM 
  public.caja_apertura 
  WHERE cerrado IS NOT TRUE
  AND id_apertura = __id_apertura
  LIMIT 1;
  
IF __existe IS NOT NULL THEN
	RETURN '1'; -- HAY CAJA ABIERTA
END IF;

RETURN '0';


END;
$body$
LANGUAGE plpgsql;
--
-- Definition for function fn_venta_temporal_pagar (OID = 33051) : 
--
CREATE FUNCTION public.fn_venta_temporal_pagar (
  integer
)
RETURNS varchar
AS 
$body$
DECLARE
  _id_venta_temporal ALIAS FOR $1;
  
  __existe VARCHAR;
BEGIN

SELECT * INTO __existe
FROM public.venta_temporal 
WHERE pagado IS NOT TRUE
AND id_venta_temp = _id_venta_temporal
LIMIT 1;

IF __existe IS NULL THEN
  RETURN '1'; -- NO SE PUEDE ACTUALIZAR
END IF;



  UPDATE 
    public.venta_temporal 
  SET
    pagado = 't',
    time_pagado = now()
  WHERE 
    id_venta_temp = _id_venta_temporal
  ;
  


RETURN '0'; -- registro actualizado

END;
$body$
LANGUAGE plpgsql;
--
-- Definition for function fn_venta_i (OID = 33052) : 
--
CREATE FUNCTION public.fn_venta_i (
  integer,
  integer,
  integer,
  integer,
  integer
)
RETURNS varchar
AS 
$body$
DECLARE

	__id_venta_temp 	ALIAS FOR $1;
	__id_apertura 		ALIAS FOR $2;
	__monto_venta 		ALIAS FOR $3;
	__id_tipo_pago 		ALIAS FOR $4;
	__id_usuario 		ALIAS FOR $5;
    
BEGIN

    INSERT INTO 
      public.venta
    (
      id_venta_temp,
      id_apertura,
      monto_venta,
      id_tipo_pago,
      id_usuario,
	  time_creado
    )
    VALUES (
      __id_venta_temp,
      __id_apertura,
      __monto_venta,
      __id_tipo_pago,
      __id_usuario,
      now()
    );

RETURN '0';

END;
$body$
LANGUAGE plpgsql;
--
-- Definition for function fn_venta_temporal_anular (OID = 33056) : 
--
CREATE FUNCTION public.fn_venta_temporal_anular (
  integer
)
RETURNS varchar
AS 
$body$
DECLARE
	__id_venta_temp 	ALIAS FOR $1;
	_existe VARCHAR;
BEGIN

  UPDATE 
  public.venta_temporal 
SET 
  anulado = 't'
WHERE 
  id_venta_temp = __id_venta_temp
  RETURNING id_venta_temp INTO _existe
;

RETURN _existe;

END;
$body$
LANGUAGE plpgsql;
--
-- Definition for function fn_gastos_caja_i (OID = 33189) : 
--
CREATE FUNCTION public.fn_gastos_caja_i (
  integer,
  integer,
  character varying,
  integer,
  boolean,
  integer,
  integer
)
RETURNS varchar
AS 
$body$
DECLARE

    _id_apertura           ALIAS FOR $1;
    _id_tipo_gasto         ALIAS FOR $2;
    _descripcion           ALIAS FOR $3;
    _monto                 ALIAS FOR $4;
    _dinero_en_custodia    ALIAS FOR $5;
    _id_dinero_custodia    ALIAS FOR $6;
    _id_usuario_i          ALIAS FOR $7;
    
    __id_gasto_retornado VARCHAR := 0;

BEGIN

IF (_dinero_en_custodia = 't') THEN

  INSERT INTO 
    public.gastos_caja
  (
    id_apertura,
    id_tipo_gasto,
    descripcion,
    monto,
    dinero_en_custodia,
    id_dinero_custodia,
    id_usuario_i,
    time_creado
  )
  VALUES (
    _id_apertura,
    _id_tipo_gasto,
    _descripcion,
    _monto,
    't',
    _id_dinero_custodia,
    _id_usuario_i,
    now()
  )
  RETURNING gastos_caja.id_gasto INTO __id_gasto_retornado;
  
  RETURN _id_gasto_retornado;
  
ELSE

  INSERT INTO 
    public.gastos_caja
  (
    id_apertura,
    id_tipo_gasto,
    descripcion,
    monto,
    dinero_en_custodia,
    id_usuario_i,
    time_creado
  )
  VALUES (
    _id_apertura,
    _id_tipo_gasto,
    _descripcion,
    _monto,
    'f',
    _id_usuario_i,
    now()
  )
  RETURNING gastos_caja.id_gasto INTO __id_gasto_retornado;
  
  RETURN __id_gasto_retornado;
  
END IF;



END;
$body$
LANGUAGE plpgsql;
--
-- Definition for function fn_gastos_caja_i_sin_custodia (OID = 33191) : 
--
CREATE FUNCTION public.fn_gastos_caja_i_sin_custodia (
  integer,
  integer,
  character varying,
  integer,
  integer
)
RETURNS varchar
AS 
$body$
DECLARE

--funcion gasto sin dinero en custodia asociado

    _id_apertura           ALIAS FOR $1;
    _id_tipo_gasto         ALIAS FOR $2;
    _descripcion           ALIAS FOR $3;
    _monto                 ALIAS FOR $4;
    _id_usuario_i          ALIAS FOR $5;

BEGIN

  INSERT INTO 
    public.gastos_caja
  (
    id_apertura,
    id_tipo_gasto,
    descripcion,
    monto,
    id_usuario_i,
    time_creado
  )
  VALUES (
    id_apertura,
    id_tipo_gasto,
    descripcion,
    monto,
    id_usuario_i,
    now()
  )
  RETURNING id_gasto;





END;
$body$
LANGUAGE plpgsql;
--
-- Definition for function fn_caja_cierre_i (OID = 33261) : 
--
CREATE FUNCTION public.fn_caja_cierre_i (
  integer,
  integer,
  integer,
  integer,
  integer,
  integer,
  integer,
  integer
)
RETURNS integer
AS 
$body$
DECLARE

	__id_apertura		ALIAS FOR $1;
	__efectivo_apertura	ALIAS FOR $2;
	__efectivo_cierre	ALIAS FOR $3;
	__ventas_efectivo	ALIAS FOR $4;
	__ventas_tarjetas	ALIAS FOR $5;
	__entrega	 		ALIAS FOR $6;
    __gastos	 		ALIAS FOR $7;
	__id_usuario 		ALIAS FOR $8;

    
    _id_cierre INTEGER;
    
BEGIN

    INSERT INTO 
      public.caja_cierre
    (
      id_apertura,
      efectivo_apertura,
      efectivo_cierre,
      ventas_efectivo,
      ventas_tarjetas,
      entrega,
      gastos,
      id_usuario,
      time_cierre
    )
    VALUES (
      __id_apertura,
      __efectivo_apertura,
      __efectivo_cierre,
      __ventas_efectivo,
      __ventas_tarjetas,
      __entrega,
      __gastos,
      __id_usuario,
      now()
    ) RETURNING id_cierre INTO _id_cierre;

    UPDATE 
      public.caja_apertura 
    SET 
      cerrado = 't'
    WHERE 
      id_apertura = __id_apertura
    ;
    
    ALTER SEQUENCE public.venta_temporal_id_diario_seq RESTART;
    
    RETURN _id_cierre;

END;
$body$
LANGUAGE plpgsql;
--
-- Structure for table producto (OID = 24588) : 
--
CREATE TABLE public.producto (
    idproducto integer DEFAULT nextval('producto_id_seq'::regclass) NOT NULL,
    nombreproducto varchar NOT NULL,
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
    nombreunidad varchar(30) NOT NULL,
    nombrelargo varchar
)
WITH (oids = false);
--
-- Structure for table usuario (OID = 32794) : 
--
CREATE TABLE public.usuario (
    id_usuario integer DEFAULT nextval('"usuario_Cod_usuario_seq"'::regclass) NOT NULL,
    nombre varchar(30) NOT NULL,
    usuario varchar(20) NOT NULL,
    password varchar NOT NULL,
    tipo_usuario varchar(10) NOT NULL
)
WITH (oids = false);
--
-- Structure for table tipo_pago (OID = 32812) : 
--
CREATE TABLE public.tipo_pago (
    id_tipo_pago serial NOT NULL,
    nombre_tipo_pago varchar(100) NOT NULL
)
WITH (oids = false);
--
-- Structure for table caja_apertura (OID = 32820) : 
--
CREATE TABLE public.caja_apertura (
    id_apertura serial NOT NULL,
    fecha date NOT NULL,
    efectivo integer NOT NULL,
    id_usuario integer NOT NULL,
    time_creado timestamp without time zone NOT NULL,
    cerrado boolean NOT NULL
)
WITH (oids = false);
--
-- Structure for table venta_temporal (OID = 32843) : 
--
CREATE TABLE public.venta_temporal (
    id_venta_temp serial NOT NULL,
    id_diario serial NOT NULL,
    id_usuario integer NOT NULL,
    time_creado timestamp without time zone DEFAULT now() NOT NULL,
    pagado boolean,
    time_pagado timestamp without time zone,
    anulado boolean DEFAULT false
)
WITH (oids = false);
--
-- Structure for table venta (OID = 32906) : 
--
CREATE TABLE public.venta (
    id_venta serial NOT NULL,
    id_venta_temp integer NOT NULL,
    id_apertura integer NOT NULL,
    monto_venta integer NOT NULL,
    id_tipo_pago integer NOT NULL,
    id_usuario integer NOT NULL,
    time_creado timestamp without time zone NOT NULL
)
WITH (oids = false);
--
-- Structure for table venta_detalle (OID = 32939) : 
--
CREATE TABLE public.venta_detalle (
    id_detalle serial NOT NULL,
    id_venta_temp integer NOT NULL,
    idproducto integer NOT NULL,
    cantidad numeric(10,5) NOT NULL,
    id_usuario integer NOT NULL,
    "time" timestamp without time zone NOT NULL,
    monto integer NOT NULL,
    id_promocion integer
)
WITH (oids = false);
--
-- Structure for table promociones (OID = 32970) : 
--
CREATE TABLE public.promociones (
    id_promocion serial NOT NULL,
    idproducto integer NOT NULL,
    cantidad integer NOT NULL,
    tipo_descuento integer NOT NULL,
    descuento integer NOT NULL,
    activo boolean NOT NULL,
    descripcion_promo varchar(50) NOT NULL
)
WITH (oids = false);
--
-- Definition for view vw_ventas_temporales_impagas (OID = 33021) : 
--
CREATE VIEW public.vw_ventas_temporales_impagas
AS
SELECT venta_temporal.id_venta_temp,
    venta_temporal.id_diario,
    venta_temporal.anulado
FROM venta_temporal
WHERE ((venta_temporal.pagado IS NOT TRUE) AND (venta_temporal.time_creado
    >= CURRENT_DATE) AND (venta_temporal.time_creado < (CURRENT_DATE + 1)))
ORDER BY venta_temporal.id_diario;

--
-- Definition for view vw_detalle_venta_temp (OID = 33057) : 
--
CREATE VIEW public.vw_detalle_venta_temp
AS
SELECT vd.id_detalle,
    vd.id_venta_temp,
    p.codigodebarras AS codigo,
    p.nombreproducto AS nombre,
    p.precio,
    vd.cantidad,
    vd.monto,
    p.idproducto,
    u.nombreunidad AS unidad,
    p.idunidad,
    vd.id_promocion AS idpromocion,
    vt.id_diario,
    vt.anulado
FROM (((producto p
     JOIN venta_detalle vd ON ((p.idproducto = vd.idproducto)))
     JOIN unidad u ON ((u.idunidad = p.idunidad)))
     JOIN venta_temporal vt ON ((vd.id_venta_temp = vt.id_venta_temp)));

--
-- Structure for table dinero_custodia (OID = 33064) : 
--
CREATE TABLE public.dinero_custodia (
    id_dinero_custodia serial NOT NULL,
    nombre varchar NOT NULL,
    id_usuario_i integer NOT NULL,
    time_creado timestamp without time zone NOT NULL,
    eliminado boolean,
    id_usuario_d integer,
    time_eliminado timestamp without time zone
)
WITH (oids = false);
--
-- Structure for table dinero_custodia_movimientos (OID = 33085) : 
--
CREATE TABLE public.dinero_custodia_movimientos (
    id_movimiento serial NOT NULL,
    id_dinero_custodia integer NOT NULL,
    monto integer NOT NULL,
    comentario varchar,
    id_usuario_i integer NOT NULL,
    time_creado timestamp without time zone NOT NULL,
    eliminado boolean,
    id_usuario_d integer,
    time_eliminado timestamp without time zone
)
WITH (oids = false);
--
-- Structure for table tipo_gasto (OID = 33142) : 
--
CREATE TABLE public.tipo_gasto (
    id_tipo_gasto serial NOT NULL,
    nombre_tipo_gasto varchar NOT NULL
)
WITH (oids = false);
--
-- Structure for table gastos_caja (OID = 33155) : 
--
CREATE TABLE public.gastos_caja (
    id_gasto serial NOT NULL,
    id_apertura integer NOT NULL,
    id_tipo_gasto integer NOT NULL,
    descripcion varchar NOT NULL,
    monto integer NOT NULL,
    dinero_en_custodia boolean,
    id_dinero_custodia integer,
    id_usuario_i integer NOT NULL,
    time_creado timestamp without time zone NOT NULL,
    eliminado boolean,
    id_usuario_d integer,
    time_eliminado timestamp without time zone
)
WITH (oids = false);
--
-- Definition for view vw_gastos (OID = 33201) : 
--
CREATE VIEW public.vw_gastos
AS
SELECT gc.id_apertura,
    gc.id_gasto,
    gc.id_tipo_gasto,
    gc.descripcion,
    gc.monto,
    gc.dinero_en_custodia,
    gc.id_dinero_custodia,
    u.usuario AS username_ingreso,
    u.nombre AS usuario_ingreso,
    gc.eliminado
FROM (gastos_caja gc
     JOIN usuario u ON ((gc.id_usuario_i = u.id_usuario)));

--
-- Definition for view vw_efectivo_apertura (OID = 33205) : 
--
CREATE VIEW public.vw_efectivo_apertura
AS
SELECT caja_apertura.id_apertura,
    caja_apertura.efectivo
FROM caja_apertura
WHERE (caja_apertura.cerrado IS NOT TRUE);

--
-- Definition for view vw_ventas_totales (OID = 33209) : 
--
CREATE VIEW public.vw_ventas_totales
AS
SELECT venta.id_apertura,
    venta.id_tipo_pago,
    sum(venta.monto_venta) AS total_ventas
FROM venta
GROUP BY venta.id_apertura, venta.id_tipo_pago;

--
-- Definition for view vw_total_gastos (OID = 33217) : 
--
CREATE VIEW public.vw_total_gastos
AS
SELECT gastos_caja.id_apertura,
    sum(gastos_caja.monto) AS total_gastos
FROM gastos_caja
WHERE (gastos_caja.eliminado IS NOT TRUE)
GROUP BY gastos_caja.id_apertura, gastos_caja.eliminado;

--
-- Structure for table caja_cierre (OID = 33244) : 
--
CREATE TABLE public.caja_cierre (
    id_cierre serial NOT NULL,
    id_apertura integer NOT NULL,
    efectivo_apertura integer NOT NULL,
    efectivo_cierre integer NOT NULL,
    ventas_efectivo integer NOT NULL,
    ventas_tarjetas integer NOT NULL,
    entrega integer NOT NULL,
    gastos integer NOT NULL,
    id_usuario integer NOT NULL,
    time_cierre timestamp without time zone NOT NULL
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
INSERT INTO unidad (idunidad, nombreunidad, nombrelargo)
VALUES (1, 'kg.', NULL);

INSERT INTO unidad (idunidad, nombreunidad, nombrelargo)
VALUES (3, 'pack', NULL);

INSERT INTO unidad (idunidad, nombreunidad, nombrelargo)
VALUES (2, 'un.', NULL);

--
-- Data for table public.tipo_pago (OID = 32812) (LIMIT 0,2)
--
INSERT INTO tipo_pago (id_tipo_pago, nombre_tipo_pago)
VALUES (1, 'Efectivo');

INSERT INTO tipo_pago (id_tipo_pago, nombre_tipo_pago)
VALUES (2, 'Tarjeta');

--
-- Data for table public.tipo_gasto (OID = 33142) (LIMIT 0,3)
--
INSERT INTO tipo_gasto (id_tipo_gasto, nombre_tipo_gasto)
VALUES (1, 'Pago proveedores');

INSERT INTO tipo_gasto (id_tipo_gasto, nombre_tipo_gasto)
VALUES (2, 'Pago trabajadores');

INSERT INTO tipo_gasto (id_tipo_gasto, nombre_tipo_gasto)
VALUES (9, 'Otros');

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
    PRIMARY KEY (id_usuario);
--
-- Definition for index usuario_User_key (OID = 32803) : 
--
ALTER TABLE ONLY usuario
    ADD CONSTRAINT "usuario_User_key"
    UNIQUE (usuario);
--
-- Definition for index categoria_producto_fk (OID = 32805) : 
--
ALTER TABLE ONLY producto
    ADD CONSTRAINT categoria_producto_fk
    FOREIGN KEY (idcategoria) REFERENCES categoria(idcategoria);
--
-- Definition for index tipo_pago_pk (OID = 32816) : 
--
ALTER TABLE ONLY tipo_pago
    ADD CONSTRAINT tipo_pago_pk
    PRIMARY KEY (id_tipo_pago);
--
-- Definition for index caja_apertura_pk (OID = 32824) : 
--
ALTER TABLE ONLY caja_apertura
    ADD CONSTRAINT caja_apertura_pk
    PRIMARY KEY (id_apertura);
--
-- Definition for index usuario_caja_apertura_fk (OID = 32826) : 
--
ALTER TABLE ONLY caja_apertura
    ADD CONSTRAINT usuario_caja_apertura_fk
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario);
--
-- Definition for index venta_temporal_pk (OID = 32848) : 
--
ALTER TABLE ONLY venta_temporal
    ADD CONSTRAINT venta_temporal_pk
    PRIMARY KEY (id_venta_temp);
--
-- Definition for index usuario_venta_temporal_fk (OID = 32850) : 
--
ALTER TABLE ONLY venta_temporal
    ADD CONSTRAINT usuario_venta_temporal_fk
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario);
--
-- Definition for index venta_pk (OID = 32910) : 
--
ALTER TABLE ONLY venta
    ADD CONSTRAINT venta_pk
    PRIMARY KEY (id_venta);
--
-- Definition for index usuario_venta_fk (OID = 32912) : 
--
ALTER TABLE ONLY venta
    ADD CONSTRAINT usuario_venta_fk
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario);
--
-- Definition for index tipo_pago_venta_fk (OID = 32917) : 
--
ALTER TABLE ONLY venta
    ADD CONSTRAINT tipo_pago_venta_fk
    FOREIGN KEY (id_tipo_pago) REFERENCES tipo_pago(id_tipo_pago);
--
-- Definition for index venta_temporal_venta_fk (OID = 32922) : 
--
ALTER TABLE ONLY venta
    ADD CONSTRAINT venta_temporal_venta_fk
    FOREIGN KEY (id_venta_temp) REFERENCES venta_temporal(id_venta_temp);
--
-- Definition for index caja_apertura_venta_fk (OID = 32927) : 
--
ALTER TABLE ONLY venta
    ADD CONSTRAINT caja_apertura_venta_fk
    FOREIGN KEY (id_apertura) REFERENCES caja_apertura(id_apertura);
--
-- Definition for index venta_detalle_pk (OID = 32943) : 
--
ALTER TABLE ONLY venta_detalle
    ADD CONSTRAINT venta_detalle_pk
    PRIMARY KEY (id_detalle);
--
-- Definition for index usuario_venta_detalle_fk (OID = 32945) : 
--
ALTER TABLE ONLY venta_detalle
    ADD CONSTRAINT usuario_venta_detalle_fk
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario);
--
-- Definition for index producto_venta_detalle_fk (OID = 32950) : 
--
ALTER TABLE ONLY venta_detalle
    ADD CONSTRAINT producto_venta_detalle_fk
    FOREIGN KEY (idproducto) REFERENCES producto(idproducto);
--
-- Definition for index venta_temp_venta_deta_fk (OID = 32955) : 
--
ALTER TABLE ONLY venta_detalle
    ADD CONSTRAINT venta_temp_venta_deta_fk
    FOREIGN KEY (id_venta_temp) REFERENCES venta_temporal(id_venta_temp);
--
-- Definition for index promociones_pk (OID = 32974) : 
--
ALTER TABLE ONLY promociones
    ADD CONSTRAINT promociones_pk
    PRIMARY KEY (id_promocion);
--
-- Definition for index producto_promociones_fk (OID = 32976) : 
--
ALTER TABLE ONLY promociones
    ADD CONSTRAINT producto_promociones_fk
    FOREIGN KEY (idproducto) REFERENCES producto(idproducto);
--
-- Definition for index promocion_venta_detalle_fk (OID = 32984) : 
--
ALTER TABLE ONLY venta_detalle
    ADD CONSTRAINT promocion_venta_detalle_fk
    FOREIGN KEY (id_promocion) REFERENCES promociones(id_promocion);
--
-- Definition for index dinero_custodia_pk (OID = 33071) : 
--
ALTER TABLE ONLY dinero_custodia
    ADD CONSTRAINT dinero_custodia_pk
    PRIMARY KEY (id_dinero_custodia);
--
-- Definition for index usuario_dinero_custodia_fk (OID = 33073) : 
--
ALTER TABLE ONLY dinero_custodia
    ADD CONSTRAINT usuario_dinero_custodia_fk
    FOREIGN KEY (id_usuario_i) REFERENCES usuario(id_usuario);
--
-- Definition for index usuario_dinero_custodia_fk_1 (OID = 33078) : 
--
ALTER TABLE ONLY dinero_custodia
    ADD CONSTRAINT usuario_dinero_custodia_fk_1
    FOREIGN KEY (id_usuario_d) REFERENCES usuario(id_usuario);
--
-- Definition for index dinero_custodia_movi_pk (OID = 33092) : 
--
ALTER TABLE ONLY dinero_custodia_movimientos
    ADD CONSTRAINT dinero_custodia_movi_pk
    PRIMARY KEY (id_movimiento);
--
-- Definition for index dinero_cus_dinero_cus_fk (OID = 33094) : 
--
ALTER TABLE ONLY dinero_custodia_movimientos
    ADD CONSTRAINT dinero_cus_dinero_cus_fk
    FOREIGN KEY (id_dinero_custodia) REFERENCES dinero_custodia(id_dinero_custodia);
--
-- Definition for index usuario_di_cus_mov_fk (OID = 33099) : 
--
ALTER TABLE ONLY dinero_custodia_movimientos
    ADD CONSTRAINT usuario_di_cus_mov_fk
    FOREIGN KEY (id_usuario_i) REFERENCES usuario(id_usuario);
--
-- Definition for index usuario_di_cus_mov_fk_1 (OID = 33104) : 
--
ALTER TABLE ONLY dinero_custodia_movimientos
    ADD CONSTRAINT usuario_di_cus_mov_fk_1
    FOREIGN KEY (id_usuario_d) REFERENCES usuario(id_usuario);
--
-- Definition for index tipo_gasto_pk (OID = 33149) : 
--
ALTER TABLE ONLY tipo_gasto
    ADD CONSTRAINT tipo_gasto_pk
    PRIMARY KEY (id_tipo_gasto);
--
-- Definition for index gastos_caja_pk (OID = 33162) : 
--
ALTER TABLE ONLY gastos_caja
    ADD CONSTRAINT gastos_caja_pk
    PRIMARY KEY (id_gasto);
--
-- Definition for index usuario_gastos_caja_fk (OID = 33164) : 
--
ALTER TABLE ONLY gastos_caja
    ADD CONSTRAINT usuario_gastos_caja_fk
    FOREIGN KEY (id_usuario_i) REFERENCES usuario(id_usuario);
--
-- Definition for index caja_apert_gastos_caj_fk (OID = 33169) : 
--
ALTER TABLE ONLY gastos_caja
    ADD CONSTRAINT caja_apert_gastos_caj_fk
    FOREIGN KEY (id_apertura) REFERENCES caja_apertura(id_apertura);
--
-- Definition for index dinero_cus_gastos_caj_fk (OID = 33174) : 
--
ALTER TABLE ONLY gastos_caja
    ADD CONSTRAINT dinero_cus_gastos_caj_fk
    FOREIGN KEY (id_dinero_custodia) REFERENCES dinero_custodia(id_dinero_custodia);
--
-- Definition for index usuario_gastos_caja_fk_1 (OID = 33179) : 
--
ALTER TABLE ONLY gastos_caja
    ADD CONSTRAINT usuario_gastos_caja_fk_1
    FOREIGN KEY (id_usuario_d) REFERENCES usuario(id_usuario);
--
-- Definition for index tipo_gasto_gastos_caja_fk (OID = 33184) : 
--
ALTER TABLE ONLY gastos_caja
    ADD CONSTRAINT tipo_gasto_gastos_caja_fk
    FOREIGN KEY (id_tipo_gasto) REFERENCES tipo_gasto(id_tipo_gasto);
--
-- Definition for index caja_cierre_pk (OID = 33248) : 
--
ALTER TABLE ONLY caja_cierre
    ADD CONSTRAINT caja_cierre_pk
    PRIMARY KEY (id_cierre);
--
-- Definition for index caja_apert_caja_cierr_fk (OID = 33250) : 
--
ALTER TABLE ONLY caja_cierre
    ADD CONSTRAINT caja_apert_caja_cierr_fk
    FOREIGN KEY (id_apertura) REFERENCES caja_apertura(id_apertura);
--
-- Definition for index usuario_caja_cierre_fk (OID = 33255) : 
--
ALTER TABLE ONLY caja_cierre
    ADD CONSTRAINT usuario_caja_cierre_fk
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario);
--
-- Comments
--
COMMENT ON SCHEMA public IS 'standard public schema';
