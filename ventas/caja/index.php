<?php 


$titulo = "Caja - Punto de Venta";
$css = "estiloscajaindex.css";

$ruta = "";
while (!(file_exists ($ruta . "index.php"))) {
    $ruta = "../" . $ruta;
}

include_once $ruta . "includes/header.php";

include_once $ruta . "db/conexion.php";



?>

<div id="ventas"></div>





<?php include_once $ruta . "includes/footer.php" ?>