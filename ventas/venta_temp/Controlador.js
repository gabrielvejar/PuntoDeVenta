
var listaDetalle = [];

function agregarLinea() {
    
    var getCodigo = $('#codigo').val();
    var getNombre = $('#nombre').val();
    var getCantidad = $('#cantidad').val();
    if (getCantidad == "") {
        getCantidad = "1";
    }
    var getPrecio = $('#precio_producto').val();
    var getMonto = $('#total_producto').val();
    var getIdproducto = $('#idproducto').val();
    var getIdunidad = $('#idunidad').val();
    var getnombreunidad = $('#nombreunidad').val();
    var getIdpromocion = $('#id_promocion').val();

    if (estaVacio(getCodigo)){ return };




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

    listaDetalle.push(lineaDetalle)

    $('#codigo').val('');
    buscarProducto();
    listarDetalle();
    $('#precio-item').collapse('hide');
    calcular_total_venta();


}


function listarDetalle() {
    var tabla = $('#cuerpo-tabla-detalle');
    var html = '';
    for (var i=0; i < listaDetalle.length; i++) {

            html += '<tr>'
            html += '<th scope="row"><span id="t-numfila">'+(i+1)+'</span></th>';
            html +='<td><span id="t-nombre">'+listaDetalle[i].nombre+'</span></td>';
            html +='<td><span id="t-precioun">'+listaDetalle[i].precio+'</span></td>';
            html +='<td><span id="t-cantidad">'+listaDetalle[i].cantidad+'</span> <span id="t-unidad">'+listaDetalle[i].unidad+'</span></td>';
            html +='<td><span id="t-preciototalprod">'+listaDetalle[i].monto+'</span></td>';
            html +='<td><button class="btn btn-danger btn-borrar-detalle" onclick="borrarLineaDetalle('+i+')">X</button></td>';
            html +='</tr>';

    }
    tabla.html(html);

    // scroll final del div
    var objDiv = document.getElementById("div-tabla-detalle");
    objDiv.scrollTop = objDiv.scrollHeight;

}





function buscarProducto() {
    
    var codigo  = document.getElementById('codigo').value;
    document.getElementById("codigo").readOnly = false;

    var ruta   = "../command.php";
    var cmd    = "detalle-producto";
    var params = "cmd="+cmd+"&codigo="+codigo;
    var metodo = "GET";
    var async  = false;
    var json  = true;

    

    document.getElementById('nombre').value = "";
    document.getElementById('promo').value = "";
    document.getElementById('cantidad').value = "";
    document.getElementById('unidad_producto').value = "";

    document.getElementById('idproducto').value = "";
    document.getElementById('idunidad').value = "";
    document.getElementById('nombreunidad').value = "";
    document.getElementById('id_promocion').value = "";
    
    
    ajax(ruta, params, metodo, async,json,function(respuesta){
        console.log(respuesta);
        var filas = Object.keys(respuesta).length;
        console.log(filas);

        if (filas == 1) {

            document.getElementById("codigo").readOnly = true;

            // hidden
            document.getElementById('idproducto').value = respuesta[0]["idproducto"];
            document.getElementById('idunidad').value = respuesta[0]["idunidad"];
            document.getElementById('id_promocion').value = respuesta[0]["id_promocion"];



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
            
        } else {
            console.log('producto no encontrado');
            $('#precio-item').collapse('hide');
            $("#img-producto").attr("src","../../img/logopanaderia.PNG");
            // $('#img-producto').hide();
        }
        
        
        
    });


}

// $('#codigo').on('keyup input', function(){
//     buscarProducto();
//   });


function calcular_total_producto () {
    var cantidad = $('#cantidad').val();
    if (cantidad == "") {
        cantidad = 1;
    }
    var total_producto = Math.round($('#precio_producto').val() * cantidad);
    console.log(total_producto);
    $('#total_producto').val(total_producto);
}



function calcular_total_venta () {
    var totalVenta = 0;

    for (var i=0; i < listaDetalle.length; i++) {
        totalVenta = totalVenta + listaDetalle[i].monto*1;
    }
    
    $('#total-venta').val(totalVenta);
}


function borrarLineaDetalle (indice) {

    if (confirm('Estas seguro de eliminar: '+listaDetalle[indice].nombre)){
        listaDetalle.splice(indice, 1);
        listarDetalle();
        calcular_total_venta();
        document.getElementById("codigo").focus();
    }



}





























$(function() {

    document.getElementById("codigo").focus();
    calcular_total_venta();


    $(document).on('keyup input', '#codigo', function(event) {
        if(event.keyCode==13){ //enter
            event.preventDefault();
            buscarProducto();
            calcular_total_producto();
            document.getElementById("cantidad").focus();
         }
     });
    $(document).on('keyup input', '#cantidad', function(event) {
        if(event.keyCode==13){ //enter
            event.preventDefault();
            agregarLinea();
            document.getElementById("codigo").focus();
         }
     });

     $(document).on('input', '.calctotal', function(event) {
        calcular_total_producto();
    });

     $(document).on('click', '#btn-mas', function(event) {
        $('#cantidad').val($('#cantidad').val()*1+1);
        calcular_total_producto();
    });

    $(document).on('click', '#btn-menos', function(event) {
         if ($('#cantidad').val()*1 >= 1) {
            $('#cantidad').val($('#cantidad').val()*1-1);
         } else {
            $('#cantidad').val('0');
         }
         calcular_total_producto();
    });


    
    $(document).on('click', '#btn-agregar', function(event) {
        agregarLinea();
        document.getElementById("codigo").focus();
   });


    $(document).on('click', '#btn-buscar', function(event) {
        alert('aqui se debiese abrir la ventana de busqueda de producto');
   });


    $(document).on('click', '#btn-borrar', function(event) {
        $('#codigo').val('');
        buscarProducto();
        document.getElementById("codigo").focus();
   });



 });







