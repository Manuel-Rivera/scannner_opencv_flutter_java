import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginProvider extends ChangeNotifier {
  String _idSesion = "";
  late final String _usr;
  late final String _pass;
  bool _cargando = false;
  final String _ip = "148.216.31.181";
  final String _puerto = "8080";

  //!Validar si se tiene una conexión activa
  void conex(String usr, String pass) async {
    String params = "";
    String endPoint = "respLogin2";
    http.post(
      Uri.parse("http://$_ip:$_puerto/siia/$endPoint"),
      body: {'usr': usr, 'pwd': pass, 'B1': 'entrar', 'TAB': '1'},
    ).then((response) {
      final res = json.decode(response.body);

      if (response.statusCode == 200) {
        //!SE ESTABLECIO CONEXIÓN CORRECTAMENTE

      } else {
        //TODO:ERROR DE CONEXIÓN
      }
    });
  }

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
