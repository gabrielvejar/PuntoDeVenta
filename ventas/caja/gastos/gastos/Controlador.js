var datos = {};
var id_apertura = getUrlParam('id','0');

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
    // var datos = {
    //     'cmd': 'tabla-gastos'
    // }

    datos['cmd'] = 'tabla-gastos';

    if (id_apertura != '0') {
        datos['id_apertura'] = id_apertura;
        $('#id_apertura').text('Caja ID: '+id_apertura);
    }

    $.ajax({
        type: "POST",
        url: "../command.php",
        data: datos,
        dataType: 'JSON',
        success: function (response) {

            console.log(response);

            var total = 0;
            
            if (response.length > 0) {

                // $('table').collapse('show');
                // $('#msg-sin-gastos').collapse('hide');

                $('table').show();
                $('#msg-sin-gastos').hide();

                
                var tabla = $('#tabla-gastos-body');
                
                var html = '';
                    
                var i = 0;
                response.forEach(element => {
                    total += parseInt(element['monto']);
                    i++;
                    // html += '<option value="'+element['id_tipo_gasto']+'">'+element['nombre_tipo_gasto']+'</option>';
                    html += '<tr>';
                    html += '<th scope="row">'+i+'</th>';
                    html += '<td class="nowrap">'+element['fecha']+'</td>';
                    html += '<td>'+element['hora']+'</td>';
                    html += '<td class="td-descripcion txt-left">'+element['descripcion']+'</th>';
                    html += '<td>$'+separadorMiles(element['monto'])+'</td>';
                    
                    if (element['id_dinero_custodia'] == null) {
                        html += '<td>No</th>';
                    } else {
                        html += '<td><a class="iframe" data-fancybox="" data-type="iframe" data-src="../dinero_en_custodia/movimientos/movimientos.php?id='+element['id_dinero_custodia']+'&amp;sb=no" href="javascript:;"><button type="button" class="btn btn-success btn-sm">Ver</button></a></th>';
                    }
                    // html += '<td class="td-acciones"><i class="fa fa-user usuario"  data-toggle="tooltip" aria-hidden="true" title="'+element['usuario_ingreso']+'"></i><i class="fas fa-edit cursor modificar" aria-hidden="true" value="'+element['id_gasto']+'" title="Modificar"></i><i class="fas fa-trash-alt cursor eliminar" aria-hidden="true" onclick="elim('+element['id_gasto']+', '+element['id_gasto']+'" title="Eliminar"></i></th>';
                    html += '<td class="td-acciones">';
                    html += '<i class="fa fa-user usuario"  data-toggle="tooltip" aria-hidden="true" title="'+element['usuario_ingreso']+'"></i>';
                    // html += '<i class="fas fa-edit cursor modificar" aria-hidden="true" value="'+element['id_gasto']+'" title="Modificar"></i>';
                    if (id_apertura != '0') html += '<i class="fas fa-trash-alt cursor eliminar" data-toggle="tooltip" aria-hidden="true" onclick="elim('+element['id_gasto']+', '+element['id_mov_custodia']+')" title="Eliminar"></i>';
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
            $('#total-gastos').text('Total: $'+separadorMiles(total));


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
                if(!isNaN(response) && response != '0') {
                    console.log('response id mov: '+response);
                    
                    datos['id_movimiento'] = response;

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
        datos['id_movimiento'] = 0;

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


function elim (idGasto, idMovCust) {

    if (idGasto == "" || idGasto == null) {return false};
    
    var mensaje = "";

    if (idMovCust != null) {
        mensaje += '<p>Este gasto tiene un movimiento en dinero en custodia, si lo eliminas también se eliminará ese movimiento.</p>';
    };
    
    mensaje += '<p>Estás seguro que deseas eliminar este gasto?</p>';

    bootbox.confirm({ 
        // size: "small",
        title: "Eliminar",
        message: mensaje,
        callback: function(result){ 
            if (result) {
                eliminarGasto(idGasto);
            }
        }
    })
}

function eliminarGasto(idGasto) {

    if (idGasto == "" || idGasto == null) {return false};

    var datos = {
        'cmd': 'eliminar-gasto',
        'id_gasto': idGasto
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
                    message: "Gasto eliminado correctamente.",
                    callback: function (result) {
                        tablaGastos();
                    }
                });
            } else if(response == '2') {
                bootbox.alert({
                    title: "",
                    message: "Gasto y movimiento de dinero en custodia eliminados correctamente.",
                    callback: function (result) {
                        tablaGastos();
                    }
                });
            } else if(response == '0') {
                bootbox.alert({
                    title: "",
                    message: "Gasto no encontrado.",
                    callback: function (result) {
                    }
                });
            } else {         

                bootbox.alert('Error al eliminar dinero en custodia.');
            }
   
        }
    });
}






function limpiarFiltros() {
    $('.filtros').val('');
}

function filtrar() {
    var fechainicio = $('#inputFechaInicio').val();
    datos['fechainicio'] = fechainicio;

    var fechafin = $('#inputFechaFin').val();
    datos['fechafin'] = fechafin;

    tablaGastos();
}





















///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

$(function() {
    selectTipoGasto();
    selectDineroCustodia();
    tablaGastos();

    if (id_apertura == '0') {
        document.getElementById("superior-ingreso").remove(); //eliminar div de ingreso de gasto
    }


    $('#btn-filtrar').click(function (e) { 
        e.preventDefault();
        filtrar();
    });
    
    
    $('#btn-limpiar').click(function (e) { 
        e.preventDefault();
        limpiarFiltros();
        filtrar();
    });
    

$('#btn-otro').click(function (e) { 
    e.preventDefault();
    $.fancybox.open({
        src  : '../dinero_en_custodia/custodia.php?&sb=no',
        type : 'iframe',
        opts : {
          afterShow : function( instance, current ) {
            console.info( 'done!' );
          },
          iframe : {
              preload : false
          },
            afterClose: function( instance, slide ) {
                selectDineroCustodia();
            }
        }
      });
});

    
    // $(".iframe").fancybox({
    //     iframe: {
    //         scrolling : 'auto',
    //         preload   : false

    //     },
    //     beforeClose: function( instance, slide ) {
    //         selectDineroCustodia();
    //     }

    // });


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