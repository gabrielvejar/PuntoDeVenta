<?php 


// verificar caja abierta
// $query     = "SELECT * FROM public.fn_verificar_caja_apertura()";
$query     = "SELECT 
                    c.id_apertura,
                    c.fecha,
                    c.time_creado,
                    u.nombre
                    FROM 
                    public.caja_apertura c
                    INNER JOIN public.usuario u
                    ON c.id_usuario = u.id_usuario
                    WHERE cerrado IS NOT TRUE
                    LIMIT 1";

$params    = array();
$result    = pg_query_params($dbconn, $query, $params);

// $row = pg_fetch_row($result);
// $_SESSION['id_apertura']=$row['0'];

$_SESSION['apertura']="";
if (pg_num_rows($result)==1) {
    $datos = pg_fetch_assoc($result);
    $_SESSION['apertura'] = $datos;
}


if(!isset($_SESSION['apertura']['id_apertura'])) {
    header('Location:'.$ruta.'ventas/caja/apertura/apertura.php');
}

// if($_SESSION['id_apertura'] == "0") {
//     header('Location:'.$ruta.'ventas/caja/apertura/apertura.php');
// }


?>