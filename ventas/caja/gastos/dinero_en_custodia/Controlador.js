


function tablaDineroEnCustodia() {
    var totalCustodia = 0;

    $.ajax({
        type: "POST",
        url: "../command.php",
        data: "cmd=tabla-dinero-en-custodia",
        dataType: 'JSON',
        success: function (response) {

            console.log(response);
            
            if (response.length > 0) {

                // $('table').collapse('show');
                // $('#msg-sin-gastos').collapse('hide');

                $('table').show();
                $('#msg-sin-gastos').hide();

                
                var tabla = $('#tabla-dec-body');
                
                var html = '';
                    
                var i = 0;
                response.forEach(element => {
                    totalCustodia += parseInt(element['saldo']);
                    i++;
                    // html += '<option value="'+element['id_tipo_gasto']+'">'+element['nombre_tipo_gasto']+'</option>';
                    html += '<tr>';
                    html += '<th scope="row">'+i+'</th>';
                    html += '<td class="td-descripcion nowrap txt-left">'+element['nombre_dinero_en_custodia']+'</th>';
                    if (element['saldo'] == null) {
                        html += '<td>$0</th>';
                    } else{
                        html += '<td>$'+separadorMiles(element['saldo'])+'</th>';
                    }
                    
                    
                    // html += '<td class="td-acciones"><i class="fa fa-user usuario"  data-toggle="tooltip" aria-hidden="true" title="'+element['nombre_usuario']+'"></i><i class="fas fa-edit cursor modificar" data-toggle="tooltip" aria-hidden="true" value="'+element['id_dinero_custodia']+'" title="Ver / Ingresar movimientos"></i><i class="fas fa-trash-alt cursor eliminar" data-toggle="tooltip" aria-hidden="true" value="'+element['id_dinero_custodia']+'" title="Eliminar"></i></th>';
                    html += '<td class="td-acciones">';
                    html += '<i class="fa fa-user usuario"  data-toggle="tooltip" aria-hidden="true" title="Ingresado por: '+element['nombre_usuario']+'"></i>';

                    html += '<a class="iframe" data-fancybox data-type="iframe" data-src="movimientos/movimientos.php?id='+element['id_dinero_custodia']+'&sb=no" href="javascript:;"><i class="fas fa-edit cursor modificar" data-toggle="tooltip" aria-hidden="true" title="Ver / Ingresar movimientos"></i></a>';
                    
                    if (element['saldo'] != 0) {
                        html += '<a class="iframe" data-fancybox data-type="iframe" data-src="movimientos/movimientos.php?id='+element['id_dinero_custodia']+'&vaciar='+element['saldo']+'&sb=no" href="javascript:;"><i class="fas fa-share-square vaciar" data-toggle="tooltip" aria-hidden="true" title="Vaciar dinero en custodia"></i>';
                    } else {
                        html += '<i class="fas fa-trash-alt cursor eliminar" data-toggle="tooltip" aria-hidden="true" onclick="elim('+element['id_dinero_custodia']+', '+"'"+element['nombre_dinero_en_custodia']+"'"+')" title="Eliminar"></i>';
                    }
                    
                    html += '</td>';

                    html += '</tr>';
                });
                tabla.html(html);
            
            } else {
                $('table').hide();
                $('#msg-sin-gastos').show();
                // $('table').collapse('hide');
                // $('#msg-sin-gastos').collapse('show');
            }

            $('#total-custodia').text('Dinero acumulado: $'+separadorMiles(totalCustodia));
            $('[data-toggle="tooltip"]').tooltip();
            $(".iframe").fancybox({
                iframe: {
                    scrolling : 'auto',
                    preload   : false
        
                },
                afterClose: function( instance, slide ) {
                    tablaDineroEnCustodia();
                }

            });

        }
    });
  }

function ingresarDineroenCustodia() {
    var descripcion = $('#descripcion').val();
    var montoInicialCheck = document.getElementById('montoInicialSwitch').checked;
    var monto = limpiarNumero($('#monto').val());


    if (descripcion == "") {return false};
    if (montoInicialCheck && monto == "") {return false};

    var datos = {
        'cmd': 'ingresar-dinero-en-custodia',
        'descripcion': descripcion
    }

    if (montoInicialCheck) {
        datos['monto'] = monto;
    } else {
        datos['monto'] = 0;
    }
    

    $.ajax({
        type: "POST",
        url: "../command.php",
        data: datos,
        async: false,
        success: function (response) {
            console.log(response);

            if(response == '1') {
                bootbox.alert({
                    title: "",
                    message: "Dinero en custodia agregado correctamente.",
                    centerVertical: true,
                    callback: function (result) {
                        location.reload();
                    }
                });
            } else if(response == '2') {
                bootbox.alert({
                    title: "",
                    message: "Dinero en custodia y movimiento de monto inicial agregado correctamente.",
                    centerVertical: true,
                    callback: function (result) {
                        location.reload();
                    }
                });
            } else {                
                bootbox.alert('Error al agregar dinero en custodia.');
            }
   
        }
    });
}


function elim (id, nombre) {

    if (id == "" || id == null) {return false};

    bootbox.confirm({ 
        // size: "small",
        title: "Eliminar",
        message: '<p>Estás seguro que deseas eliminar?</p> <p>'+nombre+'</p>',
        callback: function(result){ 
            if (result) {
                eliminarDineroCustodia(id);
            }
        }
    })
}

function eliminarDineroCustodia(id) {

    if (id == "" || id == null) {return false};

    var datos = {
        'cmd': 'eliminar-dinero-en-custodia',
        'id_custodia': id
    }

    $.ajax({
        type: "POST",
        url: "../command.php",
        data: datos,
        async: false,
        success: function (response) {
            console.log(response);

            if(response == '2') {
                bootbox.alert({
                    title: "",
                    message: "Dinero en custodia eliminado correctamente.",
                    callback: function (result) {
                        location.reload();
                    }
                });
            } else if(response == '1') {
                bootbox.alert({
                    title: "",
                    message: "Dinero en custodia no encontrado.",
                    callback: function (result) {
                    }
                });
            } else {         

                bootbox.alert('Error al eliminar dinero en custodia.');
            }
   
        }
    });
}






$(function() {
    tablaDineroEnCustodia();


    $('#agregar-agregar-custodia').change(function (e) { 
        e.preventDefault();
        $('#div-agregar-custodia').collapse('toggle');
    });


    $('#montoInicialSwitch').change(function (e) { 
        e.preventDefault();
        $('#form-monto-inicial').collapse('toggle');
    });


    $('#btn-ingresar').on('click', function () {
        if (ingresarDineroenCustodia() == false) {
            bootbox.alert('Revise los datos ingresados');
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



});