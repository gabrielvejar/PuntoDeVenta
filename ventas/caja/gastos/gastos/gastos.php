<?php 

$nav = 1;
if(isset($_REQUEST['nav'])) {
    $nav = $_REQUEST['nav'];
    
}

$titulo = "Gastos diarios - Punto de Venta";
$css = "estilosgastos.css";

$ruta = "";
while (!(file_exists ($ruta . "index.php"))) {
    $ruta = "../" . $ruta;
}

include_once $ruta . "includes/header.php";

include_once $ruta . "db/conexion.php";

include_once $ruta . "/ventas/caja/includes/v_caja_abierta.php";

?>

<?php 
if (!($nav ==0)) {
    include $ruta . "includes/nav.php"; 
}
?>

<div class="container">
    <h1 class="">Gastos <?php echo date('d-m-Y') ?> / Caja ID: <?php echo $_SESSION['apertura']['id_apertura'] ?></h1>
    <div id="superior-ingreso" class="">
        <!-- <h4>Ingreso / modificación de gasto</h4> -->

        <div class="row">

            <div id="col-form-custodia" class="col-md-2">
            </div>
        
            <div id="col-form-gasto" class="col-md-8">


                    <div class="form-row">
                        <div class="form-group col-md-6">
                            <label class="mr-sm-2" for="inlineFormCustomSelect">Tipo de gasto</label>
                            <select class="custom-select mr-sm-2" id="select-tipo-gasto">
                            </select>
                        </div>
                        <div class="form-group col-md-6">
                            <label for="monto">Monto</label>
                            <input type="number" class="form-control" id="monto" placeholder="Ingrese monto del gasto">
                        </div>
                    </div>

                    <div class="form-group">
                            <label for="descripcion">Descripción</label>
                            <input type="text" class="form-control" id="descripcion" placeholder="Ingrese descripción del gasto. Ej: Pago Coca-Cola, Pago panadero, etc.">
                    </div>

                    <!-- TODO habilitar cuando se pueda asociar dinero en custodia -->
                    <div class="form-group collapse">
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" id="asociarCheck">
                            <label class="form-check-label" for="asociarCheck">
                                Asociar a dinero en custodia
                            </label>
                        </div>
                    </div>




                    <div id="form-dinero-cust" class="form-row collapse">
                        <div class="form-group col-md-6">
                            <label for="inputCity">City</label>
                            <input type="text" class="form-control" id="inputCity">
                        </div>
                        <div class="form-group col-md-4">
                            <label for="inputState">State</label>
                            <select id="inputState" class="form-control">
                                <option selected>Choose...</option>
                                <option>...</option>
                            </select>
                        </div>
                        <div class="form-group col-md-2">
                            <label for="inputZip">Zip</label>
                            <input type="text" class="form-control" id="inputZip">
                        </div>
                    </div>

                    <button id='btn-ingresar' class="btn btn-primary">Ingresar gasto</button>

            </div>

            <div id="col-form-custodia" class="col-md-2">
            </div>

        </div>
        
    </div>

    <div id="inferior-tabla" class="table-responsive">

        <div id="btn-fontsize">
            <i class="fa fa-minus" aria-hidden="true" id="achicar"></i>   <i class="fa fa-plus" aria-hidden="true" id="agrandar"></i>
        </div>

        <table class="table table-hover table-sm table-bordered collapse">
            <thead>
                <tr>
                    <th scope="col">#</th>
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
            </tr>
            </tbody>
        </table>
    <!-- <button id="achicar" class="btn btn-danger">Achicar letra</button><button id="agrandar" class="btn btn-success">Agrandar letra</button> -->


    
    


    </div>






</div>






<?php include_once $ruta . "includes/footer.php" ?>