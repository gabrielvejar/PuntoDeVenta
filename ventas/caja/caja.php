<?php 
$ruta = "";
while (!(file_exists ($ruta . "index.php"))) {
    $ruta = "../" . $ruta;
}

// $nav = 1;
// if(isset($_REQUEST['nav'])) {
//     $nav = $_REQUEST['nav'];
    
// }


$titulo = "Caja - Punto de Venta";
$css = "estiloscaja.css";


include_once $ruta . "includes/header.php";

include_once $ruta . "db/conexion.php";

// validar apertura de caja
include_once $ruta . "/ventas/caja/includes/v_caja_abierta.php";


// validar que usuario tenga permiso para acceder a pagina
if ($_SESSION['permisos']['caja'] !='t') {
   header('Location: '.$ruta);
}



// include_once $ruta . "includes/nav.php";

//timestamp a datetime
$date = new DateTime($_SESSION['apertura']['time_creado']);
$fecha = $date->format('d-m-Y');
$hora = $date->format('H:i:s');

?>

<?php 
// if (!($nav ==0)) {
//     include $ruta . "includes/nav.php"; 
// }
?>



<?php 

if (isset($_REQUEST['sb'])) {
    if ($_REQUEST['sb'] != 'no'){
        include $ruta . "includes/sidebarinicio.php"; 
    } 
} else {
    include $ruta . "includes/sidebarinicio.php"; 
}

?>

<div class="container lam">

    <div id="encabezado">
        <h1><i class="fas fa-cash-register"></i> Caja</h1>
        <p>Caja ID: <?php echo $_SESSION['apertura']['id_apertura'] ?> - Apertura de caja realizada por: <?php echo $_SESSION['apertura']['nombre'] ?> - Fecha apertura: <?php echo $fecha ?> - Hora apertura:  <?php echo $hora ?></p>   
    </div>
    
    <div id="div1">
        <div id="div1-2">
            <h4>Ventas por pagar</h4>
            <div id="ventas" class="lam columna"></div>
        </div>
    </div>
</div>

<?php include_once $ruta . "includes/footer.php" ?>