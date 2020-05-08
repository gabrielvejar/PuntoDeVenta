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

            if(jsonvalores.total_ventas_efectivo == null){
                jsonvalores.total_ventas_efectivo = 0;
            }
            if(jsonvalores.total_ventas_tarjeta == null){
                jsonvalores.total_ventas_tarjeta = 0;
            }
            if(jsonvalores.total_gastos == null){
                jsonvalores.total_gastos = 0;
            }
            
            console.log(jsonvalores);

            $('#td-efectivo-apertura').text("$"+new Intl.NumberFormat("de-DE").format(jsonvalores.efectivo_apertura));
            $('#td-ventas-efectivo').text("$"+new Intl.NumberFormat("de-DE").format(jsonvalores.total_ventas_efectivo));
            $('#td-ventas-tarjeta').text("$"+new Intl.NumberFormat("de-DE").format(jsonvalores.total_ventas_tarjeta));
            $('#td-gastos').text("$"+new Intl.NumberFormat("de-DE").format(jsonvalores.total_gastos));
            $('#td-custodia').text("$"+new Intl.NumberFormat("de-DE").format(jsonvalores.total_custodia));
            
            
            calcularBalance();
            
        }
    });
}


function valoresApertura () {
    $.ajax({
        type: "POST",
        url: "../../command.php",
        data: {
            'cmd': 'datos-apertura'
        },
        dataType: 'JSON',
        success: function (response) {
            console.log(response);
            var mensaje = ""
            mensaje += '<h4>Datos de apertura de caja</h4>';
            mensaje += '<table style="width: 100%;"><tbody>';
            mensaje += '<tr>';
            mensaje += "<td>Apertura de caja ID:</td><td>"+response[0].id_apertura+"</td>";
            mensaje += '</tr>';
            mensaje += '<tr>';
            mensaje += "<td>Fecha de apertura:</td><td>"+response[0].fecha+"</td>";
            mensaje += '</tr>';
            mensaje += '<tr>';
            mensaje += "<td>Hora de apertura:</td><td>"+response[0].hora+"</td>";
            mensaje += '</tr>';
            mensaje += '<tr>';
            mensaje += "<td>Usuario apertura:</td><td>"+response[0].usuario+"</td>";
            mensaje += '</tr>';
            mensaje += '<tr>';
            mensaje += "<td>Efectivo apertura:</td><td>$"+separadorMiles(response[0].efectivo)+"</td>";
            mensaje += '</tr>';
            // mensaje += "Fecha de apertura: "+response[0].fecha+"<br>";
            // mensaje += "Hora de apertura: "+response[0].hora+"<br>";
            // mensaje += "Usuario apertura: "+response[0].usuario+"<br>";
            // mensaje += "Efectivo apertura: "+response[0].efectivo;
            
            mensaje += '</tr></tbody></table>';
            bootbox.alert({
                tittle: 'Datos de apertura de caja',
                message: mensaje,
                callback: function() {

                }
            });

            
        }
    });
}



function buscarVentas () {
   var ventasPendientes = 0;
    $.ajax({
        type: "POST",
        url: "../../command.php",
        data: {cmd: 'ventas-temp_impagas'},
        dataType: 'json',
        async: false,
        success: function(data) {
            
            ventasPendientes = data.length;

        }
    });

    return ventasPendientes;

}

function cerrarCaja () {


    var efectivo_cierre = $('#input-efectivo').val();
    efectivo_cierre = limpiarNumero (efectivo_cierre);

    var entrega = $('#input-entrega').val();
    entrega = limpiarNumero (entrega);


    bootbox.prompt({
        title: "<p>Cierre de caja debe se autorizado por un administrador</p><p><b>Ingrese nombre de usuario administrador</b></p>",
        inputType: 'text',
        callback: function (result) {
            console.log(result);
            if (result == null) {
                return;
            }
            // console.log('callback');
            if (result == '') {
                bootbox.alert('Ingrese los datos solicitados', function () {
                })
                return; // alert de ingrese usuario
            }

            var usuario_autoriza = result;
            bootbox.prompt({
                title: "<p>Cierre de caja debe se autorizado por un administrador</p><p><b>Ingrese contraseña de usuario administrador</b></p>",
                inputType: 'password',
                callback: function (result) {
                    console.log(result);
                    if (result == null) {
                        return;
                    }
                    // console.log('callback');
                    if (result == '') {
                        bootbox.alert('Ingrese los datos solicitados', function () {
                        })
                        return; // alert de ingrese contraseña
                    }
        
                    var pass_autoriza = result;


                    var datos = {
                        'cmd': 'cerrar-caja',
                        'efectivo_apertura': jsonvalores.efectivo_apertura,
                        'efectivo_cierre': efectivo_cierre,
                        'ventas_efectivo': jsonvalores.total_ventas_efectivo,
                        'ventas_tarjetas': jsonvalores.total_ventas_tarjeta,
                        'entrega': entrega,
                        'gastos': jsonvalores.total_gastos,
                        'username_autoriza': usuario_autoriza,
                        'pass_autoriza': pass_autoriza
                    }
                
                
                    $.ajax({
                        type: "POST",
                        url: "../../command.php",
                        data: datos,
                        success: function (response) {
                            if (isNaN(response)) {
                                bootbox.alert(response);
                            } else {
                                setTimeout(() => {
                                    location.reload();
                                }, 5000);
                                bootbox.alert('Caja cerrada correctamente!', function(){
                                    location.reload();
                                });
                            }
                        }
                    });

        
                    
        
                }
            });


        }
    });


}

var estadoIconoActual = '';
var primeraVez = true;
function switchIcono (estado) {

    if (estado != estadoIconoActual ) {
        
        if (estado == 'bien') {
            $('#icon-balance').show();

            var iconElement = document.getElementById('icon-balance');
            // var options = {
            //     from: 'fa-times-circle-o',
            //     to: 'fa-check-circle-o',
            //     animation: 'tada',
            //     duration: 300
            // };
            var options = {
                from: 'fa-times',
                to: 'fa-check',
                animation: 'tada',
                duration: 500
            };
            
            // document.getElementById('icon-balance').style.color="green";
            iconate(iconElement, options);

            if (primeraVez) {
                primeraVez = false;
            } else {

                var audio = document.getElementById("audio-bien");
                audio.play();

                var objDiv = document.getElementById("contenedor");
                objDiv.scrollTop = objDiv.scrollHeight;



            }

        } else if (estado == 'mal') {

            var iconElement = document.getElementById('icon-balance');
            // var options = {
            //     from: 'fa-check-circle-o',
            //     to: 'fa-times-circle-o',
            //     animation: 'tada',
            //     duration: 300
            // };
            var options = {
                from: 'fa-check',
                to: 'fa-times',
                animation: 'tada',
                duration: 500
            };

            // document.getElementById('icon-balance').style.color="red";
            iconate(iconElement, options);

            if (primeraVez) {
                primeraVez = false;
            } else {

                var audio = document.getElementById("audio-mal");
                audio.play();
            }

        }

        estadoIconoActual = estado;

    }

 }



function calcularBalance () {
    var efectivoCierre = $('#input-efectivo').val();
    var entrega = $('#input-entrega').val();
    var balance;

    efectivoCierre = limpiarNumero(efectivoCierre);
    entrega = limpiarNumero(entrega);

    // balance = efectivoCierre + jsonvalores.total_gastos*1 + entrega - jsonvalores.efectivo_apertura*1 - jsonvalores.total_ventas_efectivo*1;
    balance = -(jsonvalores.efectivo_apertura*1 + jsonvalores.total_ventas_efectivo*1 - jsonvalores.total_gastos*1 - efectivoCierre - entrega);
    
    if (isNaN(balance)) {
        $('#input-balance').val('');
    } else {

        $('#input-balance').val(balance);

        if (balance >= 0) {

            $('#input-balance').css('border-color', 'green');

            // var iconElement = document.getElementById('icon-balance');
            // var options = {
            //     from: 'fa-times',
            //     to: 'fa-check',
            //     animation: 'tada',
            //     duration: 300
            // };
            
            // document.getElementById('icon-balance').style.color="green";
            // iconate(iconElement, options);

            switchIcono('bien');

            

        } else {

            $('#input-balance').css('border-color', 'coral');

            // var iconElement = document.getElementById('icon-balance');
            // var options = {
            //     from: 'fa-check',
            //     to: 'fa-times',
            //     animation: 'tada',
            //     duration: 300
            // };
            // document.getElementById('icon-balance').style.color="red";
            // iconate(iconElement, options);

            switchIcono('mal');


        }

    }
    formatearDinero('#input-balance', '$');

}

function calcularProducto(valor, indice) {
    var multiplo = document.getElementsByClassName('multiplo')[indice].value;
    if (multiplo != 0){
        document.getElementsByClassName('prod-mult')[indice].value = "$"+separadorMiles(valor*multiplo);
    }
}


function calcularMultiplo(valor, indice) {


    // document.getElementsByClassName('multiplo')[indice].style.backgroundColor = "";


    var producto = document.getElementsByClassName('prod-mult')[indice].value;
    producto = limpiarNumero(producto);

    if((producto % valor) != 0) {
        // bootbox.alert('El monto ingresado no corresponde con el billete/moneda', function(){
        //     // document.getElementsByClassName('prod-mult')[indice].focus();
        // });
        // document.getElementById('input-efectivo').value='$0';
        document.getElementsByClassName('multiplo')[indice].value = "";
        document.getElementsByClassName('multiplo')[indice].style.borderColor = "coral";
    } else {
        document.getElementsByClassName('multiplo')[indice].value = producto / valor;
    }

}

function sumarEfectivo() {

    var suma = 0;
    var cantidad = document.getElementsByClassName('prod-mult').length;

    for (var i=0; i<cantidad; i++){
        var producto = limpiarNumero(document.getElementsByClassName('prod-mult')[i].value)*1;
        suma += producto; 
    }


    $('#input-efectivo').val(suma);
    formatearDinero('#input-efectivo', '$');

}

function limpiarInputsSumador() {
    var inputsMult = document.getElementsByClassName('multiplo');
    for(var i=0; i<inputsMult.length; i++) {
        inputsMult[i].value = '0';
        inputsMult[i].style.borderColor = "white";
    }
    var inputsProd = document.getElementsByClassName('prod-mult');
    for(var i=0; i<inputsProd.length; i++) {
        inputsProd[i].value = '$0';
    }
}




function playAudio() {
    if (estadoIconoActual == 'bien') {
        var audio = document.getElementById("audio-bien");
    } else if(estadoIconoActual == 'mal') {
        var audio = document.getElementById("audio-mal");
    }
    audio.play();
}



$(function() {
    var jsonvalores;
    valoresCierre();
    $('#input-efectivo').val('$0');
    $('#input-entrega').val('$0');

    $('#icon-balance').hide();

    limpiarInputsSumador();




    $('.multiplo').on('input', function (e) {
        e.target.style.borderColor = "white";

        calcularProducto(20000, 0);
        calcularProducto(10000, 1);
        calcularProducto(5000, 2);
        calcularProducto(2000, 3);
        calcularProducto(1000, 4);
        calcularProducto(500, 5);
        calcularProducto(100, 6);
        calcularProducto(50, 7);
        calcularProducto(10, 8);

        sumarEfectivo();
        calcularBalance();
        if($('#input-efectivo').val() != "$0") {
            $('#input-efectivo').attr('readonly', 'readonly');
        } else {
            $('#input-efectivo').removeAttr('readonly');
        }

    });


    $('.prod-mult').on('blur', function (e) {

        calcularMultiplo(20000, 0);
        calcularMultiplo(10000, 1);
        calcularMultiplo(5000, 2);
        calcularMultiplo(2000, 3);
        calcularMultiplo(1000, 4);
        calcularMultiplo(500, 5);
        calcularMultiplo(100, 6);
        calcularMultiplo(50, 7);
        calcularMultiplo(10, 8);

        sumarEfectivo();
        calcularBalance();
        if($('#input-efectivo').val() != "$0") {
            $('#input-efectivo').attr('readonly', 'readonly');
        } else {
            $('#input-efectivo').removeAttr('readonly');
        }

    });

   


    // $('#input-efectivo').change(function (e) { 
    //     // $('#icon-balance').show();
    //     playAudio();
    // });

    $('#input-efectivo').keydown(function (e) { 
        limpiarInputsSumador();
    });






    $('.inputs-bal').on('input change', function (e) {
        console.log('entró al on input change');
        
        formatearDinero('#'+e.target.id, '$');
        calcularBalance();
    });



    $('.prod-mult').on('input change', function (e) {
        formatearDinero('#'+e.target.id, '$');
    });

    $('#div-sumador').on('shown.bs.collapse', function () {

            // this.scrollIntoView({
            //     behavior: 'smooth'
            // });

            // document.getElementById('input-efectivo').scrollIntoView({
            //     behavior: 'smooth'
            // });

            var elemento = document.getElementById('input-efectivo');
            var posicion = elemento.getBoundingClientRect();

            var anchoNav = document.getElementById('nav-bar').offsetHeight;
            var anchoAdicional = 10;

            window.scrollTo({
                top: posicion.top - anchoNav -anchoAdicional,
                behavior: 'smooth',
              });

            document.querySelectorAll('#div-sumador input')[0].focus({preventScroll: true});

            // $('#input-efectivo').attr('readonly', 'readonly');
            // $('#input-efectivo').removeAttr("readonly");
            
      });


    // $('#div-sumador').on('hidden.bs.collapse', function () {

    //         $('#input-efectivo').removeAttr("readonly");
            
    //   });

    $('#input-efectivo').on('focus', function (e) {
       if($('#input-efectivo').attr('readonly') == "readonly") {
        //    bootbox.alert('Si modifica manualmente el <b>"Efectivo Cierre"</b> se borrarán todos los datos del <b>Sumador de efectivo</b>');

           bootbox.alert('Si modifica manualmente el <b>"Efectivo Cierre"</b> se borrarán todos los datos del <b>Sumador de efectivo</b>', function(){ 
               $('#input-efectivo').removeAttr('readonly');
               
               document.getElementById('input-efectivo').focus(); //FIXME por algun motivo no funciona..
            });

       }
    });


    var auxiliarMult;
    $('.multiplo').on('focus', function (e) {
        auxiliarMult = e.target.value;
        e.target.value = "";
    });
    $('.multiplo').on('focusout', function (e) {
        if (e.target.value == ""){
            e.target.value = auxiliarMult;
        }
    });

    var auxiliarProd;
    $('.prod-mult').on('focus', function (e) {
        auxiliarProd = e.target.value;
        e.target.value = "";
    });
    $('.prod-mult').on('focusout', function (e) {
        if (e.target.value == ""){
            e.target.value = auxiliarProd;
        }
    });


    // TODO que la animación del icono se desencadene solo cuando cambia de icono
    // $('#chk-cambio').change(function (e) { 
    //     e.preventDefault();
    //     console.log('cambió');
    // });

    $('#btn-cierre').click(function (e) { 
        e.preventDefault();
        // let ventasPendientes = buscarVentas();
        var balance = $('#input-balance').val();
        // console.log(ventasPendientes);
        
        if(buscarVentas() > 0){
            bootbox.confirm({
                title: "Ventas pendientes de pago",
                message: "<p>Se encontraron ventas pendientes de pago. Si continua éstas serán anuladas.</p><p>Desea continuar con el cierre de caja?</p>",
                callback: function (result) {
                    if (result) {

                        bootbox.confirm({
                            title: "Cerrar Caja",
                            message: "<p>El balance de caja es: <b>"+balance+"</b></p><p>Realmente quiere realizar el cierre de caja?</p>",
                            callback: function (result) {
                                if (result) {
                                    cerrarCaja();
                                }
                            }
                        });

                    }
                }
            });
        } else{
            bootbox.confirm({
                title: "Cerrar Caja",
                message: "<p>El balance de caja es: <b>"+balance+"</b></p><p>Realmente quiere realizar el cierre de caja?</p>",
                callback: function (result) {
                    if (result) {
                        cerrarCaja();
                    }
                }
            });
        }



        

        $('#icon-balance').show();




        
    });


});