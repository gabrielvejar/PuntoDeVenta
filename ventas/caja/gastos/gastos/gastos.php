<?php 

// $nav = 1;
// if(isset($_REQUEST['nav'])) {
//     $nav = $_REQUEST['nav'];
    
// }

$titulo = "Gastos diarios - Punto de Venta";
$css = "estilosgastos.css";

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

include_once $ruta . "/ventas/caja/includes/v_caja_abierta.php";

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
    <!-- <h1 class=""><i class="fas fa-share"></i> Gastos </h1> -->
    <h1 class=""><i class="fas fa-share-square"></i> Gastos </h1>
    <h5 id="id_apertura"></h5>
    <div id="superior-ingreso" class="">
        <!-- <h4>Ingreso / modificación de gasto</h4> -->
        <h4 id="total-gastos">Total: $</h4>
        <div class="row">

            <div id="col-form-custodia" class="col-md-2">
            </div>
        
            <div id="col-form-gasto" class="col-md-8">

            <div class="custom-control custom-switch">
                <input type="checkbox" class="custom-control-input" id="agregarGastoSwitch">
                <label class="custom-control-label" for="agregarGastoSwitch">Agregar nuevo gasto</label>
            </div>

                        <div id="div-agregar-gasto" class="collapse">
                            
                                                <div class="form-row">
                                                    <div class="form-group col-md-6">
                                                        <label class="mr-sm-2" for="inlineFormCustomSelect">Tipo de gasto</label>
                                                        <select class="custom-select mr-sm-2" id="select-tipo-gasto">
                                                        </select>
                                                    </div>
                                                    <div class="form-group col-md-6">
                                                        <label for="monto">Monto</label>
                                                        <input type="text" class="form-control" id="monto" placeholder="Ingrese monto del gasto">
                                                    </div>
                                                </div>
                            
                                                <div class="form-group">
                                                        <label for="descripcion">Descripción</label>
                                                        <input type="text" class="form-control" id="descripcion" placeholder="Ingrese descripción del gasto. Ej: Pago Coca-Cola, Pago panadero, etc.">
                                                </div>

                                                <div class="custom-control custom-switch">
                                                    <input type="checkbox" class="custom-control-input" id="asociarSwitch">
                                                    <label class="custom-control-label" for="asociarSwitch">Asociar gasto a dinero en custodia</label>
                                                </div>
                            
                                                <div id="form-dinero-cust" class="form-row collapse">
                                                    <div class="form-group col">
                                                        <label for="inputCustodia">Dinero en custodia</label>

                                                        <div id="dec">
                                                            <select id="inputCustodia" class="form-control">
                                                                <option selected>Seleccione dinero en custodia...</option>
                                                            </select>
                                                            <a class="iframe" data-fancybox data-type="iframe" data-src="<?php echo $ruta?>ventas\caja\gastos\dinero_en_custodia\custodia.php?&sb=no" href="javascript:;"><button id='btn-otro' class="btn btn-primary">Nuevo</button></a>
                                                        </div>

                                                    </div>
                                                    
                                                    <!-- <div class="form-group col-md-2">
                                                        <label for="inputState">State</label>
                                                        
                                                        
                                                    </div> -->
                                                </div>
                            
                                                <button id='btn-ingresar' class="btn btn-primary">Ingresar</button>
                        </div>

            </div>

            <div id="col-form-custodia" class="col-md-2">
            </div>

        </div>
        
    </div>

    <div id="inferior-tabla" class="table-responsive">

        <!-- <div id="btn-fontsize">
            <i class="fa fa-minus" aria-hidden="true" id="achicar"></i>   <i class="fa fa-plus" aria-hidden="true" id="agrandar"></i>
        </div> -->

        <p id="msg-sin-gastos" class="" style="display: none;">Sin gastos ingresados</p>

        <table class="table table-hover table-sm table-bordered" style="display: none;">
            <thead>
                <tr>
                    <th scope="col">#</th>
                    <th scope="col">Fecha</th>
                    <th scope="col">Hora</th>
                    <th scope="col">Descripción</th>
                    <th scope="col">Monto</th>
                    <th scope="col">Custodia</th>
                    <th scope="col">Acciones</th>
                </tr>
            </thead>
            <tbody id="tabla-gastos-body" class="" style="font-size: 16px;">
            <tr>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
            </tr>
            </tbody>
        </table>
    <!-- <button id="achicar" class="btn btn-danger">Achicar letra</button><button id="agrandar" class="btn btn-success">Agrandar letra</button> -->


    
    


    </div>






</div>






<?php include_once $ruta . "includes/footer.php" ?>