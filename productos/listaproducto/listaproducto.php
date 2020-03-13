<?php 


$titulo = "Productos - Punto de Venta";
$css = "estilosproducto.css";

$ruta = "";
while (!(file_exists ($ruta . "index.php"))) {
    $ruta = "../" . $ruta;
}

include_once $ruta . "includes/header.php";

include_once $ruta . "db/conexion.php";

//paginacion



?>

<!-- 
<div id="div-flotante">
    boton
</div> -->

    <div class="container">


        <div id="encabezado" class=" mt-5">
            <h1 class="text-center">Lista de Productos</h1>
        </div>

        <div class="container mt-4" align="center">
                <a class="iframe" data-fancybox data-type="iframe" data-src="<?php echo $ruta?>productos/IUproducto/IUproducto.php?producto=1" href="javascript:;">
                    <button class="btn btn-primary ">Agregar Producto <i class="fa fa-plus" aria-hidden="true"></i></button>
                </a>
        </div>

        <a class="" data-toggle="collapse" href="#filtros" role="button" aria-expanded="false" aria-controls="filtros" style="text-decoration: none; color:white;">
            <div class="row d-flex justify-content-center mt-4">
                <h5 >Filtrar</h5>
            </div>
        </a>
        
            <div id="filtros" class="form-group collapse">

                <div class="row align-items-end d-flex justify-content-between">
                    <div class="col-sm">
                        <label for="codigo">Código</label> <input type="number" name="codigo" id="codigo" class="form-control" onkeyup="filtroCodigo()">
                    </div>
                    <div class="col-sm">
                        <label for="categoria">Categoría </label> <select name="categoria" id="categoria" class="form-control" onchange="ir(1)"></select>
                    </div>
                    <div class="col-sm">
                        <label for="nombre">Nombre </label> <input type="text" name="nombre" id="nombre" class="form-control" onkeyup="ir(1)">
                    </div>
                    <div class="col-sm">
                        <label for=""></label><button type="button" class="btn btn-secondary mx-2" onclick="limpiarFiltros()">Limpiar</button>
                    </div>




                </div>
                
            </div>


        <!-- <h5>Filtros</h5>
        <div id="filtros" class="form-inline">
                    <label for="codigo">Código</label> <input type="text" name="codigo" id="codigo" class="form-control" onkeyup="filtroCodigo()">

                    <label for="categoria">Categoría </label> <select name="categoria" id="categoria" class="form-control" onchange="ir(1)"></select>

                    <label for="nombre">Nombre </label> <input type="text" name="nombre" id="nombre" class="form-control" onkeyup="ir(1)">

                    <label for=""></label><button type="button" class="btn btn-secondary mx-2" onclick="limpiarFiltros()">Limpiar</button>

        </div> -->

        <div id="div-tabla-productos" class="mb-5">
            <table class="table table-hover table-sm" id="tableId">
                <thead class="">
                    <tr>
                        <th id="col-codbarras">Código</th> 
                        <th>Categoría</th>
                        <th id="col-nombre">Nombre</th>
                        <th>Precio</th>
                        <th id="col-accion">Acción</th>
                    </tr>
                </thead>
                <tbody  id="tabla-productos">
                </tbody>
            </table>
        </div>


    <!-- paginacion con ajax -->
        <div id="paginacion" class="text-center">
            <nav aria-label="...">
                <ul id=ul-paginacion class="pagination">
                </ul>
            </nav>
        </div>
    </div>







    <input type="hidden" id="paginaactual" name="paginaactual" value="1" />
    <input type="hidden" id="prodxpag" name="prodxpag" value="15" />

    


<?php include_once $ruta . "includes/footer.php" ?>