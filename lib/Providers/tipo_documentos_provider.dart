import 'package:flutter/material.dart';

class tipoDocumentoProvider extends ChangeNotifier {
  List<DropdownMenuItem<String>> listaTDocums = [];

  void setListaTDocums (List<DropdownMenuItem<String>> tdocums){
      listaTDocums =  tdocums;
  }

  List<DropdownMenuItem<String>> getListaTDocums(){
    return listaTDocums;
  }

}
