<?php 

$titulo = "Detalle venta - Punto de Venta";
$css = "estilosdetalleventa.css";

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

<?php //include $ruta . "includes/nav.php"; ?>

<?php 
$id_venta_temp = 0;

if(isset($_REQUEST['id'])) {
    $id_venta_temp = $_REQUEST['id'];
}

?>
<input type="hidden" id="id_venta_temp" value="<?php echo $id_venta_temp?>">

<div id="contenedor" class="container lam">


    <h1><i class="fa fa-list-alt" aria-hidden="true"></i> Detalle venta #<span id="id_diario"></span></h1>

    <div class="row">
        <!-- <div class="col"></div> -->



        <div id="div-tbl-ventas" class="col">
            <table class="table table-hover">
                <thead>

                    <tr>
                    <th scope="col">#</th>
                    <th scope="col">Nombre</th>
                    <th scope="col">Precio</th>
                    <th scope="col">Cantidad</th>
                    <th scope="col">Total</th>
                    </tr>
                </thead>
                <tbody id="tbody_detalle_venta">
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
            (*) Promoción aplicada
        </div>
    
        <!-- <div class="col"></div> -->
    </div>







</div>






<?php include_once $ruta . "includes/footer.php" ?>