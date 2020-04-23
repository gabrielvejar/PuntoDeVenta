<?php

// if (isset($_REQUEST['num_atencion'])) {
//     $num_atencion = $_REQUEST['num_atencion'];
// } else {
//     die();
// }
// if (isset($_REQUEST['total'])) {
//     $total = $_REQUEST['total'];
// } else {
//     die();
// }


require __DIR__ . '/autoload.php'; //Nota: si renombraste la carpeta a algo diferente de "ticket" cambia el nombre en esta línea
use Mike42\Escpos\EscposImage;
use Mike42\Escpos\PrintConnectors\WindowsPrintConnector;
use Mike42\Escpos\Printer;


/*
Este ejemplo imprime un hola mundo en una impresora de tickets
en Windows.
La impresora debe estar instalada como genérica y debe estar
compartida
 */

/*
Conectamos con la impresora
 */

/*
Aquí, en lugar de "POS-58" (que es el nombre de mi impresora)
escribe el nombre de la tuya. Recuerda que debes compartirla
desde el panel de control
 */

$nombre_impresora = "POS58";

$connector = new WindowsPrintConnector($nombre_impresora);
$printer = new Printer($connector);
$printer->setJustification(Printer::JUSTIFY_CENTER);

// $logo = EscposImage::load("logopanaderia.jpg", false);


$logo = EscposImage::load("logopanaderia2.jpg", false);

// volver a habilitar
$printer->bitImage($logo);

/*
Imprimimos un mensaje. Podemos usar
el salto de línea o llamar muchas
veces a $printer->text()
 */

// volver a habilitar
// $printer->text(date("d/m/Y H:i:s") . "\n");
// $printer->feed();

// $detalle1 = json_decode($_POST['detalle1'], true);
// $detalle2 = json_decode($_POST['detalle2'], true);
// $total = $_POST['total'];

// foreach ($detalle1 as $linea) {

//         /*Alinear a la izquierda para la cantidad y el nombre*/
//         $printer->setJustification(Printer::JUSTIFY_LEFT);
//         $printer->text(number_format($linea['cantidad'], 2, ',', '') . " x " . $linea['nombre'] . "\n");
     
//         /*Y a la derecha para el importe*/
//         $printer->setJustification(Printer::JUSTIFY_RIGHT);
//         $printer->text(' $' . $linea['monto'] . "\n");

// }
// foreach ($detalle2 as $linea) {

//         /*Alinear a la izquierda para la cantidad y el nombre*/
//         $printer->setJustification(Printer::JUSTIFY_LEFT);
//         $printer->text(number_format($linea['cantidad'], 2, ',', '') . " x " . $linea['nombre'] . "\n");
     
//         /*Y a la derecha para el importe*/
//         $printer->setJustification(Printer::JUSTIFY_RIGHT);
//         $printer->text(' $' . $linea['monto'] . "\n");

// }

// $printer->text("--------\n");
// $printer->text("TOTAL: $". $total ."\n");
// $printer->feed(2);


// // timbre temporal---------------------
// $timbre = EscposImage::load("cbimage.png", false);
// $printer->bitImage($timbre);
// //------------------------------------------


// $printer->feed(2);
// hasta aqui


$printer->setJustification(Printer::JUSTIFY_CENTER);
$printer->text("Gracias por su preferencia :)\n");





/*
Hacemos que el papel salga. Es como
dejar muchos saltos de línea sin escribir nada
 */

//  volver a habilitar
// $printer->feed(5);

/*
Cortamos el papel. Si nuestra impresora
no tiene soporte para ello, no generará
ningún error
 */
$printer->cut();

/*
Por medio de la impresora mandamos un pulso.
Esto es útil cuando la tenemos conectada
por ejemplo a un cajón
 */
$printer->pulse();

/*
Para imprimir realmente, tenemos que "cerrar"
la conexión con la impresora. Recuerda incluir esto al final de todos los archivos
 */
$printer->close();
