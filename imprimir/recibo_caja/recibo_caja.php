<?php 
$ruta = "";
while (!(file_exists ($ruta . "index.php"))) {
    $ruta = "../" . $ruta;
}

session_start();

if(!isset($_SESSION['usuario'])) {
    echo "Sesión no iniciada";
    die();
} else {
    $usuario = $_SESSION['usuario'];
}




require $ruta . "db/conexion.php";

$id_venta = "";
if (isset($_REQUEST['id'])) {
    $id_venta = $_REQUEST['id'];
}


$autom = "";
if (isset($_REQUEST['autom'])) {
    $autom = $_REQUEST['autom'];
}

//datos venta
$query     = "SELECT 
                        v.id_venta,
                        v.id_venta_temp,
                        vt.letra_id_diario || '-' || vt.id_diario as id_diario,
                        v.id_apertura,
                        v.monto_venta,
                        v.id_tipo_pago,
                        tp.nombre_tipo_pago,
                        v.id_usuario,
                        u.nombre as cajero,
                        v.time_creado,
                        to_char(v.time_creado::timestamp with time zone, 'DD-MM-YYYY'::text) AS fecha_creado,
                        to_char(v.time_creado, 'HH24:MI:SS'::text) AS hora_creado,
                        v.anulado,
                        v.id_usuario_d,
                        v.time_anulado
                    FROM 
                        public.venta v
                        INNER JOIN public.tipo_pago tp ON v.id_tipo_pago = tp.id_tipo_pago
                        INNER JOIN public.usuario u ON v.id_usuario = u.id_usuario
                        INNER JOIN public.venta_temporal vt ON v.id_venta_temp = vt.id_venta_temp
                    WHERE v.id_venta = $1";

$params    = array($id_venta);
$result    = pg_query_params($dbconn, $query, $params);

$filas_venta = [];
$i = 0;
while($row = pg_fetch_assoc($result))
{
    $filas_venta [$i] = $row;
    $i++;
}

if (count($filas_venta) == 0) {
    echo "No se encuentra venta solicitada.";
    die();
}
// echo $filas_venta[0]['nombreproducto'];

//datos detalle
$query_detalle = "SELECT 
                                vd.id_detalle,
                                vd.id_venta_temp,
                                vd.idproducto,
                                p.nombreproducto,
                                p.precio,
                                vd.cantidad,
                                vd.monto,
                                vd.id_promocion,
                                pm.descripcion_promo  
                            FROM 
                                public.venta_detalle vd
                                INNER JOIN public.venta_temporal vt ON vd.id_venta_temp = vt.id_venta_temp
                                INNER JOIN public.venta v ON vt.id_venta_temp = v.id_venta_temp
                                INNER JOIN public.producto p ON vd.idproducto = p.idproducto
                                LEFT JOIN public.promociones pm ON p.idproducto = pm.idproducto
                            WHERE v.id_venta = $1";

$params    = array($id_venta);
$result_detalle    = pg_query_params($dbconn, $query_detalle, $params);

$filas_detalle = [];
$i = 0;
while($row = pg_fetch_assoc($result_detalle))
{
    $filas_detalle [$i] = $row;
    $i++;
}

?>


<!DOCTYPE html>
<html>
    <head>
        <link rel="stylesheet" href="estilos.css?v=<?php echo rand() ?>">
        <style type="text/css">    
            @font-face{
                font-family:"Fake Receipt W90 Regular";
                src:url("Fonts/1412530/6266325e-e205-43f0-bf52-2ef2ad19bc46.woff2") format("woff2"),url("Fonts/1412530/559bba56-973a-47ec-bb8f-61c2a45fb976.woff") format("woff");
            }
        </style>
    </head>
    <body>
        <div class="ticket">
            <!-- <img
                src="<?php echo $ruta; ?>imprimir\puma-logo.svg"
                alt="Logotipo"> -->
                <p id="titulo"><span id="tit1">PANADERÍA</span><br><span id="tit2">MINGO</span></p>
            <p class="centrado"><?php echo $filas_venta[0]['fecha_creado'].' '.$filas_venta[0]['hora_creado']; ?> </p>

            <table>
                <tbody>


                <?php foreach ($filas_detalle as $element) { // recorrer las filas de detalle e incliur a la tabla?>

                    <tr>
                        <td class="rowproducto" colspan="3"><?php echo $element['nombreproducto']; ?></td>
                    </tr>


                    <?php if($element['id_promocion'] != null){ //fila promocion?>
                    <tr>
                        <td class="rowpromo" colspan="3"><?php echo '*Promoción: '.$element['descripcion_promo']; ?></td>
                    </tr>
                    <?php } ?>


                    <tr class="rowvalores">
                        <td><?php echo number_format($element['cantidad'], 2, ',', '.'); ?> x</td>

                        
                    <?php if($element['id_promocion'] != 0){ //Mostrar monto en campo precio si es producto genérico para que no muestre precio $0?>
                        <td>$<?php echo number_format($element['precio'], 0, ',', '.'); ?></td>
                    <?php } else {?>
                        <td>$<?php echo number_format($element['monto'], 0, ',', '.'); ?></td>
                    <?php } ?>

                        <td class="tdtotal">$<?php echo number_format($element['monto'], 0, ',', '.'); if($element['id_promocion'] != null){echo '*';}?></td>
                    </tr>

                
                <?php } ?>

                
                </tbody>
            </table>
            <p id="total">Total: $<?php echo number_format($filas_venta[0]['monto_venta'], 0, ',', '.');?></p>
            <p id="totales">
                <!-- <br>Efectivo: $20.000
                <br>Vuelto: $4.710 -->
                Atención: <?php echo $filas_venta[0]['id_diario'];?>
                <br>Venta: <?php echo $filas_venta[0]['id_venta'];?>
                <br>Medio de pago: <?php echo $filas_venta[0]['nombre_tipo_pago'];?>
            </p>

            <!-- timbre -->
            <!-- <img src="data:img/png;base64, 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D7oVn3cj+lWKZyXmCsHvYLweKYRX19JR71vszeF+KtHQo0ePHj169OjRo0ePHj169OjRo0eP/uv0uWr1OVdh2aFnKlrN0phVJvZaOl0nxTVa+qZasvRx00pe3BXtet1fr5LX6RVBu45VpLunbcSnou25G5lbFcBdmB7e/2oOVwd49Hq5yt4eAlK5deya4OELS39WVzh69OjRo0ePHj169OjRo0ePHj169OjRo/8afWuujrdQt3ZzZd8x9wbr2fGVPr+NrsI3naeK++q5INvkbTSQpMesEFXP12LOrcr6e2/pzvPuvdU69Zp4on0uxFYbZ27UmS2Oc3uvO+J/s8r/9fhAq196ZeTWenO3Gs5nJRs9evTo0aNHjx49evTo0aNHjx49evTov0qvzuzBpd9ZqfCoC50thEvchfAKFY7mbjhtHnChHm3FUuY+gaOXk3XVY63tFv2nEnVbjvvV950L9or20Ud3uAM8nMfmsHpF2zeglnjVDVCWmpIlvVNZPedNET86Bj169OjRo0ePHj169OjRo0ePHj169OjRf5lelfDUv6N/cxe1zp4OYaMilWNx/XyNNO8aI7JmLC/BqzPbeXgo5tKfow4/z9r60JOBTSEcHkMyVQe4fr0mmTS3ie8q/4enjrjputI2K7caQe3VO0cBes21nhakPo568yJ69OjRo0ePHj169OjRo0ePHj169OjRf5t+004SfbaechsVkf/3dsB5UG4sbR7efGtXj/bt+HDC+rlXtFtF6jcOLu6nTsGj5m7Yd3zSFtWqPW5Pd1Z7n15AHzzWWhXx61Y8FFaGq7J1KloR3O3tZNWFTht69OjRo0ePHj169OjRo0ePHj169OjRo/8WvYrpq49tapDOmGdVwvvkDgX2rHp+HtNokoxehfOkL1Vxn3b9oTEkS2KPTvTUkXCBXdE7gir/W7+G+rE37VMDRcTJmMVR6OPm3HqYdbtauj0CpWfE+c6NN0XXb4WfIMTLzwic9p9MHUGPHj169OjRo0ePHj169OjRo0ePHj3636UfdXZVtN9atdUUi6GPuni7iOze5+fhdKjEffPcDG39cj+0iC8XkaNHGjU+Y8/o3aNt810+VbTjepOfd8yTaqrH7BK17sjscSDKnjbOlXqbeB/Y4Wp6np7xuKKt05XKunNV9m4/qWijR48ePXr06NGjR48ePXr06NGjR48e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" alt="timbre"> -->





            <!-- <table>
                <thead>
                    <tr>
                        <th class="cantidad">CANT</th>
                        <th class="producto">PRODUCTO</th>
                        <th class="precio">$</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td class="cantidad">1.00</td>
                        <td class="producto">CHEETOS VERDES 80 G</td>
                        <td class="precio">$1.500</td>
                    </tr>
                    <tr>
                        <td class="cantidad">2.00</td>
                        <td class="producto">KINDER DELICE</td>
                        <td class="precio">$6.895</td>
                    </tr>
                    <tr>
                        <td class="cantidad">1.00</td>
                        <td class="producto">COCA COLA 600 ML</td>
                        <td class="precio">$2.158</td>
                    </tr>
                    <tr>
                        <td class="cantidad"></td>
                        <td class="producto">TOTAL</td>
                        <td class="precio">$15.263</td>
                    </tr>
                </tbody>
            </table> -->
            <p class="centrado">¡GRACIAS POR SU COMPRA!
                <br></p>
                <button class="oculto-impresion" onclick="imprimir()">Imprimir</button>
        </div>












        <script>

            window.addEventListener('load', function(){

                <?php if ($autom == 'si') {?>
                imprimir ();
                <?php } ?>

            });

            window.addEventListener('afterprint', function(){
                // alert('afterprint');
            });

            function imprimir () {
                window.print();
            }

        </script>
    </body>
</html>