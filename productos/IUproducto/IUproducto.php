<?php 


$css ="estilosIUproducto.css";
$codigo = "";

$ruta = "";
while (!(file_exists ($ruta . "index.php"))) {
    $ruta = "../" . $ruta;
}



include_once $ruta . "includes/header.php";

include_once $ruta . "db/conexion.php";

// validar que usuario tenga permiso para acceder a pagina
if ($_SESSION['permisos']['mantenedor_productos'] !='t') {
    header('Location: '.$ruta);
 }

 

if (isset($_REQUEST['producto'])){
    if ($_REQUEST['producto'] == '1'){
        $accion = "Agregar";
        if (isset($_REQUEST['codigo'])){
            $codigo = $_REQUEST['codigo'] ;
        }
    } elseif ($_REQUEST['producto'] == '2') {
        $accion = "Modificar";
        if (isset($_REQUEST['codigo'])){
            $codigo = $_REQUEST['codigo'] ;
        }

        // $query     = "SELECT p.idproducto, p.nombreproducto, p.precio, p.imagen, p.idcategoria, p.idunidad
        // FROM public.producto p
        // WHERE p.codigodebarras = $1";
        // $params    = array($codigo);

        // $result    = pg_query_params($dbconn, $query, $params);

        // $filas      = array();

        // $row = pg_fetch_array($result);

        // echo $row['0'];

    } else {
        echo "Error";
        die();
    }
} else {
    echo "Error";
    die();
}


$titulo = $accion." Producto - Punto de Venta";

?>
<div id="wrapper-tabla" class="center container">

<h1><?php echo $accion ?> Producto</h1>




<form id="formulario" enctype="multipart/form-data" action="includes/send.php" method="POST">

    <table class="table table-hover" align="center">

        <tbody  id="formulario-producto">
        <input type="hidden" id="accion" name="accion" value="<?php echo $accion ?>" />
            <tr>
                <td><label for="codigo">Código de barras</label><br>
                <input type="number" name="codigo" id="codigo" class="form-control" required 
                <?php
                if ($codigo != "") {
                    echo 'value="'.$codigo . '" readonly ';
                }                
                ?>></td>
            </tr> 
            <tr>
                <td><label for="nombre">Nombre</label><br>
                <input type="text" name="nombre" id="nombre" class="form-control" required></td>
            </tr> 
            <tr>
                <td><label for="precio">Precio</label><br>
                <input type="number" name="precio" id="precio" class="form-control" required></td>
            </tr>
            <tr>
                <td><label for="unidad">Unidad</label><br>
                <select name="unidad" id="unidad" class="form-control" required> 
                </select>
            </tr>
            <tr>
                <td><label for="categoria">Categoría</label><br>
                <select name="categoria" id="categoria" class="form-control" required>
                </select>
                </td>
            </tr> 
            <tr>
                <td>
                    <div class="custom-control custom-switch">
                        <input type="checkbox" class="custom-control-input" id="inventariable" name="inventariable">
                        <label class="custom-control-label" for="inventariable">Inventariable</label>
                    </div>
                </td>
            </tr>
            <tr id="row-subir">
                <td><label for="fichero_usuario">Imagen (opcional - tamaño máximo 2 MB)</label><br>
                    <input type="hidden" name="MAX_FILE_SIZE" value="2000000" />
                    <input type="hidden" id="cambio-imagen" name="cambio-imagen" />
                    <input id="inp" name="fichero_usuario" type="file" accept="image/*" class="form-control-file" onchange="previewImage();" />
                    <div id="vistaprevia" style="display:none;">
                        <br>Vista previa:<br>
                        <img id="uploadPreview" src="" style="max-width: 50%;"/>
                    </div>
                    <br>
                </td>
            </tr>
            <tr>
                <td id="imagenactual"></td>
            </tr>


            <tr>
                <td>
                <input type="submit" value="Guardar Producto" class="btn btn-primary" />
                </td>
            </tr>
        </tbody>
    </table>
</form>

</div>

<?php include_once $ruta . "includes/footer.php" ?>