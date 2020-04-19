<?php 

$titulo = "Cierre de caja - Punto de Venta";
$css = "estiloscierre.css";

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

<div id="contenedor" class="container lam">


    <h1><i class="fas fa-money-check-alt"></i> Cierre de Caja</h1>
    <h4>Caja ID: <?php echo $_SESSION['apertura']['id_apertura'] ?> / <?php echo date('d-m-Y') ?></h4>



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
                            <td><a id="enlace-apertura" class="cursor" onclick="valoresApertura ();">Ver más</a></td>
                        </tr>
                        <tr>
                            <th scope="row">2</th>
                            <td>Ventas Efectivo</td>
                            <td id="td-ventas-efectivo">500000</td>
                            <td><a class="iframe" data-fancybox data-type="iframe" data-src="<?php echo $ruta?>ventas\registro_ventas\registro_ventas.php?id=<?php echo $_SESSION['apertura']['id_apertura'] ?>&sb=no" href="javascript:;">Ver más</a></td>
                        </tr>
                        <tr>
                            <th scope="row">3</th>
                            <td>Ventas Tarjeta</td>
                            <td id="td-ventas-tarjeta">0</td>
                            <td><a class="iframe" data-fancybox data-type="iframe" data-src="<?php echo $ruta?>ventas\registro_ventas\registro_ventas.php?id=<?php echo $_SESSION['apertura']['id_apertura'] ?>&sb=no" href="javascript:;">Ver más</a></td>
                            </tr>
                        <tr>
                            <th scope="row">4</th>
                            <td>Gastos</td>
                            <td id="td-gastos">12312213</td>
                            <td><a class="iframe" data-fancybox data-type="iframe" data-src="<?php echo $ruta?>ventas\caja\gastos\gastos\gastos.php?id=<?php echo $_SESSION['apertura']['id_apertura'] ?>&sb=no" href="javascript:;">Ver más</a></td>
                        </tr>
                        <tr>
                            <th scope="row">4</th>
                            <td>Dinero en custodia</td>
                            <!-- TODO valor dinero en custodia -->
                            <td id="td-custodia">12312213</td>
                            <td><a class="iframe" data-fancybox data-type="iframe" data-src="<?php echo $ruta?>ventas\caja\gastos\dinero_en_custodia\custodia.php?sb=no" href="javascript:;">Ver más</a></td>
                        </tr>
                    
                    </tbody>
                </table>


                <div id="div-balance" class="row">
                    <div id="div-icono-balance" class="col">
                        <i id="icon-balance" class="fa" aria-hidden="true"></i>
                    </div>
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

                            <!-- <i id="icon-balance" class="fa" aria-hidden="true"></i> -->

                            <audio id="audio-bien" class="audios" controls>
                                <source type="audio/wav" src="<?php echo $ruta ?>sound/bien.wav"> 
                            </audio>

                            <audio id="audio-mal" class="audios" controls>
                                <source type="audio/wav" src="<?php echo $ruta ?>sound/mal.wav"> 
                            </audio>

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