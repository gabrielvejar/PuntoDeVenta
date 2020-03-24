<?php


$ruta = "";
while (!(file_exists ($ruta . "index.php"))) {
    $ruta = "../" . $ruta;
}
require $ruta . "db/conexion.php";
 

$html = '';
$key = '%'.$_POST['key'].'%';
 
// $result = $connexion->query(
//     'SELECT * FROM product p 
//     LEFT JOIN product_lang pl ON (pl.id_product = p.id_product AND pl.id_lang = 1) 
//     WHERE active = 1 
//     AND pl.name LIKE "%'.strip_tags($key).'%"
//     ORDER BY date_upd DESC LIMIT 0,5'
// );


$query     = "SELECT  p.nombreproducto, p.codigodebarras, p.precio
FROM public.producto p
WHERE LOWER(p.nombreproducto) LIKE LOWER($1) AND p.activo = 't'
LIMIT 5";

$params    = array($key);

$result    = pg_query_params($dbconn, $query, $params);



if (pg_num_rows($result) > 0) {
    while ($row = pg_fetch_assoc($result)) {                
        $html .= '<div><a class="suggest-element" data="'.utf8_encode($row['nombreproducto']).'" id="'.$row['codigodebarras'].'">'.utf8_encode($row['nombreproducto']).' - $'.utf8_encode($row['precio']).'</a></div>';
    }
}



echo $html;
?>