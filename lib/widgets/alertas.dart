import 'package:flutter/material.dart';

import '../Model/models.dart';
import 'dropdowns.dart';

// Alerta de error con un mensaje predeterminado
void muestraAlerta(BuildContext context, String mensaje) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Error'),
        content: Text(mensaje),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
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
void alertaDocumentoSubido(BuildContext context, String mensaje) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Subida Archivo'),
        content: Text(mensaje),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
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
Future<InformacionFormulario?> formularioEnvio(BuildContext context) async {
  String selectedValue = "";
  final matriculaController = TextEditingController();
  final comentariosController = TextEditingController();
  final tipoDocumentoController = TextEditingController();
  final GlobalKey<FormState> formularioKey = GlobalKey<FormState>();

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Datos del documento'),
        content: Form(
          key: formularioKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Matricula faltante';
                  }
                  return null;
                },
                controller: matriculaController,
                decoration: const InputDecoration(hintText: "Matricula"),
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
                decoration: const InputDecoration(hintText: "Comentarios"),
              ),
              TextFormField(
                controller: tipoDocumentoController,
                decoration:
                    const InputDecoration(hintText: "Tipo de documento"),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              InformacionFormulario formInfo = InformacionFormulario(
                  matricula: matriculaController.text,
                  tipoDocumentoPersonal: "10",
                  respuesta: 'cancel',
                  tipoDocumento: selectedValue,
                  comentarios: comentariosController.text);
              Navigator.of(context).pop(formInfo);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              //Validaciones de campos requeridos
              if (!formularioKey.currentState!.validate()) {
                return;
              }
              if (selectedValue.isEmpty) {
                return muestraAlerta(
                    context, "Tipo de documento no establecido");
              }
              //Envio de archivos
              InformacionFormulario formInfo = InformacionFormulario(
                  matricula: matriculaController.text,
                  tipoDocumentoPersonal: "10",
                  respuesta: 'OK',
                  tipoDocumento: selectedValue,
                  comentarios: comentariosController.text);

              Navigator.of(context).pop(formInfo);
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
