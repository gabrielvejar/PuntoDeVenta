<?php

$tipo_usuario = $_SESSION['usuario']['tipo_usuario'];

$query = "SELECT 
  tipo_usuario,
  caja,
  meson,
  mantenedor_productos,
  mantenedor_usuarios
FROM 
  public.perfiles_usuario WHERE tipo_usuario = $1";

  

