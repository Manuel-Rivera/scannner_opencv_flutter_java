import 'package:flutter/material.dart';

const List<String> list = <String>['CERTIFICACION DE FIRMAS',
'ACTA DE NACIMIENTO',
'CERTIFICADO GLOBAL DE ESTUDIOS',
'TITULO DE MAESTRIA 2',
'CONSTANCIA DE TERM. DE LIC.',
'CONSTANCIA DE TERM. DE ESP.',
'CONSTANCIA DE TERM. DE MAEST.'];

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
  String? dropdownValue = null;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      hint: Text("Tipo de documento"),
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
        widget.onSelectedValueChanged(dropdownValue!); // Call the callback function with the selected value
      },
      items: list.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}