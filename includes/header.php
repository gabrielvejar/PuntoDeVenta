<?php 


$ruta2 = "";
if (file_exists ("index.php")) {
    $ruta2 = "js/";
}

    session_start();

    if(!isset($_SESSION['usuario'])) {
        header('Location: ' .$ruta. 'index.php');
    }


    $sidebar = 0;



?>


<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="ie=edge"><link rel="stylesheet" href="<?php echo $ruta ?>css/normalize.css">
    <link rel="stylesheet" href="<?php echo $ruta ?>css/bootstrap2.min.css">
    <link rel="stylesheet" href="<?php echo $ruta ?>css/estilos.css">
    <link rel="stylesheet" href="<?php echo $ruta ?>css/animate.css">
    <!-- <link rel="stylesheet" href="<?php echo $ruta ?>css/font-awesome.min.css"> -->
    <link rel="stylesheet" href="<?php echo $ruta ?>css/normalize.css">
    <?php if ($css != "") {
        echo '<link rel="stylesheet" href="'.$ruta2.$css.'?v='.rand().'">';
    } ?>
    <title> <?php echo $titulo ?></title>
    <meta name="viewport" content="width=device-width">
    <meta name="mobile-web-app-capable" content="yes">
    <link rel="icon" href="<?php echo $ruta ?>img/logopanaderia.png" type="image/png" sizes="16x16">


    <script src="<?php echo $ruta?>js/jquery.min.js"></script>
    <script src="<?php echo $ruta?>js/jquery-ui.js"></script>
    <link rel="stylesheet" href="<?php echo $ruta?>css/jquery-ui.css">

    <link rel="stylesheet" href="<?php echo $ruta?>css/iconate.min.css">
    <script type="text/javascript" src="<?php echo $ruta?>js/iconate.js"></script>


    <!-- fontawesome5 -->
    <!-- <link href="<?php echo $ruta?>vendor/fontawesome5/css/fontawesome.min.css" rel="stylesheet">
    <link href="<?php echo $ruta?>vendor/fontawesome5/css/brands.min.css" rel="stylesheet">
    <link href="<?php echo $ruta?>vendor/fontawesome5/css/solid.min.css" rel="stylesheet"> -->
    <link href="<?php echo $ruta?>vendor/fontawesome5/css/all.css" rel="stylesheet">
    <!-- <script defer src="<?php echo $ruta?>vendor/fontawesome5/js/all.js"></script> -->
    <!-- fin fontawesome5 -->
    

</head>
<!-- <body class="animated fadeIn faster"> -->
<body class="">

<input type="hidden" id="ruta" value="<?php echo $ruta?>">

<?php //include $ruta . "includes/nav.php"; ?>