import 'package:flutter/material.dart';
import 'dropdowns.dart';
import '../Model/models.dart';


// Alerta de error con un mensaje predeterminado
void muestraAlerta(BuildContext context, String mensaje){
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Error'),
        content: Text(mensaje),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

// Alerta para indicar el resultado de un documento que se trato de subir
void alertaDocumentoSubido(BuildContext context, String mensaje){
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Subida Archivo'),
        content: Text(mensaje),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

//Formulario de datos adicionales a cada archivo
Future<informacionFormulario?> formularioEnvio(BuildContext context) async {
  String selectedValue = "";
  final matriculaController = TextEditingController();
  final comentariosController = TextEditingController();
  final tipoDocumentoController = TextEditingController();
  final GlobalKey<FormState> formularioKey = GlobalKey<FormState>();

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Datos del documento'),
        content: Form(
          key: formularioKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                validator: (value){ if (value == null || value.isEmpty){
                  return 'Matricula faltante';
                } return null;},
                controller: matriculaController,
                decoration: InputDecoration(hintText: "Matricula"),
              ),
              //Creacion del DropdownButton para seleccionar el tipo de documento
              DropdownButtonExample(
                //Funcion que se ejecuta cuando hay un cambio en el valor seleccionado
                onSelectedValueChanged: (String value) {
                  selectedValue = value;
                },
              ),
              TextFormField(
                controller: comentariosController,
                decoration: InputDecoration(hintText: "Comentarios"),
              ),
              TextFormField(
                controller: tipoDocumentoController,
                decoration: InputDecoration(hintText: "Tipo de documento"),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: (){ 
              informacionFormulario formInfo = informacionFormulario(
                matricula: matriculaController.text, 
                tipoDocumentoPersonal: 10, 
                respuesta: 'cancel',tipoDocumento: selectedValue);
              Navigator.of(context).pop(formInfo);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: (){ 
              //Validaciones de campos requeridos
              if (!formularioKey.currentState!.validate()){
                return;
              }
              if(selectedValue.isEmpty){
                return muestraAlerta(context,"Tipo de documento no establecido");
              }
              //Envio de archivos
              informacionFormulario formInfo = informacionFormulario(
                matricula: matriculaController.text, 
                tipoDocumentoPersonal: 10, 
                respuesta: 'OK', tipoDocumento: selectedValue);

              Navigator.of(context).pop(formInfo);
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}





