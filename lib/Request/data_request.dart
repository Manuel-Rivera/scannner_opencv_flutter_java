import 'dart:io';
import 'dart:convert';
import 'package:xml/xml.dart';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:http/http.dart' as http;

import '../Model/docuement_model.dart';
import '../Model/informacion_formulario.dart';
import '../Providers/login_provider.dart';

  //Envia una peticion para obtener los tipos de documentos que maneja la base de datos
  Future<Tuple2<int, String>> stringTdocum(BuildContext context) async {
    /*  Esta funcion realiza una peticion POST para obtener un listado 
        con todos los tipos de documentos registrados en la base de datos,
        asi como su respectivo valor (indice).

        :Params: 
          - Context:  Contexto de la aplicacion
        :Returns:     Tupla de 2 elementos <int, String>
          - int:      Posibles valores (1,0), siendo 1 igual a una respuesta exitosa y 0 lo contrario
          - String    Mensaje respuesta de la peticion
    */

    //Construccion de la peticion POST
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://148.216.31.181:8080/siia/getPTDOCEMP2'),
    );

    // Agrega el parametro del ID de la sesion al header de la peticion
    request.headers['cookie'] =
        'JSESSIONID=${Provider.of<LoginProvider>(context, listen: false)}';
    try {
      // Envio de la peticion y espera de la respuesta
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      
      //Convierte la respuesta a JSON
      var jsonResponse = json.decode(responseBody);
      //Se genero un error en el servidor
      if (jsonResponse.containsKey('ERROR')) {
          return Tuple2(0, jsonResponse["ERROR"]);
        }
      // Respuesta correcta
      return Tuple2(1, responseBody);
    } catch (e) {
      //Error al procesar la respuesta del servidor
      return Tuple2(0, e.toString());
    }
  }


  //Envia una peticion para obtener el nombre del archivo a subir (numero consecutivo)
  Future<Tuple2<int, String>> numeroArchivo(BuildContext context) async {
    /*  Esta funcion realiza una peticion POST para obtener el siguiente numero 
        consecutivo que tomara el nombre del archivo a subir

        :Params: 
          - Context:  Contexto de la aplicacion
        :Returns:     Tupla de 2 elementos <int, String>
          - int:      Posibles valores (1,0), siendo 1 igual a una respuesta exitosa y 0 lo contrario
          - String    Mensaje respuesta de la peticion
    
    */

    //Construccion de la peticion POST
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://148.216.31.181:8080/siia/ldXML'),
    );

    // Parametros
    request.fields['lista'] = 'lista';
    request.fields['cuso'] = 'comun.cntArchis';

    // Agrega el parametro del ID de la sesion al header de la peticion
    request.headers['cookie'] =
        'JSESSIONID=${context.read<LoginProvider>().obtenerIdSesion()}';
    try {
      // Envio de la peticion y espera de la respuesta
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      //La respuesta viene en un HTML asi que se convierte en un XmlDocument
      final document = XmlDocument.parse(responseBody);
      //Busqueda del elemento que contiene el siguiente numero de la secuencia
      final cntElement = document.findAllElements('CNT').first;
      final cntValue = cntElement.text;
      //Respuesta exitosa
      return Tuple2(1, cntValue);
    } catch (e) {
      //Error al procesar la respuesta o error del servidor
      return Tuple2(0, e.toString());
    }
  }

  //Envio del archivo a la base de datos
  Future<Tuple2<int, String>> sendFile(BuildContext context,
      DocumentModel document, InformacionFormulario formInfo) async {
    /*  Esta funcion realiza una peticion POST que envia datos de un documento al servidor
        para que este los procese y cree un registro del nuevo documento recibido

        :Params: 
          - Context:  Contexto de la aplicacion
          - document: Instancia que contiene informacion acerca del documento a enviar
          - formInfo: Datos del formulario que lleno el usuario previo al envio del documento

        :Returns:     Tupla de 2 elementos <int, String>
          - int:      Posibles valores (1,0), siendo 1 igual a una respuesta exitosa y 0 lo contrario
          - String    Mensaje respuesta de la peticion
    */

    //Construccion de la peticion POST
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://148.216.31.181:8080/siia/carPDF'),
    );

    // Agrega el archivo como parametro a la peticion
    var file = File(document.pdfPath);
    var stream = http.ByteStream(file.openRead());
    var length = await file.length();
    var multipartFile =
        http.MultipartFile('archi', stream, length, filename: 'example.pdf');

    request.files.add(multipartFile);

    //Numero de sequencia del archivo
    Tuple2<int, String> respNum = await numeroArchivo(context);

    //Fallo al obtener el siguiente numero de secuencia
    if (respNum.item1 == 0) {
      return respNum;
    }

    // Agrega otros parametros a la peticion
    request.fields['usr'] = context.read<LoginProvider>().obtenerUsuario();
    request.fields['num'] = respNum.item2;                        //Numero de la secuencia que le corresponde al archivo
    request.fields['dir'] = 'archivos';                           //Directorio donde se guardara el arhivo
    request.fields['id'] = respNum.item2;                         //Id del archivo
    request.fields['coments'] = 'Desde flutter';                  //Comentarios
    request.fields['arch_alumno'] = formInfo.matricula;           //Matricula del alumno que le corresponde el archivo
    request.fields['arch_nombre'] = document.name;                //Nombre real del archivo
    //Tipo de documento (Por defecto es PDF)
    request.fields['arch_ctype'] = formInfo.tipoDocumento.isNotEmpty ? formInfo.tipoDocumento : "PDF";
    request.fields['arch_size'] = file.lengthSync().toString();   //Tamaño del archivo en bytes
    request.fields['arch_tdoc'] = formInfo.tipoDocumentoPersonal; //Tipo de documento
    request.fields['arch_boveda'] = '1';                          //Identificador en la boveda
    //request.fields['arch_wid'] = '';                            //Identificador ascendente para el siia web (OPCIONAL) Se obtiene desde el servlet
    request.fields['arch_warchid'] = '';                          //Identificador archivo siia web            (OPCIONAL)
    request.fields['arch_comen'] = formInfo.comentarios;          //Comentarios                               (OPCIONAL)
    
    // Agrega el parametro del ID de la sesion al header de la peticion
    request.headers['cookie'] =
        'JSESSIONID=${context.read<LoginProvider>().obtenerIdSesion()}';

    try {
      // Envio de la peticion y obtencion de la respuesta
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseBody);

      //En caso de recibir una respuesta del servidor
      if (response.statusCode == 200) {
        //Respuesta erronea
        if (jsonResponse.containsKey('ERROR')) {
          return Tuple2(0, jsonResponse["ERROR"]);
        }
        // Respueta exitosa
        if (jsonResponse.containsKey('OK')) {
          return const Tuple2(1, "OK");
        }
      }
      //Respuesta negativa del servidor
      return Tuple2(0, response.statusCode.toString());
    } catch (e) {
      //Error al procesar la respuesta del servidor
      return Tuple2(0, e.toString());
    }
  }