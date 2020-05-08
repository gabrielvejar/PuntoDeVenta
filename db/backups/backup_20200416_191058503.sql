--
-- PostgreSQL database dump
--

-- Dumped from database version 11.5
-- Dumped by pg_dump version 11beta2

-- Started on 2020-04-16 19:10:58

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 256 (class 1255 OID 33034)
-- Name: fn_caja_apertura_i(date, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_caja_apertura_i(date, integer, integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $_$
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
$_$;


ALTER FUNCTION public.fn_caja_apertura_i(date, integer, integer) OWNER TO postgres;

--
-- TOC entry 277 (class 1255 OID 33273)
-- Name: fn_caja_cierre_i(integer, integer, integer, integer, integer, integer, integer, integer, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_caja_cierre_i(integer, integer, integer, integer, integer, integer, integer, integer, character varying, character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $_$
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
$_$;


ALTER FUNCTION public.fn_caja_cierre_i(integer, integer, integer, integer, integer, integer, integer, integer, character varying, character varying) OWNER TO postgres;

--
-- TOC entry 270 (class 1255 OID 33404)
-- Name: fn_dinero_custodia_d(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_dinero_custodia_d(integer, integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $_$
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
$_$;


ALTER FUNCTION public.fn_dinero_custodia_d(integer, integer) OWNER TO postgres;

--
-- TOC entry 271 (class 1255 OID 33372)
-- Name: fn_dinero_custodia_i(character varying, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_dinero_custodia_i(character varying, integer, integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $_$
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
$_$;


ALTER FUNCTION public.fn_dinero_custodia_i(character varying, integer, integer) OWNER TO postgres;

--
-- TOC entry 278 (class 1255 OID 33430)
-- Name: fn_gastos_caja_d(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_gastos_caja_d(integer, integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $_$
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
$_$;


ALTER FUNCTION public.fn_gastos_caja_d(integer, integer) OWNER TO postgres;

--
-- TOC entry 273 (class 1255 OID 33420)
-- Name: fn_gastos_caja_i(integer, integer, character varying, integer, boolean, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_gastos_caja_i(integer, integer, character varying, integer, boolean, integer, integer, integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $_$
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
$_$;


ALTER FUNCTION public.fn_gastos_caja_i(integer, integer, character varying, integer, boolean, integer, integer, integer) OWNER TO postgres;

--
-- TOC entry 266 (class 1255 OID 33191)
-- Name: fn_gastos_caja_i_sin_custodia(integer, integer, character varying, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_gastos_caja_i_sin_custodia(integer, integer, character varying, integer, integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $_$
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
$_$;


ALTER FUNCTION public.fn_gastos_caja_i_sin_custodia(integer, integer, character varying, integer, integer) OWNER TO postgres;

--
-- TOC entry 262 (class 1255 OID 32996)
-- Name: fn_gastos_caja_u(integer, integer, character varying, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_gastos_caja_u(integer, integer, character varying, integer, integer) RETURNS void
    LANGUAGE plpgsql
    AS $_$
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
$_$;


ALTER FUNCTION public.fn_gastos_caja_u(integer, integer, character varying, integer, integer) OWNER TO postgres;

--
-- TOC entry 275 (class 1255 OID 33318)
-- Name: fn_id_diario_actual(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_id_diario_actual() RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
  
BEGIN

	RETURN currval('public.venta_temporal_id_venta_temp_seq');
  
END;
$$;


ALTER FUNCTION public.fn_id_diario_actual() OWNER TO postgres;

--
-- TOC entry 272 (class 1255 OID 33396)
-- Name: fn_movimiento_dec_d(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_movimiento_dec_d(integer, integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $_$
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
$_$;


ALTER FUNCTION public.fn_movimiento_dec_d(integer, integer) OWNER TO postgres;

--
-- TOC entry 279 (class 1255 OID 33409)
-- Name: fn_movimiento_dec_i(integer, integer, character varying, integer, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_movimiento_dec_i(integer, integer, character varying, integer, boolean) RETURNS character varying
    LANGUAGE plpgsql
    AS $_$
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
$_$;


ALTER FUNCTION public.fn_movimiento_dec_i(integer, integer, character varying, integer, boolean) OWNER TO postgres;

--
-- TOC entry 257 (class 1255 OID 32790)
-- Name: fn_producto_d(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_producto_d(character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $_$
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
$_$;


ALTER FUNCTION public.fn_producto_d(character varying) OWNER TO postgres;

--
-- TOC entry 258 (class 1255 OID 32788)
-- Name: fn_producto_iu(character varying, character varying, integer, character varying, integer, integer, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_producto_iu(nombre character varying, codigo character varying, precio integer, imagen character varying, idcat integer, idun integer, cambioimagen boolean) RETURNS character varying
    LANGUAGE plpgsql
    AS $_$
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
$_$;


ALTER FUNCTION public.fn_producto_iu(nombre character varying, codigo character varying, precio integer, imagen character varying, idcat integer, idun integer, cambioimagen boolean) OWNER TO postgres;

--
-- TOC entry 260 (class 1255 OID 32993)
-- Name: fn_promocion_i(integer, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_promocion_i(integer, integer, integer, integer) RETURNS void
    LANGUAGE plpgsql
    AS $_$
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
$_$;


ALTER FUNCTION public.fn_promocion_i(integer, integer, integer, integer) OWNER TO postgres;

--
-- TOC entry 261 (class 1255 OID 32994)
-- Name: fn_promocion_u(integer, integer, integer, integer, integer, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_promocion_u(integer, integer, integer, integer, integer, character varying) RETURNS void
    LANGUAGE plpgsql
    AS $_$
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
$_$;


ALTER FUNCTION public.fn_promocion_u(integer, integer, integer, integer, integer, character varying) OWNER TO postgres;

--
-- TOC entry 274 (class 1255 OID 33299)
-- Name: fn_usuario_i(character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_usuario_i(character varying, character varying, character varying, character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $_$
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
$_$;


ALTER FUNCTION public.fn_usuario_i(character varying, character varying, character varying, character varying) OWNER TO postgres;

--
-- TOC entry 259 (class 1255 OID 33001)
-- Name: fn_venta_detalle_d(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_venta_detalle_d(id_detalle integer) RETURNS void
    LANGUAGE plpgsql
    AS $_$
DECLARE

	__id_detalle 	ALIAS FOR $1;

BEGIN
    
    DELETE FROM 
      public.venta_detalle 
    WHERE 
      venta_detalle.id_detalle = __id_detalle
    ;

END;
$_$;


ALTER FUNCTION public.fn_venta_detalle_d(id_detalle integer) OWNER TO postgres;

--
-- TOC entry 254 (class 1255 OID 32989)
-- Name: fn_venta_detalle_i(integer, integer, numeric, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_venta_detalle_i(integer, integer, numeric, integer, integer, integer) RETURNS void
    LANGUAGE plpgsql
    AS $_$
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
$_$;


ALTER FUNCTION public.fn_venta_detalle_i(integer, integer, numeric, integer, integer, integer) OWNER TO postgres;

--
-- TOC entry 263 (class 1255 OID 32998)
-- Name: fn_venta_detalle_u(integer, integer, integer, numeric, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_venta_detalle_u(integer, integer, integer, numeric, integer, integer, integer) RETURNS void
    LANGUAGE plpgsql
    AS $_$
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
$_$;


ALTER FUNCTION public.fn_venta_detalle_u(integer, integer, integer, numeric, integer, integer, integer) OWNER TO postgres;

--
-- TOC entry 267 (class 1255 OID 33052)
-- Name: fn_venta_i(integer, integer, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_venta_i(integer, integer, integer, integer, integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $_$
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
$_$;


ALTER FUNCTION public.fn_venta_i(integer, integer, integer, integer, integer) OWNER TO postgres;

--
-- TOC entry 268 (class 1255 OID 33056)
-- Name: fn_venta_temporal_anular(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_venta_temporal_anular(integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $_$
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
$_$;


ALTER FUNCTION public.fn_venta_temporal_anular(integer) OWNER TO postgres;

--
-- TOC entry 264 (class 1255 OID 33000)
-- Name: fn_venta_temporal_d(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_venta_temporal_d(integer) RETURNS void
    LANGUAGE plpgsql
    AS $_$
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
$_$;


ALTER FUNCTION public.fn_venta_temporal_d(integer) OWNER TO postgres;

--
-- TOC entry 253 (class 1255 OID 33010)
-- Name: fn_venta_temporal_i(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_venta_temporal_i(integer) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
DECLARE

	_id_usuario ALIAS FOR $1;
  
BEGIN

	INSERT INTO public.venta_temporal(id_usuario) VALUES (_id_usuario);

	RETURN currval('public.venta_temporal_id_venta_temp_seq');
    
    --RETURN QUERY SELECT currval('public.venta_temporal_id_venta_temp_seq') as id_venta_temporal, currval('public.venta_temporal_id_diario_seq') as id_diario;

END;
$_$;


ALTER FUNCTION public.fn_venta_temporal_i(integer) OWNER TO postgres;

--
-- TOC entry 276 (class 1255 OID 33362)
-- Name: fn_venta_temporal_i_letra_id_diario(character, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_venta_temporal_i_letra_id_diario(character, integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $_$
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
$_$;


ALTER FUNCTION public.fn_venta_temporal_i_letra_id_diario(character, integer) OWNER TO postgres;

--
-- TOC entry 269 (class 1255 OID 33051)
-- Name: fn_venta_temporal_pagar(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_venta_temporal_pagar(integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $_$
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
$_$;


ALTER FUNCTION public.fn_venta_temporal_pagar(integer) OWNER TO postgres;

--
-- TOC entry 255 (class 1255 OID 33035)
-- Name: fn_verificar_caja_apertura(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_verificar_caja_apertura() RETURNS character varying
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.fn_verificar_caja_apertura() OWNER TO postgres;

--
-- TOC entry 265 (class 1255 OID 33038)
-- Name: fn_verificar_caja_apertura(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_verificar_caja_apertura(integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $_$
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
$_$;


ALTER FUNCTION public.fn_verificar_caja_apertura(integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 205 (class 1259 OID 32820)
-- Name: caja_apertura; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.caja_apertura (
    id_apertura integer NOT NULL,
    fecha date NOT NULL,
    efectivo integer NOT NULL,
    id_usuario integer NOT NULL,
    time_creado timestamp without time zone NOT NULL,
    cerrado boolean NOT NULL
);


ALTER TABLE public.caja_apertura OWNER TO postgres;

--
-- TOC entry 204 (class 1259 OID 32818)
-- Name: caja_apertura_id_apertura_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.caja_apertura_id_apertura_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.caja_apertura_id_apertura_seq OWNER TO postgres;

--
-- TOC entry 3118 (class 0 OID 0)
-- Dependencies: 204
-- Name: caja_apertura_id_apertura_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.caja_apertura_id_apertura_seq OWNED BY public.caja_apertura.id_apertura;


--
-- TOC entry 228 (class 1259 OID 33244)
-- Name: caja_cierre; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.caja_cierre (
    id_cierre integer NOT NULL,
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
);


ALTER TABLE public.caja_cierre OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 33242)
-- Name: caja_cierre_id_cierre_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.caja_cierre_id_cierre_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.caja_cierre_id_cierre_seq OWNER TO postgres;

--
-- TOC entry 3119 (class 0 OID 0)
-- Dependencies: 227
-- Name: caja_cierre_id_cierre_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.caja_cierre_id_cierre_seq OWNED BY public.caja_cierre.id_cierre;


--
-- TOC entry 198 (class 1259 OID 24594)
-- Name: categoria; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categoria (
    idcategoria smallint NOT NULL,
    nombrecategoria character varying(30) NOT NULL
);


ALTER TABLE public.categoria OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 33064)
-- Name: dinero_custodia; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dinero_custodia (
    id_dinero_custodia integer NOT NULL,
    nombre character varying NOT NULL,
    id_usuario_i integer NOT NULL,
    time_creado timestamp without time zone NOT NULL,
    eliminado boolean,
    id_usuario_d integer,
    time_eliminado timestamp without time zone
);


ALTER TABLE public.dinero_custodia OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 33062)
-- Name: dinero_custodia_id_dinero_custodia_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dinero_custodia_id_dinero_custodia_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.dinero_custodia_id_dinero_custodia_seq OWNER TO postgres;

--
-- TOC entry 3120 (class 0 OID 0)
-- Dependencies: 216
-- Name: dinero_custodia_id_dinero_custodia_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.dinero_custodia_id_dinero_custodia_seq OWNED BY public.dinero_custodia.id_dinero_custodia;


--
-- TOC entry 219 (class 1259 OID 33085)
-- Name: dinero_custodia_movimientos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dinero_custodia_movimientos (
    id_movimiento integer NOT NULL,
    id_dinero_custodia integer NOT NULL,
    monto integer NOT NULL,
    comentario character varying,
    id_usuario_i integer NOT NULL,
    time_creado timestamp without time zone NOT NULL,
    eliminado boolean,
    id_usuario_d integer,
    time_eliminado timestamp without time zone,
    gasto boolean
);


ALTER TABLE public.dinero_custodia_movimientos OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 33083)
-- Name: dinero_custodia_movimientos_id_movimiento_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dinero_custodia_movimientos_id_movimiento_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.dinero_custodia_movimientos_id_movimiento_seq OWNER TO postgres;

--
-- TOC entry 3121 (class 0 OID 0)
-- Dependencies: 218
-- Name: dinero_custodia_movimientos_id_movimiento_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.dinero_custodia_movimientos_id_movimiento_seq OWNED BY public.dinero_custodia_movimientos.id_movimiento;


--
-- TOC entry 223 (class 1259 OID 33155)
-- Name: gastos_caja; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.gastos_caja (
    id_gasto integer NOT NULL,
    id_apertura integer NOT NULL,
    id_tipo_gasto integer NOT NULL,
    descripcion character varying NOT NULL,
    monto integer NOT NULL,
    dinero_en_custodia boolean,
    id_dinero_custodia integer,
    id_usuario_i integer NOT NULL,
    time_creado timestamp without time zone NOT NULL,
    eliminado boolean,
    id_usuario_d integer,
    time_eliminado timestamp without time zone,
    id_movimiento_custodia integer
);


ALTER TABLE public.gastos_caja OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 33153)
-- Name: gastos_caja_id_gasto_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.gastos_caja_id_gasto_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.gastos_caja_id_gasto_seq OWNER TO postgres;

--
-- TOC entry 3122 (class 0 OID 0)
-- Dependencies: 222
-- Name: gastos_caja_id_gasto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.gastos_caja_id_gasto_seq OWNED BY public.gastos_caja.id_gasto;


--
-- TOC entry 229 (class 1259 OID 33285)
-- Name: perfiles_usuario; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.perfiles_usuario (
    tipo_usuario character varying NOT NULL,
    caja boolean,
    meson boolean,
    mantenedor_productos boolean,
    mantenedor_usuarios boolean,
    tipo_usuario_completo character varying
);
ALTER TABLE ONLY public.perfiles_usuario ALTER COLUMN tipo_usuario SET STATISTICS 0;
ALTER TABLE ONLY public.perfiles_usuario ALTER COLUMN caja SET STATISTICS 0;
ALTER TABLE ONLY public.perfiles_usuario ALTER COLUMN meson SET STATISTICS 0;


ALTER TABLE public.perfiles_usuario OWNER TO postgres;

--
-- TOC entry 197 (class 1259 OID 24588)
-- Name: producto; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.producto (
    idproducto integer NOT NULL,
    nombreproducto character varying NOT NULL,
    codigodebarras character varying(30) NOT NULL,
    precio integer NOT NULL,
    imagen character varying(100),
    idcategoria smallint DEFAULT 999,
    idunidad smallint DEFAULT 1,
    activo boolean DEFAULT true NOT NULL
);


ALTER TABLE public.producto OWNER TO postgres;

--
-- TOC entry 196 (class 1259 OID 24586)
-- Name: producto_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.producto_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.producto_id_seq OWNER TO postgres;

--
-- TOC entry 3123 (class 0 OID 0)
-- Dependencies: 196
-- Name: producto_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.producto_id_seq OWNED BY public.producto.idproducto;


--
-- TOC entry 214 (class 1259 OID 32970)
-- Name: promociones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.promociones (
    id_promocion integer NOT NULL,
    idproducto integer NOT NULL,
    cantidad integer NOT NULL,
    tipo_descuento integer NOT NULL,
    descuento integer NOT NULL,
    activo boolean NOT NULL,
    descripcion_promo character varying(50) NOT NULL
);


ALTER TABLE public.promociones OWNER TO postgres;

--
-- TOC entry 213 (class 1259 OID 32968)
-- Name: promociones_id_promocion_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.promociones_id_promocion_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.promociones_id_promocion_seq OWNER TO postgres;

--
-- TOC entry 3124 (class 0 OID 0)
-- Dependencies: 213
-- Name: promociones_id_promocion_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.promociones_id_promocion_seq OWNED BY public.promociones.id_promocion;


--
-- TOC entry 221 (class 1259 OID 33142)
-- Name: tipo_gasto; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tipo_gasto (
    id_tipo_gasto integer NOT NULL,
    nombre_tipo_gasto character varying NOT NULL
);


ALTER TABLE public.tipo_gasto OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 33140)
-- Name: tipo_gasto_id_tipo_gasto_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tipo_gasto_id_tipo_gasto_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tipo_gasto_id_tipo_gasto_seq OWNER TO postgres;

--
-- TOC entry 3125 (class 0 OID 0)
-- Dependencies: 220
-- Name: tipo_gasto_id_tipo_gasto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tipo_gasto_id_tipo_gasto_seq OWNED BY public.tipo_gasto.id_tipo_gasto;


--
-- TOC entry 203 (class 1259 OID 32812)
-- Name: tipo_pago; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tipo_pago (
    id_tipo_pago integer NOT NULL,
    nombre_tipo_pago character varying(100) NOT NULL
);


ALTER TABLE public.tipo_pago OWNER TO postgres;

--
-- TOC entry 202 (class 1259 OID 32810)
-- Name: tipo_pago_id_tipo_pago_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tipo_pago_id_tipo_pago_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tipo_pago_id_tipo_pago_seq OWNER TO postgres;

--
-- TOC entry 3126 (class 0 OID 0)
-- Dependencies: 202
-- Name: tipo_pago_id_tipo_pago_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tipo_pago_id_tipo_pago_seq OWNED BY public.tipo_pago.id_tipo_pago;


--
-- TOC entry 199 (class 1259 OID 32782)
-- Name: unidad; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.unidad (
    idunidad smallint NOT NULL,
    nombreunidad character varying(30) NOT NULL,
    nombrelargo character varying
);


ALTER TABLE public.unidad OWNER TO postgres;

--
-- TOC entry 201 (class 1259 OID 32794)
-- Name: usuario; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usuario (
    id_usuario integer NOT NULL,
    nombre character varying(30) NOT NULL,
    usuario character varying(20) NOT NULL,
    password character varying NOT NULL,
    tipo_usuario character varying(10) NOT NULL,
    activo boolean DEFAULT true NOT NULL
);


ALTER TABLE public.usuario OWNER TO postgres;

--
-- TOC entry 200 (class 1259 OID 32792)
-- Name: usuario_Cod_usuario_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."usuario_Cod_usuario_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."usuario_Cod_usuario_seq" OWNER TO postgres;

--
-- TOC entry 3127 (class 0 OID 0)
-- Dependencies: 200
-- Name: usuario_Cod_usuario_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."usuario_Cod_usuario_seq" OWNED BY public.usuario.id_usuario;


--
-- TOC entry 210 (class 1259 OID 32906)
-- Name: venta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.venta (
    id_venta integer NOT NULL,
    id_venta_temp integer NOT NULL,
    id_apertura integer NOT NULL,
    monto_venta integer NOT NULL,
    id_tipo_pago integer NOT NULL,
    id_usuario integer NOT NULL,
    time_creado timestamp without time zone NOT NULL,
    anulado boolean,
    id_usuario_d integer,
    time_anulado timestamp without time zone
);


ALTER TABLE public.venta OWNER TO postgres;

--
-- TOC entry 212 (class 1259 OID 32939)
-- Name: venta_detalle; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.venta_detalle (
    id_detalle integer NOT NULL,
    id_venta_temp integer NOT NULL,
    idproducto integer NOT NULL,
    cantidad numeric(10,5) NOT NULL,
    id_usuario integer NOT NULL,
    "time" timestamp without time zone NOT NULL,
    monto integer NOT NULL,
    id_promocion integer
);


ALTER TABLE public.venta_detalle OWNER TO postgres;

--
-- TOC entry 211 (class 1259 OID 32937)
-- Name: venta_detalle_id_detalle_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.venta_detalle_id_detalle_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.venta_detalle_id_detalle_seq OWNER TO postgres;

--
-- TOC entry 3128 (class 0 OID 0)
-- Dependencies: 211
-- Name: venta_detalle_id_detalle_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.venta_detalle_id_detalle_seq OWNED BY public.venta_detalle.id_detalle;


--
-- TOC entry 209 (class 1259 OID 32904)
-- Name: venta_id_venta_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.venta_id_venta_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.venta_id_venta_seq OWNER TO postgres;

--
-- TOC entry 3129 (class 0 OID 0)
-- Dependencies: 209
-- Name: venta_id_venta_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.venta_id_venta_seq OWNED BY public.venta.id_venta;


--
-- TOC entry 208 (class 1259 OID 32843)
-- Name: venta_temporal; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.venta_temporal (
    id_venta_temp integer NOT NULL,
    id_diario integer NOT NULL,
    id_usuario integer NOT NULL,
    time_creado timestamp without time zone DEFAULT now() NOT NULL,
    pagado boolean,
    time_pagado timestamp without time zone,
    anulado boolean DEFAULT false,
    letra_id_diario character(1),
    id_apertura integer
);


ALTER TABLE public.venta_temporal OWNER TO postgres;

--
-- TOC entry 207 (class 1259 OID 32841)
-- Name: venta_temporal_id_diario_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.venta_temporal_id_diario_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 99
    CACHE 1
    CYCLE;


ALTER TABLE public.venta_temporal_id_diario_seq OWNER TO postgres;

--
-- TOC entry 3130 (class 0 OID 0)
-- Dependencies: 207
-- Name: venta_temporal_id_diario_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.venta_temporal_id_diario_seq OWNED BY public.venta_temporal.id_diario;


--
-- TOC entry 206 (class 1259 OID 32839)
-- Name: venta_temporal_id_venta_temp_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.venta_temporal_id_venta_temp_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.venta_temporal_id_venta_temp_seq OWNER TO postgres;

--
-- TOC entry 3131 (class 0 OID 0)
-- Dependencies: 206
-- Name: venta_temporal_id_venta_temp_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.venta_temporal_id_venta_temp_seq OWNED BY public.venta_temporal.id_venta_temp;


--
-- TOC entry 236 (class 1259 OID 33405)
-- Name: vw_custodia; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_custodia AS
 SELECT dinero_custodia.id_dinero_custodia AS id_custodia,
    dinero_custodia.nombre
   FROM public.dinero_custodia
  WHERE (dinero_custodia.eliminado IS NOT TRUE);


ALTER TABLE public.vw_custodia OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 33300)
-- Name: vw_datos_apertura; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_datos_apertura AS
 SELECT ca.id_apertura,
    ca.fecha,
    ca.efectivo,
    ca.time_creado,
    ca.cerrado,
    ca.id_usuario,
    u.nombre AS usuario
   FROM (public.caja_apertura ca
     JOIN public.usuario u ON ((ca.id_usuario = u.id_usuario)))
  WHERE (ca.cerrado IS NOT TRUE);


ALTER TABLE public.vw_datos_apertura OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 33355)
-- Name: vw_detalle_venta_temp; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_detalle_venta_temp AS
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
   FROM (((public.producto p
     JOIN public.venta_detalle vd ON ((p.idproducto = vd.idproducto)))
     JOIN public.unidad u ON ((u.idunidad = p.idunidad)))
     JOIN public.venta_temporal vt ON ((vd.id_venta_temp = vt.id_venta_temp)));


ALTER TABLE public.vw_detalle_venta_temp OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 33410)
-- Name: vw_dinero_custodia_movimientos; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_dinero_custodia_movimientos AS
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
   FROM ((public.dinero_custodia_movimientos dcm
     JOIN public.usuario u ON ((dcm.id_usuario_i = u.id_usuario)))
     RIGHT JOIN public.dinero_custodia dc ON ((dcm.id_dinero_custodia = dc.id_dinero_custodia)));


ALTER TABLE public.vw_dinero_custodia_movimientos OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 33378)
-- Name: vw_dinero_en_custodia; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_dinero_en_custodia AS
 SELECT dc.id_dinero_custodia,
    dc.nombre AS nombre_dinero_en_custodia,
    ( SELECT COALESCE(sum(dinero_custodia_movimientos.monto), (0)::bigint) AS sum
           FROM public.dinero_custodia_movimientos
          WHERE ((dinero_custodia_movimientos.eliminado IS NOT TRUE) AND (dinero_custodia_movimientos.id_dinero_custodia = dc.id_dinero_custodia))) AS saldo,
    dc.id_usuario_i AS id_usuario,
    u.nombre AS nombre_usuario,
    dc.time_creado,
    dc.eliminado
   FROM (public.dinero_custodia dc
     JOIN public.usuario u ON ((dc.id_usuario_i = u.id_usuario)));


ALTER TABLE public.vw_dinero_en_custodia OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 33205)
-- Name: vw_efectivo_apertura; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_efectivo_apertura AS
 SELECT caja_apertura.id_apertura,
    caja_apertura.efectivo
   FROM public.caja_apertura
  WHERE (caja_apertura.cerrado IS NOT TRUE);


ALTER TABLE public.vw_efectivo_apertura OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 33421)
-- Name: vw_gastos; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_gastos AS
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
    to_char((gc.time_creado)::timestamp with time zone, 'DD-MM-YYYY'::text) AS fecha,
    to_char(gc.time_creado, 'HH24:MI:SS'::text) AS hora,
    gc.id_movimiento_custodia AS id_mov_custodia
   FROM (public.gastos_caja gc
     JOIN public.usuario u ON ((gc.id_usuario_i = u.id_usuario)));


ALTER TABLE public.vw_gastos OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 33217)
-- Name: vw_total_gastos; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_total_gastos AS
 SELECT gastos_caja.id_apertura,
    sum(gastos_caja.monto) AS total_gastos
   FROM public.gastos_caja
  WHERE (gastos_caja.eliminado IS NOT TRUE)
  GROUP BY gastos_caja.id_apertura, gastos_caja.eliminado;


ALTER TABLE public.vw_total_gastos OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 33310)
-- Name: vw_ventas; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_ventas AS
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
   FROM (((((public.venta v
     JOIN public.venta_temporal vt ON ((v.id_venta_temp = vt.id_venta_temp)))
     JOIN public.tipo_pago tp ON ((v.id_tipo_pago = tp.id_tipo_pago)))
     JOIN public.usuario uv ON ((v.id_usuario = uv.id_usuario)))
     JOIN public.usuario um ON ((vt.id_usuario = um.id_usuario)))
     JOIN public.caja_apertura ca ON ((v.id_apertura = ca.id_apertura)));


ALTER TABLE public.vw_ventas OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 33436)
-- Name: vw_ventas2; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_ventas2 AS
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
   FROM ((((((public.venta v
     JOIN public.venta_temporal vt ON ((v.id_venta_temp = vt.id_venta_temp)))
     JOIN public.tipo_pago tp ON ((v.id_tipo_pago = tp.id_tipo_pago)))
     JOIN public.usuario uv ON ((v.id_usuario = uv.id_usuario)))
     JOIN public.usuario um ON ((vt.id_usuario = um.id_usuario)))
     JOIN public.caja_apertura ca ON ((v.id_apertura = ca.id_apertura)))
     LEFT JOIN public.usuario ud ON ((v.id_usuario_d = ud.id_usuario)));


ALTER TABLE public.vw_ventas2 OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 33345)
-- Name: vw_ventas_temporales_anuladas; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_ventas_temporales_anuladas AS
SELECT
    NULL::integer AS id_venta_temp,
    NULL::text AS id_diario,
    NULL::integer AS id_usuario,
    NULL::character varying(30) AS nombre_usuario,
    NULL::text AS time_creado,
    NULL::boolean AS anulado,
    NULL::bigint AS total;


ALTER TABLE public.vw_ventas_temporales_anuladas OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 33431)
-- Name: vw_ventas_temporales_anuladas2; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_ventas_temporales_anuladas2 AS
SELECT
    NULL::integer AS id_venta_temp,
    NULL::text AS id_diario,
    NULL::integer AS id_usuario,
    NULL::character varying(30) AS nombre_usuario,
    NULL::text AS time_creado,
    NULL::boolean AS anulado,
    NULL::bigint AS total,
    NULL::integer AS id_apertura,
    NULL::text AS fecha;


ALTER TABLE public.vw_ventas_temporales_anuladas2 OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 33021)
-- Name: vw_ventas_temporales_impagas; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_ventas_temporales_impagas AS
 SELECT venta_temporal.id_venta_temp,
    venta_temporal.id_diario,
    venta_temporal.anulado
   FROM public.venta_temporal
  WHERE ((venta_temporal.pagado IS NOT TRUE) AND (venta_temporal.time_creado >= CURRENT_DATE) AND (venta_temporal.time_creado < (CURRENT_DATE + 1)))
  ORDER BY venta_temporal.id_diario;


ALTER TABLE public.vw_ventas_temporales_impagas OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 33336)
-- Name: vw_ventas_temporales_impagas2; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_ventas_temporales_impagas2 AS
 SELECT venta_temporal.id_venta_temp,
    (((venta_temporal.letra_id_diario)::text || '-'::text) || venta_temporal.id_diario) AS id_diario,
    venta_temporal.anulado
   FROM public.venta_temporal
  WHERE ((venta_temporal.pagado IS NOT TRUE) AND (venta_temporal.id_apertura = ( SELECT caja_apertura.id_apertura
           FROM public.caja_apertura
          WHERE (caja_apertura.cerrado IS NOT TRUE))))
  ORDER BY venta_temporal.id_venta_temp;


ALTER TABLE public.vw_ventas_temporales_impagas2 OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 33209)
-- Name: vw_ventas_totales; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_ventas_totales AS
 SELECT venta.id_apertura,
    venta.id_tipo_pago,
    sum(venta.monto_venta) AS total_ventas
   FROM public.venta
  GROUP BY venta.id_apertura, venta.id_tipo_pago;


ALTER TABLE public.vw_ventas_totales OWNER TO postgres;

--
-- TOC entry 2873 (class 2604 OID 32823)
-- Name: caja_apertura id_apertura; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.caja_apertura ALTER COLUMN id_apertura SET DEFAULT nextval('public.caja_apertura_id_apertura_seq'::regclass);


--
-- TOC entry 2885 (class 2604 OID 33247)
-- Name: caja_cierre id_cierre; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.caja_cierre ALTER COLUMN id_cierre SET DEFAULT nextval('public.caja_cierre_id_cierre_seq'::regclass);


--
-- TOC entry 2881 (class 2604 OID 33067)
-- Name: dinero_custodia id_dinero_custodia; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dinero_custodia ALTER COLUMN id_dinero_custodia SET DEFAULT nextval('public.dinero_custodia_id_dinero_custodia_seq'::regclass);


--
-- TOC entry 2882 (class 2604 OID 33088)
-- Name: dinero_custodia_movimientos id_movimiento; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dinero_custodia_movimientos ALTER COLUMN id_movimiento SET DEFAULT nextval('public.dinero_custodia_movimientos_id_movimiento_seq'::regclass);


--
-- TOC entry 2884 (class 2604 OID 33158)
-- Name: gastos_caja id_gasto; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gastos_caja ALTER COLUMN id_gasto SET DEFAULT nextval('public.gastos_caja_id_gasto_seq'::regclass);


--
-- TOC entry 2866 (class 2604 OID 24591)
-- Name: producto idproducto; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.producto ALTER COLUMN idproducto SET DEFAULT nextval('public.producto_id_seq'::regclass);


--
-- TOC entry 2880 (class 2604 OID 32973)
-- Name: promociones id_promocion; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promociones ALTER COLUMN id_promocion SET DEFAULT nextval('public.promociones_id_promocion_seq'::regclass);


--
-- TOC entry 2883 (class 2604 OID 33145)
-- Name: tipo_gasto id_tipo_gasto; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tipo_gasto ALTER COLUMN id_tipo_gasto SET DEFAULT nextval('public.tipo_gasto_id_tipo_gasto_seq'::regclass);


--
-- TOC entry 2872 (class 2604 OID 32815)
-- Name: tipo_pago id_tipo_pago; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tipo_pago ALTER COLUMN id_tipo_pago SET DEFAULT nextval('public.tipo_pago_id_tipo_pago_seq'::regclass);


--
-- TOC entry 2870 (class 2604 OID 32797)
-- Name: usuario id_usuario; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario ALTER COLUMN id_usuario SET DEFAULT nextval('public."usuario_Cod_usuario_seq"'::regclass);


--
-- TOC entry 2878 (class 2604 OID 32909)
-- Name: venta id_venta; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.venta ALTER COLUMN id_venta SET DEFAULT nextval('public.venta_id_venta_seq'::regclass);


--
-- TOC entry 2879 (class 2604 OID 32942)
-- Name: venta_detalle id_detalle; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.venta_detalle ALTER COLUMN id_detalle SET DEFAULT nextval('public.venta_detalle_id_detalle_seq'::regclass);


--
-- TOC entry 2874 (class 2604 OID 32846)
-- Name: venta_temporal id_venta_temp; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.venta_temporal ALTER COLUMN id_venta_temp SET DEFAULT nextval('public.venta_temporal_id_venta_temp_seq'::regclass);


--
-- TOC entry 2875 (class 2604 OID 32847)
-- Name: venta_temporal id_diario; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.venta_temporal ALTER COLUMN id_diario SET DEFAULT nextval('public.venta_temporal_id_diario_seq'::regclass);


--
-- TOC entry 3092 (class 0 OID 32820)
-- Dependencies: 205
-- Data for Name: caja_apertura; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.caja_apertura VALUES (44, '2020-04-13', 978798, 1, '2020-04-13 13:44:45.442592', false);
INSERT INTO public.caja_apertura VALUES (35, '2020-04-02', 12312, 1, '2020-04-02 00:14:35.023866', true);
INSERT INTO public.caja_apertura VALUES (36, '2020-04-01', 21321, 1, '2020-04-02 00:15:02.257245', true);
INSERT INTO public.caja_apertura VALUES (37, '2020-04-02', 21321, 1, '2020-04-02 00:17:45.682381', true);
INSERT INTO public.caja_apertura VALUES (38, '2020-04-02', 213123, 1, '2020-04-02 16:49:36.418945', true);
INSERT INTO public.caja_apertura VALUES (39, '2020-04-04', 100000, 1, '2020-04-04 21:49:49.269386', true);
INSERT INTO public.caja_apertura VALUES (40, '2020-04-04', 150000, 2, '2020-04-04 21:52:52.424743', true);
INSERT INTO public.caja_apertura VALUES (41, '2020-04-12', 400000, 1, '2020-04-12 05:11:03.056663', true);
INSERT INTO public.caja_apertura VALUES (42, '2020-04-13', 400000, 1, '2020-04-13 10:43:51.050609', true);
INSERT INTO public.caja_apertura VALUES (43, '2020-04-13', 50000, 1, '2020-04-13 10:52:12.081386', true);


--
-- TOC entry 3111 (class 0 OID 33244)
-- Dependencies: 228
-- Data for Name: caja_cierre; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.caja_cierre VALUES (13, 35, 12312, 0, 0, 0, 0, 0, 1, '2020-04-02 00:14:49.072348', 1);
INSERT INTO public.caja_cierre VALUES (14, 36, 21321, 0, 0, 0, 0, 0, 1, '2020-04-02 00:15:21.137582', 1);
INSERT INTO public.caja_cierre VALUES (15, 37, 21321, 0, 7200, 0, 0, 0, 1, '2020-04-02 16:49:28.992545', 1);
INSERT INTO public.caja_cierre VALUES (16, 38, 213123, 100000, 2878600, 0, 100000, 668689, 1, '2020-04-04 21:49:10.117455', 1);
INSERT INTO public.caja_cierre VALUES (17, 39, 100000, 150000, 0, 0, 150000, 0, 1, '2020-04-04 21:50:51.385165', 1);
INSERT INTO public.caja_cierre VALUES (18, 40, 150000, 400000, 584500, 0, 400000, 465624, 1, '2020-04-12 05:04:27.873576', 1);
INSERT INTO public.caja_cierre VALUES (19, 42, 400000, 0, 0, 0, 0, 0, 1, '2020-04-13 10:51:49.942255', 1);
INSERT INTO public.caja_cierre VALUES (20, 43, 50000, 0, 0, 0, 0, 0, 1, '2020-04-13 11:08:05.346029', 1);


--
-- TOC entry 3085 (class 0 OID 24594)
-- Dependencies: 198
-- Data for Name: categoria; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.categoria VALUES (5, 'Dulces');
INSERT INTO public.categoria VALUES (6, 'Bebidas');
INSERT INTO public.categoria VALUES (7, 'Abarrotes');
INSERT INTO public.categoria VALUES (3, 'Lácteos');
INSERT INTO public.categoria VALUES (4, 'Galletas');
INSERT INTO public.categoria VALUES (1, 'Panes');
INSERT INTO public.categoria VALUES (8, 'Cervezas');
INSERT INTO public.categoria VALUES (9, 'Cereales');
INSERT INTO public.categoria VALUES (10, 'Pasteles');
INSERT INTO public.categoria VALUES (11, 'Aseo');
INSERT INTO public.categoria VALUES (12, 'Higiene');
INSERT INTO public.categoria VALUES (99, 'Otros');
INSERT INTO public.categoria VALUES (13, 'Mascotas');
INSERT INTO public.categoria VALUES (14, 'Congelados');
INSERT INTO public.categoria VALUES (15, 'Helados');
INSERT INTO public.categoria VALUES (2, 'Cecinas');


--
-- TOC entry 3103 (class 0 OID 33064)
-- Dependencies: 217
-- Data for Name: dinero_custodia; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.dinero_custodia VALUES (12, 'fdsfsdsf', 1, '2020-04-08 03:00:27.959836', NULL, NULL, NULL);
INSERT INTO public.dinero_custodia VALUES (13, 'dfgfdbfd', 1, '2020-04-08 03:03:15.84996', NULL, NULL, NULL);
INSERT INTO public.dinero_custodia VALUES (14, 'dsadvfdbvfdvs sdcdsvsfcdscdsvdsvdscvdscvdscds', 1, '2020-04-08 03:40:19.721375', NULL, NULL, NULL);
INSERT INTO public.dinero_custodia VALUES (15, 'fgsfgasdf', 1, '2020-04-08 03:42:15.045856', NULL, NULL, NULL);
INSERT INTO public.dinero_custodia VALUES (16, 'ddsssss', 1, '2020-04-08 03:43:29.352812', NULL, NULL, NULL);
INSERT INTO public.dinero_custodia VALUES (17, 'Plata Ruty', 1, '2020-04-08 03:44:27.549374', NULL, NULL, NULL);
INSERT INTO public.dinero_custodia VALUES (19, 'tt3', 1, '2020-04-12 00:52:35.596736', NULL, NULL, NULL);
INSERT INTO public.dinero_custodia VALUES (18, 'tttt', 1, '2020-04-12 00:52:15.063054', true, 1, '2020-04-12 03:25:44.980099');


--
-- TOC entry 3105 (class 0 OID 33085)
-- Dependencies: 219
-- Data for Name: dinero_custodia_movimientos; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.dinero_custodia_movimientos VALUES (5, 17, 499000, 'Monto inicial', 1, '2020-04-08 03:44:27.549374', NULL, NULL, NULL, NULL);
INSERT INTO public.dinero_custodia_movimientos VALUES (7, 17, 4543, 'fgdf fgffffff', 1, '2020-04-08 04:34:49.930063', NULL, NULL, NULL, NULL);
INSERT INTO public.dinero_custodia_movimientos VALUES (8, 17, 4543, 'fgdf fgffffff', 1, '2020-04-08 04:34:56.774095', NULL, NULL, NULL, NULL);
INSERT INTO public.dinero_custodia_movimientos VALUES (9, 17, 2342423, 'fewgfsdvsdffffffgggggggg', 1, '2020-04-08 04:37:11.746301', NULL, NULL, NULL, NULL);
INSERT INTO public.dinero_custodia_movimientos VALUES (10, 17, -7000, 'yyy', 1, '2020-04-08 04:37:41.742495', NULL, NULL, NULL, NULL);
INSERT INTO public.dinero_custodia_movimientos VALUES (11, 17, 5000, 'tttt', 1, '2020-04-08 14:58:14.578639', NULL, NULL, NULL, NULL);
INSERT INTO public.dinero_custodia_movimientos VALUES (12, 17, -2848509, 'adasdsa', 1, '2020-04-08 14:58:35.725816', NULL, NULL, NULL, NULL);
INSERT INTO public.dinero_custodia_movimientos VALUES (4, 13, 23432, 'Monto inicial', 1, '2020-04-08 03:03:15.84996', true, 1, '2020-04-11 19:59:37.838742', NULL);
INSERT INTO public.dinero_custodia_movimientos VALUES (15, 13, 76767, 'oooo', 1, '2020-04-11 20:11:41.572096', true, 1, '2020-04-11 20:16:06.216585', NULL);
INSERT INTO public.dinero_custodia_movimientos VALUES (16, 12, 312321, 'aaaaaaa', 1, '2020-04-11 20:17:13.233621', true, 1, '2020-04-11 20:19:23.846839', NULL);
INSERT INTO public.dinero_custodia_movimientos VALUES (17, 12, 12312, 'dsfsddfbvvvvvvvvvvvvvvvvvvv', 1, '2020-04-11 20:20:30.534802', true, 1, '2020-04-11 20:20:41.432427', NULL);
INSERT INTO public.dinero_custodia_movimientos VALUES (18, 14, 222, 'dfadsfdfds', 1, '2020-04-11 20:39:51.320854', NULL, NULL, NULL, NULL);
INSERT INTO public.dinero_custodia_movimientos VALUES (19, 14, -3, 'dfdsf33', 1, '2020-04-11 20:42:39.821549', NULL, NULL, NULL, NULL);
INSERT INTO public.dinero_custodia_movimientos VALUES (20, 14, -300, '300', 1, '2020-04-11 20:42:51.347369', NULL, NULL, NULL, NULL);
INSERT INTO public.dinero_custodia_movimientos VALUES (21, 14, 300, '+300', 1, '2020-04-11 20:43:22.909369', NULL, NULL, NULL, NULL);
INSERT INTO public.dinero_custodia_movimientos VALUES (25, 14, -500, '3242332500', 1, '2020-04-11 20:54:10.789279', true, 1, '2020-04-11 20:54:58.138803', NULL);
INSERT INTO public.dinero_custodia_movimientos VALUES (24, 14, 500, '44', 1, '2020-04-11 20:46:59.386207', true, 1, '2020-04-11 20:55:10.485507', NULL);
INSERT INTO public.dinero_custodia_movimientos VALUES (23, 14, 1000, 'luca', 1, '2020-04-11 20:44:34.430766', true, 1, '2020-04-11 21:31:52.527781', NULL);
INSERT INTO public.dinero_custodia_movimientos VALUES (26, 14, -1000, '1000', 1, '2020-04-11 20:54:42.68072', true, 1, '2020-04-12 00:39:07.105584', NULL);
INSERT INTO public.dinero_custodia_movimientos VALUES (22, 14, -219, '-219', 1, '2020-04-11 20:44:14.421208', true, 1, '2020-04-12 00:39:14.332762', NULL);
INSERT INTO public.dinero_custodia_movimientos VALUES (27, 16, 34, 'sdfss', 1, '2020-04-12 00:52:00.850161', true, 1, '2020-04-12 00:52:05.415938', NULL);
INSERT INTO public.dinero_custodia_movimientos VALUES (28, 18, 324, '324324', 1, '2020-04-12 00:53:03.32003', true, 1, '2020-04-12 00:53:24.235307', NULL);
INSERT INTO public.dinero_custodia_movimientos VALUES (29, 18, -45, 'fgfdg', 1, '2020-04-12 00:53:17.402429', true, 1, '2020-04-12 00:53:31.678768', NULL);
INSERT INTO public.dinero_custodia_movimientos VALUES (30, 18, 44, 'dsfsdfsdf', 1, '2020-04-12 00:53:40.823093', NULL, NULL, NULL, NULL);
INSERT INTO public.dinero_custodia_movimientos VALUES (31, 12, 4000, '555', 1, '2020-04-12 01:29:29.92709', true, 1, '2020-04-12 01:30:04.373488', NULL);
INSERT INTO public.dinero_custodia_movimientos VALUES (32, 12, 7676, 'gfcvmb', 1, '2020-04-12 01:44:17.93965', NULL, NULL, NULL, NULL);
INSERT INTO public.dinero_custodia_movimientos VALUES (33, 12, -7676, 'Retiro total de dinero en custodia', 1, '2020-04-12 02:23:39.150033', true, 1, '2020-04-12 02:50:29.769923', NULL);
INSERT INTO public.dinero_custodia_movimientos VALUES (34, 14, -219, 'Retiro total de dinero en custodia', 1, '2020-04-12 03:08:54.414623', NULL, NULL, NULL, NULL);
INSERT INTO public.dinero_custodia_movimientos VALUES (35, 18, -44, 'Retiro total de dinero en custodia', 1, '2020-04-12 03:14:15.284763', NULL, NULL, NULL, NULL);
INSERT INTO public.dinero_custodia_movimientos VALUES (36, 12, -7676, 'Retiro total de dinero en custodia', 1, '2020-04-12 03:14:52.611363', NULL, NULL, NULL, NULL);
INSERT INTO public.dinero_custodia_movimientos VALUES (37, 12, 7676, 'total de dinero en custodia', 1, '2020-04-12 03:15:25.252512', NULL, NULL, NULL, NULL);
INSERT INTO public.dinero_custodia_movimientos VALUES (38, 12, -7676, 'Retiro total de dinero en custodia', 1, '2020-04-12 03:21:20.946339', NULL, NULL, NULL, NULL);
INSERT INTO public.dinero_custodia_movimientos VALUES (39, 12, 900, 'hbhbhb', 1, '2020-04-12 03:27:05.253362', NULL, NULL, NULL, NULL);
INSERT INTO public.dinero_custodia_movimientos VALUES (40, 17, 5000, 'Pago diario Ruty(Ingresado desde Gastos)', 1, '2020-04-12 03:58:39.338235', NULL, NULL, NULL, NULL);
INSERT INTO public.dinero_custodia_movimientos VALUES (41, 17, 5000, 'Pago diario Ruty(Ingresado desde Gastos)', 1, '2020-04-12 03:58:47.280706', NULL, NULL, NULL, NULL);
INSERT INTO public.dinero_custodia_movimientos VALUES (42, 17, 1000, 'jdasb ruty(Ingresado desde Gastos)', 1, '2020-04-12 04:08:22.43626', NULL, NULL, NULL, NULL);
INSERT INTO public.dinero_custodia_movimientos VALUES (43, 17, 3424, 'dsfsfsdv(Ingresado desde Gastos)', 1, '2020-04-12 04:12:20.566253', NULL, NULL, NULL, NULL);
INSERT INTO public.dinero_custodia_movimientos VALUES (44, 17, 3424, 'dsfsfsdv(Ingresado desde Gastos)', 1, '2020-04-12 04:12:54.390167', NULL, NULL, NULL, NULL);
INSERT INTO public.dinero_custodia_movimientos VALUES (45, 17, 3424, 'dsfsfsdv(Ingresado desde Gastos)', 1, '2020-04-12 04:13:33.264678', NULL, NULL, NULL, NULL);
INSERT INTO public.dinero_custodia_movimientos VALUES (46, 17, 3424, 'dsfsfsdv(Ingresado desde Gastos)', 1, '2020-04-12 04:13:42.719791', NULL, NULL, NULL, NULL);
INSERT INTO public.dinero_custodia_movimientos VALUES (47, 17, 3424, 'dsfsfsdv(Ingresado desde Gastos)', 1, '2020-04-12 04:15:20.685312', NULL, NULL, NULL, NULL);
INSERT INTO public.dinero_custodia_movimientos VALUES (49, 17, 454544, 'sdfsddsf(Ingresado desde Gastos)', 1, '2020-04-12 04:22:42.680884', NULL, NULL, NULL, NULL);
INSERT INTO public.dinero_custodia_movimientos VALUES (50, 12, 234324, 'deee', 1, '2020-04-12 04:41:05.698532', NULL, NULL, NULL, false);
INSERT INTO public.dinero_custodia_movimientos VALUES (51, 19, 234, 'ffdssdf(Ingresado desde Gastos)', 1, '2020-04-12 04:42:23.797914', NULL, NULL, NULL, NULL);
INSERT INTO public.dinero_custodia_movimientos VALUES (52, 19, 234, 'ffdssdf(Ingresado desde Gastos)', 1, '2020-04-12 04:43:22.658641', NULL, NULL, NULL, NULL);
INSERT INTO public.dinero_custodia_movimientos VALUES (53, 19, 3432, 'tttt', 1, '2020-04-12 04:43:33.750897', NULL, NULL, NULL, true);
INSERT INTO public.dinero_custodia_movimientos VALUES (54, 19, 34234, 'tttrrr', 1, '2020-04-12 22:50:54.35382', NULL, NULL, NULL, true);
INSERT INTO public.dinero_custodia_movimientos VALUES (55, 16, 5, 'rtrtrrrrttttttttttttttttttr', 1, '2020-04-12 22:58:14.623089', NULL, NULL, NULL, true);
INSERT INTO public.dinero_custodia_movimientos VALUES (56, 16, 4343, 'yy', 1, '2020-04-12 22:59:11.639347', true, 1, '2020-04-12 23:45:46.234691', true);
INSERT INTO public.dinero_custodia_movimientos VALUES (57, 16, 5000, 'polla jhvcbsdjhvbds', 1, '2020-04-13 10:35:42.985561', NULL, NULL, NULL, true);
INSERT INTO public.dinero_custodia_movimientos VALUES (58, 16, 1000, 'lucas', 1, '2020-04-13 10:37:28.420764', NULL, NULL, NULL, false);
INSERT INTO public.dinero_custodia_movimientos VALUES (59, 16, 1000, 'lucas', 1, '2020-04-13 10:37:31.005149', NULL, NULL, NULL, false);
INSERT INTO public.dinero_custodia_movimientos VALUES (60, 16, 5000, 'retreert', 1, '2020-04-13 10:52:46.567528', NULL, NULL, NULL, false);
INSERT INTO public.dinero_custodia_movimientos VALUES (61, 16, 6000, 'abono lucas', 1, '2020-04-13 10:58:45.155313', NULL, NULL, NULL, false);
INSERT INTO public.dinero_custodia_movimientos VALUES (62, 12, 564, 'dfgdgdfgdf', 1, '2020-04-14 17:28:43.935041', NULL, NULL, NULL, true);


--
-- TOC entry 3109 (class 0 OID 33155)
-- Dependencies: 223
-- Data for Name: gastos_caja; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.gastos_caja VALUES (36, 38, 2, 'ewrwefewef', 41312, false, NULL, 1, '2020-04-03 01:18:05.765718', NULL, NULL, NULL, NULL);
INSERT INTO public.gastos_caja VALUES (37, 38, 2, 'Hjjdun djdjdb', 627377, false, NULL, 1, '2020-04-03 22:07:32.532754', NULL, NULL, NULL, NULL);
INSERT INTO public.gastos_caja VALUES (38, 40, 1, 'wefgbdffgf', 3324, false, NULL, 1, '2020-04-05 18:34:07.009246', NULL, NULL, NULL, NULL);
INSERT INTO public.gastos_caja VALUES (47, 40, 2, 'dsfdsfdsfdsddddddddd', 4324, false, NULL, 1, '2020-04-12 04:21:48.467968', NULL, NULL, NULL, NULL);
INSERT INTO public.gastos_caja VALUES (48, 40, 2, 'sdfsddsf', 454544, true, 17, 1, '2020-04-12 04:22:42.740449', NULL, NULL, NULL, NULL);
INSERT INTO public.gastos_caja VALUES (49, 40, 2, 'tttt', 3432, true, 19, 1, '2020-04-12 04:43:33.80813', NULL, NULL, NULL, NULL);
INSERT INTO public.gastos_caja VALUES (51, 41, 1, 'tttrrr', 34234, true, 19, 1, '2020-04-12 22:50:54.431724', NULL, NULL, NULL, NULL);
INSERT INTO public.gastos_caja VALUES (53, 41, 2, '5555', 454, false, NULL, 1, '2020-04-12 23:26:41.667858', NULL, NULL, NULL, NULL);
INSERT INTO public.gastos_caja VALUES (50, 41, 1, '435gert', 65, false, NULL, 1, '2020-04-12 21:46:06.548743', true, 1, '2020-04-12 23:44:58.839915', NULL);
INSERT INTO public.gastos_caja VALUES (52, 41, 1, 'yy', 4343, true, 16, 1, '2020-04-12 22:59:11.709698', true, 1, '2020-04-12 23:45:46.234691', 56);
INSERT INTO public.gastos_caja VALUES (54, 41, 1, 'Cocacola', 50000, false, NULL, 1, '2020-04-13 10:34:58.007475', NULL, NULL, NULL, NULL);
INSERT INTO public.gastos_caja VALUES (55, 41, 9, 'polla jhvcbsdjhvbds', 5000, true, 16, 1, '2020-04-13 10:35:43.057297', NULL, NULL, NULL, 57);
INSERT INTO public.gastos_caja VALUES (56, 44, 2, 'dfgdgdfgdf', 564, true, 12, 1, '2020-04-14 17:28:44.025246', NULL, NULL, NULL, 62);


--
-- TOC entry 3112 (class 0 OID 33285)
-- Dependencies: 229
-- Data for Name: perfiles_usuario; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.perfiles_usuario VALUES ('admin', true, true, true, true, 'Administrador');
INSERT INTO public.perfiles_usuario VALUES ('meson', NULL, true, NULL, NULL, 'Mesonera');
INSERT INTO public.perfiles_usuario VALUES ('caja', true, NULL, true, NULL, 'Cajera');


--
-- TOC entry 3084 (class 0 OID 24588)
-- Dependencies: 197
-- Data for Name: producto; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.producto VALUES (52, '27', '2312312321', 45, '', 2, 2, true);
INSERT INTO public.producto VALUES (53, '28', '234242423', 231312, '', 1, 2, true);
INSERT INTO public.producto VALUES (54, '29', '12321312321', 5443, '', 2, 2, true);
INSERT INTO public.producto VALUES (55, '30', '2332', 231312, '', 2, 2, true);
INSERT INTO public.producto VALUES (56, '31', '23423432', 231312, '', 1, 2, false);
INSERT INTO public.producto VALUES (51, '23', '32324', 231312, '', 2, 1, false);
INSERT INTO public.producto VALUES (57, 'Pan corriente', '001', 1300, '001.jpg', 1, 1, true);
INSERT INTO public.producto VALUES (25, '01', '64649484', 600, '64649484.jpg', 2, 120, true);
INSERT INTO public.producto VALUES (11, 'GGjgvjg gvhgvh', '5656565656265', 500, '', 12, 2, true);
INSERT INTO public.producto VALUES (19, '02', '343242234', 5443, '343242234.jpg', 2, 2, true);
INSERT INTO public.producto VALUES (50, '04', '9', 649484, '9.jpg', 3, 1, true);
INSERT INTO public.producto VALUES (60, 'Gabo', '777', 655655, '777.jpg', 8, 1, true);
INSERT INTO public.producto VALUES (1, 'pan con chancho', '11', 1300, 'marraqueta.jpg', 1, 1, true);
INSERT INTO public.producto VALUES (61, 'Hsbsusb', '555', 3484, '555.jpg', 6, 1, true);
INSERT INTO public.producto VALUES (22, '06', '946434646', 777, '946434646.jpg', 2, 2, true);
INSERT INTO public.producto VALUES (37, '15', '6464949', 5000, '', 2, 2, true);
INSERT INTO public.producto VALUES (62, 'Cachantun Mas Uva 500ml', '11122233', 600, '11122233.jpg', 6, 2, true);
INSERT INTO public.producto VALUES (63, 'Coca-Cola 300ml', '2131188', 500, '2131188.jpg', 6, 2, true);
INSERT INTO public.producto VALUES (2, '03', '212', 4000, '', 1, 1, true);
INSERT INTO public.producto VALUES (64, 'Aceite Oliva Talliani 250ml', '7801320242209', 2000, '7801320242209.jpg', 7, 2, true);
INSERT INTO public.producto VALUES (65, ' Lorem ipsum dolor sit amet consectetur adipisicing elit. Doloremque sequi beatae minus at accusamus, excepturi maxime fugit sit nostrum vero enim nulla tenetur ratione esse odit culpa quia exercitationem nesciunt!', '333', 3432, '', 99, 2, false);
INSERT INTO public.producto VALUES (66, 'Virginia', '7805040313003', 1200, '7805040313003.jpg', 11, 2, true);
INSERT INTO public.producto VALUES (67, 'Silicona', '7805050582420', 3000, '7805050582420.jpg', 11, 2, true);
INSERT INTO public.producto VALUES (33, '07', '2', 5443, '', 2, 2, true);
INSERT INTO public.producto VALUES (34, '08', '21313', 231312, '', 2, 2, true);
INSERT INTO public.producto VALUES (15, '09', '2423432423', 231312, '', 2, 1, true);
INSERT INTO public.producto VALUES (21, '10', '3234324324', 231312, '', 2, 1, true);
INSERT INTO public.producto VALUES (40, '11', '41414', 231312, '', 1, 1, true);
INSERT INTO public.producto VALUES (23, '12', '613191616', 31518161, '613191616.jpg', 3, 1, true);
INSERT INTO public.producto VALUES (24, '13', '349494649', 6494994, '349494649.jpg', 2, 1, true);
INSERT INTO public.producto VALUES (47, '14', '349484646', 94648, '', 1, 1, true);
INSERT INTO public.producto VALUES (49, '16', '6494848', 64940, '6494848.jpg', 1, 1, true);
INSERT INTO public.producto VALUES (14, '17', '123123', 1300, '', 1, 2, true);
INSERT INTO public.producto VALUES (31, '18', '213123', 231312, '', 2, 2, true);
INSERT INTO public.producto VALUES (38, '20', '321321', 34649, '321321.jpg', 2, 2, true);
INSERT INTO public.producto VALUES (39, '21', '6524655', 68867, '6524655.jpg', 2, 2, true);
INSERT INTO public.producto VALUES (3, '22', '123456789012', 324, '', 2, 2, true);
INSERT INTO public.producto VALUES (4, '24', '234', 500, '234.jpg', 1, 1, true);
INSERT INTO public.producto VALUES (46, '25', '341323', 1600, '', 2, 1, true);
INSERT INTO public.producto VALUES (10, '26', '5656565656565', 44, '', 1, 1, true);


--
-- TOC entry 3101 (class 0 OID 32970)
-- Dependencies: 214
-- Data for Name: promociones; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.promociones VALUES (1, 14, 4, 1, 200, true, '4 por $5000');


--
-- TOC entry 3107 (class 0 OID 33142)
-- Dependencies: 221
-- Data for Name: tipo_gasto; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tipo_gasto VALUES (1, 'Pago proveedores');
INSERT INTO public.tipo_gasto VALUES (2, 'Pago trabajadores');
INSERT INTO public.tipo_gasto VALUES (9, 'Otros');


--
-- TOC entry 3090 (class 0 OID 32812)
-- Dependencies: 203
-- Data for Name: tipo_pago; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tipo_pago VALUES (1, 'Efectivo');
INSERT INTO public.tipo_pago VALUES (2, 'Tarjeta');


--
-- TOC entry 3086 (class 0 OID 32782)
-- Dependencies: 199
-- Data for Name: unidad; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.unidad VALUES (1, 'kg.', NULL);
INSERT INTO public.unidad VALUES (3, 'pack', NULL);
INSERT INTO public.unidad VALUES (2, 'un.', NULL);


--
-- TOC entry 3088 (class 0 OID 32794)
-- Dependencies: 201
-- Data for Name: usuario; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.usuario VALUES (1, 'Gabriel Vejar', 'gvejar', '1234', 'admin', true);
INSERT INTO public.usuario VALUES (2, 'Susy', 'susy', '1234', 'caja', true);
INSERT INTO public.usuario VALUES (3, 'Margarita', 'marg', '1234', 'meson', true);


--
-- TOC entry 3097 (class 0 OID 32906)
-- Dependencies: 210
-- Data for Name: venta; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.venta VALUES (20, 76, 37, 1200, 1, 1, '2020-04-02 15:59:30.163801', NULL, NULL, NULL);
INSERT INTO public.venta VALUES (22, 78, 38, 1311310, 1, 1, '2020-04-02 16:49:52.074946', NULL, NULL, NULL);
INSERT INTO public.venta VALUES (21, 77, 37, 6000, 2, 2, '2020-04-02 16:00:31.987472', NULL, NULL, NULL);
INSERT INTO public.venta VALUES (23, 80, 38, 210, 1, 1, '2020-04-02 18:23:47.930277', NULL, NULL, NULL);
INSERT INTO public.venta VALUES (24, 83, 38, 7600, 1, 1, '2020-04-03 00:09:50.82193', NULL, NULL, NULL);
INSERT INTO public.venta VALUES (25, 84, 38, 1513910, 1, 1, '2020-04-03 00:16:59.836435', NULL, NULL, NULL);
INSERT INTO public.venta VALUES (26, 90, 38, 3120, 1, 1, '2020-04-03 21:25:03.021298', NULL, NULL, NULL);
INSERT INTO public.venta VALUES (27, 91, 38, 1300, 1, 1, '2020-04-04 00:23:27.332842', NULL, NULL, NULL);
INSERT INTO public.venta VALUES (28, 92, 38, 6500, 1, 1, '2020-04-04 00:32:53.483947', NULL, NULL, NULL);
INSERT INTO public.venta VALUES (29, 93, 38, 1300, 1, 1, '2020-04-04 00:35:27.906696', NULL, NULL, NULL);
INSERT INTO public.venta VALUES (30, 94, 38, 1200, 1, 1, '2020-04-04 00:38:48.606273', NULL, NULL, NULL);
INSERT INTO public.venta VALUES (31, 95, 38, 2350, 1, 1, '2020-04-04 00:39:53.477716', NULL, NULL, NULL);
INSERT INTO public.venta VALUES (32, 96, 38, 0, 1, 1, '2020-04-04 00:40:52.493121', NULL, NULL, NULL);
INSERT INTO public.venta VALUES (33, 97, 38, 1200, 1, 1, '2020-04-04 00:42:25.79897', NULL, NULL, NULL);
INSERT INTO public.venta VALUES (34, 98, 38, 1200, 1, 1, '2020-04-04 00:43:01.591692', NULL, NULL, NULL);
INSERT INTO public.venta VALUES (35, 99, 38, 1200, 1, 1, '2020-04-04 00:43:59.193959', NULL, NULL, NULL);
INSERT INTO public.venta VALUES (36, 100, 38, 1200, 1, 2, '2020-04-04 03:49:09.563699', NULL, NULL, NULL);
INSERT INTO public.venta VALUES (37, 101, 38, 210, 1, 2, '2020-04-04 03:49:15.640326', NULL, NULL, NULL);
INSERT INTO public.venta VALUES (38, 102, 38, 1230, 1, 2, '2020-04-04 03:49:21.748481', NULL, NULL, NULL);
INSERT INTO public.venta VALUES (39, 103, 38, 12310, 1, 2, '2020-04-04 03:49:47.965479', NULL, NULL, NULL);
INSERT INTO public.venta VALUES (40, 104, 38, 1200, 1, 2, '2020-04-04 03:50:04.427537', NULL, NULL, NULL);
INSERT INTO public.venta VALUES (41, 109, 38, 3420, 1, 1, '2020-04-04 19:35:06.135947', NULL, NULL, NULL);
INSERT INTO public.venta VALUES (42, 113, 38, 600, 1, 1, '2020-04-04 21:00:30.805981', NULL, NULL, NULL);
INSERT INTO public.venta VALUES (43, 111, 38, 2000, 1, 1, '2020-04-04 21:03:00.229148', NULL, NULL, NULL);
INSERT INTO public.venta VALUES (44, 112, 38, 600, 1, 1, '2020-04-04 21:03:06.829213', NULL, NULL, NULL);
INSERT INTO public.venta VALUES (45, 110, 38, 3430, 1, 1, '2020-04-04 21:03:12.579149', NULL, NULL, NULL);
INSERT INTO public.venta VALUES (46, 114, 40, 1200, 1, 2, '2020-04-04 21:55:37.87342', NULL, NULL, NULL);
INSERT INTO public.venta VALUES (47, 115, 40, 500, 1, 2, '2020-04-04 21:55:47.670588', NULL, NULL, NULL);
INSERT INTO public.venta VALUES (48, 116, 40, 534540, 1, 2, '2020-04-04 22:21:39.764909', NULL, NULL, NULL);
INSERT INTO public.venta VALUES (49, 117, 40, 600, 1, 2, '2020-04-04 23:22:14.12583', NULL, NULL, NULL);
INSERT INTO public.venta VALUES (50, 119, 40, 2000, 1, 2, '2020-04-04 23:31:19.951515', NULL, NULL, NULL);
INSERT INTO public.venta VALUES (51, 123, 40, 45340, 1, 1, '2020-04-06 00:47:17.712858', NULL, NULL, NULL);
INSERT INTO public.venta VALUES (53, 126, 40, 320, 1, 1, '2020-04-06 01:27:40.727283', NULL, NULL, NULL);
INSERT INTO public.venta VALUES (54, 131, 41, 670, 1, 1, '2020-04-12 15:45:59.020883', NULL, NULL, NULL);
INSERT INTO public.venta VALUES (55, 132, 41, 500, 1, 1, '2020-04-12 16:03:33.02935', NULL, NULL, NULL);
INSERT INTO public.venta VALUES (56, 135, 41, 1200, 1, 1, '2020-04-12 16:21:27.297513', true, 1, '2020-04-13 01:20:56.172');
INSERT INTO public.venta VALUES (57, 136, 44, 500, 1, 1, '2020-04-14 17:43:46.260569', NULL, NULL, NULL);


--
-- TOC entry 3099 (class 0 OID 32939)
-- Dependencies: 212
-- Data for Name: venta_detalle; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.venta_detalle VALUES (3, 2, 1, 213.00000, 1, '2020-03-14 01:05:00.006', 1231231, NULL);
INSERT INTO public.venta_detalle VALUES (109, 99, 66, 1.00000, 1, '2020-04-04 00:43:59.126948', 1200, NULL);
INSERT INTO public.venta_detalle VALUES (7, 4, 1, 8.20000, 1, '2020-03-15 02:35:57.7858', 10660, NULL);
INSERT INTO public.venta_detalle VALUES (8, 4, 1, 0.33300, 1, '2020-03-15 02:38:21.090239', 433, NULL);
INSERT INTO public.venta_detalle VALUES (11, 2, 50, 3.00000, 1, '2020-03-21 17:35:02.53725', 21312, NULL);
INSERT INTO public.venta_detalle VALUES (12, 25, 57, 1.00000, 1, '2020-03-23 02:16:18.757717', 1300, NULL);
INSERT INTO public.venta_detalle VALUES (13, 26, 57, 1.00000, 1, '2020-03-23 02:22:21.998317', 1300, NULL);
INSERT INTO public.venta_detalle VALUES (14, 26, 60, 2.00000, 1, '2020-03-23 02:22:22.001751', 1311310, NULL);
INSERT INTO public.venta_detalle VALUES (15, 27, 57, 1.00000, 1, '2020-03-23 02:25:42.689174', 1300, NULL);
INSERT INTO public.venta_detalle VALUES (16, 28, 57, 1.00000, 1, '2020-03-23 02:28:35.531917', 1300, NULL);
INSERT INTO public.venta_detalle VALUES (17, 28, 61, 0.04000, 1, '2020-03-23 02:28:35.534707', 122, NULL);
INSERT INTO public.venta_detalle VALUES (18, 29, 1, 0.06000, 1, '2020-03-23 13:59:35.441189', 76, NULL);
INSERT INTO public.venta_detalle VALUES (19, 30, 57, 0.95000, 1, '2020-03-23 14:09:08.272547', 1231, NULL);
INSERT INTO public.venta_detalle VALUES (20, 31, 57, 0.09000, 1, '2020-03-23 14:12:45.828092', 123, NULL);
INSERT INTO public.venta_detalle VALUES (21, 32, 57, 123.00000, 1, '2020-03-23 14:29:00.747146', 159900, NULL);
INSERT INTO public.venta_detalle VALUES (22, 33, 11, 1.00000, 1, '2020-03-23 16:41:06.945994', 500, NULL);
INSERT INTO public.venta_detalle VALUES (23, 34, 14, 1.00000, 1, '2020-03-23 16:43:14.673546', 1300, NULL);
INSERT INTO public.venta_detalle VALUES (24, 35, 57, 1.00000, 1, '2020-03-23 16:53:16.549935', 1300, NULL);
INSERT INTO public.venta_detalle VALUES (25, 36, 1, 42.19000, 1, '2020-03-24 03:05:52.486983', 54846, NULL);
INSERT INTO public.venta_detalle VALUES (26, 37, 57, 1.54000, 1, '2020-03-24 19:04:44.167886', 2000, NULL);
INSERT INTO public.venta_detalle VALUES (27, 38, 57, 0.95000, 1, '2020-03-25 00:29:20.462231', 1233, NULL);
INSERT INTO public.venta_detalle VALUES (28, 38, 61, 1.00000, 1, '2020-03-25 00:29:20.467083', 3484, NULL);
INSERT INTO public.venta_detalle VALUES (29, 38, 11, 33.00000, 1, '2020-03-25 00:29:20.467859', 16500, NULL);
INSERT INTO public.venta_detalle VALUES (30, 38, 14, 4.00000, 1, '2020-03-25 00:29:20.468511', 5000, 1);
INSERT INTO public.venta_detalle VALUES (31, 39, 50, 1.00000, 1, '2020-03-25 14:13:12.464062', 649484, NULL);
INSERT INTO public.venta_detalle VALUES (32, 40, 60, 2.00000, 1, '2020-03-25 15:06:19.306824', 1311310, NULL);
INSERT INTO public.venta_detalle VALUES (33, 41, 60, 0.01000, 1, '2020-03-25 16:57:09.468764', 3454, NULL);
INSERT INTO public.venta_detalle VALUES (34, 41, 50, 0.01000, 1, '2020-03-25 16:57:09.471094', 4466, NULL);
INSERT INTO public.venta_detalle VALUES (35, 42, 60, 0.00000, 1, '2020-03-25 17:02:24.628763', 567, NULL);
INSERT INTO public.venta_detalle VALUES (36, 43, 60, 0.04000, 1, '2020-03-25 17:45:10.674751', 23133, NULL);
INSERT INTO public.venta_detalle VALUES (37, 44, 62, 2.00000, 1, '2020-03-25 19:05:48.288575', 1200, NULL);
INSERT INTO public.venta_detalle VALUES (38, 44, 63, 6.00000, 1, '2020-03-25 19:05:48.291286', 3000, NULL);
INSERT INTO public.venta_detalle VALUES (39, 45, 60, 0.19000, 1, '2020-03-25 19:08:58.558042', 123123, NULL);
INSERT INTO public.venta_detalle VALUES (40, 46, 63, 2.00000, 1, '2020-03-25 19:13:43.089814', 1000, NULL);
INSERT INTO public.venta_detalle VALUES (41, 47, 63, 2.00000, 1, '2020-03-25 19:54:02.321168', 1000, NULL);
INSERT INTO public.venta_detalle VALUES (42, 47, 62, 3.00000, 1, '2020-03-25 19:54:02.324344', 1800, NULL);
INSERT INTO public.venta_detalle VALUES (43, 48, 50, 1.00000, 1, '2020-03-25 20:29:57.099153', 649484, NULL);
INSERT INTO public.venta_detalle VALUES (44, 48, 62, 3.00000, 1, '2020-03-25 20:29:57.103791', 1800, NULL);
INSERT INTO public.venta_detalle VALUES (45, 49, 62, 1.00000, 1, '2020-03-25 22:22:25.826458', 600, NULL);
INSERT INTO public.venta_detalle VALUES (46, 50, 60, 0.00000, 1, '2020-03-25 22:42:03.912238', 2, NULL);
INSERT INTO public.venta_detalle VALUES (47, 51, 57, 0.95000, 1, '2020-03-25 22:43:30.767046', 1231, NULL);
INSERT INTO public.venta_detalle VALUES (48, 52, 60, 0.03000, 1, '2020-03-26 15:47:49.027203', 21312, NULL);
INSERT INTO public.venta_detalle VALUES (50, 54, 60, 0.00000, 1, '2020-03-29 01:20:41.250448', 123, NULL);
INSERT INTO public.venta_detalle VALUES (51, 55, 60, 1.00000, 1, '2020-03-29 02:02:17.554173', 655655, NULL);
INSERT INTO public.venta_detalle VALUES (52, 55, 63, 1.00000, 1, '2020-03-29 02:02:17.557603', 500, NULL);
INSERT INTO public.venta_detalle VALUES (53, 54, 63, 5.00000, 1, '2020-03-29 02:06:22.483779', 2500, NULL);
INSERT INTO public.venta_detalle VALUES (54, 56, 1, 0.95000, 1, '2020-03-29 02:07:39.321079', 1233, NULL);
INSERT INTO public.venta_detalle VALUES (55, 56, 62, 4.00000, 1, '2020-03-29 02:07:39.323061', 2400, NULL);
INSERT INTO public.venta_detalle VALUES (56, 57, 62, 6.00000, 1, '2020-03-29 02:09:07.809939', 3600, NULL);
INSERT INTO public.venta_detalle VALUES (57, 58, 62, 3.00000, 1, '2020-03-29 02:12:32.612142', 1800, NULL);
INSERT INTO public.venta_detalle VALUES (58, 59, 57, 1.00000, 1, '2020-03-29 03:55:19.815306', 1300, NULL);
INSERT INTO public.venta_detalle VALUES (59, 59, 63, 2.00000, 1, '2020-03-29 03:55:19.818747', 1000, NULL);
INSERT INTO public.venta_detalle VALUES (60, 59, 62, 4.00000, 1, '2020-03-29 03:55:47.97716', 2400, NULL);
INSERT INTO public.venta_detalle VALUES (61, 60, 60, 2.00000, 1, '2020-03-29 03:56:44.166', 1311310, NULL);
INSERT INTO public.venta_detalle VALUES (62, 61, 11, 2.00000, 1, '2020-03-29 03:59:36.258052', 1000, NULL);
INSERT INTO public.venta_detalle VALUES (63, 62, 60, 2.00000, 1, '2020-03-29 04:03:22.059783', 1311310, NULL);
INSERT INTO public.venta_detalle VALUES (66, 65, 62, 10.00000, 1, '2020-03-29 05:01:19.365193', 6000, NULL);
INSERT INTO public.venta_detalle VALUES (67, 66, 60, 8.00000, 1, '2020-03-29 05:03:08.955792', 5245240, NULL);
INSERT INTO public.venta_detalle VALUES (68, 67, 60, 4.00000, 1, '2020-03-29 05:08:37.118679', 2622620, NULL);
INSERT INTO public.venta_detalle VALUES (69, 68, 57, 1.00000, 1, '2020-03-29 05:11:14.997814', 1300, NULL);
INSERT INTO public.venta_detalle VALUES (70, 69, 60, 23.00000, 1, '2020-03-29 05:13:54.912524', 15080065, NULL);
INSERT INTO public.venta_detalle VALUES (71, 70, 60, 1.00000, 1, '2020-03-29 05:22:21.814493', 655655, NULL);
INSERT INTO public.venta_detalle VALUES (72, 71, 62, 2.00000, 1, '2020-03-29 05:23:58.360853', 1200, NULL);
INSERT INTO public.venta_detalle VALUES (75, 74, 11, 4.00000, 1, '2020-03-31 19:20:17.4096', 2000, NULL);
INSERT INTO public.venta_detalle VALUES (76, 75, 60, 1.17000, 1, '2020-03-31 19:20:54.535574', 765765, NULL);
INSERT INTO public.venta_detalle VALUES (77, 76, 62, 2.00000, 1, '2020-04-02 15:57:52.414523', 1200, NULL);
INSERT INTO public.venta_detalle VALUES (78, 77, 63, 12.00000, 1, '2020-04-02 15:58:12.751049', 6000, NULL);
INSERT INTO public.venta_detalle VALUES (79, 78, 60, 2.00000, 1, '2020-04-02 16:49:52.010953', 1311310, NULL);
INSERT INTO public.venta_detalle VALUES (80, 79, 60, 343.00000, 1, '2020-04-02 18:22:37.92862', 224889665, NULL);
INSERT INTO public.venta_detalle VALUES (81, 80, 1, 0.16000, 1, '2020-04-02 18:23:15.793051', 212, NULL);
INSERT INTO public.venta_detalle VALUES (82, 81, 62, 34.00000, 1, '2020-04-02 18:26:20.095244', 20400, NULL);
INSERT INTO public.venta_detalle VALUES (83, 82, 60, 32.00000, 1, '2020-04-02 19:53:53.610755', 20980960, NULL);
INSERT INTO public.venta_detalle VALUES (84, 83, 14, 6.00000, 1, '2020-04-03 00:09:50.740907', 7600, 1);
INSERT INTO public.venta_detalle VALUES (85, 84, 1, 94.78000, 1, '2020-04-03 00:16:59.755695', 123213, NULL);
INSERT INTO public.venta_detalle VALUES (86, 84, 62, 2312.00000, 1, '2020-04-03 00:16:59.7591', 1387200, NULL);
INSERT INTO public.venta_detalle VALUES (87, 84, 63, 7.00000, 1, '2020-04-03 00:16:59.759825', 3500, NULL);
INSERT INTO public.venta_detalle VALUES (89, 86, 63, 11.00000, 1, '2020-04-03 20:00:41.273078', 5500, NULL);
INSERT INTO public.venta_detalle VALUES (90, 87, 67, 1.00000, 1, '2020-04-03 20:02:41.073326', 3000, NULL);
INSERT INTO public.venta_detalle VALUES (91, 88, 1, 9.48000, 1, '2020-04-03 20:19:00.006187', 12323, NULL);
INSERT INTO public.venta_detalle VALUES (92, 89, 57, 94.71000, 1, '2020-04-03 20:21:05.357716', 123123, NULL);
INSERT INTO public.venta_detalle VALUES (93, 89, 37, 1.00000, 1, '2020-04-03 20:21:05.360189', 5000, NULL);
INSERT INTO public.venta_detalle VALUES (94, 89, 67, 41.00000, 1, '2020-04-03 21:15:07.76675', 123000, NULL);
INSERT INTO public.venta_detalle VALUES (95, 89, 14, 100.00000, 1, '2020-04-03 21:15:07.775677', 125000, 1);
INSERT INTO public.venta_detalle VALUES (96, 89, 67, 41.00000, 1, '2020-04-03 21:15:22.754878', 123000, NULL);
INSERT INTO public.venta_detalle VALUES (97, 89, 14, 100.00000, 1, '2020-04-03 21:15:22.762083', 125000, 1);
INSERT INTO public.venta_detalle VALUES (98, 88, 67, 7.00000, 1, '2020-04-03 21:16:31.778883', 21000, NULL);
INSERT INTO public.venta_detalle VALUES (99, 88, 67, 7.00000, 1, '2020-04-03 21:16:42.269388', 21000, NULL);
INSERT INTO public.venta_detalle VALUES (100, 90, 60, 0.00000, 1, '2020-04-03 21:24:36.067832', 3123, NULL);
INSERT INTO public.venta_detalle VALUES (101, 91, 14, 1.00000, 1, '2020-04-04 00:23:27.269743', 1300, NULL);
INSERT INTO public.venta_detalle VALUES (102, 92, 11, 13.00000, 1, '2020-04-04 00:32:53.416552', 6500, NULL);
INSERT INTO public.venta_detalle VALUES (103, 93, 14, 1.00000, 1, '2020-04-04 00:35:27.851236', 1300, NULL);
INSERT INTO public.venta_detalle VALUES (104, 94, 66, 1.00000, 1, '2020-04-04 00:38:48.541025', 1200, NULL);
INSERT INTO public.venta_detalle VALUES (105, 95, 60, 3.58000, 1, '2020-04-04 00:39:53.420974', 2347, NULL);
INSERT INTO public.venta_detalle VALUES (106, 96, 60, 0.01000, 1, '2020-04-04 00:40:52.429118', 5, NULL);
INSERT INTO public.venta_detalle VALUES (107, 97, 66, 1.00000, 1, '2020-04-04 00:42:25.741947', 1200, NULL);
INSERT INTO public.venta_detalle VALUES (108, 98, 66, 1.00000, 1, '2020-04-04 00:43:01.524328', 1200, NULL);
INSERT INTO public.venta_detalle VALUES (110, 100, 66, 1.00000, 3, '2020-04-04 03:48:26.47143', 1200, NULL);
INSERT INTO public.venta_detalle VALUES (111, 101, 1, 0.16000, 3, '2020-04-04 03:48:37.742465', 213, NULL);
INSERT INTO public.venta_detalle VALUES (112, 102, 21, 0.01000, 3, '2020-04-04 03:48:46.810411', 1231, NULL);
INSERT INTO public.venta_detalle VALUES (113, 103, 1, 9470.77000, 2, '2020-04-04 03:49:47.886034', 12312, NULL);
INSERT INTO public.venta_detalle VALUES (114, 104, 66, 1.00000, 2, '2020-04-04 03:50:04.356332', 1200, NULL);
INSERT INTO public.venta_detalle VALUES (115, 109, 60, 0.01000, 1, '2020-04-04 19:22:16.702127', 3424, NULL);
INSERT INTO public.venta_detalle VALUES (116, 110, 57, 2.64000, 1, '2020-04-04 20:57:21.807158', 3434, NULL);
INSERT INTO public.venta_detalle VALUES (117, 111, 64, 1.00000, 1, '2020-04-04 20:57:31.783669', 2000, NULL);
INSERT INTO public.venta_detalle VALUES (118, 112, 62, 1.00000, 1, '2020-04-04 20:58:01.514983', 600, NULL);
INSERT INTO public.venta_detalle VALUES (119, 113, 62, 1.00000, 1, '2020-04-04 20:59:12.650484', 600, NULL);
INSERT INTO public.venta_detalle VALUES (120, 114, 66, 1.00000, 3, '2020-04-04 21:54:10.49258', 1200, NULL);
INSERT INTO public.venta_detalle VALUES (121, 115, 63, 1.00000, 3, '2020-04-04 21:54:56.594645', 500, NULL);
INSERT INTO public.venta_detalle VALUES (122, 116, 50, 0.82000, 3, '2020-04-04 22:21:21.582748', 534543, NULL);
INSERT INTO public.venta_detalle VALUES (123, 117, 62, 1.00000, 3, '2020-04-04 22:22:20.120254', 600, NULL);
INSERT INTO public.venta_detalle VALUES (124, 118, 63, 1.00000, 3, '2020-04-04 22:38:06.110466', 500, NULL);
INSERT INTO public.venta_detalle VALUES (125, 119, 63, 1.00000, 3, '2020-04-04 22:41:14.937081', 500, NULL);
INSERT INTO public.venta_detalle VALUES (126, 119, 62, 1.00000, 3, '2020-04-04 22:41:14.939473', 600, NULL);
INSERT INTO public.venta_detalle VALUES (127, 119, 64, 1.00000, 3, '2020-04-04 22:41:14.940018', 2000, NULL);
INSERT INTO public.venta_detalle VALUES (128, 120, 63, 1.00000, 3, '2020-04-04 23:11:17.652296', 500, NULL);
INSERT INTO public.venta_detalle VALUES (129, 119, 64, 1.00000, 2, '2020-04-04 23:31:19.895139', 2000, NULL);
INSERT INTO public.venta_detalle VALUES (130, 121, 60, 0.33000, 1, '2020-04-05 17:12:56.023418', 213123, NULL);
INSERT INTO public.venta_detalle VALUES (133, 123, 60, 0.07000, 1, '2020-04-06 00:46:50.193133', 45345, NULL);
INSERT INTO public.venta_detalle VALUES (136, 126, 60, 0.00000, 1, '2020-04-06 00:53:33.938112', 324, NULL);
INSERT INTO public.venta_detalle VALUES (137, 127, 66, 1.00000, 1, '2020-04-06 00:55:19.891016', 1200, NULL);
INSERT INTO public.venta_detalle VALUES (138, 128, 60, 0.07000, 1, '2020-04-06 00:55:29.954411', 45353, NULL);
INSERT INTO public.venta_detalle VALUES (139, 129, 66, 1.00000, 1, '2020-04-06 18:52:00.354501', 1200, NULL);
INSERT INTO public.venta_detalle VALUES (140, 130, 66, 1.00000, 1, '2020-04-06 18:52:38.87834', 1200, NULL);
INSERT INTO public.venta_detalle VALUES (141, 131, 60, 1.02000, 1, '2020-04-12 15:45:58.962559', 667, NULL);
INSERT INTO public.venta_detalle VALUES (142, 132, 11, 1.00000, 1, '2020-04-12 16:03:32.9697', 500, NULL);
INSERT INTO public.venta_detalle VALUES (143, 133, 66, 1.00000, 1, '2020-04-12 16:04:04.620978', 1200, NULL);
INSERT INTO public.venta_detalle VALUES (144, 134, 66, 1.00000, 1, '2020-04-12 16:04:14.577201', 1200, NULL);
INSERT INTO public.venta_detalle VALUES (145, 135, 66, 1.00000, 1, '2020-04-12 16:21:27.202563', 1200, NULL);
INSERT INTO public.venta_detalle VALUES (146, 136, 11, 1.00000, 1, '2020-04-14 17:43:46.057845', 500, NULL);
INSERT INTO public.venta_detalle VALUES (147, 137, 60, 0.01000, 1, '2020-04-16 16:48:00.13885', 4354, NULL);
INSERT INTO public.venta_detalle VALUES (148, 138, 60, 1.00000, 1, '2020-04-16 17:10:19.8594', 655655, NULL);


--
-- TOC entry 3095 (class 0 OID 32843)
-- Dependencies: 208
-- Data for Name: venta_temporal; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.venta_temporal VALUES (55, 3, 1, '2020-03-29 02:02:17.541426', true, '2020-03-29 02:03:38.876918', NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (54, 2, 1, '2020-03-29 01:20:41.244495', true, '2020-03-29 02:06:22.551495', NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (56, 4, 1, '2020-03-29 02:07:39.317134', true, '2020-03-29 02:08:42.608945', NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (58, 6, 1, '2020-03-29 02:12:32.605098', true, '2020-03-29 02:12:32.680314', NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (4, 4, 1, '2020-03-13 18:48:41.026814', true, '2020-03-13 18:54:22.692537', NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (8, 8, 1, '2020-03-13 18:55:30.505224', true, '2020-03-13 18:56:37.458019', NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (2, 2, 1, '2020-03-13 17:29:46.769', true, '2020-03-13 19:00:12.722052', NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (57, 2, 1, '2020-03-29 02:09:07.80402', true, '2020-03-29 03:54:27.361164', NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (59, 41, 1, '2020-03-29 03:55:19.806314', true, '2020-03-29 03:55:48.06146', NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (60, 42, 1, '2020-03-29 03:56:44.159613', true, '2020-03-29 03:56:44.237146', NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (32, 20, 1, '2020-03-23 14:29:00.730084', true, NULL, NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (39, 27, 1, '2020-03-25 14:13:12.448516', true, '2020-03-25 18:56:28.632792', NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (17, 5, 1, '2020-03-23 01:54:52.724831', true, NULL, NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (18, 6, 1, '2020-03-23 01:55:56.11796', true, NULL, NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (19, 7, 1, '2020-03-23 01:57:26.64604', true, NULL, NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (20, 8, 1, '2020-03-23 02:01:01.555928', true, NULL, NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (21, 9, 1, '2020-03-23 02:01:32.53608', true, NULL, NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (22, 10, 1, '2020-03-23 02:02:18.912826', true, NULL, NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (23, 11, 1, '2020-03-23 02:02:40.676747', true, NULL, NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (24, 12, 1, '2020-03-23 02:10:36.992531', true, NULL, NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (25, 13, 1, '2020-03-23 02:16:18.746061', true, NULL, NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (26, 14, 1, '2020-03-23 02:22:21.990587', true, NULL, NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (27, 15, 1, '2020-03-23 02:25:42.682938', true, NULL, NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (28, 16, 1, '2020-03-23 02:28:35.522509', true, NULL, NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (29, 17, 1, '2020-03-23 13:59:35.419792', true, NULL, NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (30, 18, 1, '2020-03-23 14:09:08.25751', true, NULL, NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (31, 19, 1, '2020-03-23 14:12:45.812095', true, NULL, NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (33, 21, 1, '2020-03-23 16:41:06.896132', true, NULL, NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (34, 22, 1, '2020-03-23 16:43:14.658611', true, NULL, NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (35, 23, 1, '2020-03-23 16:53:16.530069', true, NULL, NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (36, 24, 1, '2020-03-24 03:05:52.468991', true, NULL, NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (37, 25, 1, '2020-03-24 19:04:44.138074', true, NULL, NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (38, 26, 1, '2020-03-25 00:29:20.454126', true, NULL, NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (40, 28, 1, '2020-03-25 15:06:19.300094', true, NULL, NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (41, 29, 1, '2020-03-25 16:57:09.460765', true, NULL, NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (42, 30, 1, '2020-03-25 17:02:24.612008', true, NULL, NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (43, 31, 1, '2020-03-25 17:45:10.665644', true, NULL, NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (44, 32, 1, '2020-03-25 19:05:48.281473', true, '2020-03-25 19:06:37.04599', NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (45, 33, 1, '2020-03-25 19:08:58.552163', true, NULL, NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (47, 35, 1, '2020-03-25 19:54:02.314955', true, '2020-03-25 19:55:21.194439', NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (48, 36, 1, '2020-03-25 20:29:57.091948', true, '2020-03-25 20:30:50.490728', NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (46, 34, 1, '2020-03-25 19:13:43.08251', true, '2020-03-25 20:33:16.8279', NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (61, 43, 1, '2020-03-29 03:59:36.251959', true, '2020-03-29 03:59:36.332295', NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (49, 37, 1, '2020-03-25 22:22:25.818561', true, NULL, NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (50, 38, 1, '2020-03-25 22:42:03.904012', true, NULL, NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (51, 39, 1, '2020-03-25 22:43:30.760267', true, NULL, NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (52, 40, 1, '2020-03-26 15:47:49.019492', true, NULL, NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (62, 44, 1, '2020-03-29 04:03:22.051727', true, '2020-03-29 04:03:22.138894', NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (65, 47, 1, '2020-03-29 05:01:19.359251', true, '2020-03-29 05:01:19.426031', NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (66, 48, 1, '2020-03-29 05:03:08.948893', true, '2020-03-29 05:03:09.017038', NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (67, 49, 1, '2020-03-29 05:08:37.112716', true, '2020-03-29 05:08:37.174353', NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (68, 50, 1, '2020-03-29 05:11:14.991715', true, '2020-03-29 05:11:15.062509', NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (69, 51, 1, '2020-03-29 05:13:54.906312', true, '2020-03-29 05:13:54.981276', NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (70, 52, 1, '2020-03-29 05:22:21.808308', true, '2020-03-29 05:22:21.882521', NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (71, 53, 1, '2020-03-29 05:23:58.35661', true, '2020-03-29 05:23:58.420605', NULL, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (89, 12, 1, '2020-04-03 20:21:05.348855', true, '2020-04-03 21:15:07.832349', false, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (88, 11, 1, '2020-04-03 20:18:59.997336', true, '2020-04-03 21:16:31.844887', false, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (87, 10, 1, '2020-04-03 20:02:41.065909', true, '2020-04-03 21:19:44.681962', false, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (112, 1, 1, '2020-04-04 20:58:01.511325', true, '2020-04-04 21:03:06.822158', false, 'B', NULL);
INSERT INTO public.venta_temporal VALUES (86, 9, 1, '2020-04-03 20:00:41.266437', true, '2020-04-03 21:23:10.838343', false, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (90, 13, 1, '2020-04-03 21:24:36.064056', true, '2020-04-03 21:25:03.014697', false, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (91, 14, 1, '2020-04-04 00:23:27.261983', true, '2020-04-04 00:23:27.327977', false, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (92, 15, 1, '2020-04-04 00:32:53.410341', true, '2020-04-04 00:32:53.47979', false, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (93, 16, 1, '2020-04-04 00:35:27.845291', true, '2020-04-04 00:35:27.903113', false, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (94, 17, 1, '2020-04-04 00:38:48.535195', true, '2020-04-04 00:38:48.602753', false, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (73, -99, 1, '2020-03-29 13:24:39.751925', NULL, NULL, true, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (74, 56, 1, '2020-03-31 19:20:17.405124', true, '2020-03-31 19:20:17.484838', false, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (75, 57, 1, '2020-03-31 19:20:54.529183', true, '2020-03-31 19:20:54.589269', false, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (76, 1, 1, '2020-04-02 15:57:52.40651', true, '2020-04-02 15:59:30.157679', false, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (77, 2, 1, '2020-04-02 15:58:12.7449', true, '2020-04-02 16:00:31.981452', false, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (78, 1, 1, '2020-04-02 16:49:52.006599', true, '2020-04-02 16:49:52.07075', false, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (80, 3, 1, '2020-04-02 18:23:15.786936', true, '2020-04-02 18:23:47.924887', false, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (81, 4, 1, '2020-04-02 18:26:20.087637', NULL, NULL, false, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (79, 2, 1, '2020-04-02 18:22:37.920815', NULL, NULL, true, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (82, 5, 1, '2020-04-02 19:53:53.604234', NULL, NULL, false, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (83, 6, 1, '2020-04-03 00:09:50.732573', true, '2020-04-03 00:09:50.815976', false, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (84, 7, 1, '2020-04-03 00:16:59.747803', true, '2020-04-03 00:16:59.829861', false, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (85, 8, 1, '2020-04-03 18:03:57.739422', NULL, NULL, true, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (95, 18, 1, '2020-04-04 00:39:53.417161', true, '2020-04-04 00:39:53.472592', false, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (96, 19, 1, '2020-04-04 00:40:52.422732', true, '2020-04-04 00:40:52.487923', false, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (97, 20, 1, '2020-04-04 00:42:25.736206', true, '2020-04-04 00:42:25.794907', false, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (98, 21, 1, '2020-04-04 00:43:01.519863', true, '2020-04-04 00:43:01.586756', false, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (99, 22, 1, '2020-04-04 00:43:59.11981', true, '2020-04-04 00:43:59.188428', false, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (100, 23, 3, '2020-04-04 03:48:26.461682', true, '2020-04-04 03:49:09.55525', false, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (101, 24, 3, '2020-04-04 03:48:37.733465', true, '2020-04-04 03:49:15.632939', false, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (102, 25, 3, '2020-04-04 03:48:46.804081', true, '2020-04-04 03:49:21.741121', false, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (103, 26, 2, '2020-04-04 03:49:47.877071', true, '2020-04-04 03:49:47.959031', false, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (110, 98, 1, '2020-04-04 20:57:21.801204', true, '2020-04-04 21:03:12.572405', false, 'A', NULL);
INSERT INTO public.venta_temporal VALUES (114, 3, 3, '2020-04-04 21:54:10.487171', true, '2020-04-04 21:55:37.867775', false, 'B', NULL);
INSERT INTO public.venta_temporal VALUES (104, 99, 2, '2020-04-04 03:50:04.350098', true, '2020-04-04 03:50:04.420946', false, 'D', NULL);
INSERT INTO public.venta_temporal VALUES (109, 36, 1, '2020-04-04 19:22:16.694104', true, '2020-04-04 19:35:06.13018', false, 'A', NULL);
INSERT INTO public.venta_temporal VALUES (113, 2, 1, '2020-04-04 20:59:12.64516', true, '2020-04-04 21:00:30.799435', false, 'B', NULL);
INSERT INTO public.venta_temporal VALUES (111, 99, 1, '2020-04-04 20:57:31.778495', true, '2020-04-04 21:03:00.224167', false, 'A', NULL);
INSERT INTO public.venta_temporal VALUES (115, 4, 3, '2020-04-04 21:54:56.589239', true, '2020-04-04 21:55:47.664854', false, 'B', NULL);
INSERT INTO public.venta_temporal VALUES (116, 5, 3, '2020-04-04 22:21:21.57917', true, '2020-04-04 22:21:39.757164', false, 'B', NULL);
INSERT INTO public.venta_temporal VALUES (120, 9, 3, '2020-04-04 23:11:17.641095', NULL, NULL, false, 'B', NULL);
INSERT INTO public.venta_temporal VALUES (117, 6, 3, '2020-04-04 22:22:20.114085', true, '2020-04-04 23:22:14.119287', false, 'B', NULL);
INSERT INTO public.venta_temporal VALUES (118, 7, 3, '2020-04-04 22:38:06.099068', NULL, NULL, true, 'B', NULL);
INSERT INTO public.venta_temporal VALUES (119, 8, 3, '2020-04-04 22:41:14.928569', true, '2020-04-04 23:31:19.947884', false, 'B', NULL);
INSERT INTO public.venta_temporal VALUES (121, 10, 1, '2020-04-05 17:12:56.000821', NULL, NULL, false, 'B', NULL);
INSERT INTO public.venta_temporal VALUES (123, 12, 1, '2020-04-06 00:46:50.187057', true, '2020-04-06 00:47:17.7064', false, 'B', 40);
INSERT INTO public.venta_temporal VALUES (126, 98, 1, '2020-04-06 00:53:33.932088', true, '2020-04-06 01:27:40.717791', false, 'A', 40);
INSERT INTO public.venta_temporal VALUES (127, 99, 1, '2020-04-06 00:55:19.887296', NULL, NULL, true, 'A', 40);
INSERT INTO public.venta_temporal VALUES (128, 1, 1, '2020-04-06 00:55:29.948412', NULL, NULL, true, 'B', 40);
INSERT INTO public.venta_temporal VALUES (129, 2, 1, '2020-04-06 18:52:00.340605', NULL, NULL, true, 'B', 40);
INSERT INTO public.venta_temporal VALUES (130, 3, 1, '2020-04-06 18:52:38.872745', NULL, NULL, true, 'B', 40);
INSERT INTO public.venta_temporal VALUES (131, 4, 1, '2020-04-12 15:45:58.942966', true, '2020-04-12 15:45:59.016079', false, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (132, 5, 1, '2020-04-12 16:03:32.960689', true, '2020-04-12 16:03:33.024543', false, NULL, NULL);
INSERT INTO public.venta_temporal VALUES (135, 8, 1, '2020-04-12 16:21:27.19321', true, '2020-04-12 16:21:27.286781', false, 'A', 41);
INSERT INTO public.venta_temporal VALUES (133, 6, 1, '2020-04-12 16:04:04.616218', NULL, NULL, true, 'A', 41);
INSERT INTO public.venta_temporal VALUES (134, 7, 1, '2020-04-12 16:04:14.573248', NULL, NULL, true, 'A', 41);
INSERT INTO public.venta_temporal VALUES (136, 9, 1, '2020-04-14 17:43:46.052751', true, '2020-04-14 17:43:46.256532', false, 'A', 44);
INSERT INTO public.venta_temporal VALUES (137, 10, 1, '2020-04-16 16:48:00.129367', NULL, NULL, true, 'A', 44);
INSERT INTO public.venta_temporal VALUES (138, 11, 1, '2020-04-16 17:10:19.849161', NULL, NULL, true, 'A', 44);


--
-- TOC entry 3132 (class 0 OID 0)
-- Dependencies: 204
-- Name: caja_apertura_id_apertura_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.caja_apertura_id_apertura_seq', 44, true);


--
-- TOC entry 3133 (class 0 OID 0)
-- Dependencies: 227
-- Name: caja_cierre_id_cierre_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.caja_cierre_id_cierre_seq', 20, true);


--
-- TOC entry 3134 (class 0 OID 0)
-- Dependencies: 216
-- Name: dinero_custodia_id_dinero_custodia_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dinero_custodia_id_dinero_custodia_seq', 19, true);


--
-- TOC entry 3135 (class 0 OID 0)
-- Dependencies: 218
-- Name: dinero_custodia_movimientos_id_movimiento_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dinero_custodia_movimientos_id_movimiento_seq', 62, true);


--
-- TOC entry 3136 (class 0 OID 0)
-- Dependencies: 222
-- Name: gastos_caja_id_gasto_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.gastos_caja_id_gasto_seq', 56, true);


--
-- TOC entry 3137 (class 0 OID 0)
-- Dependencies: 196
-- Name: producto_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.producto_id_seq', 67, true);


--
-- TOC entry 3138 (class 0 OID 0)
-- Dependencies: 213
-- Name: promociones_id_promocion_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.promociones_id_promocion_seq', 1, true);


--
-- TOC entry 3139 (class 0 OID 0)
-- Dependencies: 220
-- Name: tipo_gasto_id_tipo_gasto_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tipo_gasto_id_tipo_gasto_seq', 3, true);


--
-- TOC entry 3140 (class 0 OID 0)
-- Dependencies: 202
-- Name: tipo_pago_id_tipo_pago_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tipo_pago_id_tipo_pago_seq', 4, true);


--
-- TOC entry 3141 (class 0 OID 0)
-- Dependencies: 200
-- Name: usuario_Cod_usuario_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."usuario_Cod_usuario_seq"', 29, true);


--
-- TOC entry 3142 (class 0 OID 0)
-- Dependencies: 211
-- Name: venta_detalle_id_detalle_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.venta_detalle_id_detalle_seq', 148, true);


--
-- TOC entry 3143 (class 0 OID 0)
-- Dependencies: 209
-- Name: venta_id_venta_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.venta_id_venta_seq', 57, true);


--
-- TOC entry 3144 (class 0 OID 0)
-- Dependencies: 207
-- Name: venta_temporal_id_diario_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.venta_temporal_id_diario_seq', 11, true);


--
-- TOC entry 3145 (class 0 OID 0)
-- Dependencies: 206
-- Name: venta_temporal_id_venta_temp_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.venta_temporal_id_venta_temp_seq', 138, true);


--
-- TOC entry 2901 (class 2606 OID 32825)
-- Name: caja_apertura caja_apertura_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.caja_apertura
    ADD CONSTRAINT caja_apertura_pk PRIMARY KEY (id_apertura);


--
-- TOC entry 2919 (class 2606 OID 33249)
-- Name: caja_cierre caja_cierre_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.caja_cierre
    ADD CONSTRAINT caja_cierre_pk PRIMARY KEY (id_cierre);


--
-- TOC entry 2891 (class 2606 OID 24598)
-- Name: categoria categoria_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categoria
    ADD CONSTRAINT categoria_pkey PRIMARY KEY (idcategoria);


--
-- TOC entry 2913 (class 2606 OID 33093)
-- Name: dinero_custodia_movimientos dinero_custodia_movi_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dinero_custodia_movimientos
    ADD CONSTRAINT dinero_custodia_movi_pk PRIMARY KEY (id_movimiento);


--
-- TOC entry 2911 (class 2606 OID 33072)
-- Name: dinero_custodia dinero_custodia_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dinero_custodia
    ADD CONSTRAINT dinero_custodia_pk PRIMARY KEY (id_dinero_custodia);


--
-- TOC entry 2917 (class 2606 OID 33163)
-- Name: gastos_caja gastos_caja_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gastos_caja
    ADD CONSTRAINT gastos_caja_pk PRIMARY KEY (id_gasto);


--
-- TOC entry 2921 (class 2606 OID 33292)
-- Name: perfiles_usuario perfiles_usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.perfiles_usuario
    ADD CONSTRAINT perfiles_usuario_pkey PRIMARY KEY (tipo_usuario);


--
-- TOC entry 2887 (class 2606 OID 32779)
-- Name: producto producto_codigodebarras_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.producto
    ADD CONSTRAINT producto_codigodebarras_key UNIQUE (codigodebarras);


--
-- TOC entry 2889 (class 2606 OID 24593)
-- Name: producto producto_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.producto
    ADD CONSTRAINT producto_pkey PRIMARY KEY (idproducto);


--
-- TOC entry 2909 (class 2606 OID 32975)
-- Name: promociones promociones_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promociones
    ADD CONSTRAINT promociones_pk PRIMARY KEY (id_promocion);


--
-- TOC entry 2915 (class 2606 OID 33150)
-- Name: tipo_gasto tipo_gasto_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tipo_gasto
    ADD CONSTRAINT tipo_gasto_pk PRIMARY KEY (id_tipo_gasto);


--
-- TOC entry 2899 (class 2606 OID 32817)
-- Name: tipo_pago tipo_pago_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tipo_pago
    ADD CONSTRAINT tipo_pago_pk PRIMARY KEY (id_tipo_pago);


--
-- TOC entry 2893 (class 2606 OID 32786)
-- Name: unidad unidad_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.unidad
    ADD CONSTRAINT unidad_pkey PRIMARY KEY (idunidad);


--
-- TOC entry 2895 (class 2606 OID 32804)
-- Name: usuario usuario_User_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT "usuario_User_key" UNIQUE (usuario);


--
-- TOC entry 2897 (class 2606 OID 32802)
-- Name: usuario usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id_usuario);


--
-- TOC entry 2907 (class 2606 OID 32944)
-- Name: venta_detalle venta_detalle_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.venta_detalle
    ADD CONSTRAINT venta_detalle_pk PRIMARY KEY (id_detalle);


--
-- TOC entry 2905 (class 2606 OID 32911)
-- Name: venta venta_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.venta
    ADD CONSTRAINT venta_pk PRIMARY KEY (id_venta);


--
-- TOC entry 2903 (class 2606 OID 32849)
-- Name: venta_temporal venta_temporal_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.venta_temporal
    ADD CONSTRAINT venta_temporal_pk PRIMARY KEY (id_venta_temp);


--
-- TOC entry 3075 (class 2618 OID 33348)
-- Name: vw_ventas_temporales_anuladas _RETURN; Type: RULE; Schema: public; Owner: postgres
--

CREATE OR REPLACE VIEW public.vw_ventas_temporales_anuladas AS
 SELECT venta_temporal.id_venta_temp,
    (((venta_temporal.letra_id_diario)::text || '-'::text) || venta_temporal.id_diario) AS id_diario,
    venta_temporal.id_usuario,
    usuario.nombre AS nombre_usuario,
    to_char(venta_temporal.time_creado, 'HH24:MI:SS'::text) AS time_creado,
    venta_temporal.anulado,
    sum(venta_detalle.monto) AS total
   FROM ((public.venta_temporal
     JOIN public.usuario ON ((venta_temporal.id_usuario = usuario.id_usuario)))
     JOIN public.venta_detalle ON ((venta_temporal.id_venta_temp = venta_detalle.id_venta_temp)))
  WHERE ((venta_temporal.pagado IS NOT TRUE) AND (venta_temporal.time_creado >= CURRENT_DATE) AND (venta_temporal.time_creado < (CURRENT_DATE + 1)))
  GROUP BY venta_temporal.id_venta_temp, usuario.nombre
  ORDER BY venta_temporal.id_venta_temp;


--
-- TOC entry 3081 (class 2618 OID 33434)
-- Name: vw_ventas_temporales_anuladas2 _RETURN; Type: RULE; Schema: public; Owner: postgres
--

CREATE OR REPLACE VIEW public.vw_ventas_temporales_anuladas2 AS
 SELECT venta_temporal.id_venta_temp,
    (((venta_temporal.letra_id_diario)::text || '-'::text) || venta_temporal.id_diario) AS id_diario,
    venta_temporal.id_usuario,
    usuario.nombre AS nombre_usuario,
    to_char(venta_temporal.time_creado, 'HH24:MI:SS'::text) AS time_creado,
    venta_temporal.anulado,
    sum(venta_detalle.monto) AS total,
    venta_temporal.id_apertura,
    to_char(venta_temporal.time_creado, 'DD-MM-YYYY'::text) AS fecha
   FROM ((public.venta_temporal
     JOIN public.usuario ON ((venta_temporal.id_usuario = usuario.id_usuario)))
     JOIN public.venta_detalle ON ((venta_temporal.id_venta_temp = venta_detalle.id_venta_temp)))
  WHERE (venta_temporal.pagado IS NOT TRUE)
  GROUP BY venta_temporal.id_venta_temp, usuario.nombre
  ORDER BY venta_temporal.id_venta_temp;


--
-- TOC entry 2945 (class 2606 OID 33250)
-- Name: caja_cierre caja_apert_caja_cierr_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.caja_cierre
    ADD CONSTRAINT caja_apert_caja_cierr_fk FOREIGN KEY (id_apertura) REFERENCES public.caja_apertura(id_apertura);


--
-- TOC entry 2941 (class 2606 OID 33169)
-- Name: gastos_caja caja_apert_gastos_caj_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gastos_caja
    ADD CONSTRAINT caja_apert_gastos_caj_fk FOREIGN KEY (id_apertura) REFERENCES public.caja_apertura(id_apertura);


--
-- TOC entry 2929 (class 2606 OID 32927)
-- Name: venta caja_apertura_venta_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.venta
    ADD CONSTRAINT caja_apertura_venta_fk FOREIGN KEY (id_apertura) REFERENCES public.caja_apertura(id_apertura);


--
-- TOC entry 2922 (class 2606 OID 32805)
-- Name: producto categoria_producto_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.producto
    ADD CONSTRAINT categoria_producto_fk FOREIGN KEY (idcategoria) REFERENCES public.categoria(idcategoria);


--
-- TOC entry 2937 (class 2606 OID 33094)
-- Name: dinero_custodia_movimientos dinero_cus_dinero_cus_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dinero_custodia_movimientos
    ADD CONSTRAINT dinero_cus_dinero_cus_fk FOREIGN KEY (id_dinero_custodia) REFERENCES public.dinero_custodia(id_dinero_custodia);


--
-- TOC entry 2942 (class 2606 OID 33174)
-- Name: gastos_caja dinero_cus_gastos_caj_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gastos_caja
    ADD CONSTRAINT dinero_cus_gastos_caj_fk FOREIGN KEY (id_dinero_custodia) REFERENCES public.dinero_custodia(id_dinero_custodia);


--
-- TOC entry 2934 (class 2606 OID 32976)
-- Name: promociones producto_promociones_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promociones
    ADD CONSTRAINT producto_promociones_fk FOREIGN KEY (idproducto) REFERENCES public.producto(idproducto);


--
-- TOC entry 2931 (class 2606 OID 32950)
-- Name: venta_detalle producto_venta_detalle_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.venta_detalle
    ADD CONSTRAINT producto_venta_detalle_fk FOREIGN KEY (idproducto) REFERENCES public.producto(idproducto);


--
-- TOC entry 2933 (class 2606 OID 32984)
-- Name: venta_detalle promocion_venta_detalle_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.venta_detalle
    ADD CONSTRAINT promocion_venta_detalle_fk FOREIGN KEY (id_promocion) REFERENCES public.promociones(id_promocion);


--
-- TOC entry 2944 (class 2606 OID 33184)
-- Name: gastos_caja tipo_gasto_gastos_caja_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gastos_caja
    ADD CONSTRAINT tipo_gasto_gastos_caja_fk FOREIGN KEY (id_tipo_gasto) REFERENCES public.tipo_gasto(id_tipo_gasto);


--
-- TOC entry 2927 (class 2606 OID 32917)
-- Name: venta tipo_pago_venta_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.venta
    ADD CONSTRAINT tipo_pago_venta_fk FOREIGN KEY (id_tipo_pago) REFERENCES public.tipo_pago(id_tipo_pago);


--
-- TOC entry 2924 (class 2606 OID 32826)
-- Name: caja_apertura usuario_caja_apertura_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.caja_apertura
    ADD CONSTRAINT usuario_caja_apertura_fk FOREIGN KEY (id_usuario) REFERENCES public.usuario(id_usuario);


--
-- TOC entry 2946 (class 2606 OID 33255)
-- Name: caja_cierre usuario_caja_cierre_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.caja_cierre
    ADD CONSTRAINT usuario_caja_cierre_fk FOREIGN KEY (id_usuario) REFERENCES public.usuario(id_usuario);


--
-- TOC entry 2938 (class 2606 OID 33099)
-- Name: dinero_custodia_movimientos usuario_di_cus_mov_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dinero_custodia_movimientos
    ADD CONSTRAINT usuario_di_cus_mov_fk FOREIGN KEY (id_usuario_i) REFERENCES public.usuario(id_usuario);


--
-- TOC entry 2939 (class 2606 OID 33104)
-- Name: dinero_custodia_movimientos usuario_di_cus_mov_fk_1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dinero_custodia_movimientos
    ADD CONSTRAINT usuario_di_cus_mov_fk_1 FOREIGN KEY (id_usuario_d) REFERENCES public.usuario(id_usuario);


--
-- TOC entry 2935 (class 2606 OID 33073)
-- Name: dinero_custodia usuario_dinero_custodia_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dinero_custodia
    ADD CONSTRAINT usuario_dinero_custodia_fk FOREIGN KEY (id_usuario_i) REFERENCES public.usuario(id_usuario);


--
-- TOC entry 2936 (class 2606 OID 33078)
-- Name: dinero_custodia usuario_dinero_custodia_fk_1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dinero_custodia
    ADD CONSTRAINT usuario_dinero_custodia_fk_1 FOREIGN KEY (id_usuario_d) REFERENCES public.usuario(id_usuario);


--
-- TOC entry 2940 (class 2606 OID 33164)
-- Name: gastos_caja usuario_gastos_caja_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gastos_caja
    ADD CONSTRAINT usuario_gastos_caja_fk FOREIGN KEY (id_usuario_i) REFERENCES public.usuario(id_usuario);


--
-- TOC entry 2943 (class 2606 OID 33179)
-- Name: gastos_caja usuario_gastos_caja_fk_1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gastos_caja
    ADD CONSTRAINT usuario_gastos_caja_fk_1 FOREIGN KEY (id_usuario_d) REFERENCES public.usuario(id_usuario);


--
-- TOC entry 2923 (class 2606 OID 33293)
-- Name: usuario usuario_perfil_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_perfil_fk FOREIGN KEY (tipo_usuario) REFERENCES public.perfiles_usuario(tipo_usuario);


--
-- TOC entry 2930 (class 2606 OID 32945)
-- Name: venta_detalle usuario_venta_detalle_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.venta_detalle
    ADD CONSTRAINT usuario_venta_detalle_fk FOREIGN KEY (id_usuario) REFERENCES public.usuario(id_usuario);


--
-- TOC entry 2926 (class 2606 OID 32912)
-- Name: venta usuario_venta_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.venta
    ADD CONSTRAINT usuario_venta_fk FOREIGN KEY (id_usuario) REFERENCES public.usuario(id_usuario);


--
-- TOC entry 2925 (class 2606 OID 32850)
-- Name: venta_temporal usuario_venta_temporal_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.venta_temporal
    ADD CONSTRAINT usuario_venta_temporal_fk FOREIGN KEY (id_usuario) REFERENCES public.usuario(id_usuario);


--
-- TOC entry 2932 (class 2606 OID 32955)
-- Name: venta_detalle venta_temp_venta_deta_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.venta_detalle
    ADD CONSTRAINT venta_temp_venta_deta_fk FOREIGN KEY (id_venta_temp) REFERENCES public.venta_temporal(id_venta_temp);


--
-- TOC entry 2928 (class 2606 OID 32922)
-- Name: venta venta_temporal_venta_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.venta
    ADD CONSTRAINT venta_temporal_venta_fk FOREIGN KEY (id_venta_temp) REFERENCES public.venta_temporal(id_venta_temp);


-- Completed on 2020-04-16 19:11:00

--
-- PostgreSQL database dump complete
--

