var ruta = document.getElementById('ruta').value;
var datos = {};

$(function() {

    tabla();
    comboCajeros();

    // $('.filtros').change(function (e) { 
    //     e.preventDefault();


    // });

    $('#btn-filtrar').click(function (e) { 
        e.preventDefault();
        filtrar();
    });


    $('#btn-limpiar').click(function (e) { 
        e.preventDefault();
        limpiarFiltros();
        filtrar();
    });
    
})

function limpiarFiltros() {
    $('.filtros').val('');
}

function filtrar () {
    var fechainicio = $('#inputFechaInicio').val();
    datos['fechainicio'] = fechainicio;

    var fechafin = $('#inputFechaFin').val();
    datos['fechafin'] = fechafin;

    var cajero = $('#inputCajero').val();
    datos['cajero'] = cajero;

    tabla();
}

function tabla() {

    datos['cmd'] = 'registro-cierres';

    $.ajax({
        type: "POST",
        url: ruta+"ventas/command.php",
        data: datos,
        dataType: 'JSON',
        success: function (response) {


            var tabla = $('#tbody_registro_cierres');
                
            var html = '';
            if (response.length > 0) {

                var total = 0;
        /*
        id_cierre,
        id_apertura,
        fecha,
        time_apertura,
        id_user_apertura,
        user_apertura,
        efectivo_apertura,
        efectivo_cierre,
        ventas_efectivo,
        ventas_tarjetas,
        entrega,
        gastos,
        balance,
        id_user_cierre,
        user_cierre,
        time_cierre,
        id_user_autoriza,
        user_autoriza
        */ 
    //    <th scope="col">Caja</th>
    //    <th scope="col">Fecha</th>
    //    <th scope="col">Abierta por</th>
    //    <th scope="col">Cerrada por</th>
    //    <th scope="col">Ventas</th>
    //    <th scope="col">Gastos</th>
    //    <th scope="col">Efectivo Cierre</th>
    //    <th scope="col">Balance</th>
    //    <th scope="col">Acciones</th>
                response.forEach(element => {
                    
                    html += '<tr>';
                    html += '<td>'+element.id_apertura+'</td>';
                    html += '<td>'+element.fecha+'</td>';
                    html += '<td>'+element.user_apertura+'</td>';
                    html += '<td>'+element.user_cierre+'</td>';
                    html += '<td>$'+separadorMiles(parseInt(element.ventas_efectivo)+parseInt(element.ventas_tarjetas))+'</td>';
                    html += '<td>$'+separadorMiles(parseInt(element.gastos))+'</td>';
                    html += '<td>$'+separadorMiles(parseInt(element.efectivo_cierre))+'</td>';
                    html += '<td>$'+separadorMiles(parseInt(element.entrega))+'</td>';
                    html += '<td>$'+separadorMiles(parseInt(element.balance))+'</td>';

                    html += '<td>';
                    html += '<i class="fa fa-list cursor" aria-hidden="true" data-toggle="tooltip" title="Ver más" onclick="verDetalle('+element.id_cierre+');"></i>';
                    html += '</td>';

                    html += '</tr>';

                });

                // html += '<tr>';
                // html += '<td colspan="7"></td>';
                // html += '<th scope="row">Total: </td>';
                // html += '<th scope="row">$'+separadorMiles(total)+'</td>';
                // html += '<td></td>';
                // html += '</tr>';
            
            }
            
            tabla.html(html);
            $('[data-toggle="tooltip"]').tooltip();

        }
    });
}



function comboCajeros() {

    var datos = {
        'cmd': 'select-cajeros'
    }

    $.ajax({
        type: "POST",
        url: ruta+"ventas/command.php",
        data: datos,
        dataType: 'JSON',
        success: function (response) {

            console.log(response);

            var select = $('#inputCajero');
            var html = '';
            
            if (response.length > 0) {

                
                // html = '<option selected value="0">Seleccione...</option>';
                html = '<option selected value="">Seleccione...</option>';
                    
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


function elim(id) {
    bootbox.alert ('Anular venta id: '+id);
}


