<?php 


$titulo = "Registro cierres - Punto de Venta";
$css = "estilosregistrocierres.css";

$ruta = "";
while (!(file_exists ($ruta . "index.php"))) {
    $ruta = "../" . $ruta;
}


include_once $ruta . "includes/header.php";

include_once $ruta . "db/conexion.php";

//TODO cambiar permisos
// validar que usuario tenga permiso para acceder a pagina
if ($_SESSION['permisos']['caja'] !='t') {
    header('Location: '.$ruta);
 }


?>

<?php

if (isset($_REQUEST['nav'])) {
    if ($_REQUEST['nav'] == 'si'){
        include $ruta . "includes/nav.php"; 
    } 
}

?>

<?php 
$id_ap = 0;

if(isset($_REQUEST['id'])) {
    $id_ap = $_REQUEST['id'];
}
?>

<input type="hidden" id="id_ap" value="<?php echo $id_ap?>">


<?php
// asignar a inputs ocultos datos pasados
foreach ($_REQUEST as $key => $value) {
?>
<input class="filtro" type="hidden" id="<?php echo $key?>" value="<?php echo $value?>">

<?php } ?>




<?php 

if (isset($_REQUEST['sb'])) {
    if ($_REQUEST['sb'] != 'no'){
        include $ruta . "includes/sidebarinicio.php"; 
    } 
} else {
    include $ruta . "includes/sidebarinicio.php"; 
}

?>



<div id="contenedor" class="container lam">


    <h1><i class="fas fa-file-invoice-dollar"></i> Registro Cierres de Caja</h1>
    <div id="filtros">
        
        <form action="">
            <div class="form-row">
                <div class="form-group col">
                    <label for="inputFechaInicio">Fecha Inicio</label>
                    <input type="date" class="form-control filtros" id="inputFechaInicio" placeholder="">
                </div>
                <div class="form-group col">
                    <label for="inputFechaFin">Fecha Fin</label>
                    <input type="date" class="form-control filtros" id="inputFechaFin" placeholder="">
                </div>
                <div class="form-group col">
                    <label for="inputCajero">Cajero/a Cierre</label>
                    <select id="inputCajero" class="form-control filtros">
                        <option selected>Seleccione...</option>
                    </select>
                </div>
                <!-- <div class="form-group col">
                    <button id="btn-filtrar" class="btn btn-primary">Filtrar</button>
                </div> -->
            </div>
            <div class="form-row">
                <div class="form-group col">
                    <button id="btn-filtrar" class="btn btn-primary">Filtrar</button>
                    <button id="btn-limpiar" class="btn btn-primary">Limpiar</button>
                </div>
            </div>
        </form>

    </div>



    <div class="row">

        <div id="div-tbl-ventas" class="col">
            <table class="table table-hover">
                <thead>
                <!-- /*
        id_cierre,
        id_apertura,
        fecha,
        time_apertura,
        id_user_apertura,
        user_apertura,
        efectivo_apertura,
        efectivo_cierre,
        ventas_efectivo,
        ventas_tarjetas,
        entrega,
        gastos,
        id_user_cierre,
        user_cierre,
        time_cierre,
        id_user_autoriza,
        user_autoriza
        */ -->
                    <tr>
                    <th scope="col">Caja</th>
                    <th scope="col">Fecha</th>
                    <th scope="col">Abierta por</th>
                    <th scope="col">Cerrada por</th>
                    <th scope="col">Ventas</th>
                    <th scope="col">Gastos</th>
                    <th scope="col">Efectivo Cierre</th>
                    <th scope="col">Entrega</th>
                    <th scope="col">Balance</th>
                    <th scope="col">Acciones</th>
                    </tr>
                </thead>
                <tbody id="tbody_registro_cierres">
                </tbody>
            </table>
        </div>

    </div>


</div>



<?php include_once $ruta . "includes/footer.php" ?>