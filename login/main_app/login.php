<?php

if (!empty($_SERVER['HTTP_X_REQUESTED_WITH']) & strtolower($_SERVER['HTTP_X_REQUESTED_WITH']) == 'xmlhttprequest') {
    require('conexion.php');
    sleep(2);
    $usu 		 = $_POST['usuariolg'];
    $pass		= $_POST['passlg'];

    $query     = "SELECT nombre, tipo_usuario
    FROM public.usuario
    WHERE usuario = $1 AND password = $2";
    $params    = array($usu, $pass);

    $usuarios    = pg_query_params($dbconn, $query, $params);

    if (pg_num_rows($usuarios)==1):
        $datos = pg_fetch_assoc($usuarios);
        echo json_encode(array('error'=>false,'tipo'=>$datos['tipo_usuario']));
    else:
        echo json_encode(array('error'=>true));
    endif;
    pg_close($dbconn);

}
?>
