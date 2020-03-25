<?php 

if(!isset($_REQUEST['id'])) {
    die();
} else {
    $id_venta_temp = $_REQUEST['id'];
}

$titulo = "Caja - Punto de Venta";
$css = "estiloscaja.css";

$ruta = "";
while (!(file_exists ($ruta . "index.php"))) {
    $ruta = "../" . $ruta;
}

include_once $ruta . "includes/header.php";

include_once $ruta . "db/conexion.php";

?>
<input type="hidden" id="id_venta_temp" value="<?php echo $id_venta_temp?>">
<input type="hidden" id="ruta" value="<?php echo $ruta?>">

    <div><span><?php echo date("d/m/Y") ?> | </span><span>Bienvenido <?php echo $_SESSION['usuario']['nombre'] ?></span><span> - </span><span><a href="<?php echo $ruta?>login/main_app/logout.php">Cerrar Sesión</a></span></div>


    

<div id="encabezado" class="flex-container">
        <span id="titulo">CAJA - N° DE ATENCIÓN: <span><b id="idatencion"></span></b></span><button id="btn-cerrar" class="btn btn-danger">X</button>
</div>

<div id="" class="flex-container"> 
    <div id="contenedor" class="">

        <div id="columna1" class="columna">

            <div id = "row1" class="collapse">
                <div id="fila1" class="lam">

                    <div id="div1-2">
                        <img id ="img-producto" src="<?php echo $ruta?>img/logopanaderia.PNG" alt="logo">
                    </div>

                    <div id="div1-1">
                        <input type="number" name="codigo" id="codigo" class="form-control w100" placeholder="Código producto">
                        <input type="text" name="nombre" id="nombre" class="form-control w100" placeholder="Nombre">
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
                    </div>

                    <div id="div1-3">
                        <!-- <button id="btn-buscar" class="btn btn-primary">Buscar</button> -->

                        <a class="iframe" data-fancybox data-type="iframe" data-src="<?php echo $ruta?>productos\listaproducto\listaproducto.php" href="javascript:;">
                            <button id="btn-buscar" class="btn btn-primary">Buscar</button>
                        </a>
                        <button id="btn-borrar" class="btn btn-primary">Borrar</button>
                        <button id="btn-cancelar" class="btn btn-primary">Cancelar</button>
                    </div>

                </div>
            </div>

            <div id="precio-item" class="lam collapse">
                <div id="fila2" class="fila">
                    <div id="div2-1">
                        <label for="">$</label><input type="number" id="precio_producto" class="calctotal" readonly><label for="">x</label><input type="number" id="cantidad" class="calctotal" min=0 step="0.01" placeholder="1"><span id="unidad_producto"></span>
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
                    <span>Total $</span><input type="number" name="total" id="input-total" class="input-total" readonly>
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
                    <button id="btn-efectivo" class="btn btn-success btn-abajo btn-pago">Efectivo</button>
                    <button id="btn-tarjeta" class="btn btn-info btn-abajo btn-pago">Tarjeta</button>
                    <button id="btn-cancelar" class="btn btn-danger btn-abajo">Anular Venta</button>
                </div>
                <div id="btns-pago-efectivo" class=" collapse">
                    <button id="btn-pagar" class="btn btn-success btn-pago">Pagar</button>
                    <button id="btn-cancelar-pago" class="btn btn-danger">Cancelar</button>
                </div>
            </div>

        </div>


    </div>

</div>


<?php include_once $ruta . "includes/footer.php" ?>