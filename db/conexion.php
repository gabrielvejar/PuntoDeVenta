<?php

$dbconn = pg_connect("host=localhost dbname=puntodeventa_produccion user=postgres password=gabriel91") or die("No se ha podido conectar");
$stat = pg_connection_status($dbconn);
if ($stat === PGSQL_CONNECTION_OK) {
    // echo 'Conectado correctamente a base de datos';
} else {
    echo 'No se ha podido conectar';
}

?>
