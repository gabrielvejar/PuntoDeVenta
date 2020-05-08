<?php 

$titulo = "Agregar usuario - Punto de Venta";
$css = "estilosnuevousuario.css";

$ruta = "";
while (!(file_exists ($ruta . "index.php"))) {
    $ruta = "../" . $ruta;
}

include_once $ruta . "includes/header.php";

include_once $ruta . "db/conexion.php";

// validar que usuario tenga permiso para acceder a pagina
if ($_SESSION['permisos']['mantenedor_usuarios'] !='t') {
    header('Location: '.$ruta);
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

$id = "";
if (isset($_REQUEST['id'])) {
    if ($_REQUEST['id'] != ''){
        $id = $_REQUEST['id'];
    } 
} 
?>


<div id="contenedor" class="container lam">
    
    <input type="hidden" name="id_user" id="id_user" value="<?php echo $id ?>">

    <h1><i class="fa fa-user-plus" aria-hidden="true"></i> <span id="titulo">Agregar nuevo usuario</span></h1>

    <div class="row">
        <div class="col"></div>
    
        <div id="div-formulario-usuario" class="col-md-6">
            <form autocomplete="off">
                <div class="form-group">
                    <label for="inputNombre">Nombre</label>
                    <input type="text" class="form-control" id="inputNombre" placeholder="Nombre Apellido">
                </div>
                <div class="form-group">
                    <label for="inputUsername">Nombre de usuario</label>
                    <input type="text" class="form-control" id="inputUsername" placeholder="Nombre de usuario">
                </div>
                <div class="form-group">
                    <label for="inputPassword">Contraseña</label>
                    <input type="password" class="form-control" id="inputPassword" placeholder="Contraseña">
                </div>
                <div class="form-group">
                    <label for="selectPerfil">Perfil</label>
                    <select class="form-control" id="selectPerfil" required>
                        <option>-Seleccione una opción-</option>
                    </select>
                </div>
            </form>
            <button id="agregar" class="btn btn-primary">Agregar</button>
        </div>
    
        <div class="col"></div>
    </div>







</div>






<?php include_once $ruta . "includes/footer.php" ?>