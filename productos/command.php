<?php

$ruta = "";
while (!(file_exists ($ruta . "index.php"))) {
    $ruta = "../" . $ruta;
}
require $ruta . "db/conexion.php";

$cmd=$_REQUEST['cmd'];


switch ($cmd) {

    case "tabla-productos":

        $inicio = 0;
        $cant = 1000;
        $nombre = "%"."%";
        $codigo = "%"."%";
        $categoria = "";

        if (isset($_REQUEST['inicio'])) {
            if ($_REQUEST['inicio'] != ""){
                $inicio = $_REQUEST['inicio'];
            }
        }

        if (isset($_REQUEST['cant'])) {
            if ($_REQUEST['cant'] != ""){
                $cant = $_REQUEST['cant'];
            }
        }

        if (isset($_REQUEST['nombre'])) {
            if ($_REQUEST['nombre'] != ""){
                $nombre = "%".$_REQUEST['nombre']."%";
            }
        }

        if (isset($_REQUEST['codigo'])) {
            if ($_REQUEST['codigo'] != ""){
                $codigo = "%".$_REQUEST['codigo']."%";
            }
        }

        if (isset($_REQUEST['categoria'])) {
            if ($_REQUEST['categoria'] != ""){
                $categoria = $_REQUEST['categoria'];
            }
        }

        
        // $inicio=$_REQUEST['inicio'];
        // $cant=$_REQUEST['cant'];
        // $nombre = "%".$_REQUEST['nombre']."%";
        // $codigo = "%".$_REQUEST['codigo']."%";
        // $categoria = $_REQUEST['categoria'];

        $query     = "SELECT p.idproducto, p.nombreproducto, p.codigodebarras, p.precio, p.imagen, c.nombrecategoria, u.nombreunidad
                            FROM public.producto p
                            INNER JOIN public.categoria c
                            ON p.idcategoria = c.idcategoria
                            INNER JOIN public.unidad u
                            ON p.idunidad = u.idunidad
                            WHERE p.activo = TRUE 
                            AND LOWER(p.nombreproducto) LIKE LOWER($3)
                            AND LOWER(p.codigodebarras) LIKE LOWER($4)";
        if ($categoria != "") {
            $query     .= " AND p.idcategoria = $5";
            $params    = array($cant, $inicio, $nombre, $codigo, $categoria);
        } else {
            $params    = array($cant, $inicio, $nombre, $codigo);
        }
        $query     .= " ORDER BY nombreproducto ASC
                            LIMIT $1
                            OFFSET $2";

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


    // case "cant-filas":
    //     $nombre = "%".$_REQUEST['nombre']."%";
    //     $codigo = "%".$_REQUEST['codigo']."%";
    //     $categoria = $_REQUEST['categoria'];

    //     $query     = "SELECT p.idproducto
    //                         FROM public.producto p
    //                         WHERE p.activo = TRUE 
    //                         AND LOWER(p.nombreproducto) LIKE LOWER($1)
    //                         AND LOWER(p.codigodebarras) LIKE LOWER($2)";
    //     if ($categoria != "") {
    //         $query     .= " AND p.idcategoria = $3";
    //         $params    = array($nombre, $codigo, $categoria);
    //     } else {
    //         $params    = array($nombre, $codigo);
    //     }

    //     $result    = pg_query_params($dbconn, $query, $params);

    //     $total_productos_bd = pg_num_rows($result);

    //     echo $total_productos_bd;

    //     break; 

    case "combo-categorias":
        $query     = "SELECT * FROM public.categoria ORDER BY nombrecategoria ASC";
        $params    = array();

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

    case "combo-unidad":
        $query     = "SELECT * FROM public.unidad";
        $params    = array();

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
    
    case "eliminar-producto":

        $codigo = $_REQUEST["codigo"];

        $query     = "SELECT public.fn_producto_d($1)";
        $params    = array($codigo);

        $result    = pg_query_params($dbconn, $query, $params);

        $row = pg_fetch_row($result);


        echo $row['0'];

        break;

    case "detalle-producto":



        if (isset($_REQUEST['codigo'])){
        $codigo = $_REQUEST['codigo'] ;

        $query     = "SELECT p.idproducto, p.nombreproducto, p.precio, p.imagen, p.idcategoria, p.idunidad, p.activo
        FROM public.producto p
        WHERE p.codigodebarras = $1";
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


    }
    break;
}

?>