<?php 

$titulo = "Caja - Punto de Venta";
$css = "estilosapertura.css";

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


 
// verificar caja abierta
// $query     = "SELECT * FROM public.fn_verificar_caja_apertura()";
// $params    = array();
// $result    = pg_query_params($dbconn, $query, $params);

// $row = pg_fetch_row($result);

// $_SESSION['id_apertura']=$row['0'];


// if($_SESSION['id_apertura'] != "0") {
//     header('Location:'.$ruta.'ventas/caja/caja.php');
// }

$query     = "SELECT 
                    c.id_apertura,
                    c.fecha,
                    c.time_creado,
                    u.nombre
                    FROM 
                    public.caja_apertura c
                    INNER JOIN public.usuario u
                    ON c.id_usuario = u.id_usuario
                    WHERE cerrado IS NOT TRUE
                    LIMIT 1";

$params    = array();
$result    = pg_query_params($dbconn, $query, $params);

$_SESSION['apertura']="";
if (pg_num_rows($result)==1) {
    $datos = pg_fetch_assoc($result);
    $_SESSION['apertura'] = $datos;
}


if(isset($_SESSION['apertura']['id_apertura'])){
    header('Location:'.$ruta.'ventas/caja/caja.php');
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




<div class="container">
    <h1>Apertura de Caja</h1>
    <div id="" class="flex-container">
        <div id="formulario" class="lam">
                <form id="form-apertura" autocomplete="off">
                <div class="form-group">
                        <label for="input-fecha-uc">Fecha último cierre</label>
                        <input type="text" class="form-control" id="input-fecha-uc" readonly>
                    </div>
                    <div class="form-group">
                        <label for="inputEfectivoCierre">Efectivo último cierre</label>
                        <input type="text" class="form-control" id="inputEfectivoCierre" readonly>
                    </div>
                    <hr>
                    <div class="form-group">
                        <label for="input-fecha">Fecha apertura</label>
                        <input type="text" class="form-control" id="input-fecha" placeholder="<?php echo date("d-m-Y") ?>" required>
                    </div>
                    <div class="form-group">
                        <label for="inputEfectivo">Efectivo apertura</label>
                        <input type="text" class="form-control" id="inputEfectivo" required>
                        <small id="emailHelp" class="form-text text-muted">Ingrese cantidad de efectivo en caja.</small>
                    </div>
                    <button id="btn-abrir" class="btn btn-primary">Abrir Caja</button>
                </form>
        </div>
    </div>

</div>



<?php include_once $ruta . "includes/footer.php" ?>