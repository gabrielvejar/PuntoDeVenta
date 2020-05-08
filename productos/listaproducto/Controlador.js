  var cantProductos = 0;
    
  $(function() {
      document.getElementById('codigo').focus();
  })


    //Relleno de listado de productos
    function listarProductos() {
        var tabla  = document.getElementById('tabla-productos');
        // var inicio  = "&inicio="+document.getElementById('inicio').value;
        var paginaActual  = document.getElementById('paginaactual').value*1;
        var prodXpag  = document.getElementById('prodxpag').value*1;
        var inicio  = "&inicio="+(paginaActual-1)*prodXpag;
        console.log(inicio);
        
        var cant  = "&cant="+document.getElementById('prodxpag').value;
        var nombre  = "&nombre="+document.getElementById('nombre').value;
        var codigo  = "&codigo="+document.getElementById('codigo').value;
        var categoria  = "&categoria="+document.getElementById('categoria').value;

        console.log(categoria);
        

        var ruta   = "../command.php";
        var cmd    = "cmd=tabla-productos";
        var params = cmd+inicio+cant+nombre+codigo+categoria;
        var metodo = "GET";
        var async  = false;
        var json  = true;


        ajax(ruta, params, metodo, async,json,function(respuesta){
            // filas = Object.keys(respuesta).length;
            console.log(respuesta);
            cantProductos= Object.keys(respuesta).length;
            
            var cuerpo = "";
            for (i in respuesta){
                cuerpo += "<tr>";
                cuerpo += "<td>" + respuesta[i][2] + "</td>";
                cuerpo += "<td>" + respuesta[i][5] + "</td>";
                cuerpo += "<td>" + respuesta[i][1] + "</td>";
                var precio = respuesta[i][3]*1;
                // precio = formatNumber.new(precio,'$');  
                precio = '$'+separadorMiles(precio);
                
                cuerpo += "<td>" + precio + '<span class="spunidad">/' + respuesta[i][6] +'</span></td>';

                //modificar y eliminar sin botones
                // var btnMod1 = '<a class="iframe" data-fancybox data-type="iframe" data-src="../IUproducto/IUproducto.php?producto=2&codigo=';
                // var btnMod2 = '" href="javascript:;"><i class="fa fa-pencil-square-o" aria-hidden="true" title="Modificar"></i></a>';
                // var btnElim1 = '<a ><i class="fa fa-trash-o" aria-hidden="true" title="Eliminar" onClick="elim(';
                // var btnElim2 = ')"></i></a>'


                //modificar y eliminar con botones
                if (respuesta[i][0] == '0'){
                    cuerpo += '<td class="col-accion" style="height: 48.6px;"></td>';
                } else {

                    var btnMod1 = '<a class="iframe" data-fancybox data-type="iframe" data-src="../IUproducto/IUproducto.php?producto=2&codigo=';
                    var btnMod2 = '" href="javascript:;"><button class="btn btn-info mx-2" title="Modificar"><i class="fas fa-edit"></i></button></a>';
                    var btnElim1 = '<button class="btn btn-danger mx-2" title="Eliminar" onClick="elim(';
                    var btnElim2 = ')"><i class="fas fa-trash-alt"></i></button>'
                    
                    cuerpo += '<td class="col-accion">' + btnMod1 + respuesta[i][2] +btnMod2 +btnElim1 + respuesta[i][2] +btnElim2 + "</td>";
                }
                
                cuerpo += "</tr>";

                if (respuesta[i][4] == ""){
                    // cuerpo += '<td></td>';
                    // cuerpo += ' <div class="img-producto" id="'+respuesta[i][2]+'"><div><img src="/puntodeventa/img/productos/sinimagen.jpg"  width="70%"></div><div><button class="btn btn-info mod" value="' + respuesta[i][2] +'">Modificar</button></div></div>';
                    cuerpo += '<tr class="img-producto" id="'+respuesta[i][2]+'"><td  colspan="5"> <div><div><img src="/img/productos/sinimagen.jpg"  width="50%"></div></td></tr>';
                } else {
                    // cuerpo += "<tr>";
                    // cuerpo += ' <div class="img-producto" id="'+respuesta[i][2]+'"><div><img src="/puntodeventa/img/productos/' + respuesta[i][4] +'"  width="70%"></div><div><button class="btn btn-info mod" value="' + respuesta[i][2] +'">Modificar</button></div></div>';
                    cuerpo += '<tr class="img-producto" id="'+respuesta[i][2]+'"><td  colspan="5"> <div><div><img src="/img/productos/' + respuesta[i][4] +'"  width="50%"></div></td></tr>';
                    // cuerpo += "</tr>";
                }
            

                
                
            }

            tabla.innerHTML = cuerpo;
            $('.img-producto').hide();
            addRowHandlers();
        });

        document.getElementById('codigo').focus();



        cmd    = "cmd=cant-productos";
        // params = cmd+nombre+codigo+categoria;
        params = cmd+nombre+codigo+categoria;
        metodo = "GET";
        async  = false;
        json  = true;
        
        var navegacion  = document.getElementById('ul-paginacion');


        ajax(ruta, params, metodo, async,json,function(respuesta){

            console.log(respuesta);


            // var totalProductos = Object.keys(respuesta).length;
            var totalProductos = respuesta[0][0];
            

            var paginas = Math.ceil(totalProductos/prodXpag);
            // var paginas = Math.ceil(respuesta/prodXpag);
           
            // console.log(paginas);
            
            var cuerpo = "";

            //boton primera
            if (paginaActual == 1)  {
                cuerpo += '<li class="page-item disabled">';
                cuerpo += '<a class="page-link" tabindex="-1" ><i class="fas fa-angle-double-left"></i></a></li>'
            } else {
                cuerpo += '<li class="page-item">';
                cuerpo += '<a class="page-link cursor" onclick="ir(1)" tabindex="-1"><i class="fas fa-angle-double-left"></i></a></li>'
            }

            //boton anterior
            if (paginaActual <= 1)  {
                cuerpo += '<li class="page-item disabled">';
                cuerpo += '<a class="page-link" tabindex="-1" ><i class="fas fa-angle-left"></i></a></li>'
            } else {
                cuerpo += '<li class="page-item">';
                cuerpo += '<a class="page-link cursor" onclick="anterior()" tabindex="-1"><i class="fas fa-angle-left"></i></a></li>'
            }
            




            //paginas
            var maxVisibles = 9;
            var mostradas = 0; 

            for (var i=0; i<paginas; i++){

                if (mostradas >= maxVisibles){
                    break;
                }

                // if (paginaActual > paginas + maxVisibles) {
                //     if (i<paginaActual-maxVisibles) {
                //         continue;
                //     }
                // } else {

                    
                    if (i<paginaActual-5) {
                        continue;
                    }
                // }
                    
                mostradas++;



                // if (i>paginaActual+3 || i<paginaActual-5) {
                //     continue;
                // }
                

                if (paginaActual == i+1)  {
                    cuerpo += '<li class="page-item active">';  // active si es la pagina actual
                    cuerpo += '<a class="page-link" style="cursor:default">'+ (i+1) +'</a></li>'
                } else {
                    cuerpo += '<li class="page-item">'; 
                    cuerpo += '<a class="page-link cursor" onclick="ir('+ (i+1) +')">'+ (i+1) +'</a></li>'
                }

                // cuerpo += '<li class="page-item">';  // active si es la pagina actual
                // cuerpo += '<a class="page-link" onclick="ir('+ (i+1) +')">'+ (i+1) +'</a></li>'
                
            }

            //boton siguiente
            if (paginaActual >= paginas)  {
                cuerpo += '<li class="page-item disabled">';
                cuerpo += '<a class="page-link" tabindex="-1" ><i class="fas fa-angle-right"></i></a></li>'
            } else {
                cuerpo += '<li class="page-item">';
                cuerpo += '<a class="page-link cursor" onclick="siguiente()" tabindex="-1"><i class="fas fa-angle-right"></i></a></li>'
                // cuerpo += '<a class="page-link cursor" onclick="siguiente()" tabindex="-1">Siguiente</a></li>'
            }
            //boton ultimo
            if (paginaActual >= paginas)  {
                cuerpo += '<li class="page-item disabled">';
                cuerpo += '<a class="page-link" tabindex="-1" ><i class="fas fa-angle-double-right"></i></a></li>'
            } else {
                cuerpo += '<li class="page-item">';
                cuerpo += '<a class="page-link cursor" onclick="ir('+paginas+')" tabindex="-1"><i class="fas fa-angle-double-right"></i></a></li>'
            }

            navegacion.innerHTML = cuerpo;
            document.getElementById('codigo').focus();








        });

        
        
    }

    function anterior() {
        document.getElementById('paginaactual').value = (document.getElementById('paginaactual').value*1)-1;
        listarProductos();
    }
    function siguiente() {
        document.getElementById('paginaactual').value = (document.getElementById('paginaactual').value*1)+1;
        listarProductos();
    }
    function ir(pag) {
        document.getElementById('paginaactual').value = pag;
        listarProductos();
    }

    function filtroCodigo () {
        // if (document.getElementById('codigo').value.length > 2 || document.getElementById('codigo').value.length == 0) {
        //     ir(1);
        // }
        ir(1);
    }

    function limpiarFiltros() {
        document.getElementById('codigo').value="";
        document.getElementById('categoria').value="";
        document.getElementById('nombre').value="";
        ir(1);
    }



    //Eliminar de productos
    function eliminarProducto(codigo) {
        var ruta   = "../command.php";
        var cmd    = "eliminar-producto";
        var params = 'cmd='+cmd+'&codigo='+codigo;
        var metodo = "GET";
        var async  = false;
        var json  = false;

        // alert("eliminando "+codigo);

        ajax(ruta, params, metodo, async,json,function(respuesta){
                if (respuesta == '0'){
                    bootbox.alert({
                        size: "small",
                        title: "Eliminado!",
                        message: "Producto código "+codigo+" eliminado correctamente",
                        callback: function(){ 
                            listarProductos();
                        }
                    })
                }
  
        });
        
    }

    function elim (codigo) {
        bootbox.confirm({ 
            size: "small",
            title: "Eliminar",
            message: '<p>Estás seguro que deseas eliminar?</p> <p>Código: '+codigo+"</p>",
            callback: function(result){ 
                if (result) {
                    eliminarProducto(codigo);
                }
            }
        })
    }




    function addRowHandlers() {
        var table = document.getElementById("tableId");
        var rows = table.getElementsByTagName("tr");
        for (i = 0; i < rows.length; i++) {
            var currentRow = table.rows[i];
            var createClickHandler = 
                function(row) 
                {
                    return function() { 
                                            if (row.getElementsByTagName("td").length>1){
                                                var cell = row.getElementsByTagName("td")[0];
                                                var id = cell.innerHTML;
                                                
    
                                                // var cantfilas = $('.img-producto').length;
                                                // for (var i = 0; i < cantfilas; i++){
                                                //     $('.img-producto')[i].style.display = "none";
                                                // }
    
    
                                                // $('#'+id).toggle('slow');
    
    
                                                // var sw = document.getElementById(id);
                                                // if ($('#'+id).is(':hidden')) {
                                                //     // sw.style.display = "none";
                                                //     $('.img-producto').hide('slow');
                                                //     $('#'+id).show('slow');
                                                // } else {
    
                                                //     // sw.style.display = "block";
                                                //     $('#'+id).hide('slow');
                                                // }
    
    
    
                                                // $('.img-producto').hide('slow');
                                                // $('#'+id).show('slow');
    
    
                                                if ($('#'+id).is(':hidden')) {
                                                    $('.img-producto').hide();
                                                    $('#'+id).show();
                                                } else {
                                                    $('#'+id).hide();
                                                }
                                            }
                                            
                                            
                                     };
                };
    
            currentRow.onclick = createClickHandler(currentRow);
        }
    }

    function mostrarModal () {
        bootbox.alert({
            size: "small",
            title: "Buena!",
            message: "Producto guardado correctamente",
            callback: function(){ 
                // limpiarFiltros();
                document.getElementById('codigo').value = '';
                ir(1);
                document.getElementById('codigo').focus();
                // listarProductos();
            }
        })
    }






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





$( document ).ready(function() {
        
    listarProductos();
    comboCategorias()
    // $('th').addClass("text-center");
    // $('td').addClass("text-center");

    // setInterval(listarProductos, 5000);

    $(".iframe").fancybox({
        iframe: {
            scrolling : 'auto',
            preload   : false

        }
    });


    $('.btn-group-fab').on('click', '.btn', function() {
        $('.btn-group-fab').toggleClass('active');
    });
    $('has-tooltip').tooltip();


    $('#codigo').keydown(function (e) { 
        if ( event.which == 13 ) {
            event.preventDefault();
            filtroCodigo();
            if ($('#codigo').val().length > 3 && cantProductos == 0){
                bootbox.confirm('No se ha encontrado el producto código: '+$('#codigo').val()+'. <br>Desea agregarlo?', function(respuesta) {
                    if (respuesta){
                        
                        $.fancybox.open({
                            src  : '../IUproducto/IUproducto.php?producto=1&codigo='+$('#codigo').val(),
                            type : 'iframe',
                            opts : {
                              afterShow : function( instance, current ) {
                                console.info( 'done!' );
                              },
                              iframe : {
                                  preload : false
                              }
                            }
                        });

                    }
                })
            }
        }
    });

    $('#nombre').keydown(function (e) { 
        if ( event.which == 13 ) {
            event.preventDefault();
            filtroCodigo();
        }
    });

    // Acción al cerrar lightbox
    // $("[data-fancybox]").fancybox({
    //     afterClose: function( instance, slide ) {
    //         listarProductos();
    //         console.log("actualizó al cerrar lightbox");
            
    //     }
    // });


    // document.getElementsByClassName("mod").addEventListener("click", function(){
    //     idProd = this.value;
    //     console.log(idProd);
        
    //   });

    //   $(".mod").on('click', function(event){
    //     // event.stopPropagation();
    //     // event.stopImmediatePropagation();
    //     idProd = this.value;
    //     console.log(idProd);

    // });


});
