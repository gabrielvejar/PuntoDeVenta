var id_apertura = document.getElementById('id_ap').value;

var datos = {};


$(function() {

    
    tablaVentas();
    comboMediodePago();
    comboCajeros();
    comboVendedores();


    $('.filtros').change(function (e) { 
        e.preventDefault();

        var mediodePago = $('#inputMediodePago').val();
        datos['id_tipo_pago'] = mediodePago;

        var cajero = $('#inputCajero').val();
        datos['cajero'] = cajero;

        var vendedor = $('#inputVendedor').val();
        datos['vendedor'] = vendedor;


        tablaVentas();
    });
    
})




function tablaVentas() {

    // TODO agregar filtros



    // var datos = {
    //     'cmd': 'ventas'
    // }


    datos['cmd'] = 'ventas';




    if (id_apertura != 0) {
        datos['id_apertura'] = id_apertura;
    }

    $.ajax({
        type: "POST",
        url: "../command.php",
        data: datos,
        dataType: 'JSON',
        success: function (response) {

            console.log(response);



            var tabla = $('#tbody_registro_ventas');
                
            var html = '';
            if (response.length > 0) {

                var total = 0;
                    
                response.forEach(element => {
                    
                    html += '<tr>';
                    html += '<th scope="row">'+element.id_venta+'</td>';
                    html += '<td>'+element.id_diario+'</td>';
                    html += '<td>'+element.fecha2+'</td>';
                    html += '<td>'+element.hora_pago+'</td>';
                    html += '<td>'+element.nombre_tipo_pago+'</td>';
                    // html += '<td>'+element.hora_venta_temp+'</td>';
                    html += '<td>'+element.nombre_usuario_pago+'</td>';
                    html += '<td>'+element.nombre_usuario_venta_temp+' <i class="far fa-clock" aria-hidden="true" data-toggle="tooltip" title="Hora ingreso venta: '+element.hora_venta_temp+'"></i></td>';
                    html += '<th class="total-venta">$'+separadorMiles(element.monto_venta)+'</td>'; //formatear
                    // html += '<td><a value="'+element.id_venta_temp+'"><i class="fa fa-list" aria-hidden="true" title="Ver detalle" value="'+element.id_venta_temp+'"></i></a></td>';
                    html += '<td><i class="fa fa-list cursor" aria-hidden="true" data-toggle="tooltip" title="Ver detalle" onclick="verDetalle('+element.id_venta_temp+');"></i></td>';

                    
                    total += parseInt(element.monto_venta);
                    
                    html += '</tr>';

                });

                html += '<tr>';
                html += '<td colspan="6"></td>';
                html += '<th scope="row">Total: </td>';
                html += '<th scope="row">$'+separadorMiles(total)+'</td>';
                html += '<td></td>';
                html += '</tr>';
            
            }
            
            tabla.html(html);
            $('[data-toggle="tooltip"]').tooltip();

        }
    });
}




function comboMediodePago() {

    var datos = {
        'cmd': 'select-medio-de-pago'
    }

    $.ajax({
        type: "POST",
        url: "../command.php",
        data: datos,
        dataType: 'JSON',
        success: function (response) {

            console.log(response);

            var select = $('#inputMediodePago');
            var html = '';
            
            if (response.length > 0) {

                
                html = '<option selected value="0">Seleccione...</option>';
                    
                response.forEach(element => {
                    
                    html += '<option value="'+element.id_tipo_pago+'">'+element.nombre_tipo_pago+'</option>';

                });
                
            
            } else {
                html = '<option selected value="0">Sin opciones disponibles</option>';

            }

            select.html(html);

        }
    });
}

function comboCajeros() {

    var datos = {
        'cmd': 'select-cajeros'
    }

    $.ajax({
        type: "POST",
        url: "../command.php",
        data: datos,
        dataType: 'JSON',
        success: function (response) {

            console.log(response);

            var select = $('#inputCajero');
            var html = '';
            
            if (response.length > 0) {

                
                html = '<option selected value="0">Seleccione...</option>';
                    
                response.forEach(element => {
                    
                    html += '<option value="'+element.id_usuario+'">'+element.nombre+'</option>';

                });
                
            
            } else {
                html = '<option selected value="0">Sin opciones disponibles</option>';

            }

            select.html(html);

        }
    });
}

function comboVendedores() {

    var datos = {
        'cmd': 'select-vendedores'
    }

    $.ajax({
        type: "POST",
        url: "../command.php",
        data: datos,
        dataType: 'JSON',
        success: function (response) {

            console.log(response);

            var select = $('#inputVendedor');
            var html = '';
            
            if (response.length > 0) {

                
                html = '<option selected value="0">Seleccione...</option>';
                    
                response.forEach(element => {
                    
                    html += '<option value="'+element.id_usuario+'">'+element.nombre+'</option>';

                });
                
            
            } else {
                html = '<option selected value="0">Sin opciones disponibles</option>';

            }

            select.html(html);

        }
    });
}



function verDetalle(id_venta_temp) {

        $.fancybox.open({
          src  : 'detalle_ventas/detalle_venta.php?id='+id_venta_temp,
          type : 'iframe',
          opts : {
            afterShow : function( instance, current ) {
              console.info( 'done!' );
            },
            iframe : {
                preload : false
            }
          }
        });
      
}
