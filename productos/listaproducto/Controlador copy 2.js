    //Relleno de listado de productos
    function listarProductos() {
        var ruta   = "../command.php";
        var cmd    = "cmd=tabla-productos";
        var params = cmd;
        var metodo = "GET";
        var async  = false;
        var json  = true;
        var tabla  = document.getElementById('tabla-productos');

        ajax(ruta, params, metodo, async,json,function(respuesta){
            
            var cuerpo = "";
            for (i in respuesta){
                cuerpo += "<tr>";
                cuerpo += "<td>" + respuesta[i][2] + "</td>";
                cuerpo += "<td>" + respuesta[i][5] + "</td>";

                cuerpo += "<td> <div>";
                cuerpo += respuesta[i][1] + '</div>';
                // columna imagen producto
                cuerpo += "</td>";

                cuerpo += "<td>$" + respuesta[i][3] + '<span class="spunidad">/' + respuesta[i][6] +'</span></td>';

                cuerpo += "</tr>";


                var btnMod1 = '<a class="iframe" data-fancybox data-type="iframe" data-src="../IUproducto/IUproducto.php?producto=2&codigo='
                var btnMod2 = '" href="javascript:;"><button class="btn btn-info mx-3" title="Modificar"><i class="fa fa-pencil-square-o" aria-hidden="true"></i></button></a>'
                var btnElim1 = '<a class="iframe" data-fancybox data-type="iframe" data-src="../IUproducto/IUproducto.php?producto=2&codigo=' // cambiar por ruta de eliminar
                var btnElim2 = '" href="javascript:;"><button class="btn btn-danger mx-3" title="Eliminar"><i class="fa fa-trash-o" aria-hidden="true"></i></button></a>'


                if (respuesta[i][4] == ""){
                    // cuerpo += '<td></td>';
                    // cuerpo += ' <div class="img-producto" id="'+respuesta[i][2]+'"><div><img src="/puntodeventa/img/productos/sinimagen.jpg"  width="70%"></div><div><button class="btn btn-info mod" value="' + respuesta[i][2] +'">Modificar</button></div></div>';
                    cuerpo += '<tr class="img-producto" id="'+respuesta[i][2]+'"><td  colspan="4"> <div><div><img src="/puntodeventa/img/productos/sinimagen.jpg"  width="50%"></div><div>' + btnMod1 + respuesta[i][2] +btnMod2 +btnElim1 + respuesta[i][2] +btnElim2 + '</div></tr></td>';
                } else {
                    // cuerpo += "<tr>";
                    // cuerpo += ' <div class="img-producto" id="'+respuesta[i][2]+'"><div><img src="/puntodeventa/img/productos/' + respuesta[i][4] +'"  width="70%"></div><div><button class="btn btn-info mod" value="' + respuesta[i][2] +'">Modificar</button></div></div>';
                    cuerpo += '<tr class="img-producto" id="'+respuesta[i][2]+'"><td  colspan="4"> <div><div><img src="/puntodeventa/img/productos/' + respuesta[i][4] +'"  width="50%"></div><div>'  + btnMod1 + respuesta[i][2] +btnMod2 +btnElim1 + respuesta[i][2] +btnElim2 + '</div></tr></td>';
                    // cuerpo += "</tr>";
                }
                





                
                
            }

            tabla.innerHTML = cuerpo;
            $('.img-producto').hide();
            addRowHandlers();
        });
        
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
                                                $('.img-producto').hide('slow');
                                                $('#'+id).show('slow');
                                            } else {
                                                $('#'+id).hide('slow');
                                            }
                                            
                                     };
                };
    
            currentRow.onclick = createClickHandler(currentRow);
        }
    }


    $( document ).ready(function() {
        
        listarProductos();

        // setInterval(listarProductos, 5000);

        $(".iframe").fancybox({
            iframe: {
                scrolling : 'auto',
                preload   : false
    
            }
        });

        $(function() {
            $('.btn-group-fab').on('click', '.btn', function() {
              $('.btn-group-fab').toggleClass('active');
            });
            $('has-tooltip').tooltip();
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
