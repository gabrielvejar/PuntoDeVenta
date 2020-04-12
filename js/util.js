var rutaraiz = $('#ruta').val();

$.datepicker.regional['es'] = {
	closeText: 'Cerrar',
	prevText: '< Ant',
	nextText: 'Sig >',
	currentText: 'Hoy',
	monthNames: ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'],
	monthNamesShort: ['Ene','Feb','Mar','Abr', 'May','Jun','Jul','Ago','Sep', 'Oct','Nov','Dic'],
	dayNames: ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'],
	dayNamesShort: ['Dom','Lun','Mar','Mié','Juv','Vie','Sáb'],
	dayNamesMin: ['Do','Lu','Ma','Mi','Ju','Vi','Sá'],
	weekHeader: 'Sm',
	dateFormat: 'dd/mm/yy',
	firstDay: 1,
	isRTL: false,
	showMonthAfterYear: false,
	yearSuffix: ''
	};
	$.datepicker.setDefaults($.datepicker.regional['es']);

	moment.locale('es-us');

// function Valida_Rut( Objeto ) {
// 	var tmpstr   = "";
// 	var intlargo = Objeto.value
// 	if (intlargo.length> 0)
// 	{
// 		crut = Objeto.value
// 		largo = crut.length;
// 		if ( largo <8 )
// 		{
// 			return false;
// 		}
// 		for ( i=0; i <crut.length ; i++ )
// 		if ( crut.charAt(i) != ' ' && crut.charAt(i) != '.' && crut.charAt(i) != '-' )
// 		{
// 			tmpstr = tmpstr + crut.charAt(i);
// 		}
// 		rut = tmpstr;
// 		crut=tmpstr;
// 		largo = crut.length;
 
// 		if ( largo> 2 )
// 			rut = crut.substring(0, largo - 1);
// 		else
// 			rut = crut.charAt(0);
 
// 		dv = crut.charAt(largo-1);
 
// 		if ( rut == null || dv == null )
// 		return 0;
 
// 		var dvr = '0';
// 		suma = 0;
// 		mul  = 2;
 
// 		for (i= rut.length-1 ; i>= 0; i--)
// 		{
// 			suma = suma + rut.charAt(i) * mul;
// 			if (mul == 7)
// 				mul = 2;
// 			else
// 				mul++;
// 		}
 
// 		res = suma % 11;
// 		if (res==1)
// 			dvr = 'k';
// 		else if (res==0)
// 			dvr = '0';
// 		else
// 		{
// 			dvi = 11-res;
// 			dvr = dvi + "";
// 		}
 
// 		if ( dvr != dv.toLowerCase() )
// 		{
// 			return false;
// 		}
// 		return true;
// 	}
// }


function validarRegex(tipo, valor) {
	var regex;
	switch (tipo){
		case "email":
			regex = /^[a-zA-Z0-9.!#$%&*+\=?^_`{|}~-äÄëËïÏöÖüÜáéíóúáéíóúÁÉÍÓÚÂÊÎÔÛâêîôûàèìòùÀÈÌÒÙñÑ]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/;
			break;
		case "fono":
			regex = /^(\+56)([2-9])[98765432]\d{7}$/;
			break;
		case "hora":
			regex = /^([01]?[0-9]|2[0-3]):[03][0]$/;
			break;
	}

	if (!(regex.test(valor))) {
	  return false;
	}
	return true;
}

function estaVacio(valor) {
	valor = valor.trim();
	if (valor.length===0){
		return true;
	}
	return false;
}

// Funcion AJAX
function ajax(ruta, params, metodo, async, json, callback) {
	// ruta (string): ejemplo db/command.php
	// params (string): ejemplo "parametro=valor&otro_parametro=otro_valor"
	// metodo(string): "GET" | "POST"
	// async(boolean): true | false
	// json(boolean): true | false

	var url;
	var retorno;
	var xhr = new XMLHttpRequest();
	var response;

	xhr.onreadystatechange = function() {
		if (xhr.readyState == 4 && xhr.status == 200) {

			if (json) {
				response = JSON.parse(xhr.responseText);
			} else {
				response = xhr.responseText;
			}

			if (callback) {
				retorno = callback (response);
			} else {
				retorno = response;
			}
		}
	}
	if (metodo === "POST") {
		url = ruta;
		xhr.open(metodo, url, async);
		xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
		xhr.send(params);
	} else if (metodo === "GET") {
		url = ruta + "?" + params;
		xhr.open(metodo, url, async);
		xhr.send();
	}

	return retorno;
	
}

// separador de miles
function separadorMiles (valor) {
	if (!(isNaN(valor))){
		return new Intl.NumberFormat("de-DE").format(valor);
	} else {
		return valor;
	}
}


// TODO aplicar formateador
   function formatearDinero (selector, signo) {
    // selector #input-efectivo
    var valor = $(selector).val();
    valor = valor.replace("$", "");
    valor = valor.split(".").join("");
    valor = valor.split(",").join("");

    if (isNaN(valor)) {
        // bootbox.alert('Ingrese sólo números')
    } else {
       var valorFormateado = new Intl.NumberFormat("de-DE").format(valor);
       $(selector).val(signo+valorFormateado);
    }

}

function limpiarNumero(valor) {
    valor = valor.replace("$", "");
    valor = valor.split(".").join("");
    valor = valor.split(",").join("");
    return valor;
}




function salidaContenedor() {
	// const boton = document.querySelector('#sidebarCollapse')
	// boton.classList.remove('animated', boton.attributes.animacion.value, 'delay-1s')
	// boton.classList.add('animated', 'fadeOut')
	
	$('#sidebarCollapse').fadeOut();

	setTimeout(() => {
		const content = document.querySelector('#content')
		content.classList.remove('animated', content.attributes.animacion.value, 'delay-1s')
		content.classList.add('animated', 'slideOutRight')
	}, 5000);




  }

  function animateCSS(element, animationName, callback) {

	// document.querySelector('#content').attributes.animacion.value
    const node = document.querySelector(element)
	node.classList.remove('animated', node.attributes.animacion.value)
    node.classList.add('animated', animationName)

    function handleAnimationEnd() {
        node.classList.remove('animated', animationName)
        node.removeEventListener('animationend', handleAnimationEnd)

        if (typeof callback === 'function') callback()
    }

    node.addEventListener('animationend', handleAnimationEnd)
}






   $(function() {

	   if($("#nav-bar").length) {
		   $("body").css('padding-top', document.getElementById('nav-bar').offsetHeight+"px");
	   }


	   $('[data-fancybox]').fancybox({
        toolbar  : false,
        smallBtn : true,
        iframe : {
            preload : false
        }
	})
	
	// desplazamiento animado anchor
	// document.querySelectorAll('a[href^="#"]').forEach(anchor => {
	// 	anchor.addEventListener('click', function (e) {
	// 		e.preventDefault();
	
	// 		document.querySelector(this.getAttribute('href')).scrollIntoView({
	// 			behavior: 'smooth'
	// 		});
	// 	});
	// });
	

   });
