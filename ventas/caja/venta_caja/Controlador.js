
var listaDetalleDB = [];
var listaDetalle = [];
var id_venta = document.getElementById('id_venta_temp').value;

function buscarDetalle() {

    var ruta   = "../../command.php";
    var cmd    = "buscar-venta-temporal";
    var params = "cmd="+cmd+"&id_venta_temp="+id_venta;
    var metodo = "GET";
    var async  = false;
    var json  = true;
    
    ajax(ruta, params, metodo, async,json,function(respuesta){

        listaDetalleDB = respuesta;

    });

}

function listarDetalle() {
    var tabla = $('#cuerpo-tabla-detalle');
    var html = '';
    var numFila = 0;
    for (var i=0; i < listaDetalleDB.length; i++) {
        numFila++;

            html += '<tr>'
            html += '<th scope="row"><span id="t-numfila">'+(numFila)+'</span></th>';
            html +='<td><span id="t-nombre">'+listaDetalleDB[i].nombre+'</span></td>';
            html +='<td><span id="t-precioun">$'+separadorMiles(listaDetalleDB[i].precio)+'</span></td>';


            if ( (parseFloat(listaDetalleDB[i].cantidad).toFixed(2) - parseInt(listaDetalleDB[i].cantidad)) > 0 ) {
                // es un float
                html +='<td><span id="t-cantidad">'+parseFloat(listaDetalleDB[i].cantidad).toFixed(2)+'</span> <span id="t-unidad">'+listaDetalleDB[i].unidad+'</span></td>';
            } else {
                html +='<td><span id="t-cantidad">'+parseInt(listaDetalleDB[i].cantidad)+'</span> <span id="t-unidad">'+listaDetalleDB[i].unidad+'</span></td>';
            }

            
           
           
           
            html +='<td><span id="t-preciototalprod">$'+separadorMiles(listaDetalleDB[i].monto)+'</span></td>';
            html +='<td><i class="fa fa-times x-detalle" aria-hidden="true"  onclick="borrarLineaDetalledb('+i+','+listaDetalleDB[i].id_detalle+')">';
            html +='</tr>';

    }

    for (var i=0; i < listaDetalle.length; i++) {
        numFila++;
            html += '<tr>'
            html += '<th scope="row"><span id="t-numfila">'+(numFila)+'</span></th>';
            html +='<td><span id="t-nombre">'+listaDetalle[i].nombre+'</span></td>';
            html +='<td><span id="t-precioun">$'+separadorMiles(listaDetalle[i].precio)+'</span></td>';
            html +='<td><span id="t-cantidad">'+listaDetalle[i].cantidad+'</span> <span id="t-unidad">'+listaDetalle[i].unidad+'</span></td>';
            html +='<td><span id="t-preciototalprod">$'+separadorMiles(listaDetalle[i].monto)+'</span></td>';
            html +='<td><i class="fa fa-times x-detalle" aria-hidden="true"  onclick="borrarLineaDetalle('+i+')">';
            html +='</tr>';

    }
    tabla.html(html);

    if (listaDetalleDB.length > 0) {
        $('#titulo').text('CAJA - N° DE ATENCIÓN: '+listaDetalleDB[0].id_diario);
    }

    // scroll final del div
    var objDiv = document.getElementById("div-tabla-detalle");
    objDiv.scrollTop = objDiv.scrollHeight;


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

    var getPrecio = limpiarNumero($('#precio_producto').val());
    var getMonto = limpiarNumero($('#total_producto').val());
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

        for (indice; indice<listaDetalle.length; indice++){
            if (listaDetalle[indice].codigo == getCodigo) {
                existeLinea++;
                // console.log('existe producto');
                break;
            }
        }

    }

    if (existeLinea > 0) {


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
        
        listaDetalle.push(lineaDetalle);
        
    }


    // $('#codigo').val('');
    // buscarProducto();
    // listarDetalle();
    // $('#precio-item').collapse('hide');

    document.getElementById("codigo").value = "";
    document.getElementById("codigo").focus();
    listarDetalle();


    $('#input-total').val( calcular_total_venta());
    
    formatearDinero('#input-total', '');


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




function borrarLineaDetalle (indice) {

    bootbox.confirm({ 
        size: "small",
        title: "Eliminar",
        message: '<p>Estas seguro de eliminar: <b>'+listaDetalle[indice].nombre+'?</b></p>',
        centerVertical: true,
        callback: function(result){ 
            if (result) {
                listaDetalle.splice(indice, 1);
                listarDetalle();
                // calcular_total_venta();
                $('#input-total').val( calcular_total_venta());
                formatearDinero('#input-total','');
            }
        }
    })

} 


function borrarLineaDetalledb (indice, id) {

    bootbox.confirm({ 
        size: "small",
        title: "Eliminar",
        message: '<p>Estas seguro de eliminar: <b>'+listaDetalleDB[indice].nombre+'?</b></p>',
        centerVertical: true,
        callback: function(result){ 
            if (result) {
                //TODO Eliminar linea de detalle en db
                console.log('entro paso 1');
                
                $.ajax({
                    type: "POST",
                    url: "../../command.php",
                    data: {
                        'cmd': 'eliminar-detalle-db',
                        'id_detalle': id
                    },
                    success: function (response) {
                        buscarDetalle();
                        listarDetalle();
                    }
                });


                // listaDetalle.splice(indice, 1);
                // listarDetalle();
                // calcular_total_venta();
            }
        }
    })

}


function buscarProducto() {
    
    var codigo  = document.getElementById('codigo').value;
    document.getElementById("codigo").readOnly = false;
    document.getElementById("nombre").readOnly = false;

    var ruta   = "../../command.php";
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
        console.log(respuesta);
        var filas = Object.keys(respuesta).length;
        console.log(filas);

        if (filas == 1) {


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
                $("#img-producto").attr("src","../../../img/productos/"+respuesta[0]["imagen"]);
            } else {
                $("#img-producto").attr("src","../../../img/productos/sinimagen.jpg");
            }

            if (respuesta[0]["id_promocion"] != '' && respuesta[0]["promo_activo"] == 't') {
                document.getElementById('promo').value = respuesta[0]["descripcion_promo"];
            } else {
                document.getElementById('promo').value = "Sin Promoción";
            }





            if (respuesta[0].idunidad == "1") {
                $('#precio-item').collapse('show');
                $('#otraCantidad').collapse('hide');
                // document.getElementById("total_producto").readOnly = false;
                // document.getElementById("total_producto").focus();
                document.getElementById("total_producto").readOnly = false;
                document.getElementById("total_producto").value = "";
                document.getElementById("total_producto").focus();
                document.getElementById("prod_pesado").value = "1";

            } else {
                $('#otraCantidad').collapse('show');
                $('#precio-item').collapse('hide');
                // document.getElementById("cantidad").focus();
                // calcular_total_producto();

                document.getElementById("total_producto").readOnly = true;
                document.getElementById("prod_pesado").value = "";

                calcular_total_producto();
                agregarLinea();
            }


            
        } else {
            console.log('producto no encontrado');
            $('#precio-item').collapse('hide');
            $('.descuento').collapse('hide');
            $("#img-producto").attr("src","../../../img/logopanaderia.PNG");
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

        if (veces > 0) {
            $('.descuento').collapse('show');
            $('#promo_aplica').val('1');
        } else {
            $('#promo_aplica').val('');
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
    console.log(total_producto);

    $('#total_producto').val(total_producto);

}

function calcular_kilos_producto () {
    var totalProducto = $('#total_producto').val()*1;
    var precioProducto = $('#precio_producto').val()*1;

    var kilos = totalProducto / precioProducto;
    console.log(kilos);

    $('#cantidad').val(kilos.toFixed(2));

}

function calcular_total_venta () {

    var totalVenta = 0;

    for (var i=0; i < listaDetalleDB.length; i++) {
        totalVenta = totalVenta + listaDetalleDB[i].monto*1;
    }
    for (var i=0; i < listaDetalle.length; i++) {
        totalVenta = totalVenta + listaDetalle[i].monto*1;
    }
    
    return totalVenta;
}

function leyRedondeo(monto) { 
    var unidad = Math.round((monto/10 - Math.floor(monto/10))*10);
    var nuevoMonto = monto;

    if (unidad <= 5) {
       nuevoMonto = monto - unidad;
    } else if (unidad > 5) {
        nuevoMonto = monto + 10 - unidad;
    }
    
    return nuevoMonto;
}


function agre_canc_collapse () {
    $('#botonera').collapse('show'); 
    $('#btns1').collapse('show');
    $('#btns-pago-efectivo').collapse('hide');
    $('#row1').collapse('hide');
    $('#precio-item').collapse('hide');
    $('#div-boton-detalle').collapse('show');
    if (id_venta != 0) {
        $('#div-tabla-detalle').css('height', '31rem');
    }
}

function sumarBillete (valor) {
    var efectivo = parseInt($('#input-efectivo').val());
    var billete = parseInt(valor);
    if(isNaN(efectivo)) {
        $('#input-efectivo').val(billete);
    } else {
        $('#input-efectivo').val(efectivo+billete);
    }
    calc_vuelto();
}

function calc_vuelto () {
    var total = parseInt(limpiarNumero($('#input-total').val()));
    var efectivo = parseInt(limpiarNumero($('#input-efectivo').val()));
    $('#input-vuelto').val('');

    if (!(isNaN(total) || isNaN(efectivo))) {
        if(efectivo >= total && total>0) {
            $('#input-vuelto').val(efectivo-total);
        }
        
    }

}


function imprimir_recibo () {

        if (listaDetalle.length > 0 || listaDetalleDB.length > 0) {
    
            var totalVenta = $('#input-total').val();
    
            // var dataString = 'key='+key;
            $.ajax({
                    type: "POST",
                    url: rutaraiz+"print/recibo_venta.php",
                    data: {
                        'total': totalVenta,
                        'detalle1':JSON.stringify(listaDetalleDB),
                        'detalle2':JSON.stringify(listaDetalle)
                    },
                    success: function(data) {
                        
                        console.log(data);
                        // location.replace(rutaraiz+'ventas/caja/caja.php');

                        // setTimeout(() => {
                        //     location.replace(rutaraiz+'ventas/caja/caja.php');
                        // }, 5000);

                        // bootbox.alert({
                        //     title: "",
                        //     message: "<b>Recibo impreso</b>",
                        //     centerVertical: true,
                        //     callback: function (result) {
                        //         location.replace(rutaraiz+'ventas/caja/caja.php');
                        //     }
                        // });
    
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

function pagar (id_tipo_pago) {
    // id_tipo_pago
    // 1 efectivo
    // 2 tarjeta

    var cantItems = listaDetalle.length + listaDetalleDB.length;

    if (cantItems > 0) {

        var id_venta = document.getElementById('id_venta_temp').value;
        var monto_venta = limpiarNumero(document.getElementById('input-total').value);
        
        if (listaDetalle.length > 0) {

                var datos = {
                    // 'cmd': 'ingresar-venta-temporal-caja',
                    'cmd': 'ingresar-venta-temporal-caja-idletra',
                    'id_venta_temp': id_venta,
                    'detalle':JSON.stringify(listaDetalle)
                };
    
                $.ajax({
                    type: "POST",
                    url: "../../command.php",
                    data: datos,
                    async: false,
                    success: function(data) {
                        id_venta = data;
                    }
                });
                    
        }

        $.ajax({
            type: "POST",
            url: "../../command.php",
            data: {
                'cmd': 'pagar-venta',
                'id_venta_temp': id_venta,
                'monto_venta': monto_venta,
                'id_tipo_pago': id_tipo_pago
            },
            success: function(data) {

                
                if(data == 0) {

                    bootbox.alert({
                        title: "",
                        message: "<b>Imprimiendo recibo...</b>",
                        centerVertical: true,
                        callback: function (result) {
                            
                            
                        }
                    });
                    imprimir_recibo();
                    setTimeout(() => {
                        location.replace(rutaraiz+'ventas/caja/caja.php');
                    }, 2000);
                    //TODO volver a habilitar

                } else {
                    bootbox.alert({
                        title: "Error",
                        message: "<b>Error al pagar venta</b>",
                        centerVertical: true,
                        callback: function (result) {
                            
                        }
                    });
                }
                
                
            }
        });

    
    } else {
        bootbox.alert("No hay productos agregados");
    }


        // bootbox.alert("Ticket impreso", function(){

        //     // location.reload();
            
        //     var ruta = $('#btn-imprimir').val();

        //     location.replace(ruta);
        // })





}


$(function() {
    
    buscarDetalle();
    listarDetalle();
    $('#input-total').val( calcular_total_venta());
    formatearDinero('#input-total','');
   
    $('#otraCantidad').click(function (e) { 
        e.preventDefault();
        $('#otraCantidad').collapse('hide');
        $('#precio-item').collapse('show');
        document.getElementById("cantidad").focus();
    });

    $(document).on('focus', '#cantidad', function(event) {
        $('#cantidad').val('');
   });

    $(document).on('input', '#cantidad', function(event) {
        if(event.keyCode==13){ //enter
            event.preventDefault();
            agregarLinea();
            document.getElementById("codigo").focus();
         }
         // aplicar promocion
         aplicarDescuento();
         calcular_total_producto();
     });

     $(document).on('input', '#total_producto', function(event) {
        calcular_kilos_producto();
    });

    $(document).on('click', '#btn-agregar', function(event) {

        var prod_pesado = $('#prod_pesado').val();
        if (prod_pesado == 1) {
            agregarLinea();
        } else {
            modificarLinea();
        }

        $('#codigo').val('');
        buscarProducto();
        $('#input-total').val( calcular_total_venta());
        formatearDinero('#input-total','');
        document.getElementById("codigo").focus();

   });






    $(document).on('click', '#btn-efectivo', function(event) {
        $('#btns1').collapse('hide');
        $('#div-boton-detalle').collapse('hide');
        $('#pago-efectivo').collapse('show');
        $('#btns-pago-efectivo').collapse('show');
        document.getElementById("input-efectivo").focus();
        $('#input-total').val(leyRedondeo(calcular_total_venta()));
        formatearDinero('#input-total','');

    });


    $(document).on('click', '#btn-tarjeta', function(event) {
        bootbox.alert('Pago con tarjeta no habilitado.');
    });

    $(document).on('click', '#btn-cancelar-pago', function(event) {
        $('#btns1').collapse('show');
        $('#div-boton-detalle').collapse('show');
        $('#pago-efectivo').collapse('hide');
        $('#btns-pago-efectivo').collapse('hide');
        $('#input-efectivo').val('');
        $('#input-vuelto').val('');

        $('#input-total').val( calcular_total_venta());
        formatearDinero('#input-total', '');
    });

//TODO
    if (id_venta == 0) {
        $('#div-boton-detalle').removeClass('collapse');
        $('#div-boton-detalle').css('display', 'none');
        $('#btn-cancelar').css('display', 'none');
        $('#div1-3').css('justify-content', 'space-around');
        $('#row1').removeClass('collapse');
        $('#div-tabla-detalle').css('transition', 'none');
        $('#div-tabla-detalle').css('height', '20rem');
    }


    $(document).on('click', '#btn-agregar-prod', function(event) {
        $('#botonera').collapse('hide');
        $('#pago-efectivo').collapse('hide');
        $('#row1').collapse('show');
        document.getElementById("codigo").focus();
        $('#div-boton-detalle').collapse('hide');
        $('#div-tabla-detalle').css('height', '21rem');
    });



    $(document).on('click', '#btn-cancelar', function(event) {
        $('#codigo').val('');
        buscarProducto();
        agre_canc_collapse();
    });
    $(document).on('click', '#btn-agregar', function(event) {
        agre_canc_collapse();
    });
    $(document).on('click', '.btn-billete', function(event) {
        sumarBillete(this.value);
    });
    $(document).on('click', '#btn-cerrar', function(event) {
        bootbox.confirm({ 
            size: "small",
            title: "Volver",
            message: '<p>Desea volver a la ventana principal de Caja?</b></p>',
            centerVertical: true,
            callback: function(result){ 
                if (result) {
                    window.location.replace('../caja.php');
                }
            }
        })
    });
    $(document).on('click', '#btn-anular', function(event) {
        bootbox.confirm({ 
            size: "small",
            title: "Anular Venta",
            message: '<p>Esta seguro que desea anular esta venta?</p>',
            centerVertical: true,
            callback: function(result){ 
                if (result) {
                    var cantItems = listaDetalle.length + listaDetalleDB.length;

                    if (id_venta == 0) {
                        window.location.replace('../caja.php');
                    } else {
                        $.ajax({
                            type: "POST",
                            url: "../../command.php",
                            data: {
                                'cmd': 'anular-venta-temp-logico',
                                'id_venta_temp': id_venta
                            },
                            success: function (response) {
                                if (response == id_venta) {
                                    location.replace('../caja.php');
                                } else {
                                    bootbox.alert('Error al anular');
                                }

                            }
                        });
                    }

                }
            }
        })
    });


    $(document).on('click', '#btn-pagar', function(event) {

        if (listaDetalle.length > 0 || listaDetalleDB.length > 0) {
            
            bootbox.confirm({ 
                size: "small",
                title: "Pagar?",
                message: '<p>Finalizar venta?</b></p>',
                centerVertical: true,
                callback: function(result){ 
                    if(result) {
                        pagar(1);
                    }
                }
            })

        } else {
            bootbox.alert("No hay productos agregados");
        }

    });



    $(document).on('focus', '#input-efectivo', function(event) {
        $('#input-efectivo').val('');
        calc_vuelto();
    });


    $(document).on('input', '#input-efectivo', function(event) {
        if(event.keyCode==13){ //enter
            event.preventDefault();
         }
         calc_vuelto();

     });


     $(document).on('click', '#btn-borrar', function(event) {
        $('#codigo').val('');
        buscarProducto();
        document.getElementById("codigo").readOnly = true;
        document.getElementById("codigo").focus();
        document.getElementById("codigo").readOnly = false;
   });

   $(document).on('keyup input', '#codigo', function(event) {
    if(event.keyCode==13){ //enter
        event.preventDefault();
        buscarProducto();
        
     }
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
            url: "../../autocompletar.php",
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