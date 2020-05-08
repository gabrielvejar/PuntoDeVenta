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
    case 'select-tipo-gasto':

        $query     = "SELECT * FROM public.tipo_gasto ORDER BY id_tipo_gasto ASC";
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

    case 'select-custodia':

        $query     = "SELECT id_custodia, nombre FROM public.vw_custodia ORDER BY nombre ASC";
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

    case 'ingresar-gasto':
        // _id_apertura           ALIAS FOR $1;
        // _id_tipo_gasto         ALIAS FOR $2;
        // _descripcion           ALIAS FOR $3;
        // _monto                 ALIAS FOR $4;
        // _dinero_en_custodia    ALIAS FOR $5;
        // _id_dinero_custodia    ALIAS FOR $6;
        // _id_usuario_i          ALIAS FOR $7;
        $id_apertura = $_SESSION['apertura']['id_apertura'];
        $id_tipo_gasto = $_REQUEST['id_tipo_gasto'];
        $descripcion = $_REQUEST['descripcion'];
        $monto = $_REQUEST['monto'];
        $dinero_en_custodia = $_REQUEST['dinero_en_custodia'];
        $id_dinero_custodia = $_REQUEST['id_dinero_custodia'];
        $id_usuario = $usuario['id_usuario'];
        $id_movimiento = $_REQUEST['id_movimiento'];
        
        
        $query     = "SELECT * FROM public.fn_gastos_caja_i($1,$2,$3,$4,$5,$6,$7,$8)";
        $params    = array($id_apertura, $id_tipo_gasto, $descripcion, $monto, $dinero_en_custodia, $id_dinero_custodia, $id_usuario, $id_movimiento);
        $result    = pg_query_params($dbconn, $query, $params);

        if(pg_num_rows($result) > 0) {
            $row = pg_fetch_row($result);
            echo $row[0];
        }

    break;


    case 'ingresar-dinero-en-custodia':

        $descripcion = $_REQUEST['descripcion'];
        $monto = $_REQUEST['monto'];
        $id_usuario = $usuario['id_usuario'];
        
        
        $query     = "SELECT * FROM public.fn_dinero_custodia_i($1,$2,$3)";
        $params    = array($descripcion, $monto, $id_usuario);
        $result    = pg_query_params($dbconn, $query, $params);

        if(pg_num_rows($result) > 0) {
            $row = pg_fetch_row($result);
            echo $row[0];
        }

    break;

    case 'ingresar-movimiento-custodia':

        $id_custodia = $_REQUEST['id_custodia'];
        $tipoMov = $_REQUEST['tipoMov'];
        $monto = $_REQUEST['monto'];
        $comentario = $_REQUEST['comentario'];
        $gasto = $_REQUEST['gasto'];
        $id_usuario = $usuario['id_usuario'];

        if ($tipoMov == 2) {
            $monto = $monto*-1;
        }
        
        
        $query     = "SELECT * FROM public.fn_movimiento_dec_i($1,$2,$3,$4, $5)";
        $params    = array($id_custodia, $monto, $comentario, $id_usuario, $gasto);
        $result    = pg_query_params($dbconn, $query, $params);

        if(pg_num_rows($result) > 0) {
            $row = pg_fetch_row($result);
            echo $row[0];
        }

    break;

    case 'eliminar-gasto':

        $id_gasto = $_REQUEST['id_gasto'];
        $id_usuario = $usuario['id_usuario'];
        
        $query     = "SELECT * FROM public.fn_gastos_caja_d($1,$2)";
        $params    = array($id_gasto, $id_usuario);
        $result    = pg_query_params($dbconn, $query, $params);

        $row = pg_fetch_row($result);
        echo $row[0];

    break;
    
    case 'eliminar-dinero-en-custodia':

        $id_custodia = $_REQUEST['id_custodia'];
        $id_usuario = $usuario['id_usuario'];
        
        $query     = "SELECT * FROM public.fn_dinero_custodia_d($1,$2)";
        $params    = array($id_custodia, $id_usuario);
        $result    = pg_query_params($dbconn, $query, $params);

        $row = pg_fetch_row($result);
        echo $row[0];

    break;

    case 'eliminar-movimiento-custodia':

        $id_movimiento = $_REQUEST['id_movimiento'];
        $id_usuario = $usuario['id_usuario'];
        
        $query     = "SELECT * FROM public.fn_movimiento_dec_d($1,$2)";
        $params    = array($id_movimiento, $id_usuario);
        $result    = pg_query_params($dbconn, $query, $params);

        $row = pg_fetch_row($result);
        echo $row[0];

    break;

    case 'tabla-gastos':

        $query     = "SELECT * FROM public.vw_gastos WHERE eliminado IS NOT TRUE";

        $params    = array();

        $filtros = 0;

        //filtro idapertura
        if(isset($_REQUEST['id_apertura'])) {
            $filtros ++;
            $query .= " AND id_apertura = $".$filtros;
            $id_apertura = $_REQUEST['id_apertura'];
            array_push($params, $id_apertura);
        }

        //filtro fechainicio
        if(isset($_REQUEST['fechainicio'])) {
            if ($_REQUEST['fechainicio'] != ''){
                $filtros ++;
                $query .= " AND CAST(fecha AS date) >= CAST( $".$filtros." AS date)";
                $fechainicio = $_REQUEST['fechainicio'];
                array_push($params, $fechainicio);
            }
        }
        //filtro fechafin
        if(isset($_REQUEST['fechafin'])) {
            if ($_REQUEST['fechafin'] != ''){
                $filtros ++;
                $query .= " AND CAST(fecha AS date) <= CAST( $".$filtros." AS date)";
                $fechafin = $_REQUEST['fechafin'];
                array_push($params, $fechafin);
            }
        }


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

    case 'tabla-dinero-en-custodia':

        $query     = "SELECT * FROM public.vw_dinero_en_custodia WHERE eliminado IS NOT TRUE ORDER BY id_dinero_custodia ASC";
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

    case 'tabla-dinero-en-custodia-movimientos':
        $id_dinero_custodia = $_REQUEST['id_dc'];

        $query     = "SELECT * FROM public.vw_dinero_custodia_movimientos WHERE id_dinero_custodia=$1 ORDER BY id_movimiento ASC";
        $params    = array($id_dinero_custodia);
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
}