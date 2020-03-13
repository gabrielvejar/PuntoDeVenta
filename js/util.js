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
var formatNumber = {
	separador: ".", // separador para los miles
	sepDecimal: ',', // separador para los decimales
	formatear:function (num){
	num +='';
	var splitStr = num.split('.');
	var splitLeft = splitStr[0];
	var splitRight = splitStr.length > 1 ? this.sepDecimal + splitStr[1] : '';
	var regx = /(\d+)(\d{3})/;
	while (regx.test(splitLeft)) {
	splitLeft = splitLeft.replace(regx, '$1' + this.separador + '$2');
	}
	return this.simbol + splitLeft +splitRight;
	},
	new:function(num, simbol){
	this.simbol = simbol ||'';
	return this.formatear(num);
	}
   }