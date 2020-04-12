<?php 

if ($sidebar == 1) {
        include $ruta . "includes/sidebarfin.php"; 
}

?>


    <script src="<?php echo $ruta?>js/popper.min.js"></script>
    <script src="<?php echo $ruta?>js/bootstrap.min.js"></script>
    <link rel="stylesheet" href="<?php echo $ruta?>css/jquery.fancybox.min.css" />
    <script src="<?php echo $ruta?>js/jquery.fancybox.min.js"></script>
    <script src="<?php echo $ruta?>js/bootbox.min.js"></script>
    <script src="<?php echo $ruta?>js/bootbox.locales.min.js"></script>
    <script src="<?php echo $ruta?>js/bootstrap-paginator.min.js"></script>

    <!-- moment js  -->
    <script src="<?php echo $ruta?>js/moment.js/2.24.0/moment.min.js"></script>
    <script src="<?php echo $ruta?>js/moment.js/2.24.0/locale/es-us.js"></script>

    <script src="<?php echo $ruta?>js/util.js?v=<?php echo rand() ?>"></script>
    <script src="<?php echo $ruta2?>Controlador.js?v=<?php echo rand() ?>"></script>

</body>
</html>