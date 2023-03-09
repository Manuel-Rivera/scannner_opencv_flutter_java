import 'dart:io';
import 'dart:convert';

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:document_scanner/main.dart';
import 'package:tuple/tuple.dart';

import '../home_screen/home_.dart';


String idSesion ="";

class Login extends StatefulWidget {
  Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController userController   = TextEditingController();

  final TextEditingController paswordController   = TextEditingController();

  final GlobalKey<FormState> keyLogin = GlobalKey<FormState>();

  bool cargando = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('UMSNH'),
      ),
      body: Center(
      child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Form(
        key: keyLogin,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:  [
            TextFormField(
              validator: (value){ if (value == null || value.isEmpty){
                return 'Usuario faltante';
              } return null;},
              maxLines: 1,
              controller: userController,
              decoration: InputDecoration(
                hintText: "Usuario",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16), // Add some space between the text fields
            TextFormField(
              validator: (value){ if (value == null || value.isEmpty){
                return 'Contraseña faltante';
              } return null;},
              maxLines: 1,
              controller: paswordController,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: InputDecoration(
                hintText: "Contraseña",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16), // Add some space between the text fields
            ElevatedButton(
              onPressed: () {
                FocusManager.instance.primaryFocus?.unfocus(); //Oculta el teclado
                
                //Validacion de los campos del formulario (que no esten vacios)
                if (!keyLogin.currentState!.validate()){
                  return;
                }
                if(!cargando){ //Evita una multiples llamadas al Login si ya hay una en proceso
                  //Llamada al login
                  callLogin(context, userController.text, paswordController.text).then((tuple) {
                    int login = tuple.item1;
                    String mensaje = tuple.item2;
                    //Login correcto
                    if(login==1){
                      //Llamada a una nueva ventana
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Home()),
                      );
                    }
                    else{//Error en login
                      muestraAlerta(context, mensaje.toString());
                    }
                  });
                }
              }, 
              child: Text("Entrar")),
              

              //Imagen de carga
              if(cargando)
                Positioned(
                  bottom: 10,
                  left: size.width * 0.5 - 30,
                  child: const _loading(),
                  ),
          ],
        ),
      ),
      ),
    ),
    );
  }

//Post al login del servlet
Future<Tuple2<int, String>> callLogin(BuildContext context, String urs, String pwd) async {
  cargando = true;
  setState(() {});
  //await Future.delayed(const Duration(seconds: 5));
  
  final response = await http.post(
    Uri.parse('http://192.168.56.1:8080/siia/respLogin2'),
    body: {
      'usr': urs,
      'pwd': pwd,
      'B1': 'entrar',
      'TAB': '1',
    },
  );

  cargando = false;
  setState(() {});
  
  var jsonResponse = json.decode(response.body);
  //print("jsonResponse: $jsonResponse");
  
  //Verificacion de la respuesta del servidor
  if (response.statusCode == 200) {
    
    if(jsonResponse.containsKey('ERROR')){
      return Tuple2(0, jsonResponse["ERROR"]);
    }

    if(jsonResponse.containsKey('OK')){
      idSesion=jsonResponse["JSESSIONID"]; //Obtencion del Id de la sesion 
      return Tuple2(1, "OK");
    }
    
  }
  return Tuple2(0, response.statusCode.toString());
}

/*
//Intento de Post al login del servlet usando otra libreria
Future<Tuple2<int, String>> callLogin2(BuildContext context, String urs, String pwd) async {
  cargando = true;
  setState(() {});
  
  dio.interceptors.add(CookieManager(cookieJar));
  //await Future.delayed(const Duration(seconds: 5));
  //String idSesion = "";
  Response respuesta = await Dio().post(
    'http://192.168.56.1:8080/siia/respLogin',
    queryParameters: {
      'usr': urs,
      'pwd': pwd,
      'B1': 'entrar',
      'TAB': '1',
    },
  );

  cargando = false;
  setState(() {});


  if (respuesta.statusCode == 200) {
    
    if(respuesta.data.contains("OK")){
        //Obtencion del Id de la sesion 
        idSesion=respuesta.data.toString().split(":")[1];
        var cookies = <Cookie>[];
        cookies.add(Cookie('session_id', idSesion));
        //Guarda el ID de la sesion para futuras peticiones
        cookieJar.saveFromResponse(
          respuesta.requestOptions.uri,
          cookies,
        );

      return Tuple2(1, "OK");
    }

    if(respuesta.data.contains("No corresponde Contraseña")){
      return Tuple2(0, "No corresponde Contraseña");
    }
    else if ( respuesta.data.contains("No existe Usuario")){
      return Tuple2(0, "No existe Usuario");
    }
  }
  return Tuple2(0, respuesta.statusCode.toString());
}
*/
}

class _loading extends StatelessWidget {
  const _loading({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        shape: BoxShape.circle
      ),
      child: const CircularProgressIndicator(
        color: Colors.blue,
      ),
    );
  }
}




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