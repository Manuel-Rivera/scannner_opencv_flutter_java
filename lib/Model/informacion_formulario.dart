import 'package:flutter/cupertino.dart';

//Formato de respuesta del formulario previo al envio del archivo

class informacionFormulario {
  final String matricula;
  final int tipoDocumentoPersonal;
  final String comentarios="";
  final String tipoDocumento;
  final String respuesta;
  informacionFormulario(
      {required this.matricula,
      required this.tipoDocumentoPersonal,
      required this.respuesta,
      required this.tipoDocumento});
}