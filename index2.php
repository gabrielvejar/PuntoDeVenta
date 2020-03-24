<?php 
$titulo = "Inicio - Punto de Venta";
$css ="";
$ruta = "";
while (!(file_exists ($ruta . "index.php"))) {
    $ruta = "../" . $ruta;
}

include_once "includes/header.php";
?>
<div>
    <span>Bienvenido <?php echo $_SESSION['usuario']['nombre'] ?></span><span> - </span><span><a href="<?php echo $ruta?>login/main_app/logout.php">Cerrar Sesión</a></span>
</div>

<a class="iframe" data-fancybox data-type="iframe" data-src="productos/listaproducto/listaproducto.php" href="javascript:;">
    <button class="btn btn-primary">Lista de Productos</button>
</a>
<a class="iframe" data-fancybox data-type="iframe" data-src="productos/IUproducto/IUproducto.php?producto=1" href="javascript:;">
<button class="btn btn-primary">Agregar Producto</button>
</a>
<a href="ventas/meson/venta_meson.php"><button class="btn btn-primary">Nueva Venta</button></a>
<a href="ventas\caja\venta_caja.php"><button class="btn btn-primary">Caja</button></a>


<?php include_once "includes/footer.php"; ?>