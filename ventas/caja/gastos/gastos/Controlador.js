function selectTipoGasto() {
    $.ajax({
        type: "POST",
        url: "../command.php",
        data: "cmd=select-tipo-gasto",
        dataType: 'JSON',
        success: function (response) {

            var select = $('#select-tipo-gasto');

            var html = '<option selected>Seleccione tipo de gasto...</option>';

            response.forEach(element => {
                html += '<option value="'+element['id_tipo_gasto']+'">'+element['nombre_tipo_gasto']+'</option>';
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

                $('table').collapse('show');

                
                var tabla = $('#tabla-gastos-body');
                
                var html = '';
                    
                var i = 0;
                response.forEach(element => {
                    i++;
                    // html += '<option value="'+element['id_tipo_gasto']+'">'+element['nombre_tipo_gasto']+'</option>';
                    html += '<tr>';
                    html += '<th scope="row">'+i+'</th>';
                    html += '<td class="nowrap txt-left">'+element['descripcion']+'</th>';
                    html += '<td>'+element['monto']+'</th>';
                    
                    if (element['id_dinero_custodia'] == null) {
                        html += '<td>No</th>';
                    } else {
                        html += '<td><button type="button" class="btn btn-info btn-sm" value="'+element['id_dinero_custodia']+'">Si</button></th>';
                    }
                    html += '<td class="td-acciones"><i class="fa fa-user usuario" aria-hidden="true" title="'+element['usuario_ingreso']+'"></i><i class="fa fa-pencil-square-o cursor modificar" aria-hidden="true" value="'+element['id_gasto']+'" title="Modificar"></i><i class="fa fa-trash-o cursor eliminar" aria-hidden="true" value="'+element['id_gasto']+'" title="Eliminar"></i></th>';
                    html += '</tr>';
                });
                tabla.html(html);
            
            } else {
                $('table').collapse('hide');
            }

        }
    });
  }

function ingresarGasto() {
    var tipoGasto = $('#select-tipo-gasto').val();
    var monto = $('#monto').val();
    var descripcion = $('#descripcion').val();
    var custodiaCheck = document.getElementById('asociarCheck').checked;
    var idDineroCustodia;

    if (tipoGasto == "") {return false};
    if (monto == "") {return false};
    if (descripcion == "") {return false};

    var datos = {
        'cmd': 'ingresar-gasto',
        'id_tipo_gasto': tipoGasto,
        'monto': monto,
        'descripcion': descripcion
    }

    if (custodiaCheck) {
        datos['dinero_en_custodia'] = 't';
        if (idDineroCustodia == "") {return false};
        datos['id_dinero_custodia'] = idDineroCustodia;
    } else {
        datos['dinero_en_custodia'] = 'f';
        datos['id_dinero_custodia'] = 0;
    }
    

    $.ajax({
        type: "POST",
        url: "../command.php",
        data: datos,
        async: false,
        success: function (response) {
            console.log(response);

            if(isNaN(response)) {
                bootbox.alert('Error al ingresar gasto');
            } else {
                // bootbox.alert('Gasto ingresado');
                bootbox.alert({
                    title: "",
                    message: "Gasto ingresado correctamente",
                    centerVertical: true,
                    callback: function (result) {
                        location.reload();
                    }
                });
            }

   
        }
    });
}


$(function() {
    selectTipoGasto();
    tablaGastos();

    $('#asociarCheck').on('click', function () {
        var seleccionado = document.getElementById('asociarCheck').checked

        if (seleccionado) {
            $('#form-dinero-cust').collapse('show');
        } else {
            $('#form-dinero-cust').collapse('hide');
            //TODO eliminar los datos de dinero en custodia ingresados al ocultar... o quizas no...
        }
            
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



});