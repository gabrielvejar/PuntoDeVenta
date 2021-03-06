<?php
$ruta = "";
while (!(file_exists ($ruta . "index.php"))) {
    $ruta = "../" . $ruta;
}

if (!empty($_SERVER['HTTP_X_REQUESTED_WITH']) & strtolower($_SERVER['HTTP_X_REQUESTED_WITH']) == 'xmlhttprequest') {

    require ($ruta . "db/conexion.php");
    // require('conexion.php');
    sleep(2);

    session_start();

    $usu 		 = $_POST['usuariolg'];
    $pass		= $_POST['passlg'];
    
    $pass = hash('sha256', $pass);

    $query     = "SELECT id_usuario, nombre, tipo_usuario
    FROM public.usuario
    WHERE activo IS TRUE AND LOWER(usuario) = LOWER($1) AND password = $2";
    $params    = array($usu, $pass);

    $usuarios    = pg_query_params($dbconn, $query, $params);

    if (pg_num_rows($usuarios)==1){
        $datos = pg_fetch_assoc($usuarios);
        $_SESSION['usuario'] = $datos;
        echo json_encode(array('error'=>false,'tipo'=>$datos['tipo_usuario']));

        //obtener permisos de usuario
        $query = "SELECT * FROM public.perfiles_usuario WHERE tipo_usuario = $1";
        $params    = array($_SESSION['usuario']['tipo_usuario']);
        $permisos    = pg_query_params($dbconn, $query, $params);
        if (pg_num_rows($permisos)==1) {
            $_SESSION['permisos'] = pg_fetch_assoc($permisos);
        }

        
    }else{
        echo json_encode(array('error'=>true));
    }
    pg_close($dbconn);

}
?>