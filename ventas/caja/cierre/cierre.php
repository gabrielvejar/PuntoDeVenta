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


    <h1><i class="fa fa-bar-chart" aria-hidden="true"></i> Cierre de Caja ID: <?php echo $_SESSION['apertura']['id_apertura'] ?> / <?php echo date('d-m-Y') ?></h1>



    <div class="row">
        <div class="col">
            </div>
            <div class="col-md-8">
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th scope="col">#</th>
                            <th scope="col">Detalle</th>
                            <th scope="col">Valor</th>
                            <th scope="col"></th>
                        </tr>
                    </thead>
                    <tbody>
                    <tr>
                        <!-- TODO enlazar a vistas reales -->
                            <th scope="row">1</th>
                            <td>Efectivo Apertura</td>
                            <td id="td-efectivo-apertura"></td>
                            <td><a class="iframe" data-fancybox data-type="iframe" data-src="<?php echo $ruta?>productos\listaproducto\listaproducto.php" href="javascript:;">Ver más</a></td>
                        </tr>
                        <tr>
                            <th scope="row">2</th>
                            <td>Ventas Efectivo</td>
                            <td id="td-ventas-efectivo">500000</td>
                            <td><a class="iframe" data-fancybox data-type="iframe" data-src="<?php echo $ruta?>productos\listaproducto\listaproducto.php" href="javascript:;">Ver más</a></td>
                        </tr>
                        <tr>
                            <th scope="row">3</th>
                            <td>Ventas Tarjeta</td>
                            <td id="td-ventas-tarjeta">0</td>
                            <td><a class="iframe" data-fancybox data-type="iframe" data-src="<?php echo $ruta?>productos\listaproducto\listaproducto.php" href="javascript:;">Ver más</a></td>
                        </tr>
                        <tr>
                            <th scope="row">4</th>
                            <td>Gastos</td>
                            <td id="td-gastos">12312213</td>
                            <td><a class="iframe" data-fancybox data-type="iframe" data-src="<?php echo $ruta?>ventas\caja\gastos\gastos\gastos.php?nav=0" href="javascript:;">Ver más</a></td>
                        </tr>
                    
                    </tbody>
                </table>


                <div id="div-balance" class="row">
                    <div class="col"></div>
                    <div id="divinputs" class="col-md-8">
                        <div class="row">
                            <div id="efectivocierrel" class="col"><a data-toggle="collapse" href="#div-sumador"><i class="fa fa-calculator" id="icon-calc" aria-hidden="true" title="Sumador de efectivo"></i></a> Efectivo Cierre:</div>
                            <div class="col"><input id="input-efectivo" class="inputs-bal" type="text"></div>
                        </div>


                        <!-- sumador de efectivo -->

                        <div id="div-sumador" class="collapse">
                            <div id="titulo-sumador">Sumador de efectivo</div>
                            <table id="tbl-sumador" class="table table-hover">
                                <tbody>
                                    <tr>
                                        <td class="pt">$20.000</td>
                                        <td class="pt">x</td>
                                        <td><input id="mult-20mil" class="input-sumador multiplo" type="number"></td>
                                        <td class="pt">=</td>
                                        <td><input id="prod-20mil" class="input-sumador prod-mult" type="text"></td>
                                    </tr>
                                    <tr>
                                        <td class="pt">$10.000</td>
                                        <td class="pt">x</td>
                                        <td><input id="mult-10mil" class="input-sumador multiplo" type="number"></td>
                                        <td class="pt">=</td>
                                        <td><input id="prod-10mil" class="input-sumador prod-mult" type="text"></td>
                                    </tr>
                                    <tr>
                                        <td class="pt">$5.000</td>
                                        <td class="pt">x</td>
                                        <td><input id="mult-5mil" class="input-sumador multiplo" type="number"></td>
                                        <td class="pt">=</td>
                                        <td><input id="prod-5mil" class="input-sumador prod-mult" type="text"></td>
                                    </tr>
                                    <tr>
                                        <td class="pt">$2.000</td>
                                        <td class="pt">x</td>
                                        <td><input id="mult-2mil" class="input-sumador multiplo" type="number"></td>
                                        <td class="pt">=</td>
                                        <td><input id="prod-2mil" class="input-sumador prod-mult" type="text"></td>
                                    </tr>
                                    <tr>
                                        <td class="pt">$1.000</td>
                                        <td class="pt">x</td>
                                        <td><input id="mult-1mil" class="input-sumador multiplo" type="number"></td>
                                        <td class="pt">=</td>
                                        <td><input id="prod-1mil" class="input-sumador prod-mult" type="text"></td>
                                    </tr>
                                    <tr>
                                        <td class="pt">$500</td>
                                        <td class="pt">x</td>
                                        <td><input id="mult-500" class="input-sumador multiplo" type="number"></td>
                                        <td class="pt">=</td>
                                        <td><input id="prod-500" class="input-sumador prod-mult" type="text"></td>
                                    </tr>
                                    <tr>
                                        <td class="pt">$100</td>
                                        <td class="pt">x</td>
                                        <td><input id="mult-100" class="input-sumador multiplo" type="number"></td>
                                        <td class="pt">=</td>
                                        <td><input id="prod-100" class="input-sumador prod-mult" type="text"></td>
                                    </tr>
                                    <tr>
                                        <td class="pt">$50</td>
                                        <td class="pt">x</td>
                                        <td><input id="mult-50" class="input-sumador multiplo" type="number"></td>
                                        <td class="pt">=</td>
                                        <td><input id="prod-50" class="input-sumador prod-mult" type="text"></td>
                                    </tr>
                                    <tr>
                                        <td class="pt">$10</td>
                                        <td class="pt">x</td>
                                        <td><input id="mult-10" class="input-sumador multiplo" type="number"></td>
                                        <td class="pt">=</td>
                                        <td><input id="prod-10" class="input-sumador prod-mult" type="text"></td>
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
                        <div id="div-icono-balance">
                            <!-- TODO icono animación cambio signo -->
                            <!-- <input type="checkbox" name="chk-cambio" id="chk-cambio"> -->
                            <i id="icon-balance" class="fa" aria-hidden="true"></i>
                        </div>

                        <div>
                            <button id="btn-cierre" class="btn btn-secondary">Realizar cierre de caja</button>
                        </div>
                    </div>

                </div>

            </div>
            <div class="col">
        </div>
    </div>







</div>






<?php include_once $ruta . "includes/footer.php" ?>