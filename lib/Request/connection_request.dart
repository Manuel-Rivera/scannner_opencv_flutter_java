
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:http/http.dart' as http;

import '../Providers/login_provider.dart';

//Peticion post para realizar un Login al siia web
Future<Tuple2<int, String>> callLogin(
      BuildContext context, String usr, String pwd) async {
    /*  Esta funcion realiza una peticion POST al servidor con el objetivo de iniciar sesion
        y obtener una respuesta del mismo.

        :Params:
          - Context:  Contexto de la aplicacion
          - usr:      Usuario
          - pwd:      Contraseña
        :Returns:     Tupla de 2 elementos <int, String>
          - int:      Posibles valores (1,0), siendo 1 igual a un inicio de sesion exitoso y 0 lo contrario
          - String    Mensaje respuesta del inicio de sesion
    */

    //Indica el estado del inicio de sesion
    Provider.of<LoginProvider>(context, listen: false).cambiarCargando(true);

    //Realiza la peticion post
    try {
      //Creacion de la peticion junto a sus parametros
      final response = await http.post(
        Uri.parse('http://148.216.31.181:8080/siia/respLogin'),
        body: {
          'usr': usr,
          'pwd': pwd,
          'B1': 'entrar',
          'TAB': '1',
        },
      );

      //Transforma la respuesta de la peticion a un JSON
      var jsonResponse = json.decode(response.body);
      
      //En caso de recibir una respuesta del servidor
      if (response.statusCode == 200) {
        //Recepcion de un error
        if (jsonResponse.containsKey('ERROR')) {
          return Tuple2(0, jsonResponse["ERROR"]);
        }

        //Inicio de sesion correcto
        if (jsonResponse.containsKey('OK')) {
          //Recupera el ID de la sesion
          context.read<LoginProvider>().estableceIdSesion(
              jsonResponse["JSESSIONID"], jsonResponse["USR"]);
          return const Tuple2(1, "OK");
        }
      }
      //Respuesta negativa del servidor
      return Tuple2(0, response.statusCode.toString());
    } catch (e) {
      //Error al procesar la respuesta del servidor
      Provider.of<LoginProvider>(context, listen: false).cambiarCargando(false);
      return Tuple2(0, e.toString());
    }
  }


  
