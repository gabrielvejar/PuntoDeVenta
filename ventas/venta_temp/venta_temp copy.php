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
<div>
    <span>Bienvenido <?php echo $_SESSION['usuario']['nombre'] ?></span><span> - </span><span><a href="<?php echo $ruta?>login/main_app/logout.php">Cerrar Sesión</a></span>
</div>


<!-- <div class="container contenedor"> -->
<!-- 
    <div class="row">
        <div class="col-9">
                <div class="row">
                    <div class="col-8">col-8 Lorem ipsum dolor sit amet consectetur adipisicing elit. Tenetur tempora temporibus voluptatibus ab et exercitationem delectus necessitatibus sed dolore? Animi, rerum laborum reprehenderit explicabo necessitatibus officia natus. Deleniti, quidem quia. Lorem ipsum dolor sit amet consectetur adipisicing elit. Assumenda quaerat illum a fugit optio expedita ipsa consequuntur animi atque ex neque, saepe, officiis eveniet provident necessitatibus quidem dolorem minus obcaecati.</div>
                    <div class="col-4">
                            <div class="row">
                                <div class="col-3">Lorem ipsum dolor sit amet consectetur adipisicing elit. Dolor, ullam. At animi nostrum incidunt magnam esse omnis nulla explicabo possimus totam provident odio enim officiis suscipit iste, assumenda architecto quia.</div>
                                <div class="col-6"><input type="text" name="cantidad" id="cantidad"></div>
                                <div class="col-3">Lorem ipsum dolor sit, amet consectetur adipisicing elit. Perferendis, sit laboriosam illum eos nostrum eius doloribus consequuntur perspiciatis omnis quo nam ut voluptates, in possimus tempora consectetur ab. Corrupti, recusandae!</div>
                            </div>
                            <div class="row"></div>
                            <div class="row"></div>
                    </div>
                </div>
        </div>
        <div class="col-3">col-4 Lorem ipsum dolor sit amet consectetur, adipisicing elit. Ipsa nostrum reiciendis atque neque. Dolor ipsam, cumque impedit in officiis unde labore aperiam, veniam dolore excepturi voluptatem fuga architecto rem fugit.</div>
    </div> -->

<!--     
        <table id = "tabla1">
            <tr>
                <td>
                    <table>
                        <tr>
                            <td>
                                <table>

                                    <tr> 
                                        <td>
                                            <label for="codigo">Código</label>
                                        </td>
                                        <td>
                                            <input type="number" name="codigo" id="codigo">
                                        </td>
                                    </tr>
                                    <tr> 
                                        <td>
                                            <label for="codigo">Nombre</label>
                                        </td>
                                        <td>
                                            <input type="text" name="codigo" id="codigo">
                                        </td>
                                    </tr>
                                    <tr> 
                                        <td>
                                            <label for="codigo">Precio Un.</label>
                                        </td>
                                        <td>
                                            <input type="text" name="codigo" id="codigo">
                                        </td>
                                    </tr>

                                </table>

                            </td>
                            <td><button onclick="document.getElementById('codigo').focus();">Agregar</button></td>
                        </tr>
                    </table>
                </td>
                <td id='imagen'></td>
            </tr>
        </table> -->


        <!-- style="max-width: 14rem;" -->




<!-- ultimo -->
<div id="color">

<table>
    <tr>
        <td  style="width:50%">
            <table>
                <tr>
                    <td style="width:50%">
                        <label for="codigo">Codigo</label>
                    </td>
                    <td>
                        <input type="number" name="codigo" id="codigo">
                    </td>
                </tr>
                <tr>
                    <td>
                        <label for="nombre">Nombre</label>
                    </td>
                    <td>
                        <input type="text" name="nombre" id="nombre">
                    </td>
                </tr>
                <tr>
                    <td>
                        <label for="precio">Precio Un.</label>
                    </td>
                    <td>
                        <input type="text" name="precio" id="precio">
                    </td>
                </tr>
                <tr>
                    <td>
                        <label for="promo">Promoción</label>
                    </td>
                    <td>
                        <button>Ver Promoción</button>
                    </td>
                </tr>
                <tr>
                    <td>
                        <label for="descripcion">Descripción</label>
                    </td>
                    <td>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <textarea id="descripcion" style="width:100%"></textarea>
                    </td>
                </tr>
            </table>
        </td>
        <td style="width:50%">
            <div class="flex-container">
                <img src="https://dummyimage.com/600x600/ff0000/fffff3.jpg&text=imagen" alt="" style="width: 50%">
            </div>
        </td>
    </tr>
    <tr>
        <td>
            
        </td>
        <td>
            asd     
        </td>
    </tr>



</table>



<!-- </div> -->


</div>

<?php include_once $ruta . "includes/footer.php" ?>