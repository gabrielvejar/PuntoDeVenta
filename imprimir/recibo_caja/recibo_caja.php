<?php 
$ruta = "";
while (!(file_exists ($ruta . "index.php"))) {
    $ruta = "../" . $ruta;
}
?>


<!DOCTYPE html>
<html>
    <head>
        <link rel="stylesheet" href="estilos.css"> 
    </head>
    <body>
        <div class="ticket">
            <!-- <img
                src="<?php echo $ruta; ?>imprimir\puma-logo.svg"
                alt="Logotipo"> -->
                <p id="titulo"><span id="tit1">PANADERÍA</span><br><span id="tit2">MINGO</span></p>
            <p class="centrado">New New York
                <br>23/08/2017 08:22 a.m.</p>
            <table>
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
            </table>
            <p class="centrado">¡GRACIAS POR SU COMPRA!
                <br>parzibyte.me</p>
        </div>
        <button class="oculto-impresion" onclick="imprimir()">Imprimir</button>

        <script>

            window.addEventListener('load', function(){
                imprimir ();
            });

            window.addEventListener('afterprint', function(){
                alert('afterprint');
            });

            function imprimir () {
                window.print();
            }

        </script>
    </body>
</html>