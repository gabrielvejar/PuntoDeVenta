<?php 

$titulo = "Ventas Anuladas - Punto de Venta";
$css = "estilosventastempanuladas.css";

$ruta = "";
while (!(file_exists ($ruta . "index.php"))) {
    $ruta = "../" . $ruta;
}


include_once $ruta . "includes/header.php";

include_once $ruta . "db/conexion.php";


// validar que usuario tenga permiso para acceder a pagina
if ($_SESSION['permisos']['caja'] !='t') {
    header('Location: '.$ruta);
}


?>


<?php 
$id_ap = 0;

if(isset($_REQUEST['id_ap'])) {
    $id_ap = $_REQUEST['id_ap'];
}
?>



<?php

// if (isset($_REQUEST['nav'])) {
//     if ($_REQUEST['nav'] != 'no'){
//         include $ruta . "includes/nav.php"; 
//     } 
// } else {
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

<?php
// asignar a inputs ocultos datos pasados
foreach ($_REQUEST as $key => $value) {
?>
<input class="filtro" type="hidden" id="<?php echo $key?>" value="<?php echo $value?>">

<?php } ?>

<div id="contenedor" class="container lam">


    <h1><i class="fas fa-trash-alt"></i> Ventas temporales anuladas</h1>
    <h5><?php if ($id_ap != 0) {echo 'Caja ID: '.$id_ap;} ?></h5>

    <div class="row">
        <!-- <div class="col"></div> -->



        <div id="div-tbl-ventas" class="col">
            <table class="table table-hover">
                <thead>

                    <tr>
                    <th scope="col">#</th>
                    <th scope="col">Fecha</th>
                    <th scope="col">Hora</th>
                    <th scope="col">Total</th>
                    <th scope="col">Vendedor</th>
                    <th scope="col">Acción</th>
                    </tr>
                </thead>
                <tbody id="tbody_ventas_temp_anuladas">
                    <!-- <tr>
                    <th scope="row">1</th>
                    <td>Mark</td>
                    <td>Otto</td>
                    <td>@mdo</td>
                    <td>@mdo</td>
                    <td>@mdo</td>
                    <td>@mdo</td>
                    <td>@mdo</td>
                    </tr> -->
                </tbody>
            </table>
            <div id="mensaje"></div>
        </div>
    
        <!-- <div class="col"></div> -->
    </div>







</div>






<?php include_once $ruta . "includes/footer.php" ?>