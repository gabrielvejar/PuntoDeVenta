var saldoVaciar = $('#saldo-vaciar').val();
function vaciar() {

    if (saldoVaciar != 0) {
        $('#agregar-mov-custodia').click();
        $('#div-agregar-mov-custodia').collapse('show');
        $('#inputTipoMov').val('2');
        $('#monto').val(saldoVaciar);
        formatearDinero('#monto','$');
        $('#comentario').val('Retiro total de dinero en custodia');
    }

}


function tablaMovimientosCustodia() { 
    var id = $('#id-dinero-custodia').val();

    var datos = {
        "cmd": "tabla-dinero-en-custodia-movimientos",
        "id_dc": id
    }

    $.ajax({
        type: "POST",
        url: "../../command.php",
        data: datos,
        dataType: 'JSON',
        success: function (response) {

            console.log(response);
            var saldo = 0;
            
            if (response.length > 0 && response[0]['id_movimiento'] != null) {

                // $('table').collapse('show');
                // $('#msg-sin-gastos').collapse('hide');

                $('table').show();
                $('#msg-sin-gastos').hide();

                
                var tabla = $('#tabla-dec-mov-body');
                
                var html = '';
                // id_movimiento,
                // id_dinero_custodia,
                // nombre_custodia,
                // monto_movimiento,
                // comentario,
                // id_usuario,
                // nombre_usuario,
                // fecha_movimiento,
                // hora_movimiento,
                // eliminado
                var lineas = 0;
                for(var i=0; i < response.length; i++) {

                    if (response[i]['eliminado'] == 't') {
                        continue;
                    }


                    saldo += parseInt(response[i]['monto_movimiento']);
                    html += '<tr>';
                    if (response[i]['gasto'] == 't') {
                        html += '<th scope="row">'+(lineas+1)+'*</th>';
                    } else {
                        html += '<th scope="row">'+(lineas+1)+'</th>';
                    }
                    html += '<td class="nowrap">'+response[i]['fecha_movimiento']+'</td>';
                    html += '<td class="">'+response[i]['hora_movimiento']+'</td>';
                    html += '<td class="txt-left">'+response[i]['comentario']+'</td>';


                    if (response[i]['monto_movimiento'] < 0){
                        html += '<td class="txt-red">$'+separadorMiles(response[i]['monto_movimiento'])+'</td>';
                    } else {
                        html += '<td class="">$'+separadorMiles(response[i]['monto_movimiento'])+'</td>';
                    }


                    html += '<td class="">$'+separadorMiles(saldo)+'</td>';

                    // html += '<td class="td-acciones"><i class="fa fa-user usuario"  data-toggle="tooltip" aria-hidden="true" title="'+response[i]['nombre_usuario']+'"></i><i class="fas fa-trash-alt cursor eliminar" data-toggle="tooltip" aria-hidden="true" onclick="eliminarMovimientoCustodia('+response[i]['id_movimiento']+')" title="Eliminar movimiento"></i></td>';
                    
                    
                    html += '<td class="td-acciones">';
                    html += '<i class="fa fa-user usuario"  data-toggle="tooltip" aria-hidden="true" title="'+response[i]['nombre_usuario']+'"></i>';

                    html += '<i class="fas fa-trash-alt cursor eliminar" data-toggle="tooltip" aria-hidden="true" onclick="elim('+response[i]['id_movimiento']+')" title="Eliminar movimiento"></i>';

                    html += '</td>';
                    
                    html += '</tr>';

                    lineas++;
                }
                
                // var i = 0;
                // response.forEach(element => {
                //     i++;
                //     saldo += parseInt(element['monto_movimiento']);
                //     html += '<tr>';
                //     html += '<th scope="row">'+i+'</th>';
                //     html += '<td class="nowrap">'+element['fecha_movimiento']+'</td>';
                //     html += '<td class="">'+element['hora_movimiento']+'</td>';
                //     html += '<td class="txt-left">'+element['comentario']+'</td>';


                //     if (element['monto_movimiento'] < 0){
                //         html += '<td class="txt-red">$'+separadorMiles(element['monto_movimiento'])+'</td>';
                //     } else {
                //         html += '<td class="">$'+separadorMiles(element['monto_movimiento'])+'</td>';
                //     }


                //     html += '<td class="">$'+separadorMiles(saldo)+'</td>';
                //     html += '<td class="td-acciones"><i class="fa fa-user usuario"  data-toggle="tooltip" aria-hidden="true" title="'+element['nombre_usuario']+'"></i><i class="fas fa-trash-alt cursor eliminar" data-toggle="tooltip" aria-hidden="true" onclick="eliminarMovimientoCustodia('+element['id_movimiento']+')" title="Eliminar movimiento"></i></td>';
                //     html += '</tr>';
                // });
                // console.log('i: '+i);
                if (lineas > 0) {
                    tabla.html(html);
                } else {
                    $('table').hide();
                    $('#msg-sin-gastos').show();
                }


            
            } else {
                $('table').hide();
                $('#msg-sin-gastos').show();
                // $('table').collapse('hide');
                // $('#msg-sin-gastos').collapse('show');
            }
            $('#nom_dinero_custodia').text(response[0]['nombre_custodia']);
            $('#saldo_dinero_custodia').text('Saldo: $'+separadorMiles(saldo));
            $('#saldo').val(saldo);
            $('[data-toggle="tooltip"]').tooltip();

            
        }
    });
  }

function ingresarMovimientoCustodia() {

    var saldo = $('#saldo').val();
    var idCustodia = $('#id-dinero-custodia').val();
    var comentario = $('#comentario').val();
    var tipoMov = $('#inputTipoMov').val();
    var monto = limpiarNumero($('#monto').val());

    if (tipoMov == 2 && saldo == 0) {return false};

    comentario = comentario.trim(); 
    monto = monto.trim();



    if (idCustodia == "" || idCustodia == '0') {return false};
    if (comentario == "") {return false};
    if (tipoMov != "1" && tipoMov != "2") {return false};
    if (monto == "" || monto == "$0") {return false};

    var datos = {
        'cmd': 'ingresar-movimiento-custodia',
        'id_custodia': idCustodia,
        'tipoMov': tipoMov,
        'monto': monto,
        'comentario': comentario,
        'gasto': 'f'
    }

    $.ajax({
        type: "POST",
        url: "../../command.php",
        data: datos,
        async: false,
        success: function (response) {
            console.log(response);

            if(response == '0') {
                bootbox.alert('Error al agregar movimiento de dinero en custodia.');
            } else {                
                bootbox.alert({
                    title: "",
                    message: "Movimiento de dinero en custodia agregado correctamente.",
                    centerVertical: true,
                    callback: function (result) {
                        if (saldoVaciar != '0') {
                            parent.$.fancybox.close();
                        } else {
                            location.reload();
                        }
                    }
                });
            }
   
        }
    });
}

function elim (id) {

    if (id == "" || id == null) {return false};

    bootbox.confirm({ 
        size: "small",
        title: "Eliminar",
        message: '<p>Estás seguro que deseas eliminar?</p>',
        callback: function(result){ 
            if (result) {
                eliminarMovimientoCustodia(id);
            }
        }
    })
}

function eliminarMovimientoCustodia(id) {

    if (id == "" || id == null) {return false};

    

    var datos = {
        'cmd': 'eliminar-movimiento-custodia',
        'id_movimiento': id
    }

    $.ajax({
        type: "POST",
        url: "../../command.php",
        data: datos,
        async: false,
        success: function (response) {
            console.log(response);

            if(response == '2') {
                bootbox.alert({
                    title: "",
                    message: "Movimiento de dinero en custodia eliminado correctamente.",
                    callback: function (result) {
                            location.reload();
                    }
                });
            } else if(response == '1') {
                bootbox.alert({
                    title: "",
                    message: "Movimiento de dinero en custodia no encontrado.",
                    callback: function (result) {
                    }
                });
            } else {
                bootbox.alert('Error al eliminar movimiento de dinero en custodia.');
            }
   
        }
    });
}



$(function() {
    tablaMovimientosCustodia();
    vaciar();

    $('#agregar-mov-custodia').change(function (e) { 
        e.preventDefault();
        $('#div-agregar-mov-custodia').collapse('toggle');
    });



    $('#btn-ingresar').on('click', function () {
        var saldo = parseInt($('#saldo').val());
        var tipoMov = $('#inputTipoMov').val();
        var monto = parseInt(limpiarNumero($('#monto').val()));
        console.log('saldo: '+saldo+' - monto: '+monto);
        
        if (tipoMov == 2 && saldo < monto) {
            bootbox.alert('No puede realizar <b>egreso</b> de dinero por un monto mayor al saldo disponible');
        } else {
            if (ingresarMovimientoCustodia() == false) {
                bootbox.alert('Revise los datos ingresados');
            }
        }
    });


    $('#achicar').on('click', function () {
        if (document.getElementById('tabla-gastos-body').style.fontSize != '10px') {
            document.getElementById('tabla-gastos-body').style.fontSize = (document.getElementById('tabla-gastos-body').style.fontSize.slice(0, document.getElementById('tabla-gastos-body').style.fontSize.length-2)*1-1)+"px";
        }
    });
    $('#agrandar').on('click', function () {
        if (document.getElementById('tabla-gastos-body').style.fontSize != '30px') {
            document.getElementById('tabla-gastos-body').style.fontSize = (document.getElementById('tabla-gastos-body').style.fontSize.slice(0, document.getElementById('tabla-gastos-body').style.fontSize.length-2)*1+1)+"px";
        }
    });


    $('#monto').on('input', function () {
            formatearDinero('#monto', '$');
    });


    $('i .eliminar').click(function (e) { 
        console.log('click icono eliminar');
        
        e.preventDefault();
        prueba();
    });

});