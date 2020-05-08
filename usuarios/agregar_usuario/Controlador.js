var modificarPass = "";

$(function() {
    
    selectPerfiles();
    buscarUsuario();

    $('#inputPassword').click(function (e) { 
        e.preventDefault();
        if (modificarPass != 't' && $('#agregar').text() =="Modificar") {    
            bootbox.confirm('Desea modificar contraseña?', function (respuesta) {
                if (respuesta) {
                    modificarPass = "t";
                    $('#inputPassword').removeAttr('readonly');
                }
            })
        }

    });


    $('#agregar').click(function (e) { 
        e.preventDefault();



        var nombre = $('#inputNombre').val();
        var username = $('#inputUsername').val();
        var password = $('#inputPassword').val();
        var perfil = $('#selectPerfil').val();

        if (nombre.length < 4) {
            bootbox.alert('Nombre debe tener al menos 4 caracteres');
            return;
        }
        if (username.length < 4) {
            bootbox.alert('Nombre de usuario debe tener al menos 4 caracteres');
            return;
        }
        if (perfil.length < 1) {
            bootbox.alert('Seleccione perfil de usuario');
            return;
        }


        if ($('#agregar').text() =="Modificar") {

            if (modificarPass == 't'){
                if (password.length < 4) {
                    bootbox.alert('Contraseña debe tener al menos 4 caracteres');
                    return;
                }
            }

            modificarUsuario();

        } else {   
            if (password.length < 4) {
                bootbox.alert('Contraseña debe tener al menos 4 caracteres');
                return;
            }
            agregarUsuario();
        }

    });




});


function selectPerfiles() {
    $.ajax({
        type: "POST",
        url: "../command.php",
        data: {
            'cmd': 'select-perfiles'
        },
        dataType: "json",
        success: function (response) {
            console.log(response);

            if (response.length > 0){

                var select = $('#selectPerfil');
                var html = '<option value="">-Seleccione una opción-</option>';
                for (var i=0; i < response.length; i++) {
                    html +='<option value="'+response[i].tipo_usuario+'">'+response[i].tipo_usuario_completo+'</option>';
                }
                select.html(html);
                
            }
        }
    });
}



function agregarUsuario() {

    var nombre = $('#inputNombre').val();
    var username = $('#inputUsername').val();
    var password = $('#inputPassword').val();
    var perfil = $('#selectPerfil').val();

    $.ajax({
        type: "POST",
        url: "../command.php",
        data: {
            'cmd': 'agregar-usuario',
            'nombre': nombre,
            'username': username,
            'password': password,
            'tipo_usuario': perfil
        },
        success: function (response) {

            if (isNaN(response)){
                bootbox.alert(response);
            } else {
                bootbox.alert('Usuario agregado correctamente', function() {
                    parent.jQuery.fancybox.getInstance().close();
                });
            }


        }
    });
}



function modificarUsuario() {

    var idUsuario = $('#id_user').val();
    var nombre = $('#inputNombre').val();
    var password = $('#inputPassword').val();
    var perfil = $('#selectPerfil').val();

    var datos = {
        'cmd': 'modificar-usuario',
        'idUsuario': idUsuario,
        'nombre': nombre,
        'modPass': modificarPass,
        'password': password,
        'tipo_usuario': perfil
    }


    $.ajax({
        type: "POST",
        url: "../command.php",
        data: datos,
        success: function (response) {

            if (isNaN(response)){
                bootbox.alert(response);
            } else if (response == '0') {
                bootbox.alert('No se encontró usuario a modificar');
            } else {
                bootbox.alert('Usuario modificado correctamente', function() {

                });
            }


        }
    });
}


function buscarUsuario() {

    var idUsuario = $('#id_user').val();

    if (idUsuario != "") {

        
        $.ajax({
            type: "POST",
            url: "../command.php",
            dataType: 'json',
            data: {
                'cmd': 'datos-usuario',
                'id': idUsuario
            },
            success: function (response) {

                $('#titulo').text('Modificar usuario');
                $('#agregar').text('Modificar');
                $('#inputNombre').val(response[0].nombre);
                $('#inputUsername').val(response[0].usuario);
                $('#inputUsername').attr('readonly', 'true');
                $('#inputPassword').attr('readonly', 'true');
                $('#selectPerfil').val(response[0].tipo_usuario);

                
                
                
            }
        });


    }


}