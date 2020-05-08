<?php

if (isset($_REQUEST['num_atencion'])) {
    $num_atencion = $_REQUEST['num_atencion'];
} else {
    die();
}
if (isset($_REQUEST['total'])) {
    $total = $_REQUEST['total'];
} else {
    die();
}

date_default_timezone_set("America/Santiago");
$tiempo = date('d-m-y h:i:s');


$texto = ''.
            //   'XXXXXXXXXXXXXX\n\n'.
              '//////////////////\n\n'.
              ' PANADERIA MINGO\n\n'.
              ' '.$tiempo.'\n\n'.
              '    ID: '.$num_atencion.'\n\n'.
              '  TOTAL: \$'.number_format($total, 0, ',', '.').'\n\n'.
            //   '  Gracias por su \n'.
            //   '   preferencia\n\n'.
              '//////////////////'.
            '';

$comando = 'printf "'.$texto.'" | smbclient "//caja/POS58" gabriel91 -U "gabriel" -c "print -"';

echo shell_exec($comando);
