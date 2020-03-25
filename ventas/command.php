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
    case 'ingresar-venta-temporal':

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

        // TODO imprimir ticket




    break;

    case 'buscar-venta-temporal':

        $id_venta_temp = $_REQUEST['id_venta_temp'] ;

        $query     = "SELECT * FROM public.vw_detalle_venta_temp WHERE id_venta_temp = $1";
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

    case 'ventas-temporales':
        //SELECT id_venta_temp, id_diario FROM public.venta_temporal 
  WHERE pagado IS NOT TRUE

}

?>