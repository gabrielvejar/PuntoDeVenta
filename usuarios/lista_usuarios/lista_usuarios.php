<?php 

$titulo = "Usuarios - Punto de Venta";
$css = "estilosusuarios.css";

$ruta = "";
while (!(file_exists ($ruta . "index.php"))) {
    $ruta = "../" . $ruta;
}


include_once $ruta . "includes/header.php";

include_once $ruta . "db/conexion.php";


// validar que usuario tenga permiso para acceder a pagina
if ($_SESSION['permisos']['mantenedor_usuarios'] !='t') {
    die();
 }


?>

<?php //include $ruta . "includes/nav.php"; ?>

<?php 
$id_venta_temp = 0;

if(isset($_REQUEST['id'])) {
    $id_venta_temp = $_REQUEST['id'];
}

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




<input type="hidden" id="id_venta_temp" value="<?php echo $id_venta_temp?>">

<div id="contenedor" class="container lam">


    <h1><i class="fa fa-users" aria-hidden="true"></i> Usuarios</h1>

    

    <div class="row">
        <!-- <div class="col"></div> -->



        <div id="div-tbl-usuarios" class="col">
            <table class="table table-hover">
                <thead>

                    <tr>
                    <th scope="col">Nombre</th>
                    <th scope="col">Nombre de usuario</th>
                    <th scope="col">Perfil</th>
                    <th scope="col">Acciones</th>
                    </tr>
                </thead>
                <tbody id="tbody_usuarios">
                    <!-- <tr>
                    <th scope="row">1</th>
                    <td>Mark</td>
                    <td>Otto</td>
                    <td>@mdo</td>
                    <td>@mdo</td>
                    <td>@mdo</td>
                    <td>@mdo</td>
                    <td>@mdo</td>
                    </tr> -->
                </tbody>
            </table>
        </div>
    
        <!-- <div class="col"></div> -->
    </div>
    
    <button id="nuevo_usuario" class="btn btn-primary">Nuevo Usuario</button>






</div>






<?php include_once $ruta . "includes/footer.php" ?>