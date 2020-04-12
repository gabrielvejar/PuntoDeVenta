<?php 

$nav = 1;
if(isset($_REQUEST['nav'])) {
    $nav = $_REQUEST['nav'];
    
}


$titulo = "Caja - Punto de Venta";
$css = "estilosventa_caja.css";

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


if(!isset($_REQUEST['id'])) {
    $id_venta_temp = 0;
} else {
    $id_venta_temp = $_REQUEST['id'];

    $query     = " SELECT venta_temporal.id_venta_temp
                            FROM venta_temporal
                            WHERE venta_temporal.pagado IS NOT TRUE 
                            AND venta_temporal.id_venta_temp = $1";
    $params    = array($id_venta_temp);
    $result    = pg_query_params($dbconn, $query, $params);

    if($rows = pg_num_rows($result) == 0) {
        header('Location:'.$ruta.'ventas/caja/caja.php');
    }

}

?>
<input type="hidden" id="id_venta_temp" value="<?php echo $id_venta_temp?>">


    <!-- <div><span><?php echo date("d/m/Y") ?> | </span><span>Bienvenido <?php echo $_SESSION['usuario']['nombre'] ?></span><span> - </span><span><a href="<?php echo $ruta?>login/main_app/logout.php">Cerrar Sesión</a></span></div> -->





<?php 
if (!($nav ==0)) {
    include $ruta . "includes/nav.php"; 
}
?>

<div id="encabezado">
        <span id="titulo">CAJA - N° DE ATENCIÓN: <span><b id="idatencion"></span></b></span><button id="btn-cerrar" class="btn btn-danger">X</button>
</div>

<div id="contcont">   
<!-- <div id="" class="flex-container">    -->
    <div id="contenedor" class="">

        <div id="columna1" class="columna">

            <div id = "row1" class="collapse">
                <div id="fila1" class="lam">

                    <div id="div1-2">
                        <img id ="img-producto" src="<?php echo $ruta?>img/logopanaderia.PNG" alt="logo">
                    </div>

                    <div id="div1-1">
                        <input type="number" name="codigo" id="codigo" class="form-control w100" placeholder="Código producto">
                        <input type="text" name="nombre" id="nombre" class="form-control w100" placeholder="Nombre"  autocomplete="off">
                                <!-- autocompletar -->
                        <div id="suggestions"></div>
                        
                        <input type="text" name="promo" id="promo" class="form-control w100" placeholder="Promoción" readonly>

                        <input type="hidden" id="idproducto" value="">
                        <input type="hidden" id="idunidad" value="">
                        <input type="hidden" id="nombreunidad" value="">
                        <input type="hidden" id="id_promocion" value="">
                        <input type="hidden" id="promo_cantidad" value="">
                        <input type="hidden" id="promo_tipo_desc" value="">
                        <input type="hidden" id="promo_monto_desc" value="">
                        <input type="hidden" id="promo_activo" value="">
                        <input type="hidden" id="promo_aplica" value="">
                        <input type="hidden" id="prod_pesado" value="">
                        <input type="hidden" id="cod_hidden" value="">
                    </div>

                    <div id="div1-3">
                        <!-- <button id="btn-buscar" class="btn btn-primary">Buscar</button> -->

                        <a class="iframe" data-fancybox data-type="iframe" data-src="<?php echo $ruta?>productos\listaproducto\listaproducto.php" href="javascript:;">
                            <button id="btn-buscar" class="btn btn-primary">Buscar</button>
                        </a>
                        <button id="btn-borrar" class="btn btn-primary">Limpiar</button>
                        <button id="btn-cancelar" class="btn btn-primary"><i class="fa fa-chevron-up" aria-hidden="true"></i></button>
                    </div>

                </div>
            </div>

            <div id="precio-item" class="lam collapse">
                <div id="fila2" class="fila">
                    <div id="div2-1">
                        <label for="">$</label><input type="text" id="precio_producto" class="calctotal" readonly><label for="">x</label><input type="number" id="cantidad" class="calctotal" min=0 step="0.01" placeholder="1"><span id="unidad_producto"></span>
                    </div>
                </div>
                <div id="fila2" class="fila descuento collapse">
                    <div id="div2-1">
                        <label for="">descuento $</label><input type="number" id="monto_descuento" value="0" readonly>
                    </div>
                </div>

                <div id="fila3" class="fila">
                    <div id="div3-1">
                    <label for="">= $</label><input type="number" id="total_producto" readonly><button id="btn-agregar" class="btn btn-primary">Agregar</button>
                    </div>
                </div>    
            </div>



            <div id="div-detalle" class="lam">
                <h4>Detalle</h4>
                <div id="div-tabla-detalle">
                    <table class="table" id="tbl-detalle">
                        <thead>
                            <tr>
                                <th scope="col">#</th>
                                <th scope="col" id="col-nombre">Nombre</th>
                                <th scope="col">Precio</th>
                                <th scope="col">Cantidad</th>
                                <th scope="col">Total</th>
                                <th scope="col"></th>
                            </tr>
                        </thead>
                        <tbody id="cuerpo-tabla-detalle">
                        </tbody>
                    </table>
                </div>
                <div id="div-boton-detalle" class="collapse show">
                    <button id="btn-agregar-prod" class="btn btn-primary">Agregar Producto</button>
                </div>
            </div>



        </div>

        <div id="columna2" class="columna">
            <div id="totales" class="lam">
                <div id="total" class="total">
                    <span>Total $</span><input type="text" name="total" id="input-total" class="input-total" readonly>
                </div>
                
                <div id="pago-efectivo" class="collapse">
                    <div id="efectivo" class="total pago-efectivo">
                        <span>Efectivo $</span><input type="number" name="total" id="input-efectivo" class="input-total">
                    </div>
                    <div id="vuelto" class="total pago-efectivo">
                        <span>Vuelto $</span><input type="number" name="total" id="input-vuelto" class="input-total" readonly>
                    </div>
                    
                    <div id="billetes" class="pago-efectivo">
                        <button id="billete-1000" class="btn-billete btn btn-success" value="1000">$1.000</button>
                        <button id="billete-2000" class="btn-billete btn" value="2000">$2.000</button>
                        <button id="billete-5000" class="btn-billete btn btn-danger" value="5000">$5.000</button>
                        <button id="billete-10000" class="btn-billete btn btn-info" value="10000">$10.000</button>
                        <button id="billete-20000" class="btn-billete btn btn-primary" value="20000">$20.000</button>
                    
                    </div>

                </div>
            </div>
            <div id="botonera" class="lam collapse show">
                <div id="btns1" class=" collapse show">
                    <button id="btn-efectivo" class="btn btn-success btn-abajo btn-pago"><i class="fa fa-money" aria-hidden="true"></i> Efectivo</button>
                    <button id="btn-tarjeta" class="btn btn-info btn-abajo btn-pago"><i class="fa fa-credit-card-alt" aria-hidden="true"></i> Tarjeta</button>
                    <button id="btn-anular" class="btn btn-danger btn-abajo">Anular Venta</button>
                </div>
                <div id="btns-pago-efectivo" class=" collapse">
                    <button id="btn-pagar" class="btn btn-success btn-pago"><i class="fa fa-money" aria-hidden="true"></i> Pagar</button>
                    <button id="btn-cancelar-pago" class="btn btn-danger">Cancelar</button>
                </div>
            </div>

        </div>


    </div>

</div>


<?php include_once $ruta . "includes/footer.php" ?>