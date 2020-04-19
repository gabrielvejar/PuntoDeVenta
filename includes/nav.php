

<style>

    #nav-bar {
        /* background-color: teal !important; */
        background-color: #095064;
        box-shadow: 0rem 0.5625rem 0.4375rem 0.0125rem rgba(0,0,0,0.2);
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

<?php  if ($_SESSION['permisos']['meson'] =='t') { ?>
                <li class="nav-item">
                    <a class="nav-link" href="<?php echo $ruta?>ventas/meson/venta_meson.php">Mesón</a>
                </li>
<?php } ?>



            </ul>
            <form class="form-inline my-2 my-lg-0">
                <ul class="navbar-nav mr-auto">
                    <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle" href="#" id="menuDesplegable" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false"><i class="fa fa-user" aria-hidden="true"></i> <?php echo $_SESSION['usuario']['nombre'] ?></a>
                            <div class="dropdown-menu drop2" aria-labelledby="menuDesplegable">
                                <a class="dropdown-item" href="<?php echo $ruta?>login/main_app/logout.php"><i class="fa fa-sign-out" aria-hidden="true"></i> Cerrar Sesión</a>
                            </div>
                    </li>
                </ul>
            </form>
        </div>
    </nav>
    <!-- productos/listaproducto/listaproducto.php -->