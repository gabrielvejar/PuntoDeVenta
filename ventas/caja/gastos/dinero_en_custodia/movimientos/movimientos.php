<?php 

// $nav = 1;
// if(isset($_REQUEST['nav'])) {
//     $nav = $_REQUEST['nav'];
    
// }

$titulo = "Dinero en custodia - Punto de Venta";
$css = "estilosmovimientos.css";

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
$id_cust = 0;
if (isset ($_REQUEST['id'])) {
    if ($_REQUEST['id'] != "") {
        $id_cust = $_REQUEST['id'];
    }
}

$vaciar = 0;
if (isset ($_REQUEST['vaciar'])) {
    if ($_REQUEST['vaciar'] != "") {
        $vaciar = $_REQUEST['vaciar'];
    }
}
?>


<input type="hidden" id="id-dinero-custodia" value="<?php echo $id_cust ?>">
<input type="hidden" id="saldo-vaciar" value="<?php echo $vaciar ?>">
<input type="hidden" id="saldo" value="0">

<div class="container lam">
    <h1 class=""><i class="fas fa-archive"></i> Dinero en custodia </h1>
    <h5 id="nom_dinero_custodia" class="">Nombre del dinero en custodia</h5>
    <h5 id="saldo_dinero_custodia" class="">Saldo: $</h5>
    <div id="superior-ingreso" class="">

        <div class="row">

            <div id="col-form-custodia" class="col-md-2">
            </div>
        
            <div id="col-form-gasto" class="col-md-8">

                                <div class="custom-control custom-switch">
                                    <input type="checkbox" class="custom-control-input" id="agregar-mov-custodia">
                                    <label class="custom-control-label" for="agregar-mov-custodia">Agregar movimiento de dinero en custodia</label>
                                </div>

                                <div id="div-agregar-mov-custodia" class="collapse">

                                                <div id="form-agregar-mov" class="form-row">

                                                    <div class="form-group col-md-6">
                                                        <label for="inputTipoMov">Tipo de movimiento</label>
                                                        <select id="inputTipoMov" class="form-control">
                                                                    <option value="0">--Seleccione--</option>
                                                                    <option value="1">Ingreso</option>
                                                                    <option value="2">Egreso</option>
                                                        </select>
                                                    </div>
                                                    <div class="form-group col-md-6">
                                                        <label for="monto">Monto inicial</label>
                                                        <input type="text" class="form-control" id="monto" placeholder="Ingrese monto inicial de dinero en custodia">
                                                    </div>

                                                </div>
                                                <div class="form-group">
                                                        <label for="descripcion">Comentario</label>
                                                        <input type="text" class="form-control" id="comentario" placeholder="Ingrese comentario de movimiento.">
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

        <p id="msg-sin-gastos" class="" style="display: none;">Sin movimientos</p>
        
        <table class="table table-hover table-sm table-bordered" style="display: none;">
            <thead>
                <tr>
                    <th scope="col">#</th>
                    <th scope="col">Fecha</th>
                    <th scope="col">Hora</th>
                    <th scope="col">Comentario</th>
                    <th scope="col">Monto</th>
                    <th scope="col">Saldo</th>
                    <th scope="col">Acciones</th>
                </tr>
            </thead>
            <tbody id="tabla-dec-mov-body" class="" style="font-size: 16px;">
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
        <label>(*) Ingresado desde Gastos</label>


    
    


    </div>






</div>






<?php include_once $ruta . "includes/footer.php" ?>