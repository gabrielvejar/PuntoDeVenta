<?php 

$ruta = "";
while (!(file_exists ($ruta . "index.php"))) {
    $ruta = "../" . $ruta;
}


session_start();

session_destroy();

header('Location: '. $ruta);

?>