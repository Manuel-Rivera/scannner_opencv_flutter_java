import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:http/http.dart' as http;

import '../Providers/login_provider.dart';

List<DropdownMenuItem<String>> get dropdownItems {
  List<DropdownMenuItem<String>> menuItems = [
    const DropdownMenuItem(value: "0", child: Text("CERTIFICACION DE FIRMAS")),
    const DropdownMenuItem(value: "1", child: Text("ACTA DE NACIMIENTO")),
    const DropdownMenuItem(
        value: "10", child: Text("ERTIFICADO GLOBAL DE ESTUDIOS")),
    const DropdownMenuItem(value: "100", child: Text("TITULO DE MAESTRIA 2")),
    const DropdownMenuItem(
        value: "101", child: Text("CONSTANCIA DE TERM. DE LIC.")),
    const DropdownMenuItem(
        value: "102", child: Text("CONSTANCIA DE TERM. DE ESP.")),
    const DropdownMenuItem(
        value: "103", child: Text("TCONSTANCIA DE TERM. DE MAEST.")),
  ];
  return menuItems;
}

//Envia una peticion para obtener los tipos de documentos que maneja la base de datos
  Future<String> stringTdocum(BuildContext context) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://148.216.31.181:8080/siia/getPTDOCEMP'),
    );

    // Set the session ID as a cookie in the request headers
    request.headers['cookie'] =
        'JSESSIONID=${Provider.of<LoginProvider>(context, listen: false)}';
    try {
      // Send the request and get the response
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      //var responseBody = "";
      
      return responseBody;
    } catch (e) {
      return "";
    }
  }


//Funcion que crea una lista de DropdownMenuItem en base a una peticion POST a la base de datos
Future<List<DropdownMenuItem<String>>> StringToDropdownlist(BuildContext context) async{
  String tdocum = await stringTdocum(context);
  List<String> parts = tdocum.replaceAll("{", "").replaceAll("}", "").split(", ");
  List<DropdownMenuItem<String>> dropdownItems = parts.map((part) {
  List<String> pair = part.split("=");
  return DropdownMenuItem(
      value: pair[0],
      child: Text(pair[1]),
    );
  }).toList();

  return dropdownItems;
}

class DropdownButtonExample extends StatefulWidget {
  //Definicion de una funcion callback
  final Function(String) onSelectedValueChanged;
  //El constructor pide como argumento una funcion
  //Esta funcion se llamara cuando haya un cambio en el valor seleccionado de DropdownButton
  const DropdownButtonExample({Key? key, required this.onSelectedValueChanged})
      : super(key: key);

  @override
  State<DropdownButtonExample> createState() => _DropdownButtonExampleState();
}

class _DropdownButtonExampleState extends State<DropdownButtonExample> {
  String? dropdownValue;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DropdownMenuItem<String>>>(
      future: StringToDropdownlist(context),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return DropdownButton<String>(
            hint: const Text("Tipo de documento"),
            value: dropdownValue,
            icon: const Icon(Icons.arrow_drop_down),
            elevation: 16,
            style: const TextStyle(color: Colors.black),
            underline: Container(
              height: 2,
              color: Colors.black,
            ),
            onChanged: (String? value) {
              // This is called when the user selects an item.
              setState(() {
                dropdownValue = value!;
              });
              //Llamada a la funcion callback pasandole como parametro el valor seleccionado
              widget.onSelectedValueChanged(
                  dropdownValue!); // Call the callback function with the selected value
            },
            items: snapshot.data!,
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
