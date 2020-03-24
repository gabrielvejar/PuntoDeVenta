<?php 

$ruta = "";
while (!(file_exists ($ruta . "index.php"))) {
    $ruta = "../" . $ruta;
}

    session_start();

    if(!isset($_SESSION['usuario'])) {
        header('Location: ' .$ruta. 'index.php');
    }


?>


<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="ie=edge"><link rel="stylesheet" href="<?php echo $ruta ?>css/normalize.css">
    <link rel="stylesheet" href="<?php echo $ruta ?>css/bootstrap2.min.css">
    <link rel="stylesheet" href="<?php echo $ruta ?>css/estilos.css">
    <!-- <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css"> -->
    <link rel="stylesheet" href="<?php echo $ruta ?>css/font-awesome.min.css">
    <link rel="stylesheet" href="<?php echo $ruta ?>css/normalize.css">
    <?php if ($css != "") {
        echo '<link rel="stylesheet" href="'.$css.'?v='.rand().'">';
    } ?>
    <!-- <link rel="stylesheet" href="<?php echo $css ?>?v=<?php echo rand() ?>"> -->
    <title> <?php echo $titulo ?></title>
    <meta name="viewport" content="width=device-width">
    <meta name="mobile-web-app-capable" content="yes">
    <link rel="icon" href="<?php echo $ruta ?>img/logopanaderia.png" type="image/png" sizes="16x16">

</head>
<body>

