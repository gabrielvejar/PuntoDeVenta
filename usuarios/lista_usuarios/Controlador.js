$(function() {
  tablaUsuarios();
    
})


function tablaUsuarios() {


    var datos = {
        'cmd': 'tabla-usuarios'
    }

    $.ajax({
        type: "POST",
        url: "../command.php",
        data: datos,
        dataType: 'JSON',
        success: function (response) {

            console.log(response);
            
            if (response.length > 0) {



                var tabla = $('#tbody_usuarios');
                
                var html = '';
                    

                response.forEach(element => {
                    
                    html += '<tr>';
                    html += '<td>'+element.nombre+'</td>';
                    html += '<td>'+element.usuario+'</td>';
                    html += '<td>'+element.tipo_usuario_completo+'</td>';
                    html += '<td><i class="fas fa-edit cursor" aria-hidden="true" data-toggle="tooltip" title="Modificar" onclick="modificar('+element.id_usuario+');"></i></td>';
                    html += '</tr>';
                    
                  });

                tabla.html(html);
                $('[data-toggle="tooltip"]').tooltip();
            
            }

        }
    });
  }

function modificar (id) {
  $.fancybox.open({
    src  : '../agregar_usuario/nuevo_usuario.php?sb=no&id='+id,
    type : 'iframe',
    opts : {
      afterShow : function( instance, current ) {
        console.info( 'done!' );
      },
      beforeClose : function () {
        parent.tablaUsuarios();
      },
      iframe : {
          preload : false
      }
    }
  });
}


$('#nuevo_usuario').click(function (e) { 
  e.preventDefault();
  
  $.fancybox.open({
    src  : '../agregar_usuario/nuevo_usuario.php?sb=no',
    type : 'iframe',
    opts : {
      afterShow : function( instance, current ) {
        console.info( 'done!' );
      },
      beforeClose : function () {
        parent.tablaUsuarios();
      },
      iframe : {
          preload : false
      }
    }
  });



});