var listaDetalleDB = [];
var listaDetalle = [];

function buscarDetalle() {

    var id_venta = document.getElementById('id_venta_temp').value;

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
            html +='<td><span id="t-precioun">'+listaDetalleDB[i].precio+'</span></td>';
            html +='<td><span id="t-cantidad">'+parseFloat(listaDetalleDB[i].cantidad).toFixed(2)+'</span> <span id="t-unidad">'+listaDetalleDB[i].unidad+'</span></td>';
            html +='<td><span id="t-preciototalprod">'+listaDetalleDB[i].monto+'</span></td>';
            html +='<td><i class="fa fa-times x-detalle" aria-hidden="true"  onclick="borrarLineaDetalledb('+i+','+listaDetalleDB[i].id_detalle+')">';
            html +='</tr>';

    }
    for (var i=0; i < listaDetalle.length; i++) {
        numFila++;
            html += '<tr>'
            html += '<th scope="row"><span id="t-numfila">'+(numFila)+'</span></th>';
            html +='<td><span id="t-nombre">'+listaDetalle[i].nombre+'</span></td>';
            html +='<td><span id="t-precioun">'+listaDetalle[i].precio+'</span></td>';
            html +='<td><span id="t-cantidad">'+listaDetalle[i].cantidad+'</span> <span id="t-unidad">'+listaDetalle[i].unidad+'</span></td>';
            html +='<td><span id="t-preciototalprod">'+listaDetalle[i].monto+'</span></td>';
            html +='<td><i class="fa fa-times x-detalle" aria-hidden="true"  onclick="borrarLineaDetalle('+i+')">';
            html +='</tr>';

    }
    tabla.html(html);

    if (listaDetalleDB.length > 0) {
        $('#idatencion').text(listaDetalleDB[0].id_diario);
    }

    // scroll final del div
    var objDiv = document.getElementById("div-tabla-detalle");
    objDiv.scrollTop = objDiv.scrollHeight;


}

function agregarLinea() {
    
    var getCodigo = $('#codigo').val();
    var getNombre = $('#nombre').val();
    if($('#cantidad').val() == "") {
        $('#cantidad').val('1');
    }
    var getCantidad = parseFloat($('#cantidad').val()).toFixed(2);
    // if (getCantidad == "") {
    //     getCantidad = "1";
    // }
    var getPrecio = $('#precio_producto').val();
    var getMonto = $('#total_producto').val();
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

    $('#codigo').val('');
    buscarProducto();
    listarDetalle();
    $('#precio-item').collapse('hide');
    $('#input-total').val( calcular_total_venta());


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
                calcular_total_venta();
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
                alert('Eliminar detalle id: '+id);
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



            document.getElementById("codigo").readOnly = true;
            document.getElementById("nombre").readOnly = true;

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
            $('#unidad_producto').text(respuesta[0]["nombreunidad"]);
            $('#nombreunidad').val(respuesta[0]["nombreunidad"]);

            // $('#div1-2').show('slow');

            // $('#img-producto').show();

            if (respuesta[0]["imagen"] != '' ) {
                $("#img-producto").attr("src","../../img/productos/"+respuesta[0]["imagen"]);
            } else {
                $("#img-producto").attr("src","../../img/productos/sinimagen.jpg");
            }

            if (respuesta[0]["id_promocion"] != '' && respuesta[0]["promo_activo"] == 't') {
                document.getElementById('promo').value = respuesta[0]["descripcion_promo"];
            } else {
                document.getElementById('promo').value = "Sin Promoción";
            }


            $('#precio-item').collapse('show');
            console.log('show');


            if (respuesta[0].idunidad == "1") {
                document.getElementById("total_producto").readOnly = false;
                document.getElementById("total_producto").focus();

            } else {
                document.getElementById("cantidad").focus();
                calcular_total_producto();
            }


            
        } else {
            console.log('producto no encontrado');
            $('#precio-item').collapse('hide');
            $('.descuento').collapse('hide');
            $("#img-producto").attr("src","../../img/logopanaderia.PNG");
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
    var total_producto = Math.round($('#precio_producto').val() * cantidad) - descuento;
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
    var total = parseInt($('#input-total').val());
    var efectivo = parseInt($('#input-efectivo').val());
    $('#input-vuelto').val('');

    if (!(isNaN(total) || isNaN(efectivo))) {
        if(efectivo >= total && total>0) {
            $('#input-vuelto').val(efectivo-total);
        }
        
    }

}


$(function() {
    buscarDetalle();
    listarDetalle();
    $('#input-total').val( calcular_total_venta());
   

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
        agregarLinea();
   });






    $(document).on('click', '#btn-efectivo', function(event) {
        $('#btns1').collapse('hide');
        $('#div-boton-detalle').collapse('hide');
        $('#pago-efectivo').collapse('show');
        $('#btns-pago-efectivo').collapse('show');
        document.getElementById("input-efectivo").focus();
        $('#input-total').val(leyRedondeo(calcular_total_venta()));

    });
    $(document).on('click', '#btn-cancelar-pago', function(event) {
        $('#btns1').collapse('show');
        $('#div-boton-detalle').collapse('show');
        $('#pago-efectivo').collapse('hide');
        $('#btns-pago-efectivo').collapse('hide');
        $('#input-efectivo').val('');
        $('#input-vuelto').val('');

        $('#input-total').val( calcular_total_venta());
    });
    $(document).on('click', '#btn-agregar-prod', function(event) {
        $('#botonera').collapse('hide');
        $('#pago-efectivo').collapse('hide');
        $('#row1').collapse('show');
        document.getElementById("codigo").focus();
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