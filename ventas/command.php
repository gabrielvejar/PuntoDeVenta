<?php
session_start();

if(!isset($_SESSION['usuario'])) {
    die();
} else {
    $usuario = $_SESSION['usuario'];
}

$ruta = "";
while (!(file_exists ($ruta . "index.php"))) {
    $ruta = "../" . $ruta;
}
require $ruta . "db/conexion.php";

if (!isset($_REQUEST['cmd'])) {
    die();
}


$cmd=$_REQUEST['cmd'];


switch ($cmd) {
    case 'ultimo-cierre':

        $query     = "SELECT 
                                cc.id_cierre,
                                cc.id_apertura,
                                cc.efectivo_cierre,
                                cc.id_usuario,
                                cc.time_cierre,
                                to_char(ca.fecha, 'DD-MM-YYYY') fecha
                            FROM 
                                public.caja_cierre cc
                            INNER JOIN public.caja_apertura ca
                            ON cc.id_apertura = ca.id_apertura
                                ORDER BY id_cierre DESC LIMIT 1";
        $params    = array();
        $result    = pg_query_params($dbconn, $query, $params);

        $filas = [];
        $i = 0;
        while($row = pg_fetch_assoc($result))
        {
            $filas[$i] = $row;
            $i++;
        }

        $json = json_encode($filas);
        echo $json;

    break;

    case 'verificar-caja-abierta':
        // verificar que no haya caja abierta
        $query     = "SELECT * FROM public.fn_verificar_caja_apertura()";
        $params    = array();
        $result    = pg_query_params($dbconn, $query, $params);

        $row = pg_fetch_row($result);

        echo $row['0'];

    break;

    case "apertura-caja":
        if (!isset($_REQUEST['fecha'])) {
            die();
        } else {
            if ($_REQUEST['fecha'] == '') {
                die();
            }
        }
        if (!isset($_REQUEST['efectivo'])) {
            die();
        } else {
            if ($_REQUEST['efectivo'] == '') {
                die();
            }
        }


        $fecha = $_REQUEST['fecha'];
        $efectivo = $_REQUEST['efectivo'];
        $id_usuario = $usuario['id_usuario'];

        // verificar que no haya caja abierta
        $query     = "SELECT * FROM public.fn_verificar_caja_apertura()";
        $params    = array();
        $result    = pg_query_params($dbconn, $query, $params);

        $row = pg_fetch_row($result);

        if($row['0'] == 0){

            // abrir caja
            $query     = "SELECT * FROM public.fn_caja_apertura_i($1, $2, $3)";
            $params    = array($fecha, $efectivo, $id_usuario);
            $result    = pg_query_params($dbconn, $query, $params);

            $row = pg_fetch_row($result);

            // $_SESSION['id_apertura'] = $row['0'];

            echo $row['0']; // si es 0 se hizo apertura de caja correctamente

        } else {
            echo '1'; //Ya se realizó una apertura de caja
        }

    break;

    case "cerrar-caja":
        // retornos
        // e0: faltan parametros
        // e1: no hay caja abierta
        // e2: error en db al ejecutar funcion

        $id_apertura = $_SESSION['apertura']['id_apertura'];
        $id_usuario = $usuario['id_usuario'];

        if (isset($_REQUEST['efectivo_apertura'])) {
            $efectivo_apertura = $_REQUEST['efectivo_apertura'];
        } else {
            echo "e0";
            die();
        }

        if (isset($_REQUEST['efectivo_cierre'])) {
            $efectivo_cierre = $_REQUEST['efectivo_cierre'];
        } else {
            echo "e0";
            die();
        }

        if (isset($_REQUEST['ventas_efectivo'])) {
            $ventas_efectivo = $_REQUEST['ventas_efectivo'];
        } else {
            echo "e0";
            die();
        }

        if (isset($_REQUEST['ventas_tarjetas'])) {
            $ventas_tarjetas = $_REQUEST['ventas_tarjetas'];
        } else {
            echo "e0";
            die();
        }

        if (isset($_REQUEST['entrega'])) {
            $entrega = $_REQUEST['entrega'];
        } else {
            echo "e0";
            die();
        }

        if (isset($_REQUEST['gastos'])) {
            $gastos = $_REQUEST['gastos'];
        } else {
            echo "e0";
            die();
        }



        // verificar que no haya caja abierta
        $query     = "SELECT * FROM public.fn_verificar_caja_apertura()";
        $params    = array();
        $result    = pg_query_params($dbconn, $query, $params);

        $row = pg_fetch_row($result);

        if($row['0'] == 0){

            echo 'e1'; //no hay caja abierta

            
        } else {
            // abrir caja
            $query     = "SELECT * FROM public.fn_caja_cierre_i($1, $2, $3, $4, $5, $6, $7, $8)";

            $params    = array(
                $id_apertura,  
                $efectivo_apertura, 
                $efectivo_cierre, 
                $ventas_efectivo, 
                $ventas_tarjetas, 
                $entrega, 
                $gastos, 
                $id_usuario);

            $result    = pg_query_params($dbconn, $query, $params);

            $row = pg_fetch_row($result);

            if ($row['0'] > 0) {
                echo $row['0']; // id de cierre de caja
            } else {
                echo "e2"; // error en db al ejecutar funcion
            }
            

        }

    break;

    case "detalle-producto":

            $codigo = $_REQUEST['codigo'] ;
        
            $query     = "SELECT p.idproducto, p.nombreproducto, p.precio, p.imagen, p.idcategoria, p.idunidad, u.nombreunidad, p.activo  prod_activo, pm.id_promocion,
            pm.cantidad, pm.tipo_descuento, pm.descuento, pm.activo promo_activo, pm.descripcion_promo
            FROM public.producto p
            LEFT JOIN public.promociones pm
            ON p.idproducto = pm.idproducto
            INNER JOIN public.unidad u
            ON p.idunidad = u.idunidad
            WHERE p.codigodebarras = $1 AND p.activo = 't'";
            $params    = array($codigo);

            $result    = pg_query_params($dbconn, $query, $params);

            $filas      = array();

            $i = 0;
            while($row = pg_fetch_array($result))
            {
                $filas[$i] = $row;
                $i++;
            }

            $json = json_encode($filas);
            echo $json;


        
    break;
    case 'ingresar-venta-temporal-meson':

        // codigo
        // nombre
        // precio
        // cantidad
        // monto
        // idproducto
        // unidad
        // idunidad
        // idpromocion

        $detalle = json_decode($_POST['detalle'], true);

        // echo $detalle[0]['codigo'];


        $query     = "SELECT * FROM public.fn_venta_temporal_i($1)";

        $params    = array($usuario['id_usuario']);

        $result    = pg_query_params($dbconn, $query, $params);

        $row = pg_fetch_row($result);

        $id_venta_temp = $row['0'];


        foreach ($detalle as $linea) {
            // echo $linea['codigo'];
            // __id_venta_temp 	ALIAS FOR $1;
            // __id_producto 		ALIAS FOR $2;
            // __cantidad 			ALIAS FOR $3;
            // __id_usuario 		ALIAS FOR $4;
            // __monto 			ALIAS FOR $5;
            // __id_promocion 		ALIAS FOR $6;
            $id_promocion = $linea['idpromocion'];
            if ($id_promocion == "") {
                $id_promocion = 0;
            }

            $query     = "SELECT * FROM public.fn_venta_detalle_i($1, $2, $3, $4, $5, $6)";

            $params    = array($id_venta_temp, $linea['idproducto'], $linea['cantidad'], $usuario['id_usuario'], $linea['monto'], $id_promocion);

            $result    = pg_query_params($dbconn, $query, $params);

        }


        $query     = "SELECT id_diario FROM public.venta_temporal WHERE id_venta_temp = $1";

        $params    = array($id_venta_temp);

        $result    = pg_query_params($dbconn, $query, $params);

        $row = pg_fetch_row($result);

        $id_diario = $row['0'];

        echo $id_diario;





    break;
    case 'ingresar-venta-temporal-caja':

        // codigo
        // nombre
        // precio
        // cantidad
        // monto
        // idproducto
        // unidad
        // idunidad
        // idpromocion

        $detalle = json_decode($_POST['detalle'], true);

        // echo $detalle[0]['codigo'];

        if ($_REQUEST['id_venta_temp'] == 0) {

            
            $query     = "SELECT * FROM public.fn_venta_temporal_i($1)";
            
            $params    = array($usuario['id_usuario']);
            
            $result    = pg_query_params($dbconn, $query, $params);
            
            $row = pg_fetch_row($result);
            
            $id_venta_temp = $row['0'];
            
        } else {
            $id_venta_temp = $_REQUEST['id_venta_temp'] ;
        }

        foreach ($detalle as $linea) {
            // echo $linea['codigo'];
            // __id_venta_temp 	ALIAS FOR $1;
            // __id_producto 		ALIAS FOR $2;
            // __cantidad 			ALIAS FOR $3;
            // __id_usuario 		ALIAS FOR $4;
            // __monto 			ALIAS FOR $5;
            // __id_promocion 		ALIAS FOR $6;
            $id_promocion = $linea['idpromocion'];
            if ($id_promocion == "") {
                $id_promocion = 0;
            }

            $query     = "SELECT * FROM public.fn_venta_detalle_i($1, $2, $3, $4, $5, $6)";

            $params    = array($id_venta_temp, $linea['idproducto'], $linea['cantidad'], $usuario['id_usuario'], $linea['monto'], $id_promocion);

            $result    = pg_query_params($dbconn, $query, $params);

        }

        echo $id_venta_temp;


    break;

    case 'eliminar-detalle-db':
        $id_detalle = $_REQUEST['id_detalle'];

        $query     = "SELECT * FROM public.fn_venta_detalle_d($1)";
        $params    = array($id_detalle);
        $result    = pg_query_params($dbconn, $query, $params);

    break;

    case 'buscar-venta-temporal':

        $id_venta_temp = $_REQUEST['id_venta_temp'] ;

        $query     = "SELECT * FROM public.vw_detalle_venta_temp WHERE id_venta_temp = $1 AND anulado IS NOT TRUE";
        $params    = array($id_venta_temp);
        $result    = pg_query_params($dbconn, $query, $params);

        $filas = [];
        $i = 0;
        while($row = pg_fetch_assoc($result))
        {
            $filas[$i] = $row;
            $i++;
        }

        $json = json_encode($filas);
        echo $json;
        
    break;

    case 'ventas-temp_impagas':

        $query     = "SELECT id_venta_temp, id_diario FROM public.vw_ventas_temporales_impagas WHERE anulado IS NOT TRUE";
        $params    = array();
        $result    = pg_query_params($dbconn, $query, $params);

        $filas = [];
        $i = 0;
        while($row = pg_fetch_assoc($result))
        {
            $filas[$i] = $row;
            $i++;
        }

        $json = json_encode($filas);
        echo $json;
    
    break;

    case 'ventas-temp_impagas_anuladas':
        //TODO implementar ventas impagas anuladas

        $query     = "SELECT id_venta_temp, id_diario FROM public.vw_ventas_temporales_impagas WHERE anulado IS TRUE";
        $params    = array();
        $result    = pg_query_params($dbconn, $query, $params);

        $filas = [];
        $i = 0;
        while($row = pg_fetch_assoc($result))
        {
            $filas[$i] = $row;
            $i++;
        }

        $json = json_encode($filas);
        echo $json;
    
    break;

    case 'anular-venta-temp':

        $id_venta_temp = $_REQUEST['id_venta_temp'];
        
        $query     = "SELECT * FROM public.fn_venta_temporal_d($1)";
        $params    = array($id_venta_temp);
        $result    = pg_query_params($dbconn, $query, $params);

        $row = pg_fetch_row($result);

        echo $row[0];

    break;
    case 'anular-venta-temp-logico':

        $id_venta_temp = $_REQUEST['id_venta_temp'];
        
        $query     = "SELECT * FROM public.fn_venta_temporal_anular($1)";
        $params    = array($id_venta_temp);
        $result    = pg_query_params($dbconn, $query, $params);

        $row = pg_fetch_row($result);

        echo $row[0];

    break;

    case 'pagar-venta':

        $id_venta_temp = $_REQUEST['id_venta_temp'];
        $id_apertura = $_SESSION['apertura']['id_apertura'];
        $monto_venta = $_REQUEST['monto_venta'];
        $id_tipo_pago = $_REQUEST['id_tipo_pago'];
        $id_usuario = $usuario['id_usuario'];

        
        $query     = "SELECT * FROM public.fn_venta_temporal_pagar($1)";
        $params    = array($id_venta_temp);
        $result    = pg_query_params($dbconn, $query, $params);

        $row = pg_fetch_row($result);
        if($row['0'] == '1'){
            echo "1"; // no se encontró id o id estaba pagado
            die();
        }

        // __id_venta_temp 	ALIAS FOR $1;
        // __id_apertura 		ALIAS FOR $2;
        // __monto_venta 		ALIAS FOR $3;
        // __id_tipo_pago 		ALIAS FOR $4;
        // __id_usuario 		ALIAS FOR $5;
        //SELECT * FROM public.fn_venta_i(?param1, ?param2, ?param3, ?param4, ?param5);
        
        $query     = "SELECT * FROM public.fn_venta_i($1, $2, $3, $4, $5)";
        $params    = array($id_venta_temp, $id_apertura, $monto_venta, $id_tipo_pago, $id_usuario);
        $result    = pg_query_params($dbconn, $query, $params);

        $row = pg_fetch_row($result);
        if($row['0'] == '0'){
            echo "0"; //todo bien.. todo correcto
        } else {
            echo '2'; //error al insertar
        }

    break;


    case 'valores-cierre-caja':
        $id_apertura = $_SESSION['apertura']['id_apertura'];

        $efectivo_apertura;
        $total_ventas_efectivo;
        $total_ventas_tarjeta;
        $total_gastos;

        // efectivo apertura
        $query     = "SELECT id_apertura, efectivo FROM public.vw_efectivo_apertura WHERE id_apertura = $1";
        $params    = array($id_apertura);
        $result    = pg_query_params($dbconn, $query, $params);
       
        $efectivo_apertura = pg_fetch_assoc($result);


        // total ventas efectivo
        $query     = "SELECT id_apertura, id_tipo_pago, total_ventas FROM public.vw_ventas_totales WHERE id_apertura = $1
                            AND id_tipo_pago = 1";
        $params    = array($id_apertura);
        $result    = pg_query_params($dbconn, $query, $params);
       
        $total_ventas_efectivo = pg_fetch_assoc($result);

        // total ventas tarjeta
        $query     = "SELECT id_apertura, id_tipo_pago, total_ventas FROM public.vw_ventas_totales WHERE id_apertura = $1
                            AND id_tipo_pago = 2";
        $params    = array($id_apertura);
        $result    = pg_query_params($dbconn, $query, $params);
       
        $total_ventas_tarjeta = pg_fetch_assoc($result);



        // total gastos
        $query     = "SELECT id_apertura, total_gastos FROM public.vw_total_gastos WHERE id_apertura = $1";
        $params    = array($id_apertura);
        $result    = pg_query_params($dbconn, $query, $params);
        
        $total_gastos = pg_fetch_assoc($result);
        
        
        
        
        // $filas= [$efectivo_apertura, $total_ventas, $total_gastos];

        $valores = array(
            'efectivo_apertura' => $efectivo_apertura['efectivo'], 
            'total_ventas_efectivo' => $total_ventas_efectivo['total_ventas'],
            'total_ventas_tarjeta' => $total_ventas_tarjeta['total_ventas'],
            'total_gastos' => $total_gastos['total_gastos']      
        );

        $json = json_encode($valores);
        echo $json;

    break;


    case 'valores-cierre-caja_backup':
        $id_apertura = $_SESSION['apertura']['id_apertura'];

        $efectivo_apertura;
        $total_ventas_efectivo;
        $total_ventas_tarjeta;
        $total_gastos;

        // efectivo apertura
        $query     = "SELECT id_apertura, efectivo FROM public.vw_efectivo_apertura WHERE id_apertura = $1";
        $params    = array($id_apertura);
        $result    = pg_query_params($dbconn, $query, $params);
       
        $efectivo_apertura = pg_fetch_assoc($result);


        // total ventas efectivo
        $query     = "SELECT id_apertura, id_tipo_pago, total_ventas FROM public.vw_ventas_totales WHERE id_apertura = $1";
        $params    = array($id_apertura);
        $result    = pg_query_params($dbconn, $query, $params);
       
        // $total_ventas = pg_fetch_assoc($result);
        // echo $total_ventas["id_tipo_pago"];
        // die();

        // $rows = [];
        $i = 0;
        while($row = pg_fetch_assoc($result))
        {
            $total_ventas['medio_pago_'.$row["id_tipo_pago"]] = $row;
            $i++;
        }



        // total gastos
        $query     = "SELECT id_apertura, id_tipo_gasto, total_gastos FROM public.vw_total_gastos WHERE id_apertura = $1";
        $params    = array($id_apertura);
        $result    = pg_query_params($dbconn, $query, $params);

        $i = 0;
        while($row = pg_fetch_assoc($result))
        {
            $total_gastos['tipo_gasto_'.$row["id_tipo_gasto"]] = $row;
            $i++;
        }
        
        
        
        
        // $filas= [$efectivo_apertura, $total_ventas, $total_gastos];

        $filas = array(
            'efectivo_apertura' => $efectivo_apertura, 
            'total_ventas' => $total_ventas,
            'total_gastos' => $total_gastos        
        );

        $json = json_encode($filas);
        echo $json;

    break;

}

?>