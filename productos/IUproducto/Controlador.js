var getCodigo = "";
var nombre = "";
var precio = "";
var unidad = "";
var categoria = "";
var imagen = "";


var inputNombre = "";
var inputPrecio = "";
var selectUnidad = "";
var selectCategoria = "";
var inputImagen = "";



$( document ).ready(function() {

    datosProducto();
    comboCategorias();
    comboUnidad();

    $('#inp').val("");

    // if($('#inp').val() != ""){
    //     $( "#imagenactual" ).hide();
    //     $('#row-subir').show();
    // }

    // $( "#eliminar-imagen" ).click(function() {
    //     $( "#imagenactual" ).hide();
    //     $('#row-subir').show();
    //     $('#cambio-imagen').val("t");
    //     // document.getElementById('cambio-imagen').value = "t";
    //   });

      $( "#codigo" ).change(function() {
        datosProducto();
      });

    

    // $(".iframe").fancybox({
    //     iframe: {
    //         scrolling : 'auto',
    //         preload   : false

    //     }
    // });

});



  //Relleno de listado de productos
   function comboCategorias() {
    var ruta   = "../command.php";
    var cmd    = "cmd=combo-categorias";
    var params = cmd;
    var metodo = "GET";
    var async  = false;
    var json  = true;
    var combo  = document.getElementById('categoria');

    ajax(ruta, params, metodo, async,json,function(respuesta){

        var cuerpo = '<option value="">-Selecione una categoría-</option>';
        for (i in respuesta){

            if (respuesta[i][0] == categoria) {
                cuerpo += '<option value="'+respuesta[i][0]+'" selected>'+respuesta[i][1]+'</option>';
            } else {
                cuerpo += '<option value="'+respuesta[i][0]+'">'+respuesta[i][1]+'</option>';
            }
        }

        combo.innerHTML = cuerpo;

    });

}
   //Relleno de listado de unidad
   function comboUnidad() {
    var ruta   = "../command.php";
    var cmd    = "cmd=combo-unidad";
    var params = cmd;
    var metodo = "GET";
    var async  = false;
    var json  = true;
    var combo  = document.getElementById('unidad');

    ajax(ruta, params, metodo, async,json,function(respuesta){
        
        var cuerpo = '<option value="">-Selecione unidad-</option>';
        for (i in respuesta){

            if (respuesta[i][0] == unidad) {
                cuerpo += '<option value="'+respuesta[i][0]+'" selected>'+respuesta[i][1]+'</option>';
            } else {
                cuerpo += '<option value="'+respuesta[i][0]+'">'+respuesta[i][1]+'</option>';
            }

        }

        combo.innerHTML = cuerpo;

    });

}

   //Relleno de datos de producto
   function datosProducto() {
    getCodigo = document.getElementById('codigo').value;
    var ruta   = "../command.php";
    var cmd    = "cmd=detalle-producto";
    var codigo    = "codigo="+getCodigo;
    var params = cmd + "&" + codigo;
    var metodo = "GET";
    var async  = false;
    var json  = true;

    ajax(ruta, params, metodo, async,json,function(respuesta){


        console.log(respuesta.length);

        if (respuesta.length > 0){

            nombre = respuesta[0][1];
            precio = respuesta[0][2];
            unidad = respuesta[0][5];
            categoria = respuesta[0][4];
            imagen = respuesta[0][3];
            activo =  respuesta[0][6];
     

            if (document.getElementById("accion").value == "Agregar") {

                if (activo == 'f') {

                    var mensaje = '<p>Se ha encontrado un producto en la papelera</p>';
                    mensaje     += '<p>Código: '+getCodigo+'</p>';
                    mensaje     += '<p>Nombre: '+nombre+'</p>';
                    mensaje     += '<p><strong>Quieres recuperarlo?</strong></p>';

                    bootbox.confirm({ 
                        size: "large",
                        title: "Recuperar producto",
                        message: mensaje,
                        callback: function(result){ 
                            if (result) {
                                window.location.href = "IUproducto.php?producto=2&codigo="+getCodigo;
                            }
                        }
                    })

                } else {
        
                    var mensaje = '<p>El código ingresado ya existe</p>';
                    mensaje     += '<p>Código: '+getCodigo+'</p>';
                    mensaje     += '<p>Nombre: '+nombre+'</p>';
                    mensaje     += '<p><strong>Quieres modificarlo?</strong></p>';

                    bootbox.confirm({ 
                        size: "large",
                        title: "Código duplicado",
                        message: mensaje,
                        callback: function(result){ 
                            if (result) {
                                window.location.href = "IUproducto.php?producto=2&codigo="+getCodigo;
                            } else {
                                document.getElementById('codigo').value="";
                            }
                        }
                    })
                }   


            } else {
                document.getElementById('nombre').value=nombre;
                document.getElementById('precio').value=precio;
                comboCategorias();
                comboUnidad();

                if (imagen != ""){
                    document.getElementById('imagenactual').innerHTML = ' <a id="eliminar-imagen" class="cursor">Eliminar Imagen</a> <div class="img-producto" id="'+imagen+'"><img src="/PuntodeVenta/img/productos/' + imagen +'"  width="50%" > </div>';
                    $('#row-subir').hide();
                    $( "#eliminar-imagen" ).click(function() {
                        $( "#imagenactual" ).hide();
                        $('#row-subir').show();
                        $('#cambio-imagen').val("t");
                      });
                } else {
                    document.getElementById('imagenactual').innerHTML = "";
                    $('#row-subir').show();
                    document.getElementById('cambio-imagen').value = "t";
                } 
            }
    
        } else {
            console.log("vaciar campos");
            
            document.getElementById('unidad').selectedIndex="0";
            document.getElementById('categoria').selectedIndex="0";

            document.getElementById('imagenactual').innerHTML = "";
            document.getElementById('cambio-imagen').value = "t";
            document.getElementById('nombre').value="";
            document.getElementById('precio').value="";


        }

    });


}


function previewImage() {        
    var reader = new FileReader();         
    if (document.getElementById('inp').files[0] == null) {
        document.getElementById('vistaprevia').style.display = "none";
    } else {
        reader.readAsDataURL(document.getElementById('inp').files[0]);         
        reader.onload = function (e) {             
            document.getElementById('vistaprevia').style.display = "";
            document.getElementById('uploadPreview').src = e.target.result;
        };
    }     
}