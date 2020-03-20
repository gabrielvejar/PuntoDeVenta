<?php 


$titulo = "Mesón - Punto de Venta";
$css = "estilosmeson.css";

$ruta = "";
while (!(file_exists ($ruta . "index.php"))) {
    $ruta = "../" . $ruta;
}

include_once $ruta . "includes/header.php";

include_once $ruta . "db/conexion.php";



?>

    <span>Bienvenido <?php echo $_SESSION['usuario']['nombre'] ?></span><span> - </span><span><a href="<?php echo $ruta?>login/main_app/logout.php">Cerrar Sesión</a></span>



<div id="contenedor" class="flex-container">


<div id="color">

    <div id="fila1" class="fila">
        <div id="div1-1">
            <input type="number" name="codigo" id="codigo"class="form-control w100" placeholder="Código">
            <input type="text" name="nombre" id="nombre"class="form-control w100" placeholder="Nombre">
            <input type="text" name="promo" id="promo"class="form-control w100" placeholder="Promoción">
        </div>
        <div id="div1-2">
            <img id ="img-producto" src="https://i.pinimg.com/600x315/bf/b7/c5/bfb7c5575cedcd742b4e6eb7937921ea.jpg" alt="">
        </div>
        <div id="div1-3">
            <button class="btn btn-primary">BUSCAR</button>
            <button class="btn btn-primary">BORRAR</button>
        </div>
    </div>




    <div id="fila2" class="fila">
        <div id="div2-1">
            <label for="">$</label><input type="number"><label for="">x</label><button class="btn btn-primary">-</button><input type="number" value="1"><button class="btn btn-primary">+</button>
        </div>
    </div>

    <div id="fila3" class="fila">
        <div id="div3-1">
        <label for="">$</label><input type="number"><button id="btn-agregar" class="btn btn-primary">AGREGAR</button>
        </div>
    </div>    

    <div id="fila4" class="fila">
        <div id="div4-1">
            <h4>Detalle</h4>
            <div id="div-tabla-detalle">

            <table class="table" id="tbl-detalle">
                    <thead>
                        <tr>
                            <th scope="col">#</th>
                            <th scope="col" id="col-nombre">Nombre</th>
                            <th scope="col">Precio Unitario</th>
                            <th scope="col">Cantidad</th>
                            <th scope="col">Total</th>
                        </tr>
                    </thead>
            
                    <tbody>
                        <tr>
                            <th scope="row">1</th>
                            <td>Pan Corriente</td>
                            <td>1300/kg</td>
                            <td>1.5</td>
                            <td>1950</td>
                        </tr>
                        <tr>
                            <th scope="row">2</th>
                            <td>Pan Corriente</td>
                            <td>1300/kg</td>
                            <td>1.5</td>
                            <td>1950</td>
                        </tr>
                        <tr>
                            <th scope="row">2</th>
                            <td>Pan Corriente</td>
                            <td>1300/kg</td>
                            <td>1.5</td>
                            <td>1950</td>
                        </tr>
                        <tr>
                            <th scope="row">2</th>
                            <td>Pan Corriente</td>
                            <td>1300/kg</td>
                            <td>1.5</td>
                            <td>1950</td>
                        </tr>
                        <tr>
                            <th scope="row">2</th>
                            <td>Pan Corriente</td>
                            <td>1300/kg</td>
                            <td>1.5</td>
                            <td>1950</td>
                        </tr>
                        <tr>
                            <th scope="row">2</th>
                            <td>Pan Corriente</td>
                            <td>1300/kg</td>
                            <td>1.5</td>
                            <td>1950</td>
                        </tr>
                        <tr>
                            <th scope="row">2</th>
                            <td>Pan Corriente</td>
                            <td>1300/kg</td>
                            <td>1.5</td>
                            <td>1950</td>
                        </tr>
                        <tr>
                            <th scope="row">2</th>
                            <td>Pan Corriente</td>
                            <td>1300/kg</td>
                            <td>1.5</td>
                            <td>1950</td>
                        </tr>
                        <tr>
                            <th scope="row">2</th>
                            <td>Pan Corriente</td>
                            <td>1300/kg</td>
                            <td>1.5</td>
                            <td>1950</td>
                        </tr>
                        <tr>
                            <th scope="row">2</th>
                            <td>Pan Corriente</td>
                            <td>1300/kg</td>
                            <td>1.5</td>
                            <td>1950</td>
                        </tr>
                        <tr>
                            <th scope="row">2</th>
                            <td>Pan Corriente</td>
                            <td>1300/kg</td>
                            <td>1.5</td>
                            <td>1950</td>
                        </tr>
                        <tr>
                            <th scope="row">2</th>
                            <td>Pan Corriente</td>
                            <td>1300/kg</td>
                            <td>1.5</td>
                            <td>1950</td>
                        </tr>
                        <tr>
                            <th scope="row">2</th>
                            <td>Pan Corriente</td>
                            <td>1300/kg</td>
                            <td>1.5</td>
                            <td>1950</td>
                        </tr>
                    </tbody>
                </table>
            </div>


        </div>
    </div>    

    <div id="fila5" class="fila">
        <div id="div5-1">
            <label for="">Total $</label><input type="number">
        </div>
    </div>    

    <div id="fila6" class="fila">
        <div id="div6-1">
        <button id="btn-imprimir" class="btn btn-success">IMPRIMIR</button>
        <button id="btn-cancelar" class="btn btn-danger">CANCELAR</button>
        </div>
    </div>    




</div>


</div> <!-- divcontenedor -->

<?php include_once $ruta . "includes/footer.php" ?>