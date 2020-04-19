$(function() {
  tablaVentasTempAnuladas();
    
})


function tablaVentasTempAnuladas() {
  var id_apertura = 0;

  if ($('#id_ap').val() != null){
    id_apertura = $('#id_ap').val();
  }


    var datos = {
        'cmd': 'ventas-temp_impagas_anuladas'
    }

    if (id_apertura != 0) {
      datos['id_apertura'] = id_apertura;
    }

    $.ajax({
        type: "POST",
        url: "../../command.php",
        data: datos,
        dataType: 'JSON',
        success: function (response) {

            console.log(response);
            
            if (response.length > 0) {

                var tabla = $('#tbody_ventas_temp_anuladas');
                
                var html = '';

                response.forEach(element => {
                    
                    html += '<tr>';
                    html += '<th scope="row">'+element.id_diario+'</td>';
                    html += '<td>'+element.fecha+'</td>';
                    html += '<td>'+element.time_creado+'</td>';
                    html += '<td>$'+separadorMiles(element.total)+'</td>';
                    html += '<td>'+element.nombre_usuario+'</td>';

                    html += '<td><i class="fas fa-recycle cursor" data-toggle="tooltip" aria-hidden="true" title="Recuperar" onclick="recuperar('+element.id_venta_temp+');"></i></td>';

                    html += '</tr>';
                    
                  });
                  
                tabla.html(html);
                $('[data-toggle="tooltip"]').tooltip();
            
            } else {
              $('#mensaje').text('Sin ventas temporales anuladas')
            }

        }
    });
  }

// function verDetalle(id_venta_temp) {

//         $.fancybox.open({
//           src  : '../caja/caja.php?id='+id_venta_temp,
//           type : 'iframe',
//           opts : {
//             afterShow : function( instance, current ) {
//               console.info( 'done!' );
//             }
//           }
//         });
      
// }


function recuperar(id) {
  location.replace('../../caja/venta_caja/venta_caja.php?id='+id);
}