import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginProvider extends ChangeNotifier {
  String _idSesion = "";
  String _usr = "";
  bool _cargando = false;

  void estableceIdSesion(String idSesion, String usr) {
    _idSesion = idSesion;
    _usr = usr;
  }

  String obtenerIdSesion() {
    return _idSesion;
  }

  void cambiarCargando(bool cargando) {
    _cargando = cargando;
    notifyListeners();
  }

  bool obtenerCargando() {
    return _cargando;
  }

  String obtenerUsuario() {
    return _usr;
  }
}
