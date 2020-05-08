<?php

session_start();

if(!isset($_SESSION['usuario'])) {
    die();
} else {
    $usuario = $_SESSION['usuario'];
}

// validar que usuario tenga permiso para acceder a pagina
if ($_SESSION['permisos']['mantenedor_usuarios'] !='t') {
    die();
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
    case 'select-perfiles':

        $query     = "SELECT tipo_usuario, tipo_usuario_completo FROM public.perfiles_usuario";
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


    case 'agregar-usuario':


        $nombre = $_REQUEST['nombre'];
        $username = $_REQUEST['username'];
        // $password = $_REQUEST['password']; 
        $password = hash('sha256', $_REQUEST['password']);
        $tipo_usuario = $_REQUEST['tipo_usuario'];

        $query     = "SELECT * FROM public.fn_usuario_i($1, $2, $3, $4)";
        $params    = array($nombre, $username, $password, $tipo_usuario);
        $result    = pg_query_params($dbconn, $query, $params);
        

        $row = pg_fetch_row($result);

        echo $row['0'];

    break;


    case 'modificar-usuario':

        $idUsuario = $_REQUEST['idUsuario'];
        
        $nombre = $_REQUEST['nombre'];
        $modPass = $_REQUEST['modPass'];
        // $password = $_REQUEST['password'];
        $password = hash('sha256', $_REQUEST['password']);
        $tipo_usuario = $_REQUEST['tipo_usuario'];

        $query     = "SELECT * FROM public.fn_usuario_u($1, $2, $3, $4, $5)";
        $params    = array($idUsuario, $nombre, $modPass, $password, $tipo_usuario);
        $result    = pg_query_params($dbconn, $query, $params);
        

        $row = pg_fetch_row($result);

        echo $row['0'];

    break;

    case 'tabla-usuarios':

        $query     = "SELECT 
                                id_usuario,
                                nombre,
                                usuario,
                                tipo_usuario,
                                tipo_usuario_completo
                            FROM 
                                public.vw_usuarios;";
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

    case 'datos-usuario':
        $id = $_REQUEST['id'];

        $query     = "SELECT 
                                id_usuario,
                                nombre,
                                usuario,
                                tipo_usuario,
                                tipo_usuario_completo
                            FROM 
                                public.vw_usuarios
                            WHERE
                                id_usuario = $1;";

        $params    = array($id);

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