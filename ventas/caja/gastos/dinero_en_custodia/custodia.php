<?php 

// $nav = 1;
// if(isset($_REQUEST['nav'])) {
//     $nav = $_REQUEST['nav'];
    
// }

$titulo = "Dinero en custodia - Punto de Venta";
$css = "estiloscustodia.css";

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
if (isset($_REQUEST['sb'])) {
    if ($_REQUEST['sb'] != 'no'){
        include $ruta . "includes/sidebarinicio.php"; 
    } 
} else {
    include $ruta . "includes/sidebarinicio.php"; 
}
?>



<div class="container lam">
    <h1 class=""><i class="fas fa-archive"></i> Dinero en custodia </h1>
    <div id="superior-ingreso" class="">
        <h4 id="total-custodia">Dinero acumulado: $</h4>

        <div class="row">

            <div id="col-form-custodia" class="col-md-2">
            </div>
        
            <div id="col-form-gasto" class="col-md-8">

            <div class="custom-control custom-switch">
                <input type="checkbox" class="custom-control-input" id="agregar-agregar-custodia">
                <label class="custom-control-label" for="agregar-agregar-custodia">Agregar dinero en custodia</label>
            </div>

                        <div id="div-agregar-custodia" class="collapse">

                                                <div class="form-group">
                                                        <label for="descripcion">Descripción</label>
                                                        <input type="text" class="form-control" id="descripcion" placeholder="Ingrese descripción de dinero en custodia.">
                                                </div>

                                                <div class="custom-control custom-switch">
                                                    <input type="checkbox" class="custom-control-input" id="montoInicialSwitch">
                                                    <label class="custom-control-label" for="montoInicialSwitch">Indicar monto inicial</label>
                                                </div>

                                                <div id="form-monto-inicial" class="form-row collapse">
                                                    <div class="form-group col-md-6">
                                                        <label for="monto">Monto inicial</label>
                                                        <input type="text" class="form-control" id="monto" placeholder="Ingrese monto inicial de dinero en custodia">
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

        <p id="msg-sin-gastos" class="" style="display: none;">Sin dinero en custodia ingresado</p>

        <table class="table table-hover table-sm table-bordered" style="display: none;">
            <thead>
                <tr>
                    <th scope="col">#</th>
                    <th scope="col">Descripción</th>
                    <th scope="col">Saldo</th>
                    <th scope="col">Acciones</th>
                </tr>
            </thead>
            <tbody id="tabla-dec-body" class="" style="font-size: 16px;">
            <tr>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
            </tr>
            </tbody>
        </table>


    
    


    </div>






</div>






<?php include_once $ruta . "includes/footer.php" ?>