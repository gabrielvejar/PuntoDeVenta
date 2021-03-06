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
    
    datos['anulado'] = 't';


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



            var tabla = $('#tbody_registro_ventas');
                
            var html = '';
            if (response.length > 0) {

                var total = 0;
                    
                response.forEach(element => {
                    
                    html += '<tr>';
                    html += '<td>'+element.id_apertura+'</td>';
                    html += '<td>'+element.id_venta+'</td>';
                    html += '<td>'+element.id_diario+'</td>';
                    html += '<td>'+element.fecha_anulado+'</td>';
                    html += '<td>'+element.hora_anulado+'</td>';
                    html += '<td>'+element.nombre_usuario_d+'</td>';
                    html += '<td>'+element.nombre_tipo_pago+'</td>';
                    html += '<td>'+element.nombre_tipo_pago+'</td>';

                    html += '<td>';
                    html += '<i class="fa fa-user usuario"  data-toggle="tooltip" aria-hidden="true" title="Vendedor: '+element.nombre_usuario_venta_temp+'"></i>';
                    html += '<i class="far fa-clock" aria-hidden="true" data-toggle="tooltip" title="Hora ingreso venta: '+element.hora_venta_temp+'"></i>';
                    html += '</td>';

                    html += '<td>';
                    html += '<i class="fa fa-user usuario"  data-toggle="tooltip" aria-hidden="true" title="Cajero: '+element.nombre_usuario_pago+'"></i>';
                    html += '<i class="far fa-clock" aria-hidden="true" data-toggle="tooltip" title="Hora pago venta: '+element.hora_pago+'"></i>';
                    html += '</td>';
                    
                    html += '<th class="total-venta">$'+separadorMiles(element.monto_venta)+'</td>';
                    html += '</tr>';
                    
                    total += parseInt(element.monto_venta);

                });

                html += '<tr>';
                html += '<td colspan="9"></td>';
                html += '<th scope="row">Total: </td>';
                html += '<th scope="row">$'+separadorMiles(total)+'</td>';
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
        url: "../../command.php",
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
        url: "../../command.php",
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
        url: "../../command.php",
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
