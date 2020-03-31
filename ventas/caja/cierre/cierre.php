<?php 

$titulo = "Cierre de caja - Punto de Venta";
$css = "estiloscierre.css";

$ruta = "";
while (!(file_exists ($ruta . "index.php"))) {
    $ruta = "../" . $ruta;
}

include_once $ruta . "includes/header.php";

include_once $ruta . "db/conexion.php";

include_once $ruta . "/ventas/caja/includes/v_caja_abierta.php";

?>

<?php include $ruta . "includes/nav.php"; ?>
<div id="contenedor" class="container lam">


    <h1>Cierre de Caja ID: <?php echo $_SESSION['apertura']['id_apertura'] ?> / <?php echo date('d-m-Y') ?></h1>



    <div class="row">
        <div class="col">
            </div>
            <div class="col-md-8">
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th scope="col">#</th>
                            <th scope="col">Detalle</th>
                            <th scope="col">Ingreso</th>
                            <th scope="col">Egreso</th>
                            <th scope="col">Detalle</th>
                        </tr>
                    </thead>
                    <tbody>
                    <tr>
                            <th scope="row">1</th>
                            <td>Efectivo Apertura</td>
                            <td id="td-efectivo-apertura"></td>
                            <td></td>
                            <td></td>
                        </tr>
                        <tr>
                            <th scope="row">2</th>
                            <td>Ventas Efectivo</td>
                            <td id="td-ventas-efectivo">500000</td>
                            <td></td>
                            <td><a class="iframe" data-fancybox data-type="iframe" data-src="<?php echo $ruta?>productos\listaproducto\listaproducto.php" href="javascript:;">Ver</a></td>
                        </tr>
                        <tr>
                            <th scope="row">3</th>
                            <td>Ventas Tarjeta</td>
                            <td id="td-ventas-tarjeta">0</td>
                            <td></td>
                            <td><a data-toggle="collapse" href="#div-sumador" >Sumador</a></td>
                            
                        </tr>
                        <tr>
                            <th scope="row">4</th>
                            <td>Gastos</td>
                            <td></td>
                            <td id="td-gastos">12312213</td>
                            <td><a class="iframe" data-fancybox data-type="iframe" data-src="<?php echo $ruta?>ventas\caja\gastos\gastos\gastos.php?nav=0" href="javascript:;">Ver</a></td>
                        </tr>
                    
                    </tbody>
                </table>


                <div id="div-balance" class="row">
                    <div class="col"></div>
                    <div id="divinputs" class="col-md-8">
                        <div class="row">
                            <div id="efectivocierrel" class="col"><a data-toggle="collapse" href="#div-sumador"><i class="fa fa-calculator" id="icon-calc" aria-hidden="true"></i></a> Efectivo Cierre:</div>
                            <div class="col"><input id="input-efectivo" class="inputs-bal" type="text"></div>
                        </div>


                        <!-- sumador de efectivo -->

                        <div id="div-sumador" class="collapse">
                            <div id="titulo-sumador">Sumador de efectivo</div>
                            <table class="table">
                                <tbody>
                                    <tr>
                                        <td>$20.000</td>
                                        <td>x</td>
                                        <td><input class="input-sumador multiplo" type="text"></td>
                                        <td>=</td>
                                        <td><input class="input-sumador prod-mult" type="text"></td>
                                    </tr>
                                    <tr>
                                        <td>$10.000</td>
                                        <td>x</td>
                                        <td><input class="input-sumador multiplo" type="text"></td>
                                        <td>=</td>
                                        <td><input class="input-sumador prod-mult" type="text"></td>
                                    </tr>
                                    <tr>
                                        <td>$5.000</td>
                                        <td>x</td>
                                        <td><input class="input-sumador multiplo" type="text"></td>
                                        <td>=</td>
                                        <td><input class="input-sumador prod-mult" type="text"></td>
                                    </tr>
                                    <tr>
                                        <td>$2.000</td>
                                        <td>x</td>
                                        <td><input class="input-sumador multiplo" type="text"></td>
                                        <td>=</td>
                                        <td><input class="input-sumador prod-mult" type="text"></td>
                                    </tr>
                                    <tr>
                                        <td>$1.000</td>
                                        <td>x</td>
                                        <td><input class="input-sumador multiplo" type="text"></td>
                                        <td>=</td>
                                        <td><input class="input-sumador prod-mult" type="text"></td>
                                    </tr>
                                    <tr>
                                        <td>$500</td>
                                        <td>x</td>
                                        <td><input class="input-sumador multiplo" type="text"></td>
                                        <td>=</td>
                                        <td><input class="input-sumador prod-mult" type="text"></td>
                                    </tr>
                                    <tr>
                                        <td>$100</td>
                                        <td>x</td>
                                        <td><input class="input-sumador multiplo" type="text"></td>
                                        <td>=</td>
                                        <td><input class="input-sumador prod-mult" type="text"></td>
                                    </tr>
                                    <tr>
                                        <td>$50</td>
                                        <td>x</td>
                                        <td><input class="input-sumador multiplo" type="text"></td>
                                        <td>=</td>
                                        <td><input class="input-sumador prod-mult" type="text"></td>
                                    </tr>
                                    <tr>
                                        <td>$10</td>
                                        <td>x</td>
                                        <td><input class="input-sumador multiplo" type="text"></td>
                                        <td>=</td>
                                        <td><input class="input-sumador prod-mult" type="text"></td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                        
                        
                        
                        
                        <!-- fin sumador de efectivo -->
                        
                        <div class="row">
                            <div class="col">Entrega:</div>
                            <div id="div-input-entrega" class="col"><input id="input-entrega" class="inputs-bal"  type="text"></div>
                        </div>
                        <div class="row">
                            <div class="col">Balance:</div>
                            <div class="col"><input id="input-balance" class="inputs-bal" type="text" readonly></div>
                        </div>
                    </div>

                </div>

            </div>
            <div class="col">
        </div>
    </div>







</div>






<?php include_once $ruta . "includes/footer.php" ?>