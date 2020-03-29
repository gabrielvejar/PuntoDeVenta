var cierre;


function ultimoCierre() {
    $.ajax({
        type: "GET",
        url: "../../command.php",
        data: {
            'cmd': 'ultimo-cierre'
        },
        dataType: "JSON",
        success: function (response) {
            cierre = response;

            $('#input-fecha-uc').val(response[0]['fecha']);
            $('#inputEfectivoCierre').val(response[0]['efectivo']);
            
        }
    });
}

function verificarDiaSiguiente(diaMayor, diaMenor) {

    var a = moment(diaMayor,"DD-MM-YYYY");
    var b = moment(diaMenor,"DD-MM-YYYY");
    var diferencia = a.diff(b, 'days');

    if (diferencia == 1) {
        return true;
    } else {
        return false;
    }

}

function aperturaCaja (fecha, efectivo) {
    $.ajax({
        type: "POST",
        url: "../../command.php",
        data: {
            'cmd': 'apertura-caja',
            'fecha': fecha,
            'efectivo': efectivo
        },
        success: function (response) {
            if(response == 0){
                alert('Apertura de caja correcta');
                location.reload();
            } else {
                alert('Error en apertura de caja');
            }
        }
    });
}


$(function() {

    $('#btn-abrir').on('click', function () {
        var fechaApertura = $('#input-fecha').val();
        var fechaCierre = cierre[0]['fecha'];

        var efectivoApertura = $('#inputEfectivo').val();
        var efectivoCierre = cierre[0]['efectivo'];

        if(fechaApertura == ""){
            alert('Ingrese fecha de apertura');
            return false;
        }
        if(!moment(fechaApertura, "DD-MM-YYYY").isValid()){
            alert('Ingrese fecha de apertura válida');
            return false;
        }
        if(efectivoApertura == ""){
            alert('Ingrese efectivo que hay en caja');
            return false;
        }
        if(isNaN(efectivoApertura)){
            alert('Ingrese una cantidad válida');
            return false;
        }

        if(!verificarDiaSiguiente(fechaApertura, fechaCierre)) {
           if(!confirm('La fecha de apertura no es el día siguiente a la fecha de ultimo cierre de caja. Desea continuar?')){
                return false;
           }
        }

        if (efectivoCierre != efectivoApertura){
            if(!confirm('El monto de efectivo de apertura no coincide con el monto de efectivo del ultimo cierre de caja. Desea continuar?')){
                return false;
            }
        }

        // llamar a funcion que abre caja
        aperturaCaja (fechaApertura, efectivoApertura);


    });

    // para validar fecha
    // var fechaApertura = $('#input-fecha').val();
    // var fechaCierre = cierre[0]['fecha'];
    // moment($('#input-fecha').val(), "DD-MM-YYYY").isValid()

    

    $('#form-apertura').on('submit', function (event) {
        event.preventDefault();
    });

    
    $('#input-fecha').datepicker({
        dateFormat : 'dd-mm-yy'
      }
   );

   ultimoCierre();



});