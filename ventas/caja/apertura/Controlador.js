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

            if (response.length > 0){
                
                cierre = response;
    
                $('#input-fecha-uc').val(response[0]['fecha']);
                $('#inputEfectivoCierre').val(response[0]['efectivo_cierre']);
                formatearDinero('#inputEfectivoCierre', '$');

            }
                
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
                setTimeout(() => {
                    location.reload();
                }, 3000);
                bootbox.alert('Apertura de caja correcta', function(){
                    location.reload();
                });
                
            } else {
                bootbox.alert('Error en apertura de caja');
            }
        }
    });
}


$(function() {

    $('#btn-abrir').on('click', function () {
        var fechaApertura = $('#input-fecha').val();
        var efectivoApertura = limpiarNumero($('#inputEfectivo').val());

        if (cierre != null) {
            var fechaCierre = cierre[0]['fecha'];
            var efectivoCierre = cierre[0]['efectivo_cierre'];
        }

        if(fechaApertura == ""){
            bootbox.alert('Ingrese fecha de apertura');
            return false;
        }
        if(!moment(fechaApertura, "DD-MM-YYYY").isValid()){
            bootbox.alert('Ingrese fecha de apertura válida');
            return false;
        }
        if(efectivoApertura == ""){
            bootbox.alert('Ingrese efectivo que hay en caja');
            return false;
        }
        if(isNaN(efectivoApertura)){
            bootbox.alert('Ingrese una cantidad válida');
            return false;
        }


        if (cierre != null) {

            if(!verificarDiaSiguiente(fechaApertura, fechaCierre)) {

            bootbox.confirm("La fecha de apertura no es el día siguiente a la fecha de ultimo cierre de caja. Desea continuar?", function(result){ 
                    if(result) {

                        if (efectivoApertura != efectivoCierre){

                            bootbox.confirm("El monto de efectivo de apertura no coincide con el monto de efectivo del ultimo cierre de caja. Desea continuar?", function(result){ 
                                if(result) {
                                    aperturaCaja (fechaApertura, efectivoApertura);
                                }
                            });

                        } else {
                            aperturaCaja (fechaApertura, efectivoApertura);
                        }

                    }
                });
            } else {

                if (efectivoApertura != efectivoCierre){

                    bootbox.confirm("El monto de efectivo de apertura no coincide con el monto de efectivo del ultimo cierre de caja. Desea continuar?", function(result){ 
                        if(result) {
                            aperturaCaja (fechaApertura, efectivoApertura);
                        }
                    });

                } else {
                    aperturaCaja (fechaApertura, efectivoApertura);
                }


            }

        } else {
            aperturaCaja (fechaApertura, efectivoApertura);
        }

    });

    $('#inputEfectivo').on('input', function (e) {
        formatearDinero('#'+e.target.id, '$');
    });

    $('#form-apertura').on('submit', function (event) {
        event.preventDefault();
    });

    
    $('#input-fecha').datepicker({
        dateFormat : 'dd-mm-yy'
      }
   );

   ultimoCierre();



});