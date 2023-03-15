import 'package:flutter/material.dart';

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
      items: dropdownItems,
    );
  }
}
