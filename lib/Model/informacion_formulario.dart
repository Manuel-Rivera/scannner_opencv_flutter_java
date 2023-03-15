//Formato de respuesta del formulario previo al envio del archivo

class InformacionFormulario {
  final String matricula;
  final int tipoDocumentoPersonal;
  final String comentarios;
  final String tipoDocumento;
  final String respuesta;
  InformacionFormulario(
      {required this.matricula,
      required this.tipoDocumentoPersonal,
      required this.comentarios,
      required this.tipoDocumento,
      required this.respuesta});
}
