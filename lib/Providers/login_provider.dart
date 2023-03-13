import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class loginProvider extends ChangeNotifier {
  String _idSesion = "";
  String _usr = "";
  bool _cargando = false;
  bool _cargandoEnvio = false;

  void establece_idSesion(String idSesion, String usr){
    _idSesion = idSesion;
    _usr = usr;
  }

  String obtener_idSesion(){
    return _idSesion;
  }

  void cambiar_cargando(bool cargando) {
    _cargando = cargando;
    notifyListeners();
  }

  bool obtener_cargando(){
    return _cargando;
  }

  String obtener_usuario(){
    return _usr;
  }

}