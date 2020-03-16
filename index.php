<?php 
    session_start();

    if(isset($_SESSION['usuario'])) {
        header('Location: index2.php');
    }


?>


<!DOCTYPE html>
<html lang="es">
  <head>
    <meta charset="utf-8">
    <title>Login</title>
    <link rel="stylesheet" href="login/css/main.css">
  </head>
  <body>
    <div class="error">
      <span>Datos de ingreso no válidos, inténtelo de nuevo  por favor</span>
    </div>
    <div class="main">
     <form action="" id="formLg">
        <input type="text" name="usuariolg"  placeholder="Usuario" required>
        <input type="password" name="passlg"  placeholder="Contraseña" required>
        <input type="submit" class="botonlg"  value="Iniciar Sesión" >
     </form>
    </div>
    <script src="login/js/jquery-3.3.1.min.js"></script>
    <script src="login/js/main.js"></script>
  </body>
</html>
