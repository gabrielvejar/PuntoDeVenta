--
-- PostgreSQL database dump
--

-- Dumped from database version 11.5
-- Dumped by pg_dump version 11.1

-- Started on 2020-04-30 04:01:56

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
-- TOC entry 3088 (class 0 OID 0)
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
-- TOC entry 3089 (class 0 OID 0)
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
-- TOC entry 3090 (class 0 OID 0)
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
-- TOC entry 3091 (class 0 OID 0)
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
-- TOC entry 3092 (class 0 OID 0)
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
    idcategoria smallint DEFAULT 99,
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
-- TOC entry 3093 (class 0 OID 0)
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
-- TOC entry 3094 (class 0 OID 0)
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
-- TOC entry 3095 (class 0 OID 0)
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
-- TOC entry 3096 (class 0 OID 0)
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
-- TOC entry 3097 (class 0 OID 0)
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
-- TOC entry 3098 (class 0 OID 0)
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
-- TOC entry 3099 (class 0 OID 0)
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
-- TOC entry 3100 (class 0 OID 0)
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
-- TOC entry 3101 (class 0 OID 0)
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


-- Completed on 2020-04-30 04:01:57

--
-- PostgreSQL database dump complete
--

