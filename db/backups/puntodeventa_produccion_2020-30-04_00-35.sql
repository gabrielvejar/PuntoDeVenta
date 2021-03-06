﻿-- SQL Manager for PostgreSQL 5.9.5.52424
-- ---------------------------------------
-- Host      : 192.168.0.20
-- Database  : puntodeventa_produccion
-- Version   : PostgreSQL 11.7 (Ubuntu 11.7-2.pgdg16.04+1) on x86_64-pc-linux-gnu, compiled by gcc (Ubuntu 5.4.0-6ubuntu1~16.04.12) 5.4.0 20160609, 64-bit



--
-- Definition for function fn_caja_apertura_i (OID = 16415) : 
--
SET search_path = public, pg_catalog;
SET check_function_bodies = false;
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
-- Definition for function fn_caja_cierre_i (OID = 16416) : 
--
CREATE FUNCTION public.fn_caja_cierre_i (
  integer,
  integer,
  integer,
  integer,
  integer,
  integer,
  integer,
  integer,
  character varying,
  character varying
)
RETURNS varchar
AS 
$body$
DECLARE

	__id_apertura				ALIAS FOR $1;
	__efectivo_apertura			ALIAS FOR $2;
	__efectivo_cierre			ALIAS FOR $3;
	__ventas_efectivo			ALIAS FOR $4;
	__ventas_tarjetas			ALIAS FOR $5;
	__entrega	 				ALIAS FOR $6;
    __gastos	 				ALIAS FOR $7;
	__id_usuario 				ALIAS FOR $8;
	__user_autoriza				ALIAS FOR $9;
	__pass_usuario__autoriza 	ALIAS FOR $10;

    
    _id_cierre INTEGER;
    
    _usuario RECORD;
    
BEGIN


SELECT 
  id_usuario,
  tipo_usuario
INTO _usuario
FROM 
  public.usuario 
WHERE usuario = __user_autoriza 
AND password = __pass_usuario__autoriza;

-- _usuario.id_usuario
-- _usuario.tipo_usuario



IF (_usuario.id_usuario IS NULL) THEN
	-- RETURN 'E01-DB'; --usuario y/o contraseña incorrecta
    RETURN 'Usuario y/o contraseña incorrecta';
END IF;

IF (_usuario.tipo_usuario != 'admin') THEN
	-- RETURN 'E02-DB'; --usuario no es administrador
    RETURN 'Usuario ingresado no es administrador'; --usuario no es administrador
END IF;



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
      time_cierre,
      id_usuario_autoriza
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
      now(),
      _usuario.id_usuario
    ) RETURNING id_cierre INTO _id_cierre;

    UPDATE 
      public.caja_apertura 
    SET 
      cerrado = 't'
    WHERE 
      id_apertura = __id_apertura
    ;
    
    --anular ventas impagas
    UPDATE 
      public.venta_temporal 
    SET 
      anulado = 't'
    WHERE 
        id_apertura = __id_apertura AND
        pagado IS NOT TRUE;
    
    
    
    --ALTER SEQUENCE public.venta_temporal_id_diario_seq RESTART;
    
    RETURN _id_cierre;

END;
$body$
LANGUAGE plpgsql;
--
-- Definition for function fn_dinero_custodia_d (OID = 16417) : 
--
CREATE FUNCTION public.fn_dinero_custodia_d (
  integer,
  integer
)
RETURNS varchar
AS 
$body$
DECLARE

  _id_dinero_custodia 		ALIAS FOR $1;
  _id_usuario 				ALIAS FOR $2;
  
  __id_dinero_custodia_r 	INTEGER;
  
BEGIN

    UPDATE 
      public.dinero_custodia 
    SET 
      eliminado = 't',
      id_usuario_d = _id_usuario,
      time_eliminado = now()
    WHERE 
      id_dinero_custodia = _id_dinero_custodia
    RETURNING id_dinero_custodia INTO __id_dinero_custodia_r;

    
    IF (__id_dinero_custodia_r IS NULL) THEN
    	RETURN '1'; --no se encontró id de custodia
    ELSE
    	RETURN '2'; --eliminado correctamente
  	END IF;
  
    EXCEPTION
    WHEN others THEN
		RETURN '0'; --'Error al eliminar dinero en custodia.';
END;
$body$
LANGUAGE plpgsql;
--
-- Definition for function fn_dinero_custodia_i (OID = 16418) : 
--
CREATE FUNCTION public.fn_dinero_custodia_i (
  character varying,
  integer,
  integer
)
RETURNS varchar
AS 
$body$
DECLARE
  _nombre 				ALIAS FOR $1;
  _monto_inicial 		ALIAS FOR $2;
  _id_usuario 			ALIAS FOR $3;
  
  __id_dinero_custodia 	INTEGER;
  __id_movimiento 		INTEGER;
  
BEGIN


  INSERT INTO 
    public.dinero_custodia
  (
    nombre,
    id_usuario_i,
    time_creado
  )
  VALUES (
    _nombre,
    _id_usuario,
    now()
  ) 
  RETURNING id_dinero_custodia INTO __id_dinero_custodia;


IF (_monto_inicial > 0) THEN
	INSERT INTO 
      public.dinero_custodia_movimientos
    (
      id_dinero_custodia,
      monto,
      comentario,
      id_usuario_i,
      time_creado
    )
    VALUES (
      __id_dinero_custodia,
      _monto_inicial,
      'Monto inicial',
      _id_usuario,
      now()
    )RETURNING id_movimiento INTO __id_movimiento;
    
    RETURN '2'; --'Dinero en custodia y movimiento de monto inicial agregado correctamente.';

ELSE
	RETURN '1'; --'Dinero en custodia agregado correctamente.';

END IF;



EXCEPTION
    WHEN others THEN
		RETURN '0'; --'Error al agregar dinero en custodia.';

END;
$body$
LANGUAGE plpgsql;
--
-- Definition for function fn_gastos_caja_d (OID = 16419) : 
--
CREATE FUNCTION public.fn_gastos_caja_d (
  integer,
  integer
)
RETURNS varchar
AS 
$body$
DECLARE

  __id_gasto 	ALIAS FOR $1;
  __id_usuario 	ALIAS FOR $2;
  
  _id_gasto_r 				INTEGER;
  _id_movimiento_custodia 	INTEGER;
  
BEGIN

    
UPDATE 
  public.gastos_caja 
SET 
  eliminado = 't',
  id_usuario_d = __id_usuario,
  time_eliminado = now()
WHERE 
  id_gasto = __id_gasto
RETURNING id_gasto INTO _id_gasto_r
;

IF (_id_gasto_r IS NULL) THEN
	RETURN '0'; --error
END IF;

SELECT id_movimiento_custodia INTO _id_movimiento_custodia
FROM public.gastos_caja
WHERE id_gasto = __id_gasto;


IF (_id_movimiento_custodia IS NULL) THEN
	RETURN '1'; --gasto borrado. sin mov en custodia asociado
ELSE
	UPDATE 
      public.dinero_custodia_movimientos 
    SET
      eliminado = 't',
      id_usuario_d = __id_usuario,
      time_eliminado = now()
    WHERE 
      id_movimiento = _id_movimiento_custodia
	;
    RETURN '2'; --gasto y mov en custodia asociado borrados
END IF;


    
END;
$body$
LANGUAGE plpgsql;
--
-- Definition for function fn_gastos_caja_i (OID = 16420) : 
--
CREATE FUNCTION public.fn_gastos_caja_i (
  integer,
  integer,
  character varying,
  integer,
  boolean,
  integer,
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
    _id_mov_custodia       ALIAS FOR $8;
    
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
    time_creado,
    id_movimiento_custodia
  )
  VALUES (
    _id_apertura,
    _id_tipo_gasto,
    _descripcion,
    _monto,
    't',
    _id_dinero_custodia,
    _id_usuario_i,
    now(),
    _id_mov_custodia
  )
  RETURNING gastos_caja.id_gasto INTO __id_gasto_retornado;
   
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
  
END IF;

IF (__id_gasto_retornado IS NOT NULL) THEN
  RETURN '1'; --'Dinero en custodia agregado correctamente.';
ELSE
  RETURN '2'; --'Error.';
END IF;

--EXCEPTION
--WHEN others THEN
--    RETURN '0'; --'Error al agregar gasto.';

END;
$body$
LANGUAGE plpgsql;
--
-- Definition for function fn_gastos_caja_i_sin_custodia (OID = 16421) : 
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
-- Definition for function fn_gastos_caja_u (OID = 16422) : 
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
-- Definition for function fn_id_diario_actual (OID = 16423) : 
--
CREATE FUNCTION public.fn_id_diario_actual (
)
RETURNS varchar
AS 
$body$
DECLARE
  
BEGIN

	RETURN currval('public.venta_temporal_id_venta_temp_seq');
  
END;
$body$
LANGUAGE plpgsql;
--
-- Definition for function fn_movimiento_dec_d (OID = 16424) : 
--
CREATE FUNCTION public.fn_movimiento_dec_d (
  integer,
  integer
)
RETURNS varchar
AS 
$body$
DECLARE
  _id_movimiento 		ALIAS FOR $1;
  _id_usuario 			ALIAS FOR $2;
  
  __id_movimiento_r 	INTEGER;
BEGIN

	UPDATE 
      public.dinero_custodia_movimientos 
    SET 
      eliminado = 't',
      id_usuario_d = _id_usuario,
      time_eliminado = now()
    WHERE 
      id_movimiento = _id_movimiento
    RETURNING id_movimiento INTO __id_movimiento_r;
    
    
    IF (__id_movimiento_r IS NULL) THEN
    	RETURN '1'; --no se encontró id de movimiento
    ELSE
    	RETURN '2'; --eliminado correctamente
  	END IF;
  
    EXCEPTION
    WHEN others THEN
		RETURN '0'; --'Error al eliminar movimiento de dinero en custodia.';
END;
$body$
LANGUAGE plpgsql;
--
-- Definition for function fn_movimiento_dec_i (OID = 16425) : 
--
CREATE FUNCTION public.fn_movimiento_dec_i (
  integer,
  integer,
  character varying,
  integer,
  boolean
)
RETURNS varchar
AS 
$body$
DECLARE

  _id_dinero_custodia 	ALIAS FOR $1;
  _monto		 		ALIAS FOR $2;
  _comentario 			ALIAS FOR $3;
  _id_usuario 			ALIAS FOR $4;
  _gasto	 			ALIAS FOR $5;
  
  __id_movimiento 		INTEGER;
  
BEGIN
	INSERT INTO 
      public.dinero_custodia_movimientos
    (
      id_dinero_custodia,
      monto,
      comentario,
      id_usuario_i,
      time_creado,
      gasto
    )
    VALUES (
      _id_dinero_custodia,
      _monto,
      _comentario,
      _id_usuario,
      now(),
      _gasto
    )RETURNING id_movimiento INTO __id_movimiento;
    
    --RETURN '1'; --'Movimiento de dinero en custodia agregado correctamente.';
    IF (__id_movimiento IS NOT NULL) THEN
    	RETURN __id_movimiento; --'Movimiento de dinero en custodia agregado correctamente.';
    ELSE
    	RETURN '0';
    END IF;
    
    EXCEPTION
    WHEN others THEN
		RETURN '0'; --'Error al agregar movimiento de dinero en custodia.';
        
END;
$body$
LANGUAGE plpgsql;
--
-- Definition for function fn_producto_d (OID = 16426) : 
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
-- Definition for function fn_promocion_i (OID = 16428) : 
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
-- Definition for function fn_promocion_u (OID = 16429) : 
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
-- Definition for function fn_usuario_i (OID = 16430) : 
--
CREATE FUNCTION public.fn_usuario_i (
  character varying,
  character varying,
  character varying,
  character varying
)
RETURNS varchar
AS 
$body$
DECLARE

  __nombre 			ALIAS FOR $1;
  __usuario 		ALIAS FOR $2;
  __password 		ALIAS FOR $3;
  __tipo_usuario 	ALIAS FOR $4;

  _id_usuario 		VARCHAR;
  
BEGIN

SELECT 
  id_usuario INTO _id_usuario
FROM 
  public.usuario 
  WHERE usuario = __usuario;
  
IF (_id_usuario IS NOT NULL) THEN
	RETURN 'Usuario ya existe'; -- usuario ya existe
END IF;




INSERT INTO 
  public.usuario
(
  nombre,
  usuario,
  password,
  tipo_usuario
)
VALUES (
  __nombre,
  __usuario,
  __password,
  __tipo_usuario
  ) RETURNING id_usuario INTO _id_usuario;


RETURN _id_usuario;

  EXCEPTION
  WHEN OTHERS THEN
    RETURN 'Error al agregar usuario';
    
    
END;
$body$
LANGUAGE plpgsql;
--
-- Definition for function fn_venta_detalle_d (OID = 16431) : 
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
-- Definition for function fn_venta_detalle_i (OID = 16432) : 
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
-- Definition for function fn_venta_detalle_u (OID = 16433) : 
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
-- Definition for function fn_venta_i (OID = 16434) : 
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
    
    _id_venta INTEGER;
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
    ) RETURNING id_venta INTO _id_venta;

RETURN _id_venta;

    EXCEPTION
    WHEN others THEN
		RETURN '0'; --'Error';
END;
$body$
LANGUAGE plpgsql;
--
-- Definition for function fn_venta_temporal_anular (OID = 16435) : 
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
-- Definition for function fn_venta_temporal_d (OID = 16436) : 
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
-- Definition for function fn_venta_temporal_i (OID = 16437) : 
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
-- Definition for function fn_venta_temporal_i_letra_id_diario (OID = 16438) : 
--
CREATE FUNCTION public.fn_venta_temporal_i_letra_id_diario (
  character,
  integer
)
RETURNS varchar
AS 
$body$
DECLARE

	_letra_id_diario 	ALIAS FOR $1;
	_id_usuario 		ALIAS FOR $2;
    
    id_diario_alfa VARCHAR;
  
BEGIN

	INSERT INTO public.venta_temporal(id_usuario, letra_id_diario, id_apertura) 
    VALUES (_id_usuario, _letra_id_diario, 
                                          (
                                              SELECT 
                                              id_apertura
                                            FROM 
                                              public.caja_apertura 
                                            WHERE cerrado IS NOT TRUE
                                          )
    
    );
    
    RETURN currval('public.venta_temporal_id_venta_temp_seq');
    
    --SELECT letra_id_diario || '-' || id_diario 
    --INTO id_diario_alfa
    --FROM 
    --    public.venta_temporal 
    --    WHERE id_venta_temp = (SELECT 
    --    MAX(id_venta_temp)
    --FROM 
    --    public.venta_temporal);
    --    
	--RETURN id_diario_alfa;

	
    
    
    
END;
$body$
LANGUAGE plpgsql;
--
-- Definition for function fn_venta_temporal_pagar (OID = 16439) : 
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
    anulado = 'f',
    time_pagado = now()
  WHERE 
    id_venta_temp = _id_venta_temporal
  ;
  


RETURN '0'; -- registro actualizado

END;
$body$
LANGUAGE plpgsql;
--
-- Definition for function fn_verificar_caja_apertura (OID = 16440) : 
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
-- Definition for function fn_verificar_caja_apertura (OID = 16441) : 
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
-- Definition for function fn_producto_iu (OID = 16807) : 
--
CREATE FUNCTION public.fn_producto_iu (
  nombre character varying,
  codigo character varying,
  precio integer,
  imagen character varying,
  idcat integer,
  idun integer,
  cambioimagen boolean,
  inventariable boolean,
  idusuario integer
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
    _inventariable		ALIAS FOR $8;
    _usuario			ALIAS FOR $9;

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
          idunidad,
          activo,
          inventariable,
          usuario_ultima_modificacion,
          time_ultima_modificacion
          
        )
        VALUES (
          _nombreproducto,
          _codigodebarras,
          _precio,
          _imagen,
          _idcategoria,
          _idunidad,
          't',
          _inventariable,
          _usuario,
          now()          
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
              activo = true,
              inventariable = _inventariable,
              usuario_ultima_modificacion = _usuario,
              time_ultima_modificacion = now()
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
              activo = true,
              inventariable = _inventariable,
              usuario_ultima_modificacion = _usuario,
              time_ultima_modificacion = now()
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
-- Structure for table caja_apertura (OID = 16442) : 
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
-- Structure for table caja_cierre (OID = 16447) : 
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
    time_cierre timestamp without time zone NOT NULL,
    id_usuario_autoriza integer NOT NULL
)
WITH (oids = false);
--
-- Structure for table categoria (OID = 16452) : 
--
CREATE TABLE public.categoria (
    idcategoria smallint NOT NULL,
    nombrecategoria varchar(30) NOT NULL
)
WITH (oids = false);
--
-- Structure for table dinero_custodia (OID = 16455) : 
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
-- Structure for table dinero_custodia_movimientos (OID = 16463) : 
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
    time_eliminado timestamp without time zone,
    gasto boolean
)
WITH (oids = false);
--
-- Structure for table gastos_caja (OID = 16471) : 
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
    time_eliminado timestamp without time zone,
    id_movimiento_custodia integer
)
WITH (oids = false);
--
-- Structure for table perfiles_usuario (OID = 16479) : 
--
CREATE TABLE public.perfiles_usuario (
    tipo_usuario varchar NOT NULL,
    caja boolean,
    meson boolean,
    mantenedor_productos boolean,
    mantenedor_usuarios boolean,
    tipo_usuario_completo varchar
)
WITH (oids = false);
ALTER TABLE ONLY public.perfiles_usuario ALTER COLUMN tipo_usuario SET STATISTICS 0;
ALTER TABLE ONLY public.perfiles_usuario ALTER COLUMN caja SET STATISTICS 0;
ALTER TABLE ONLY public.perfiles_usuario ALTER COLUMN meson SET STATISTICS 0;
--
-- Structure for table producto (OID = 16485) : 
--
CREATE TABLE public.producto (
    idproducto integer DEFAULT nextval('producto_id_seq'::regclass) NOT NULL,
    nombreproducto varchar NOT NULL,
    codigodebarras varchar(30) NOT NULL,
    precio integer NOT NULL,
    imagen varchar(100),
    idcategoria smallint DEFAULT 99,
    idunidad smallint DEFAULT 1,
    activo boolean DEFAULT true NOT NULL,
    inventariable boolean,
    usuario_ultima_modificacion varchar,
    time_ultima_modificacion timestamp without time zone
)
WITH (oids = false);
--
-- Structure for table promociones (OID = 16496) : 
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
-- Structure for table tipo_gasto (OID = 16501) : 
--
CREATE TABLE public.tipo_gasto (
    id_tipo_gasto serial NOT NULL,
    nombre_tipo_gasto varchar NOT NULL
)
WITH (oids = false);
--
-- Structure for table tipo_pago (OID = 16509) : 
--
CREATE TABLE public.tipo_pago (
    id_tipo_pago serial NOT NULL,
    nombre_tipo_pago varchar(100) NOT NULL
)
WITH (oids = false);
--
-- Structure for table unidad (OID = 16514) : 
--
CREATE TABLE public.unidad (
    idunidad smallint NOT NULL,
    nombreunidad varchar(30) NOT NULL,
    nombrelargo varchar
)
WITH (oids = false);
--
-- Structure for table usuario (OID = 16520) : 
--
CREATE TABLE public.usuario (
    id_usuario integer DEFAULT nextval('"usuario_Cod_usuario_seq"'::regclass) NOT NULL,
    nombre varchar(30) NOT NULL,
    usuario varchar(20) NOT NULL,
    password varchar NOT NULL,
    tipo_usuario varchar(10) NOT NULL,
    activo boolean DEFAULT true NOT NULL
)
WITH (oids = false);
--
-- Structure for table venta (OID = 16529) : 
--
CREATE TABLE public.venta (
    id_venta serial NOT NULL,
    id_venta_temp integer NOT NULL,
    id_apertura integer NOT NULL,
    monto_venta integer NOT NULL,
    id_tipo_pago integer NOT NULL,
    id_usuario integer NOT NULL,
    time_creado timestamp without time zone NOT NULL,
    anulado boolean,
    id_usuario_d integer,
    time_anulado timestamp without time zone
)
WITH (oids = false);
--
-- Structure for table venta_detalle (OID = 16532) : 
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
-- Structure for table venta_temporal (OID = 16539) : 
--
CREATE TABLE public.venta_temporal (
    id_venta_temp serial NOT NULL,
    id_diario serial NOT NULL,
    id_usuario integer NOT NULL,
    time_creado timestamp without time zone DEFAULT now() NOT NULL,
    pagado boolean,
    time_pagado timestamp without time zone,
    anulado boolean DEFAULT false,
    letra_id_diario char(1),
    id_apertura integer
)
WITH (oids = false);
--
-- Definition for view vw_custodia (OID = 16548) : 
--
CREATE VIEW public.vw_custodia
AS
SELECT dinero_custodia.id_dinero_custodia AS id_custodia,
    dinero_custodia.nombre
FROM dinero_custodia
WHERE (dinero_custodia.eliminado IS NOT TRUE);

--
-- Definition for view vw_datos_apertura (OID = 16552) : 
--
CREATE VIEW public.vw_datos_apertura
AS
SELECT ca.id_apertura,
    ca.fecha,
    ca.efectivo,
    ca.time_creado,
    ca.cerrado,
    ca.id_usuario,
    u.nombre AS usuario
FROM (caja_apertura ca
     JOIN usuario u ON ((ca.id_usuario = u.id_usuario)))
WHERE (ca.cerrado IS NOT TRUE);

--
-- Definition for view vw_detalle_venta_temp (OID = 16556) : 
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
    (((vt.letra_id_diario)::text || '-'::text) || vt.id_diario) AS id_diario,
    vt.pagado,
    vt.anulado
FROM (((producto p
     JOIN venta_detalle vd ON ((p.idproducto = vd.idproducto)))
     JOIN unidad u ON ((u.idunidad = p.idunidad)))
     JOIN venta_temporal vt ON ((vd.id_venta_temp = vt.id_venta_temp)));

--
-- Definition for view vw_dinero_custodia_movimientos (OID = 16561) : 
--
CREATE VIEW public.vw_dinero_custodia_movimientos
AS
SELECT dcm.id_movimiento,
    dc.id_dinero_custodia,
    dc.nombre AS nombre_custodia,
    dcm.monto AS monto_movimiento,
    dcm.comentario,
    dcm.id_usuario_i AS id_usuario,
    u.nombre AS nombre_usuario,
    to_char(dcm.time_creado, 'DD-MM-YYYY'::text) AS fecha_movimiento,
    to_char(dcm.time_creado, 'HH24:MI:SS'::text) AS hora_movimiento,
    dcm.eliminado,
    dcm.gasto
FROM ((dinero_custodia_movimientos dcm
     JOIN usuario u ON ((dcm.id_usuario_i = u.id_usuario)))
     RIGHT JOIN dinero_custodia dc ON ((dcm.id_dinero_custodia =
         dc.id_dinero_custodia)));

--
-- Definition for view vw_dinero_en_custodia (OID = 16566) : 
--
CREATE VIEW public.vw_dinero_en_custodia
AS
SELECT dc.id_dinero_custodia,
    dc.nombre AS nombre_dinero_en_custodia,
    (
    SELECT COALESCE(sum(dinero_custodia_movimientos.monto), (0)::bigint) AS sum
    FROM dinero_custodia_movimientos
    WHERE ((dinero_custodia_movimientos.eliminado IS NOT TRUE) AND
        (dinero_custodia_movimientos.id_dinero_custodia = dc.id_dinero_custodia))
    ) AS saldo,
    dc.id_usuario_i AS id_usuario,
    u.nombre AS nombre_usuario,
    dc.time_creado,
    dc.eliminado
FROM (dinero_custodia dc
     JOIN usuario u ON ((dc.id_usuario_i = u.id_usuario)));

--
-- Definition for view vw_efectivo_apertura (OID = 16571) : 
--
CREATE VIEW public.vw_efectivo_apertura
AS
SELECT caja_apertura.id_apertura,
    caja_apertura.efectivo
FROM caja_apertura
WHERE (caja_apertura.cerrado IS NOT TRUE);

--
-- Definition for view vw_gastos (OID = 16575) : 
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
    gc.eliminado,
    to_char((gc.time_creado)::timestamp with time zone, 'DD-MM-YYYY'::text)
        AS fecha,
    to_char(gc.time_creado, 'HH24:MI:SS'::text) AS hora,
    gc.id_movimiento_custodia AS id_mov_custodia
FROM (gastos_caja gc
     JOIN usuario u ON ((gc.id_usuario_i = u.id_usuario)));

--
-- Definition for view vw_total_gastos (OID = 16580) : 
--
CREATE VIEW public.vw_total_gastos
AS
SELECT gastos_caja.id_apertura,
    sum(gastos_caja.monto) AS total_gastos
FROM gastos_caja
WHERE (gastos_caja.eliminado IS NOT TRUE)
GROUP BY gastos_caja.id_apertura, gastos_caja.eliminado;

--
-- Definition for view vw_ventas (OID = 16584) : 
--
CREATE VIEW public.vw_ventas
AS
SELECT v.id_venta,
    v.id_venta_temp,
    vt.id_diario,
    v.id_apertura,
    ca.fecha,
    to_char((ca.fecha)::timestamp with time zone, 'DD-MM-YYYY'::text) AS fecha2,
    v.monto_venta,
    tp.id_tipo_pago,
    tp.nombre_tipo_pago,
    vt.id_usuario AS id_usuario_venta_temp,
    um.nombre AS nombre_usuario_venta_temp,
    to_char(vt.time_creado, 'HH24:MI:SS'::text) AS hora_venta_temp,
    v.id_usuario AS id_usuario_pago,
    uv.nombre AS nombre_usuario_pago,
    to_char(v.time_creado, 'HH24:MI:SS'::text) AS hora_pago
FROM (((((venta v
     JOIN venta_temporal vt ON ((v.id_venta_temp = vt.id_venta_temp)))
     JOIN tipo_pago tp ON ((v.id_tipo_pago = tp.id_tipo_pago)))
     JOIN usuario uv ON ((v.id_usuario = uv.id_usuario)))
     JOIN usuario um ON ((vt.id_usuario = um.id_usuario)))
     JOIN caja_apertura ca ON ((v.id_apertura = ca.id_apertura)));

--
-- Definition for view vw_ventas2 (OID = 16589) : 
--
CREATE VIEW public.vw_ventas2
AS
SELECT v.id_venta,
    v.id_venta_temp,
    (((vt.letra_id_diario)::text || '-'::text) || vt.id_diario) AS id_diario,
    v.id_apertura,
    ca.fecha,
    to_char((ca.fecha)::timestamp with time zone, 'DD-MM-YYYY'::text) AS fecha2,
    v.monto_venta,
    tp.id_tipo_pago,
    tp.nombre_tipo_pago,
    vt.id_usuario AS id_usuario_venta_temp,
    um.nombre AS nombre_usuario_venta_temp,
    to_char(vt.time_creado, 'HH24:MI:SS'::text) AS hora_venta_temp,
    v.id_usuario AS id_usuario_pago,
    uv.nombre AS nombre_usuario_pago,
    to_char(v.time_creado, 'HH24:MI:SS'::text) AS hora_pago,
    v.anulado,
    v.id_usuario_d,
    ud.nombre AS nombre_usuario_d,
    to_char(v.time_anulado, 'DD-MM-YYYY'::text) AS fecha_anulado,
    to_char(v.time_anulado, 'HH24:MI:SS'::text) AS hora_anulado
FROM ((((((venta v
     JOIN venta_temporal vt ON ((v.id_venta_temp = vt.id_venta_temp)))
     JOIN tipo_pago tp ON ((v.id_tipo_pago = tp.id_tipo_pago)))
     JOIN usuario uv ON ((v.id_usuario = uv.id_usuario)))
     JOIN usuario um ON ((vt.id_usuario = um.id_usuario)))
     JOIN caja_apertura ca ON ((v.id_apertura = ca.id_apertura)))
     LEFT JOIN usuario ud ON ((v.id_usuario_d = ud.id_usuario)));

--
-- Definition for view vw_ventas_temporales_anuladas (OID = 16594) : 
--
CREATE VIEW public.vw_ventas_temporales_anuladas
AS
SELECT venta_temporal.id_venta_temp,
    (((venta_temporal.letra_id_diario)::text || '-'::text) ||
        venta_temporal.id_diario) AS id_diario,
    venta_temporal.id_usuario,
    usuario.nombre AS nombre_usuario,
    to_char(venta_temporal.time_creado, 'HH24:MI:SS'::text) AS time_creado,
    venta_temporal.anulado,
    sum(venta_detalle.monto) AS total
FROM ((venta_temporal
     JOIN usuario ON ((venta_temporal.id_usuario = usuario.id_usuario)))
     JOIN venta_detalle ON ((venta_temporal.id_venta_temp =
         venta_detalle.id_venta_temp)))
WHERE ((venta_temporal.pagado IS NOT TRUE) AND (venta_temporal.time_creado
    >= CURRENT_DATE) AND (venta_temporal.time_creado < (CURRENT_DATE + 1)))
GROUP BY venta_temporal.id_venta_temp, usuario.nombre
ORDER BY venta_temporal.id_venta_temp;

--
-- Definition for view vw_ventas_temporales_anuladas2 (OID = 16598) : 
--
CREATE VIEW public.vw_ventas_temporales_anuladas2
AS
SELECT venta_temporal.id_venta_temp,
    (((venta_temporal.letra_id_diario)::text || '-'::text) ||
        venta_temporal.id_diario) AS id_diario,
    venta_temporal.id_usuario,
    usuario.nombre AS nombre_usuario,
    to_char(venta_temporal.time_creado, 'HH24:MI:SS'::text) AS time_creado,
    venta_temporal.anulado,
    sum(venta_detalle.monto) AS total,
    venta_temporal.id_apertura,
    to_char(venta_temporal.time_creado, 'DD-MM-YYYY'::text) AS fecha
FROM ((venta_temporal
     JOIN usuario ON ((venta_temporal.id_usuario = usuario.id_usuario)))
     JOIN venta_detalle ON ((venta_temporal.id_venta_temp =
         venta_detalle.id_venta_temp)))
WHERE (venta_temporal.pagado IS NOT TRUE)
GROUP BY venta_temporal.id_venta_temp, usuario.nombre
ORDER BY venta_temporal.id_venta_temp;

--
-- Definition for view vw_ventas_temporales_impagas (OID = 16602) : 
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
-- Definition for view vw_ventas_temporales_impagas2 (OID = 16606) : 
--
CREATE VIEW public.vw_ventas_temporales_impagas2
AS
SELECT venta_temporal.id_venta_temp,
    (((venta_temporal.letra_id_diario)::text || '-'::text) ||
        venta_temporal.id_diario) AS id_diario,
    venta_temporal.anulado
FROM venta_temporal
WHERE ((venta_temporal.pagado IS NOT TRUE) AND (venta_temporal.id_apertura = (
    SELECT caja_apertura.id_apertura
    FROM caja_apertura
    WHERE (caja_apertura.cerrado IS NOT TRUE)
    )))
ORDER BY venta_temporal.id_venta_temp;

--
-- Definition for view vw_ventas_totales (OID = 16610) : 
--
CREATE VIEW public.vw_ventas_totales
AS
SELECT venta.id_apertura,
    venta.id_tipo_pago,
    sum(venta.monto_venta) AS total_ventas
FROM venta
GROUP BY venta.id_apertura, venta.id_tipo_pago;

--
-- Data for table public.categoria (OID = 16452) (LIMIT 0,16)
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
-- Data for table public.perfiles_usuario (OID = 16479) (LIMIT 0,3)
--
INSERT INTO perfiles_usuario (tipo_usuario, caja, meson, mantenedor_productos, mantenedor_usuarios, tipo_usuario_completo)
VALUES ('admin', true, true, true, true, 'Administrador');

INSERT INTO perfiles_usuario (tipo_usuario, caja, meson, mantenedor_productos, mantenedor_usuarios, tipo_usuario_completo)
VALUES ('meson', NULL, true, NULL, NULL, 'Mesonera');

INSERT INTO perfiles_usuario (tipo_usuario, caja, meson, mantenedor_productos, mantenedor_usuarios, tipo_usuario_completo)
VALUES ('caja', true, NULL, true, NULL, 'Cajera');

--
-- Data for table public.producto (OID = 16485) (LIMIT 0,1)
--
INSERT INTO producto (idproducto, nombreproducto, codigodebarras, precio, imagen, idcategoria, idunidad, activo, inventariable, usuario_ultima_modificacion, time_ultima_modificacion)
VALUES (0, 'Producto genérico', '0000', 0, 'productos.png', 99, 2, true, false, NULL, NULL);

--
-- Data for table public.tipo_gasto (OID = 16501) (LIMIT 0,3)
--
INSERT INTO tipo_gasto (id_tipo_gasto, nombre_tipo_gasto)
VALUES (1, 'Pago proveedores');

INSERT INTO tipo_gasto (id_tipo_gasto, nombre_tipo_gasto)
VALUES (2, 'Pago trabajadores');

INSERT INTO tipo_gasto (id_tipo_gasto, nombre_tipo_gasto)
VALUES (9, 'Otros');

--
-- Data for table public.tipo_pago (OID = 16509) (LIMIT 0,2)
--
INSERT INTO tipo_pago (id_tipo_pago, nombre_tipo_pago)
VALUES (1, 'Efectivo');

INSERT INTO tipo_pago (id_tipo_pago, nombre_tipo_pago)
VALUES (2, 'Tarjeta');

--
-- Data for table public.unidad (OID = 16514) (LIMIT 0,3)
--
INSERT INTO unidad (idunidad, nombreunidad, nombrelargo)
VALUES (1, 'un.', 'Unidad');

INSERT INTO unidad (idunidad, nombreunidad, nombrelargo)
VALUES (2, 'kg.', 'Kilogramo');

INSERT INTO unidad (idunidad, nombreunidad, nombrelargo)
VALUES (3, 'pack', 'Pack');



--
-- Data for table public.usuario (OID = 16520) (LIMIT 0,3)
--
INSERT INTO usuario (id_usuario, nombre, usuario, password, tipo_usuario, activo)
VALUES (1, 'Gabriel Vejar', 'gvejar', '1234', 'admin', true);

INSERT INTO usuario (id_usuario, nombre, usuario, password, tipo_usuario, activo)
VALUES (2, 'Susy', 'susy', '1234', 'caja', true);

INSERT INTO usuario (id_usuario, nombre, usuario, password, tipo_usuario, activo)
VALUES (3, 'Margarita', 'marg', '1234', 'meson', true);

--
-- Definition for index caja_apertura_pk (OID = 16628) : 
--
ALTER TABLE ONLY caja_apertura
    ADD CONSTRAINT caja_apertura_pk
    PRIMARY KEY (id_apertura);
--
-- Definition for index caja_cierre_pk (OID = 16630) : 
--
ALTER TABLE ONLY caja_cierre
    ADD CONSTRAINT caja_cierre_pk
    PRIMARY KEY (id_cierre);
--
-- Definition for index categoria_pkey (OID = 16632) : 
--
ALTER TABLE ONLY categoria
    ADD CONSTRAINT categoria_pkey
    PRIMARY KEY (idcategoria);
--
-- Definition for index dinero_custodia_movi_pk (OID = 16634) : 
--
ALTER TABLE ONLY dinero_custodia_movimientos
    ADD CONSTRAINT dinero_custodia_movi_pk
    PRIMARY KEY (id_movimiento);
--
-- Definition for index dinero_custodia_pk (OID = 16636) : 
--
ALTER TABLE ONLY dinero_custodia
    ADD CONSTRAINT dinero_custodia_pk
    PRIMARY KEY (id_dinero_custodia);
--
-- Definition for index gastos_caja_pk (OID = 16638) : 
--
ALTER TABLE ONLY gastos_caja
    ADD CONSTRAINT gastos_caja_pk
    PRIMARY KEY (id_gasto);
--
-- Definition for index perfiles_usuario_pkey (OID = 16640) : 
--
ALTER TABLE ONLY perfiles_usuario
    ADD CONSTRAINT perfiles_usuario_pkey
    PRIMARY KEY (tipo_usuario);
--
-- Definition for index producto_codigodebarras_key (OID = 16642) : 
--
ALTER TABLE ONLY producto
    ADD CONSTRAINT producto_codigodebarras_key
    UNIQUE (codigodebarras);
--
-- Definition for index producto_pkey (OID = 16644) : 
--
ALTER TABLE ONLY producto
    ADD CONSTRAINT producto_pkey
    PRIMARY KEY (idproducto);
--
-- Definition for index promociones_pk (OID = 16646) : 
--
ALTER TABLE ONLY promociones
    ADD CONSTRAINT promociones_pk
    PRIMARY KEY (id_promocion);
--
-- Definition for index tipo_gasto_pk (OID = 16648) : 
--
ALTER TABLE ONLY tipo_gasto
    ADD CONSTRAINT tipo_gasto_pk
    PRIMARY KEY (id_tipo_gasto);
--
-- Definition for index tipo_pago_pk (OID = 16650) : 
--
ALTER TABLE ONLY tipo_pago
    ADD CONSTRAINT tipo_pago_pk
    PRIMARY KEY (id_tipo_pago);
--
-- Definition for index unidad_pkey (OID = 16652) : 
--
ALTER TABLE ONLY unidad
    ADD CONSTRAINT unidad_pkey
    PRIMARY KEY (idunidad);
--
-- Definition for index usuario_User_key (OID = 16654) : 
--
ALTER TABLE ONLY usuario
    ADD CONSTRAINT "usuario_User_key"
    UNIQUE (usuario);
--
-- Definition for index usuario_pkey (OID = 16657) : 
--
ALTER TABLE ONLY usuario
    ADD CONSTRAINT usuario_pkey
    PRIMARY KEY (id_usuario);
--
-- Definition for index venta_detalle_pk (OID = 16659) : 
--
ALTER TABLE ONLY venta_detalle
    ADD CONSTRAINT venta_detalle_pk
    PRIMARY KEY (id_detalle);
--
-- Definition for index venta_pk (OID = 16661) : 
--
ALTER TABLE ONLY venta
    ADD CONSTRAINT venta_pk
    PRIMARY KEY (id_venta);
--
-- Definition for index venta_temporal_pk (OID = 16663) : 
--
ALTER TABLE ONLY venta_temporal
    ADD CONSTRAINT venta_temporal_pk
    PRIMARY KEY (id_venta_temp);
--
-- Definition for index caja_apert_caja_cierr_fk (OID = 16667) : 
--
ALTER TABLE ONLY caja_cierre
    ADD CONSTRAINT caja_apert_caja_cierr_fk
    FOREIGN KEY (id_apertura) REFERENCES caja_apertura(id_apertura);
--
-- Definition for index caja_apert_gastos_caj_fk (OID = 16672) : 
--
ALTER TABLE ONLY gastos_caja
    ADD CONSTRAINT caja_apert_gastos_caj_fk
    FOREIGN KEY (id_apertura) REFERENCES caja_apertura(id_apertura);
--
-- Definition for index caja_apertura_venta_fk (OID = 16677) : 
--
ALTER TABLE ONLY venta
    ADD CONSTRAINT caja_apertura_venta_fk
    FOREIGN KEY (id_apertura) REFERENCES caja_apertura(id_apertura);
--
-- Definition for index categoria_producto_fk (OID = 16682) : 
--
ALTER TABLE ONLY producto
    ADD CONSTRAINT categoria_producto_fk
    FOREIGN KEY (idcategoria) REFERENCES categoria(idcategoria);
--
-- Definition for index dinero_cus_dinero_cus_fk (OID = 16687) : 
--
ALTER TABLE ONLY dinero_custodia_movimientos
    ADD CONSTRAINT dinero_cus_dinero_cus_fk
    FOREIGN KEY (id_dinero_custodia) REFERENCES dinero_custodia(id_dinero_custodia);
--
-- Definition for index dinero_cus_gastos_caj_fk (OID = 16692) : 
--
ALTER TABLE ONLY gastos_caja
    ADD CONSTRAINT dinero_cus_gastos_caj_fk
    FOREIGN KEY (id_dinero_custodia) REFERENCES dinero_custodia(id_dinero_custodia);
--
-- Definition for index producto_promociones_fk (OID = 16697) : 
--
ALTER TABLE ONLY promociones
    ADD CONSTRAINT producto_promociones_fk
    FOREIGN KEY (idproducto) REFERENCES producto(idproducto);
--
-- Definition for index producto_venta_detalle_fk (OID = 16702) : 
--
ALTER TABLE ONLY venta_detalle
    ADD CONSTRAINT producto_venta_detalle_fk
    FOREIGN KEY (idproducto) REFERENCES producto(idproducto);
--
-- Definition for index promocion_venta_detalle_fk (OID = 16707) : 
--
ALTER TABLE ONLY venta_detalle
    ADD CONSTRAINT promocion_venta_detalle_fk
    FOREIGN KEY (id_promocion) REFERENCES promociones(id_promocion);
--
-- Definition for index tipo_gasto_gastos_caja_fk (OID = 16712) : 
--
ALTER TABLE ONLY gastos_caja
    ADD CONSTRAINT tipo_gasto_gastos_caja_fk
    FOREIGN KEY (id_tipo_gasto) REFERENCES tipo_gasto(id_tipo_gasto);
--
-- Definition for index tipo_pago_venta_fk (OID = 16717) : 
--
ALTER TABLE ONLY venta
    ADD CONSTRAINT tipo_pago_venta_fk
    FOREIGN KEY (id_tipo_pago) REFERENCES tipo_pago(id_tipo_pago);
--
-- Definition for index usuario_caja_apertura_fk (OID = 16722) : 
--
ALTER TABLE ONLY caja_apertura
    ADD CONSTRAINT usuario_caja_apertura_fk
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario);
--
-- Definition for index usuario_caja_cierre_fk (OID = 16727) : 
--
ALTER TABLE ONLY caja_cierre
    ADD CONSTRAINT usuario_caja_cierre_fk
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario);
--
-- Definition for index usuario_di_cus_mov_fk (OID = 16732) : 
--
ALTER TABLE ONLY dinero_custodia_movimientos
    ADD CONSTRAINT usuario_di_cus_mov_fk
    FOREIGN KEY (id_usuario_i) REFERENCES usuario(id_usuario);
--
-- Definition for index usuario_di_cus_mov_fk_1 (OID = 16737) : 
--
ALTER TABLE ONLY dinero_custodia_movimientos
    ADD CONSTRAINT usuario_di_cus_mov_fk_1
    FOREIGN KEY (id_usuario_d) REFERENCES usuario(id_usuario);
--
-- Definition for index usuario_dinero_custodia_fk (OID = 16742) : 
--
ALTER TABLE ONLY dinero_custodia
    ADD CONSTRAINT usuario_dinero_custodia_fk
    FOREIGN KEY (id_usuario_i) REFERENCES usuario(id_usuario);
--
-- Definition for index usuario_dinero_custodia_fk_1 (OID = 16747) : 
--
ALTER TABLE ONLY dinero_custodia
    ADD CONSTRAINT usuario_dinero_custodia_fk_1
    FOREIGN KEY (id_usuario_d) REFERENCES usuario(id_usuario);
--
-- Definition for index usuario_gastos_caja_fk (OID = 16752) : 
--
ALTER TABLE ONLY gastos_caja
    ADD CONSTRAINT usuario_gastos_caja_fk
    FOREIGN KEY (id_usuario_i) REFERENCES usuario(id_usuario);
--
-- Definition for index usuario_gastos_caja_fk_1 (OID = 16757) : 
--
ALTER TABLE ONLY gastos_caja
    ADD CONSTRAINT usuario_gastos_caja_fk_1
    FOREIGN KEY (id_usuario_d) REFERENCES usuario(id_usuario);
--
-- Definition for index usuario_perfil_fk (OID = 16762) : 
--
ALTER TABLE ONLY usuario
    ADD CONSTRAINT usuario_perfil_fk
    FOREIGN KEY (tipo_usuario) REFERENCES perfiles_usuario(tipo_usuario);
--
-- Definition for index usuario_venta_detalle_fk (OID = 16767) : 
--
ALTER TABLE ONLY venta_detalle
    ADD CONSTRAINT usuario_venta_detalle_fk
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario);
--
-- Definition for index usuario_venta_fk (OID = 16772) : 
--
ALTER TABLE ONLY venta
    ADD CONSTRAINT usuario_venta_fk
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario);
--
-- Definition for index usuario_venta_temporal_fk (OID = 16777) : 
--
ALTER TABLE ONLY venta_temporal
    ADD CONSTRAINT usuario_venta_temporal_fk
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario);
--
-- Definition for index venta_temp_venta_deta_fk (OID = 16782) : 
--
ALTER TABLE ONLY venta_detalle
    ADD CONSTRAINT venta_temp_venta_deta_fk
    FOREIGN KEY (id_venta_temp) REFERENCES venta_temporal(id_venta_temp);
--
-- Definition for index venta_temporal_venta_fk (OID = 16787) : 
--
ALTER TABLE ONLY venta
    ADD CONSTRAINT venta_temporal_venta_fk
    FOREIGN KEY (id_venta_temp) REFERENCES venta_temporal(id_venta_temp);
--
-- Data for sequence public.caja_apertura_id_apertura_seq (OID = 16445)
--
SELECT pg_catalog.setval('caja_apertura_id_apertura_seq', 1, true);
--
-- Data for sequence public.caja_cierre_id_cierre_seq (OID = 16450)
--
SELECT pg_catalog.setval('caja_cierre_id_cierre_seq', 1, false);
--
-- Data for sequence public.dinero_custodia_id_dinero_custodia_seq (OID = 16461)
--
SELECT pg_catalog.setval('dinero_custodia_id_dinero_custodia_seq', 1, false);
--
-- Data for sequence public.dinero_custodia_movimientos_id_movimiento_seq (OID = 16469)
--
SELECT pg_catalog.setval('dinero_custodia_movimientos_id_movimiento_seq', 1, false);
--
-- Data for sequence public.gastos_caja_id_gasto_seq (OID = 16477)
--
SELECT pg_catalog.setval('gastos_caja_id_gasto_seq', 1, false);
--
-- Data for sequence public.producto_id_seq (OID = 16494)
--
SELECT pg_catalog.setval('producto_id_seq', 8, true);
--
-- Data for sequence public.promociones_id_promocion_seq (OID = 16499)
--
SELECT pg_catalog.setval('promociones_id_promocion_seq', 1, true);
--
-- Data for sequence public.tipo_gasto_id_tipo_gasto_seq (OID = 16507)
--
SELECT pg_catalog.setval('tipo_gasto_id_tipo_gasto_seq', 1, false);
--
-- Data for sequence public.tipo_pago_id_tipo_pago_seq (OID = 16512)
--
SELECT pg_catalog.setval('tipo_pago_id_tipo_pago_seq', 1, false);
--
-- Data for sequence public."usuario_Cod_usuario_seq" (OID = 16527)
--
SELECT pg_catalog.setval('"usuario_Cod_usuario_seq"', 1, false);
--
-- Data for sequence public.venta_detalle_id_detalle_seq (OID = 16535)
--
SELECT pg_catalog.setval('venta_detalle_id_detalle_seq', 99, true);
--
-- Data for sequence public.venta_id_venta_seq (OID = 16537)
--
SELECT pg_catalog.setval('venta_id_venta_seq', 38, true);
--
-- Data for sequence public.venta_temporal_id_diario_seq (OID = 16544)
--
SELECT pg_catalog.setval('venta_temporal_id_diario_seq', 76, true);
--
-- Data for sequence public.venta_temporal_id_venta_temp_seq (OID = 16546)
--
SELECT pg_catalog.setval('venta_temporal_id_venta_temp_seq', 76, true);
--
-- Comments
--
COMMENT ON SCHEMA public IS 'standard public schema';
