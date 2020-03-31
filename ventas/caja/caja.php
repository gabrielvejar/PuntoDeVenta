<?php 
$ruta = "";
while (!(file_exists ($ruta . "index.php"))) {
    $ruta = "../" . $ruta;
}

$nav = 1;
if(isset($_REQUEST['nav'])) {
    $nav = $_REQUEST['nav'];
    
}


$titulo = "Caja - Punto de Venta";
$css = "estiloscaja.css";


include_once $ruta . "includes/header.php";

include_once $ruta . "db/conexion.php";

// validar apertura de caja
include_once $ruta . "/ventas/caja/includes/v_caja_abierta.php";


// include_once $ruta . "includes/nav.php";

//timestamp a datetime
$date = new DateTime($_SESSION['apertura']['time_creado']);
$fecha = $date->format('d-m-Y');
$hora = $date->format('H:i:s');

?>

<?php 
if (!($nav ==0)) {
    include $ruta . "includes/nav.php"; 
}
?>

<div class="container">
    <h1>Caja</h1>
    <p>Caja ID: <?php echo $_SESSION['apertura']['id_apertura'] ?> - Usuario: <?php echo $_SESSION['apertura']['nombre'] ?> - Fecha apertura: <?php echo $fecha ?> - Hora apertura:  <?php echo $hora ?></p>
    <div id="div1">
        <div id="div1-1">
            <h3>Menú</h3>
            <div id="menu" class="lam columna">
                <div>
                <button class="btn btn-info btn-menu color-fondo hoverceleste" type="button" data-toggle="collapse" data-target="#collapseVentas" aria-expanded="false" aria-controls="collapseVentas">Ventas</button>
                    <div class="collapse" id="collapseVentas" data-parent="#menu">
                    <a href="venta_caja/venta_caja.php"><button id="" class="btn btn-info btn-menu btn-sub-menu">Nueva Venta</button></a>
                    <a class="iframe" data-fancybox data-type="iframe" data-src="venta_caja/venta_caja.php?nav=0" href="javascript:;"><button class="btn btn-secondary btn-menu btn-sub-menu">Ventas Pagadas</button></a>
                        <a href=""><button class="btn btn-secondary btn-menu btn-sub-menu">Ventas Anuladas</button></a>
                    </div>
                <button class="btn btn-info btn-menu color-fondo hoverceleste" type="button" data-toggle="collapse" data-target="#collapseSalidas" aria-expanded="false" aria-controls="collapseSalidas">Salidas de dinero</button>
                    <div class="collapse" id="collapseSalidas" data-parent="#menu">
                        <a href="gastos/gastos/gastos.php"><button class="btn btn-secondary btn-menu btn-sub-menu">Gastos</button></a>
                        <a href=""><button class="btn btn-secondary btn-menu btn-sub-menu">Dinero en custodia</button></a>
                    </div>
                </div>
                <div>
                    <a href=""><button class="btn btn-danger btn-menu">Cerrar Caja</button></a>
                </div>
            </div>
            <div>
            </div>
        </div>
        <div id="div1-2">
            <h3>Ventas por pagar</h3>
            <div id="ventas" class="lam columna"></div>
        </div>
    </div>
</div>

<?php include_once $ruta . "includes/footer.php" ?>