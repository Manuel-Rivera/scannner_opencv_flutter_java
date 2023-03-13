import 'package:flutter/material.dart';
import 'dropdowns.dart';


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




Future<String?> formularioEnvio(BuildContext context) async {
  String selectedValue = "USA";
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('My Form'),
        content: Column(children: [
          TextField(
            decoration: InputDecoration(hintText: "Matricula"),
          ),
          DropdownButtonExample(),
          TextField(
            decoration: InputDecoration(hintText: "Comentarios"),
            
          ),
          TextField(
            decoration: InputDecoration(hintText: "Tipo de documento"),
          ),
         

        ],),
        actions: <Widget>[
          TextButton(
            onPressed: (){ Navigator.of(context).pop('cancel');},
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('OK'),
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}





