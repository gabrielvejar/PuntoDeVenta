<?php 
$titulo = "Inicio - Punto de Venta";
$css ="";
$ruta = "";
while (!(file_exists ($ruta . "index.php"))) {
    $ruta = "../" . $ruta;
}

include_once "includes/header.php";
?>


<a class="iframe" data-fancybox data-type="iframe" data-src="productos/listaproducto/listaproducto.php" href="javascript:;">
    <button class="btn btn-primary">Lista de Productos</button>
</a>
<a class="iframe" data-fancybox data-type="iframe" data-src="productos/IUproducto/IUproducto.php?producto=1" href="javascript:;">
<button class="btn btn-primary">Agregar Producto</button>
</a>


<?php include_once "includes/footer.php"; ?>