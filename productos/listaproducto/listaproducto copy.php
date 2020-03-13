<?php 


$titulo = "Productos - Punto de Venta";
$css = "estilosproducto.css";

$ruta = "";
while (!(file_exists ($ruta . "index.php"))) {
    $ruta = "../" . $ruta;
}

include_once $ruta . "includes/header.php";

include_once $ruta . "db/conexion.php";

?>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
<style>
body { width: 100%; height: 100%; }
.btn-group-fab {
  position: fixed;
  width: 50px;
  height: auto;
  right: 20px; bottom: 20px;
}
.btn-group-fab div {
  position: relative; width: 100%;
  height: auto;
}
.btn-group-fab .btn {
  position: absolute;
  bottom: 0;
  border-radius: 50%;
  display: block;
  margin-bottom: 4px;
  width: 40px; height: 40px;
  margin: 4px auto;
}
.btn-group-fab .btn-main {
  width: 50px; height: 50px;
  right: 50%; margin-right: -25px;
  z-index: 9;
}
.btn-group-fab .btn-sub {
  bottom: 0; z-index: 8;
  right: 50%;
  margin-right: -20px;
  -webkit-transition: all 2s;
  transition: all 0.5s;
}
.btn-group-fab.active .btn-sub:nth-child(2) {
  bottom: 60px;
}
.btn-group-fab.active .btn-sub:nth-child(3) {
  bottom: 110px;
}
.btn-group-fab.active .btn-sub:nth-child(4) {
  bottom: 160px;
}
.btn-group-fab .btn-sub:nth-child(5) {
  bottom: 210px;
}
</style>


    <div id="encabezado" class="container mt-5">
        <h1 align="center">Lista de Productos</h1>
    </div>
    <div class="container mt-4" align="center">
            <a class="iframe" data-fancybox data-type="iframe" data-src="<?php echo $ruta?>productos/IUproducto/IUproducto.php?producto=1" href="javascript:;">
                <button class="btn btn-primary">Agregar Producto</button>
            </a>
    </div>

    <div id="div-tabla-productos" class="container mt-5 mb-5">
        <table class="table table-hover" id="tableId">
            <thead class="">
                <tr>
                    <th id="col-codbarras">Cód. Barras</th> 
                    <th>Categoría</th>
                    <th id="col-nombre">Nombre Producto</th>
                    <th>Unidad</th>
                    <th>Precio</th>
                </tr>
            </thead>
            <tbody  id="tabla-productos">
            </tbody>
        </table>
    </div>
    <!-- <a class="iframe" data-fancybox data-type="iframe" data-src="<?php echo $ruta?>productos/IUproducto/IUproducto.php?producto=1" href="javascript:;">
        <button class="btn btn-primary">Agregar Producto</button>
    </a> -->

    <!-- modal -->
    <div id="modal-exito" class="modal fade" tabindex="-1" role="dialog">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Buena!</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <p>Producto guardado con éxito</p>
            </div>
            <div class="modal-footer">
                <!-- <button type="button" class="btn btn-primary">Save changes</button> -->
                <button type="button" class="btn btn-primary" data-dismiss="modal">Cerrar</button>
            </div>
            </div>
        </div>
    </div>
    <!-- fin modal -->


    <!-- menu flotante -->
    <!-- <div class="btn-group-fab" role="group" aria-label="FAB Menu">
        <div>
            <button type="button" class="btn btn-main btn-primary has-tooltip" data-placement="left" title="Menu"> <i class="fa fa-bars"></i> </button>
            
                <button type="button" class="btn btn-sub btn-info has-tooltip" data-placement="left" title="Fullscreen"> <i class="fa fa-plus"></i></button>
            
            <!-- <button type="button" class="btn btn-sub btn-danger has-tooltip" data-placement="left" title="Save"> <i class="fa fa-floppy-o"></i> </button>
            <button type="button" class="btn btn-sub btn-warning has-tooltip" data-placement="left" title="Download"> <i class="fa fa-download"></i> </button>
        </div>
    </div> -->
    <!-- fin menu flotante -->

    




<?php include_once $ruta . "includes/footer.php" ?>