

<style>

    #nav-bar {
        background-color: darkcyan;
    }

    .drop2 {
    left: unset;
    right: 0;
    }
/*media query telefono */

</style>
<nav id="nav-bar" class="navbar navbar-expand-md navbar-dark fixed-top">
        <a class="navbar-brand" href="<?php echo $ruta?>"><img src="<?php echo $ruta?>img/logopanaderia.PNG" alt="" style="width: 40px;     border-radius: 4px;"> Panadería Mingo</a>
        <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#miNavbar" aria-controls="miNavbar" aria-expanded="false" aria-label="Mostrar u ocultar menú">
        <span class="navbar-toggler-icon"></span>
      </button>

        <div class="collapse navbar-collapse" id="miNavbar">
            <ul class="navbar-nav mr-auto">
                <li class="nav-item">
                    <a class="nav-link" href="<?php echo $ruta?>">Inicio</a>
                </li>
                <li class="nav-item">
                <a class="nav-link" href="<?php echo $ruta?>ventas/caja/caja.php">Caja</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="<?php echo $ruta?>ventas/meson/venta_meson.php">Mesón</a>
                </li>
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle" href="#" id="menuDesplegable" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">Administrar</a>
                    <div class="dropdown-menu" aria-labelledby="menuDesplegable">

                        <a class="dropdown-item" href="<?php echo $ruta?>productos/listaproducto/listaproducto.php">Productos</a>
                        <!-- <a class="dropdown-item" href="#">2</a> -->
                    </div>
                </li>
            </ul>
            <form class="form-inline my-2 my-lg-0">
                <ul class="navbar-nav mr-auto">
                    <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle" href="#" id="menuDesplegable" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false"><?php echo $_SESSION['usuario']['nombre'] ?></a>
                            <div class="dropdown-menu drop2" aria-labelledby="menuDesplegable">
                                <a class="dropdown-item" href="<?php echo $ruta?>login/main_app/logout.php">Cerrar Sesión</a>
                            </div>
                    </li>
                </ul>
            </form>
        </div>
    </nav>
    <!-- productos/listaproducto/listaproducto.php -->