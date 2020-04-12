function selectTipoGasto() {
    $.ajax({
        type: "POST",
        url: "../command.php",
        data: "cmd=select-tipo-gasto",
        dataType: 'JSON',
        success: function (response) {

            var select = $('#select-tipo-gasto');

            var html = '<option selected value="0">Seleccione tipo de gasto...</option>';

            response.forEach(element => {
                html += '<option value="'+element['id_tipo_gasto']+'">'+element['nombre_tipo_gasto']+'</option>';
            });
            select.html(html);
        }
    });
  }
function selectDineroCustodia() {
    $.ajax({
        type: "POST",
        url: "../command.php",
        data: "cmd=select-custodia",
        dataType: 'JSON',
        success: function (response) {

            var select = $('#inputCustodia');

            var html = '<option selected value="0">Seleccione dinero en custodia...</option>';

            response.forEach(element => {
                html += '<option value="'+element['id_custodia']+'">'+element['nombre']+'</option>';
            });
            select.html(html);
        }
    });
  }
function tablaGastos() {
    $.ajax({
        type: "POST",
        url: "../command.php",
        data: "cmd=tabla-gastos",
        dataType: 'JSON',
        success: function (response) {

            console.log(response);
            
            if (response.length > 0) {

                // $('table').collapse('show');
                // $('#msg-sin-gastos').collapse('hide');

                $('table').show();
                $('#msg-sin-gastos').hide();

                
                var tabla = $('#tabla-gastos-body');
                
                var html = '';
                    
                var i = 0;
                response.forEach(element => {
                    i++;
                    // html += '<option value="'+element['id_tipo_gasto']+'">'+element['nombre_tipo_gasto']+'</option>';
                    html += '<tr>';
                    html += '<th scope="row">'+i+'</th>';
                    html += '<td class="td-descripcion nowrap txt-left">'+element['descripcion']+'</th>';
                    html += '<td>$'+separadorMiles(element['monto'])+'</th>';
                    
                    if (element['id_dinero_custodia'] == null) {
                        html += '<td>No</th>';
                    } else {
                        html += '<td><a class="iframe" data-fancybox="" data-type="iframe" data-src="../dinero_en_custodia/movimientos/movimientos.php?id='+element['id_dinero_custodia']+'&amp;sb=no" href="javascript:;"><button type="button" class="btn btn-success btn-sm"><i class="fas fa-archive"></i> Ver</button></a></th>';
                    }
                    html += '<td class="td-acciones"><i class="fa fa-user usuario"  data-toggle="tooltip" aria-hidden="true" title="'+element['usuario_ingreso']+'"></i><i class="fas fa-edit cursor modificar" aria-hidden="true" value="'+element['id_gasto']+'" title="Modificar"></i><i class="fas fa-trash-alt cursor eliminar" aria-hidden="true" value="'+element['id_gasto']+'" title="Eliminar"></i></th>';
                    html += '</tr>';
                });
                tabla.html(html);
            
            } else {
                $('table').hide();
                $('#msg-sin-gastos').show();
                // $('table').collapse('hide');
                // $('#msg-sin-gastos').collapse('show');
            }
            $('[data-toggle="tooltip"]').tooltip();

            $(".iframe").fancybox({
                iframe: {
                    scrolling : 'auto',
                    preload   : false
        
                }
            });

        }
    });
  }

function ingresarGasto() {

    var tipoGasto = $('#select-tipo-gasto').val();
    var monto = limpiarNumero($('#monto').val());
    var descripcion = $('#descripcion').val();
    var custodiaCheck = document.getElementById('asociarSwitch').checked;
    var idDineroCustodia  = $('#inputCustodia').val();

    if (tipoGasto == "") {return false};
    if (monto == "") {return false};
    if (descripcion == "") {return false};

    var datos = {
        'cmd': 'ingresar-gasto',
        'id_tipo_gasto': tipoGasto,
        'monto': monto,
        'descripcion': descripcion
    }

    var datosCustodia = {
        'cmd': 'ingresar-movimiento-custodia',
        'id_custodia': idDineroCustodia,
        'tipoMov': '1',
        'monto': monto,
        'comentario': descripcion,
        'gasto': 't'
    }




    if (custodiaCheck) {
        datos['dinero_en_custodia'] = 't';
        if (idDineroCustodia == "") {return false};
        datos['id_dinero_custodia'] = idDineroCustodia;

        $.ajax({
            type: "POST",
            url: "../command.php",
            data: datosCustodia,
            async: false,
            success: function (response) {
                if(response == '1') {
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
                                    message: "Gasto y dinero en custodia ingresados correctamente",
                                    centerVertical: true,
                                    callback: function (result) {
                                        location.reload();
                                    }
                                });
    
                            } else {
                                bootbox.alert('Error al ingresar gasto');
                            }               
                        }
                    });
    
                } else {                
                    bootbox.alert('Error al agregar movimiento de dinero en custodia.');
                }
       
            }
        });





    } else {
        datos['dinero_en_custodia'] = 'f';
        datos['id_dinero_custodia'] = 0;

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
                        message: "Gasto ingresado correctamente",
                        centerVertical: true,
                        callback: function (result) {
                            location.reload();
                        }
                    });

                } else {
                    bootbox.alert('Error al ingresar gasto');
                }               
            }
        });


    }
}

$(function() {
    selectTipoGasto();
    selectDineroCustodia();
    tablaGastos();

    
    $(".iframe").fancybox({
        iframe: {
            scrolling : 'auto',
            preload   : false

        },
        afterClose: function( instance, slide ) {
            selectDineroCustodia();
        }

    });


    $('#agregarGastoSwitch').change(function (e) { 
        e.preventDefault();
        $('#div-agregar-gasto').collapse('toggle');
    });
    $('#asociarSwitch').change(function (e) { 
        e.preventDefault();
        $('#form-dinero-cust').collapse('toggle');
    });


    $('#btn-ingresar').on('click', function () {
        if (ingresarGasto() == false) {
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