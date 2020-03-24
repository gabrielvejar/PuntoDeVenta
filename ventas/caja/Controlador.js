function agre_canc_collapse () {
    $('#botonera').collapse('show'); 
    $('#btns1').collapse('show');
    $('#btns-pago-efectivo').collapse('hide');
    $('#row1').collapse('hide');
    $('#precio-item').collapse('hide');
}


$(function() {

    $(document).on('click', '#btn-efectivo', function(event) {
        $('#btns1').collapse('hide');
        $('#pago-efectivo').collapse('show');
        $('#btns-pago-efectivo').collapse('show');
    });
    $(document).on('click', '#btn-cancelar-pago', function(event) {
        $('#btns1').collapse('show');
        $('#pago-efectivo').collapse('hide');
        $('#btns-pago-efectivo').collapse('hide');
    });
    $(document).on('click', '#btn-agregar-prod', function(event) {
        $('#botonera').collapse('hide');
        $('#pago-efectivo').collapse('hide');
        $('#row1').collapse('show');
    });
    $(document).on('click', '#btn-cancelar', function(event) {
        agre_canc_collapse();
    });
    $(document).on('click', '#btn-agregar', function(event) {
        agre_canc_collapse();
    });

});