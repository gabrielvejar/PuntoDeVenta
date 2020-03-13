<?php 

$ruta = "";
while (!(file_exists ($ruta . "index.php"))) {
    $ruta = "../" . $ruta;
}

include_once $ruta . "includes/header.php";
#conexion a base de datos
include_once $ruta . "db/conexion.php";

include_once $ruta . "includes/footer.php" ;

#obtener valores
$accion = $_REQUEST["accion"];
$codigo = $_REQUEST["codigo"];
$nombre = $_REQUEST["nombre"];
$precio = $_REQUEST["precio"];
$unidad = $_REQUEST["unidad"];
$categoria = $_REQUEST["categoria"];
$cambioimagen = "f";
if ($_REQUEST["cambio-imagen"] == "t"){
    $cambioimagen = $_REQUEST["cambio-imagen"];
}
$imagen = $_FILES["fichero_usuario"]['name'];
$dir_subida = $ruta.'img/productos/';

$fichero_subido = "";
// $fichero_subido = $dir_subida . basename($_FILES['fichero_usuario']['name'], $ext) . $ext;
// $fichero_subido = basename($_FILES['fichero_usuario']['name']);

if ($imagen != ""){

    $tipo_archivo = explode("/", $_FILES['fichero_usuario']['type']);
    $tipo_archivo = $tipo_archivo[0];
    $ext = pathinfo($_FILES['fichero_usuario']['name'], PATHINFO_EXTENSION);
    $extlow = strtolower($ext);

    // echo $tipo_archivo;
    // die();

    if ($extlow != "jpg" && $extlow != "jpeg" && $extlow != "png") {
        // echo '<div class="container">';
        // echo "Error al guardar archivo<br>";
        // echo "Archivo seleccionado no es imagen<br>";
        // echo "Extensión: ".$extlow;
        // // echo explode("/", $_FILES['fichero_usuario']['type'])[0];
        // // echo 'lalala';
        // echo '<button onClick="history.back();" class="btn btn-secondary mx-2">Volver</button>';
        // echo '</div>';

        ?>    
        <script>

                bootbox.alert({
                    size: "small",
                    title: "Error",
                    message: "Error al guardar producto<br>Archivo seleccionado no es imagen<br>",
                    callback: function(){ 
                        history.back();                        
                    }
                })
            
        </script>


    <?php

        die();
    }



    // $ext = pathinfo($_FILES['fichero_usuario']['name'], PATHINFO_EXTENSION);
    $fichero_subido = basename($codigo) ."." .$ext;
    if (move_uploaded_file($_FILES['fichero_usuario']['tmp_name'], $dir_subida . $fichero_subido)) {
        $cargada = true;
    } else {
        // echo '<div class="container">';
        // echo "Error al guardar archivo<br>";
        // echo "Archivo excede tamaño máximo permitido<br>";
        // // echo '<a href="history.back()">Volver</a> ';
        // echo '<button onClick="history.back();">Volver</button>';
        // echo '</div>';
        // print_r($_FILES);
        ?>    
        <script>

                bootbox.alert({
                    size: "small",
                    title: "Error",
                    message: "Error al guardar producto<br>Archivo excede tamaño máximo permitido<br>",
                    callback: function(){ 
                        history.back();                        
                    }
                })
            
        </script>

    <?php
        die();
    }
}



    // $imagen = $_FILES["fichero_usuario"];
    // SELECT public.fn_producto_iu(?nombre, ?codigo, ?precio, ?imagen, ?idcat, ?idun);
    $query     = "SELECT public.fn_producto_iu($1, $2, $3, $4, $5, $6, $7)";
    $params    = array($nombre, $codigo, $precio, $fichero_subido, $categoria, $unidad, $cambioimagen);

    $result    = pg_query_params($dbconn, $query, $params);


    $row = pg_fetch_row($result);


    // if ($row['0'] == '0') {
    //     // include_once "success.php";
    //     header("Location: success.php?a=0");
    // } elseif ($row['0'] == '1') {
    //     header("Location: success.php?a=1");
    // }
    
    // include_once $ruta . "includes/footer.php" ;

    if ($row['0'] == '0' || $row['0'] == '1') { ?>
        <script>
            // parent.$.fancybox.close();
            // parent.$('#modal-exito').modal();
            // parent.listarProductos();
            $( document ).ready(function() {
                parent.$.fancybox.close();
                parent.mostrarModal();

        });

        </script>
    <?php } else { ?>    
        <script>
            function errorModal () {
                bootbox.alert({
                    size: "small",
                    title: "Error",
                    message: "Error al guardar producto",
                    callback: function(){ 
                        history.back();
                    }
                })
            }
            $( document ).ready(function() {
                // parent.$.fancybox.close();
                errorModal();

        });
        </script>


    <?php } ?>
