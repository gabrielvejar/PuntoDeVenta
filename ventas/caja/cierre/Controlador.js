function valoresCierre () {
    $.ajax({
        type: "POST",
        url: "../../command.php",
        data: {
            'cmd': 'valores-cierre-caja'
        },
        dataType: 'JSON',
        success: function (response) {
            console.log(response);
            jsonvalores = response;
            $('#td-efectivo-apertura').text("$"+new Intl.NumberFormat("de-DE").format(jsonvalores.efectivo_apertura));
            $('#td-ventas-efectivo').text("$"+new Intl.NumberFormat("de-DE").format(jsonvalores.total_ventas_efectivo));
            $('#td-ventas-tarjeta').text("$"+new Intl.NumberFormat("de-DE").format(jsonvalores.total_ventas_tarjeta));
            $('#td-gastos').text("$"+new Intl.NumberFormat("de-DE").format(jsonvalores.total_gastos));
            
            
            calcularBalance();
            
        }
    });
}

function calcularBalance () {
    var efectivoCierre = $('#input-efectivo').val();
    var entrega = $('#input-entrega').val();
    var balance;

    efectivoCierre = limpiarNumero(efectivoCierre);
    entrega = limpiarNumero(entrega);

    // balance = efectivoCierre + jsonvalores.total_gastos*1 + entrega - jsonvalores.efectivo_apertura*1 - jsonvalores.total_ventas_efectivo*1;
    balance = -(jsonvalores.efectivo_apertura*1 + jsonvalores.total_ventas_efectivo*1 - jsonvalores.total_gastos*1 - efectivoCierre - entrega);
    
    $('#input-balance').val(balance);

    if (balance < 0) {
        $('#input-balance').css('color', 'red');
    } else {
        $('#input-balance').css('color', 'darkgreen');
    }

    formatearDinero('#input-balance');




}



$(function() {
    var jsonvalores;
    valoresCierre();

    $('input').on('input change', function (e) {
        formatearDinero('#'+e.target.id);
        calcularBalance();
    });




});