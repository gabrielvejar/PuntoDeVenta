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
    <!-- <meta name="viewport" content="width=device-width, initial-scale=1.0"> -->
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <!-- <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css" integrity="sha384-Vkoo8x4CGsO3+Hhxv8T/Q5PaXtkKtu6ug5TOeNV6gBiFeWPGFN9MuhOf23Q9Ifjh" crossorigin="anonymous"> -->
    <link rel="stylesheet" href="<?php echo $ruta ?>css/normalize.css">
    <link rel="stylesheet" href="<?php echo $ruta ?>css/bootstrap2.min.css">
    <link rel="stylesheet" href="<?php echo $ruta ?>css/estilos.css">
    <!-- <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css"> -->
    <link rel="stylesheet" href="<?php echo $ruta ?>css/font-awesome.min.css">
    <link rel="stylesheet" href="<?php echo $ruta ?>css/normalize.css">
    <link rel="stylesheet" href="<?php echo $css ?>">
    <title> <?php echo $titulo ?></title>
    <meta name="viewport" content="width=device-width">
    <!-- <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" /> -->
    <meta name="mobile-web-app-capable" content="yes">

</head>
<body>
