// var rutaraiz = $('#ruta').val();


var listaDetalle = [];


function verificarCajaAbierta() {
    $.ajax({
        type: "GET",
        url: "../command.php",
        data: {
            'cmd': 'verificar-caja-abierta'
        },
        success: function (response) {
            if (response == 0){
                bootbox.alert('<br>No se ha realizado apertura de caja. <br>Presione Ok para volver a verificar<br>', function () {
                    location.reload();
                  });
            }
            
        }
    });
}






function agregarLinea() {
    
    // var getCodigo = $('#codigo').val();
    var getCodigo = $('#cod_hidden').val();
    var getNombre = $('#nombre').val();
    if($('#cantidad').val() == "") {
        $('#cantidad').val('1');
    }


    if ( (parseFloat($('#cantidad').val()).toFixed(2) - parseInt($('#cantidad').val())) > 0 ) {
        // es un float
        var getCantidad = parseFloat($('#cantidad').val()).toFixed(2);
    } else {
        var getCantidad = parseInt($('#cantidad').val());
    }



    // if (getCantidad == "") {
    //     getCantidad = "1";
    // }
    var getPrecio = limpiarNumero($('#precio_producto').val());
    var getMonto = limpiarNumero($('#total_producto').val());
    // var getMonto = $('#total_producto').val();
    var getIdproducto = $('#idproducto').val();
    var getIdunidad = $('#idunidad').val();
    var getnombreunidad = $('#nombreunidad').val();
    var getPromoAplica = $('#promo_aplica').val();
    var getIdpromocion = "";
    if (!estaVacio(getPromoAplica)) {
        getIdpromocion = $('#id_promocion').val();
    }

    if (estaVacio(getCodigo)){ return };
    if (estaVacio(getMonto) || getMonto == 0){ return };

    var existeLinea = 0;
    var indice = 0;

    if (listaDetalle != "") {
        
        // listaDetalle.forEach(element => {
        //     debugger;
        //     if (element.codigo == getCodigo) {
        //         existeLinea++;
        //         console.log('existe producto');
        //     }
        //     indice ++;
        // });


// debugger;

        for (indice; indice<listaDetalle.length; indice++){
            if (listaDetalle[indice].codigo == getCodigo) {
                existeLinea++;
                // console.log('existe producto');
                break;
            }
        }
        // console.log('existeLinea: '+existeLinea);
        // console.log('indice: '+indice);
        
    }

    if (existeLinea > 0 && getCodigo != '0000') {


        var getCantidad = $('#cantidad').val();
        if (estaVacio(getCantidad)) {
            getCantidad = 1;
        }
    
        var getMonto = $('#total_producto').val();
    
        var getPromoAplica = $('#promo_aplica').val();
        var getIdpromocion = "";
        if (!estaVacio(getPromoAplica)) {
            getIdpromocion = $('#id_promocion').val();
        }
    
        listaDetalle[indice]["cantidad"] = listaDetalle[indice]["cantidad"]*1 + getCantidad*1;
        listaDetalle[indice]["monto"] = listaDetalle[indice]["monto"]*1+getMonto*1;
        listaDetalle[indice]["idpromocion"] = getIdpromocion;

        // listaDetalle[indice].monto = listaDetalle[indice].monto*1 + getPrecio*1;
        // listaDetalle[indice].cantidad = listaDetalle[indice].cantidad*1 +1;


        // if (indice == listaDetalle.length-1){

        //     listaDetalle[indice].monto = listaDetalle[indice].monto*1 + getPrecio*1;
        //     listaDetalle[indice].cantidad = listaDetalle[indice].cantidad*1 +1;

        // }
        //  else {
            
        //     console.log('no hace nada.. se supone que no es el ultimo');
            
        //     // listaDetalle[indice].monto = listaDetalle[indice].monto*1 + getMonto*1;
        //     // listaDetalle[indice].cantidad = listaDetalle[indice].cantidad*1 + getCantidad*1;
        
        // }
        

    } else {
        
        var lineaDetalle = {
            
            codigo: getCodigo,
            nombre: getNombre,
            precio: getPrecio,
            cantidad: getCantidad,
            monto: getMonto,
            idproducto: getIdproducto,
            unidad: getnombreunidad,
            idunidad: getIdunidad,
            idpromocion: getIdpromocion
            
        }

        if (getCodigo == '0000'){
            lineaDetalle['precio'] = getMonto;
        }
        
        listaDetalle.push(lineaDetalle);
        
    }

    // deshabilitado fix
    // $('#codigo').val('');
    // buscarProducto();

// acaaaaa


                // agregado fix
                document.getElementById("codigo").value = "";
                document.getElementById("codigo").focus();
                // fin agregado fix

    listarDetalle();

        // deshabilitado fix
    // $('#precio-item').collapse('hide');



    calcular_total_venta();

}


function modificarLinea() {

    var indice = 0;
    var existeLinea = 0;
    var getCodigo = $('#cod_hidden').val();

    for (indice; indice<listaDetalle.length; indice++){
        if (listaDetalle[indice].codigo == getCodigo) {
            existeLinea++;
            break;
        }
    }



    if (estaVacio($('#cantidad').val())) {
        $('#cantidad').val('1');
    }

    var getCantidad = $('#cantidad').val()*1 -1;
    $('#cantidad').val(getCantidad);
    calcular_total_producto();

    var getMonto = $('#total_producto').val();

    var getPromoAplica = $('#promo_aplica').val();
    var getIdpromocion = "";
    if (!estaVacio(getPromoAplica)) {
        getIdpromocion = $('#id_promocion').val();
    }

        listaDetalle[indice]["cantidad"] = listaDetalle[indice]["cantidad"]*1 + getCantidad*1;
        listaDetalle[indice]["monto"] = listaDetalle[indice]["monto"]*1+getMonto*1;
        listaDetalle[indice]["idpromocion"] = getIdpromocion;

    listarDetalle();





}






function listarDetalle() {
    var tabla = $('#cuerpo-tabla-detalle');
    var html = '';
    for (var i=0; i < listaDetalle.length; i++) {

            html += '<tr>'
            html += '<th scope="row"><span id="t-numfila">'+(i+1)+'</span></th>';
            html +='<td><span id="t-nombre">'+listaDetalle[i].nombre+'</span></td>';
            html +='<td><span id="t-precioun">$'+separadorMiles(listaDetalle[i].precio)+'</span></td>';
            html +='<td><span id="t-cantidad">'+listaDetalle[i].cantidad+'</span> <span id="t-unidad">'+listaDetalle[i].unidad+'</span></td>';
            html +='<td><span id="t-preciototalprod">$'+separadorMiles(listaDetalle[i].monto)+'</span></td>';
            // html +='<td><button class="btn btn-danger btn-borrar-detalle" onclick="borrarLineaDetalle('+i+')">X</button></td>';
            html +='<td><i class="fa fa-times x-detalle" aria-hidden="true"  onclick="borrarLineaDetalle('+i+')">';
            html +='</tr>';

    }
    tabla.html(html);

    // scroll final del div
    var objDiv = document.getElementById("div-tabla-detalle");
    objDiv.scrollTop = objDiv.scrollHeight;

}


function buscarProducto() {
    $('#total_producto').val('');
    $('#otraCantidad').collapse('hide');

    
    var codigo  = document.getElementById('codigo').value;
    document.getElementById("codigo").readOnly = false;
    document.getElementById("nombre").readOnly = false;

    var ruta   = "../command.php";
    var cmd    = "detalle-producto";
    var params = "cmd="+cmd+"&codigo="+codigo;
    var metodo = "GET";
    var async  = false;
    var json  = true;

    

    document.getElementById('cod_hidden').value = codigo;

    document.getElementById('nombre').value = "";
    document.getElementById('promo').value = "";
    document.getElementById('cantidad').value = "";
    document.getElementById('unidad_producto').value = "";
    document.getElementById('monto_descuento').value = "";

    document.getElementById('idproducto').value = "";
    document.getElementById('idunidad').value = "";
    document.getElementById('nombreunidad').value = "";

    document.getElementById('id_promocion').value = "";
    document.getElementById('promo_cantidad').value = "";
    document.getElementById('promo_tipo_desc').value = "";
    document.getElementById('promo_monto_desc').value = "";
    document.getElementById('promo_activo').value = "";
    
    
    ajax(ruta, params, metodo, async,json,function(respuesta){
        // console.log(respuesta);
        var filas = Object.keys(respuesta).length;
        // console.log(filas);

        if (filas == 1) {
            // $('#fila2').collapse('show');
            $('#fila2').show();
            // deshabilitado fix
            // document.getElementById("codigo").readOnly = true;
            // document.getElementById("nombre").readOnly = true;

            // hidden
            document.getElementById('idproducto').value = respuesta[0]["idproducto"];
            document.getElementById('idunidad').value = respuesta[0]["idunidad"];
            
            // data promo hidden
            document.getElementById('id_promocion').value = respuesta[0]["id_promocion"];
            document.getElementById('promo_cantidad').value = respuesta[0]["cantidad"];
            document.getElementById('promo_tipo_desc').value = respuesta[0]["tipo_descuento"];
            document.getElementById('promo_monto_desc').value = respuesta[0]["descuento"];
            document.getElementById('promo_activo').value = respuesta[0]["promo_activo"];


            document.getElementById('nombre').value = respuesta[0]["nombreproducto"];
            $('#precio_producto').val(respuesta[0]["precio"]);
            formatearDinero('#precio_producto','');
            $('#unidad_producto').text(respuesta[0]["nombreunidad"]);
            $('#nombreunidad').val(respuesta[0]["nombreunidad"]);

            
            // $('#div1-2').show('slow');

            // $('#img-producto').show();

            if (respuesta[0]["imagen"] != '' ) {
                $("#img-producto").attr("src","../../img/productos/"+respuesta[0]["imagen"]);
            } else {
                // $("#img-producto").attr("src","../../img/productos/sinimagen.jpg");
                $("#img-producto").attr("src","../../img/productos/productos.png");
            }

            if (respuesta[0]["id_promocion"] != '' && respuesta[0]["promo_activo"] == 't') {
                document.getElementById('promo').value = respuesta[0]["descripcion_promo"];
            } else {
                document.getElementById('promo').value = "Sin Promoción";
            }





            
            // console.log('show');
            if (respuesta[0].idproducto == "0") {
                document.getElementById("total_producto").readOnly = false;
                document.getElementById("prod_pesado").value = "1";
                // $('#fila2').collapse('hide');
                $('#fila2').hide();
                $('#precio-item').collapse('show');
                document.getElementById("total_producto").focus();
            } else {  

                
                if (respuesta[0].idunidad == "1") {
                    $('#precio-item').collapse('show');
                    $('#otraCantidad').collapse('hide');
                    document.getElementById("total_producto").readOnly = false;
                    document.getElementById("total_producto").value = "";
                    document.getElementById("total_producto").focus();
                    document.getElementById("prod_pesado").value = "1";
                    
                    
                } else {
                    
                    $('#otraCantidad').collapse('show');
                    $('#precio-item').collapse('hide');
                    document.getElementById("total_producto").readOnly = true;
                    document.getElementById("prod_pesado").value = "";
                    
                    // TODO AQUI ESTOY TRABAJANDO
                    
                    // deshabilitado fix
                    // document.getElementById("cantidad").focus();
                    
                    
                    
                    calcular_total_producto();
                    
                    // agregado fix
                    agregarLinea();
                    // fin agregado fix
                }
                
            }
                
            
        } else {
            
            // console.log('producto no encontrado');
            $('#precio-item').collapse('hide');
            $('.descuento').collapse('hide');
            $("#img-producto").attr("src","../../img/productos/productos.png");
            $("#precio_producto").val('');
            $("#cantidad").val('');
            $("#total_producto").val('');

            // $('#img-producto').hide();
        }
        
        
        
    });


}


function aplicarDescuento () {
    var promo_cantidad = document.getElementById('promo_cantidad').value;
    var promo_tipo_desc = document.getElementById('promo_tipo_desc').value;
    var promo_monto_desc = document.getElementById('promo_monto_desc').value;
    var promo_activo = document.getElementById('promo_activo').value;
    var cantidad = document.getElementById('cantidad').value;

    if (promo_activo == 't' && promo_tipo_desc == '1') {

        var veces = Math.floor(cantidad / promo_cantidad);

        document.getElementById('monto_descuento').value = promo_monto_desc * veces;

        // console.log('cantidad: '+cantidad);
        // console.log('promocanti: '+promo_cantidad);
        // console.log('veces: '+veces);

        if (veces > 0) {
            $('.descuento').collapse('show');
            $('#promo_aplica').val('1');
        } else {
            $('#promo_aplica').val('');
            // $('.descuento').collapse('hide');
        }

        
    } else {
        document.getElementById('monto_descuento').value = 0;
        $('.descuento').collapse('hide');
    }

}

function calcular_total_producto () {
    var cantidad = $('#cantidad').val();
    var descuento = document.getElementById('monto_descuento').value;

    if (cantidad == "") {
        cantidad = 1;
    }
    var total_producto = Math.round(limpiarNumero($('#precio_producto').val()) * cantidad) - descuento;
    // console.log(total_producto);

    $('#total_producto').val(total_producto);

}

function calcular_kilos_producto () {
    var totalProducto = limpiarNumero($('#total_producto').val())*1;
    var precioProducto = limpiarNumero($('#precio_producto').val())*1;

    var kilos = totalProducto / precioProducto;
    // console.log(kilos);

    $('#cantidad').val(kilos.toFixed(2));

}



function calcular_total_venta () {

    var totalVenta = 0;

    for (var i=0; i < listaDetalle.length; i++) {
        totalVenta = totalVenta + listaDetalle[i].monto*1;
    }
    
    // $('#total-venta').val(separadorMiles(totalVenta));
    $('#total-venta').val(totalVenta);
    formatearDinero($('#total-venta'), '');
}


function borrarLineaDetalle (indice) {

    // if (confirm('Estas seguro de eliminar: '+listaDetalle[indice].nombre)){
    //     listaDetalle.splice(indice, 1);
    //     listarDetalle();
    //     calcular_total_venta();
    //     document.getElementById("codigo").focus();
    // }


    bootbox.confirm({ 
        size: "small",
        title: "Eliminar",
        message: '<p>Estas seguro de eliminar: <b>'+listaDetalle[indice].nombre+'?</b></p>',
        centerVertical: true,
        callback: function(result){ 
            if (result) {
                listaDetalle.splice(indice, 1);
                listarDetalle();
                calcular_total_venta();
                document.getElementById("codigo").focus();
            }
        }
    })



}

function imprimirTicket(id, total) {
    $.ajax({
        type: "POST",
        url: rutaraiz+"print/ticket_atencion.php",
        data: {
            'num_atencion': id,
            'total': total},
        success: function(data) {
        }
    });
}


function terminarVenta() {

    if (listaDetalle.length > 0) {

        var totalVenta = limpiarNumero($('#total-venta').val());

        // var dataString = 'key='+key;
        $.ajax({
                type: "POST",
                url: "../command.php",
                data: {
                    // 'cmd': 'ingresar-venta-temporal-meson',
                    'cmd': 'ingresar-venta-temporal-meson-idletra',
                    'total': totalVenta,
                    'detalle':JSON.stringify(listaDetalle)},
                success: function(data) {

                    // console.log(data);

                    // imprimirTicket(data, totalVenta); FIXME volver a habilitar

                    setTimeout(() => {
                        location.reload();
                    }, 3000);

                    bootbox.alert({
                        title: "Ticket",
                        message: "Número de atencion: <b>"+data+"</b>",
                        centerVertical: true,
                        callback: function (result) {
                            var ruta = $('#btn-imprimir').val();
                            // location.replace(ruta);
                            location.reload();
                        }
                    });









                }
            });













        // bootbox.alert("Ticket impreso", function(){

        //     // location.reload();
            
        //     var ruta = $('#btn-imprimir').val();

        //     location.replace(ruta);
        // })

    } else {

        bootbox.alert("No hay productos agregados");

    }




}
























$(function() {
    verificarCajaAbierta();

    document.getElementById("codigo").focus();
    calcular_total_venta();


    $(document).on('keyup input', '#codigo', function(event) {
        if(event.keyCode==13){ //enter
            event.preventDefault();
            buscarProducto();
            
         }
     });


    $(document).on('input keydown', '#cantidad', function(event) {
        if(event.keyCode==13){ //enter
            event.preventDefault();
            document.getElementById('btn-agregar').click()
         }

         // aplicar promocion
         aplicarDescuento();
         calcular_total_producto();

     });
    $(document).on('input keydown', '#total_producto', function(event) {
        if(event.keyCode==13){ //enter
            event.preventDefault();
            document.getElementById('btn-agregar').click()
         }


        aplicarDescuento();
        calcular_kilos_producto();

     });





    $(document).on('click', '#btn-agregar', function(event) {


        // fix
        // agregarLinea();
        // document.getElementById("codigo").focus();

        var prod_pesado = $('#prod_pesado').val();
        if (prod_pesado == 1){
            agregarLinea();
        } else {
            modificarLinea();
        }

        $('#codigo').val('');
        buscarProducto();
        calcular_total_venta();
        document.getElementById("codigo").focus();

   });

$('#btn-otra-cant').click(function (e) { 
    e.preventDefault();
    $('#otraCantidad').collapse('hide');
    $('#precio-item').collapse('show');
    document.getElementById("cantidad").focus();
});


    $(document).on('focus', '#nombre', function(event) {
        $('#nombre').val('');
   });
    $(document).on('focus', '#cantidad', function(event) {
        $('#cantidad').val('');
   });

    $(document).on('focus', '#codigo', function(event) {
        $('#codigo').val('');
   });
   $('#codigo').focusout(function() {
    buscarProducto()
  })
   $('#nombre').focusout(function() {
    buscarProducto()
  })


    $(document).on('click', '#btn-borrar', function(event) {
        $('#codigo').val('');
        buscarProducto();
        document.getElementById("codigo").readOnly = true;
        document.getElementById("codigo").focus();
        document.getElementById("codigo").readOnly = false;
   });

   $(document).on('click', '#btn-cancelar', function(event) {
        // console.log(this.value);
        // if (confirm('Esta seguro de cancelar la venta?')) {
        //     location.replace(this.value);
        // }
        
        var ruta = this.value;

        bootbox.confirm({ 
            size: "small",
            title: "Cancelar",
            message: '<p>Estás seguro que deseas cancelar la venta?</p>',
            centerVertical: true,
            callback: function(result){ 
                if (result) {
                    location.replace(ruta);
                }
            },
            buttons: {
                confirm: {
                    label: 'Si',
                    className: 'btn-primary'
                },
                cancel: {
                    label: 'No',
                    className: 'btn-secondary'
                }
            }
        });




});

   $(document).on('click', '#btn-imprimir', function(event) {

    bootbox.confirm({ 
        size: "small",
        // title: "Finalizar venta?",
        message: '<p>Finalizar venta?</p>',
        centerVertical: true,
        callback: function(result){ 
            if (result) {
                terminarVenta();
            }
        }
    });


    

});


//    autocompletar nombre
    $('#nombre').on('keyup', function() {
        var key = $(this).val();
        
        if (key == "") {
            $('#suggestions').fadeOut(500);
            return false;
        }
        

        var dataString = 'key='+key;
	$.ajax({
            type: "POST",
            url: "../autocompletar.php",
            data: dataString,
            success: function(data) {
                //Escribimos las sugerencias que nos manda la consulta
                $('#suggestions').fadeIn(200).html(data);
                //Al hacer click en alguna de las sugerencias
                $('.suggest-element').on('click', function(){
                        //Obtenemos la id unica de la sugerencia pulsada
                        var id = $(this).attr('id');
                        //Editamos el valor del input con data de la sugerencia pulsada
                        // $('#nombre').val($('#'+id).attr('data'));
                         $('#codigo').val(id);
                         buscarProducto();


                        //Hacemos desaparecer el resto de sugerencias
                        $('#suggestions').fadeOut(500);
                        // alert('Has seleccionado el '+id+' '+$('#'+id).attr('data'));
                        return false;
                });
            }
        });
    });

    $("html").click(function() {
        $('#suggestions').fadeOut(500);
    });
    $('#suggestions').click(function (e) {
        e.stopPropagation();
    });








 });







