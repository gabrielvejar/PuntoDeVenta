<?php 
$sidebar = 1; 

$id_apertura = 0;
if (isset($_SESSION['apertura']['id_apertura'])) {
    $id_apertura = $_SESSION['apertura']['id_apertura'];
}

?>

<div class="wrapper">
        <!-- Sidebar Holder -->
        <nav id="sidebar">
            <div class="sidebar-header">
                <!-- <h3>Bootstrap Sidebar</h3> -->
                <a class="navbar-brand" href="<?php echo $ruta?>"><img src="<?php echo $ruta?>img/logopanaderia.PNG" alt="" style="border-radius: 4px;"></a>
            </div>

            <ul class="list-unstyled components">
                <!-- <p>Menú</p> -->
                <li class="">
                    <a href="<?php echo $ruta?>"><i class="fa fa-home" aria-hidden="true"></i> Inicio</a>
                    <a href="#cajaSubmenu" data-toggle="collapse" aria-expanded="false" class="dropdown-toggle"><i class="fas fa-cash-register"></i> Caja</a>
                    <ul class="collapse list-unstyled" id="cajaSubmenu">
                        <li>
                            <a href="<?php echo $ruta?>ventas/caja/caja.php">Caja</a>
                        </li>




                        <?php if ($id_apertura != 0) {?>


                        <li class="">
                            <a href="#ventasSubmenu" data-toggle="collapse" aria-expanded="false" class="dropdown-toggle">Ventas</a>
                            <ul class="collapse list-unstyled" id="ventasSubmenu">
                                <li>
                                    <a href="<?php echo $ruta?>ventas/registro_ventas/registro_ventas.php?id=<?php echo $id_apertura ?>">Ventas pagadas</a>
                                </li>
                                <li>
                                    <a href="<?php echo $ruta?>ventas/registro_ventas/ventas_temp_anuladas/ventas_temp_anuladas.php?id_ap=<?php echo $id_apertura ?>">Ventas anuladas</a>
                                </li>
                            </ul>
                        </li>
                        <li class="">
                            <a href="#egresosSubmenu" data-toggle="collapse" aria-expanded="false" class="dropdown-toggle">Salidas de dinero</a>
                            <ul class="collapse list-unstyled" id="egresosSubmenu">
                                <li>
                                    <a href="<?php echo $ruta?>ventas/caja/gastos/gastos/gastos.php">Gastos</a>
                                </li>
                                <li>
                                    <a href="<?php echo $ruta?>ventas/caja/gastos/dinero_en_custodia/custodia.php">Dinero en custodia</a>
                                </li>
                            </ul>
                        </li>
                        <li>
                            <a href="<?php echo $ruta?>ventas/caja/cierre/cierre.php">Cierre de caja</a>
                        </li>

                        <?php } ?>



                    </ul>
                </li>
                <li>
                    <a href="<?php echo $ruta?>ventas/meson/venta_meson.php"><i class="fas fa-shopping-basket"></i> Mesón</a>
                </li>
                <li>
                    <a href="#mantSubmenu" data-toggle="collapse" aria-expanded="false" class="dropdown-toggle"><i class="fas fa-sliders-h"></i> Mantenedor</a>
                    <ul class="collapse list-unstyled" id="mantSubmenu">

                        <li>
                            <a href="#usuariosSubmenu" data-toggle="collapse" aria-expanded="false" class="dropdown-toggle"><i class="fas fa-user"></i> Usuarios</a>
                            <ul class="collapse list-unstyled" id="usuariosSubmenu">
                                <li>
                                    <a href="<?php echo $ruta?>usuarios/agregar_usuario/nuevo_usuario.php"><i class="fas fa-user-plus"></i> Agregar usuario</a>
                                </li>
                            </ul>
                        </li>

                        <li>

                        <li>
                            <a href="<?php echo $ruta?>productos\listaproducto\listaproducto.php"><i class="fas fa-box-open"></i> Productos</a>
                        </li>



                    </ul>
                </li>
                <li>
                    <a href="#usuarioSubmenu" data-toggle="collapse" aria-expanded="false" class="dropdown-toggle"><i class="fas fa-user"></i> <?php echo $_SESSION['usuario']['nombre'] ?></a>
                    <ul class="collapse list-unstyled" id="usuarioSubmenu">
                        <li>
                            <a href="<?php echo $ruta?>login/main_app/logout.php"><i class="fas fa-sign-out-alt"></i> Cerrar Sesión</a>
                        </li>
                    </ul>
                </li>
                
            </ul>
            
            <div>
                <p style="text-align: center; margin-left: 10px; font-size: 13px;">
                Creado con <i class="fa fa-heart" aria-hidden="true"></i> en cuarentena 2020<br>
                - Gabriel Vejar -
                </p>
            </div>
            
        </nav>

        <!-- Page Content Holder -->
        
        <div id="content" class ="animated slideInRight faster" animacion="slideInRight">
            <button type="button" id="sidebarCollapse" class="navbar-btn animated fadeIn delay-1s" animacion="fadeIn"><i class="fa fa-bars" aria-hidden="true"></i></button>