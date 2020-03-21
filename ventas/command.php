<?php

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
}

?>