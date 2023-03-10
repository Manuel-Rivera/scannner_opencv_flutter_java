import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class loginProvider extends ChangeNotifier {
  String _idSesion = "";
  bool _cargando = false;
  bool _cargandoEnvio = false;

  void establece_idSesion(String idSesion){
    _idSesion = idSesion;
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

}