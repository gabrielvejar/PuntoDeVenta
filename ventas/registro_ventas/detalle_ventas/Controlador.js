$(function() {
  tablaDetalleVenta();
    
})

var id_venta = document.getElementById('id_venta_temp').value;

function tablaDetalleVenta() {


    var datos = {
        'cmd': 'buscar-venta-temporal',
        'id_venta_temp': id_venta
    }

    $.ajax({
        type: "POST",
        url: "../../command.php",
        data: datos,
        dataType: 'JSON',
        success: function (response) {

            console.log(response);
            
            if (response.length > 0) {

              $('#id_diario').text(response[0].id_diario);

              var totalVenta = 0;


                var tabla = $('#tbody_detalle_venta');
                
                var html = '';
                    
                var i = 0;
                response.forEach(element => {
                  i++;
                  totalVenta += element.monto*1;
                    
                    html += '<tr>';
                    html += '<th scope="row">'+i+'</td>';
                    html += '<td>'+element.nombre+'</td>';
                    html += '<td>$'+separadorMiles(element.precio)+' / '+element.unidad+'</td>';
                    html += '<td>'+parseFloat(element.cantidad).toFixed(2)+'</td>'; //formatear
                    var promo = "";
                    if (element.idpromocion != null){ promo = "*"}; 
                    html += '<td>$'+separadorMiles(element.monto)+promo+'</td>';
                    html += '</tr>';
                    
                  });
                  
                  html += '<tr>';
                  html += '<th scope="row" colspan="3"></td>';
                  html += '<th scope="row">Total:</td>';
                  html += '<th scope="row">$'+separadorMiles(totalVenta)+'</td>';
                  html += '</tr>';

                tabla.html(html);
            //     $('[data-toggle="tooltip"]').tooltip();
            
            } else {
              $('#mensaje').text('Sin líneas de detalle')
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
