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
        
        
        $query     = "SELECT * FROM public.fn_gastos_caja_i($1,$2,$3,$4,$5,$6,$7)";
        $params    = array($id_apertura, $id_tipo_gasto, $descripcion, $monto, $dinero_en_custodia, $id_dinero_custodia, $id_usuario);
        $result    = pg_query_params($dbconn, $query, $params);

        if(pg_num_rows($result) > 0) {
            $row = pg_fetch_row($result);
            echo $row[0];
        }

    break;

    case 'tabla-gastos':

        $query     = "SELECT * FROM public.vw_gastos WHERE eliminado IS NOT TRUE AND id_apertura = $1";
        $params    = array($_SESSION['apertura']['id_apertura']);
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