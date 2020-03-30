function buscarVentas () {
   
    $.ajax({
        type: "POST",
        url: "../command.php",
        data: {cmd: 'ventas-temp_impagas'},
        success: function(data) {

            var ventas = JSON.parse(data);

            var html='';
            // var html='<a href="venta_caja/venta_caja.php"><button id="btn-nueva-venta" class="btn btn-info btn-venta hoverceleste">Nueva Venta</button></a>';

            for (var i=0; i < ventas.length; i++) {
                    html += '<a href="venta_caja/venta_caja.php?id='+ventas[i].id_venta_temp+'"><button class="btn btn-primary btn-venta">'+ventas[i].id_diario+'</button></a>';
        
            }

            $('#ventas').html(html);

            cambiarTamanioBotones();

        }
    });

}


function cambiarTamanioBotones() {
  var btns = document.getElementsByClassName('btn-venta');
  if (btns.length > 0) {
      var ancho = document.querySelectorAll('.btn-venta')[document.querySelectorAll('.btn-venta').length-1].offsetWidth +'px';
      for(i = 0; i < btns.length; i++) {
          document.getElementsByClassName('btn-venta')[i].style.height = ancho;
          document.getElementsByClassName('btn-venta')[i].style.width = ancho;
        }
    }
}


$(function() {

    buscarVentas();
    setInterval(buscarVentas, 3000);



});