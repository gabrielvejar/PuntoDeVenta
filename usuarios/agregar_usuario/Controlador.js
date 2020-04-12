$(function() {
    selectPerfiles();


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
        if (password.length < 4) {
            bootbox.alert('Contraseña debe tener al menos 4 caracteres');
            return;
        }
        if (perfil.length < 1) {
            bootbox.alert('Seleccione perfil de usuario');
            return;
        }


        agregarUsuario();
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
                    location.reload();
                });
            }


        }
    });
}