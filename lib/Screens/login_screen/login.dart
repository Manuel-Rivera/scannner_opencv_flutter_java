import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:http/http.dart' as http;

import '../../ui/input_decorations.dart';
import '../../widgets/widgets.dart';
import '../home_screen/home.dart';
import '../../Providers/login_provider.dart';

//String idSesion ="";

class Login extends StatefulWidget {
  Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}


class _LoginState extends State<Login>{
  final TextEditingController userController   = TextEditingController();
  final TextEditingController paswordController   = TextEditingController();
  final GlobalKey<FormState> keyLogin = GlobalKey<FormState>();
  //bool cargando = false;

  @override 
  Widget build(BuildContext context){
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: AuthBackground(
        formulario: SingleChildScrollView(
          child: Form(
            key: keyLogin,
            child: Column(
              children: [
                SizedBox(height: size.height*0.3),
                formularioContenedor(
                  child: Column(
                    children: [
                      Text('Ingreso',style: Theme.of(context).textTheme.headline4),
                      SizedBox(height: 16), // Add some space between the text fields
                      TextFormField(
                        validator: (value){ if (value == null || value.isEmpty){
                          return 'Usuario faltante';
                        } return null;},
                        maxLines: 1,
                        autocorrect: false,
                        controller: userController,
                        decoration: InputDecorations.authInputDecoration(
                          hintText: "Usuario",
                          prefixIcon: Icons.account_circle_rounded,
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
                        decoration: InputDecorations.authInputDecoration(
                          hintText: "Contraseña",
                          prefixIcon: Icons.password,
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
                          if(!context.read<loginProvider>().obtener_cargando()){ //Evita una multiples llamadas al Login si ya hay una en proceso}
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
                        child: Text("Entrar")
                      ),
                    ],
                  )
                ),
                //Construye la animacion de cargando cuando sea necesario
                Consumer<loginProvider>(
                  builder: (context, provider, child) {
                    if (provider.obtener_cargando()) {  //Si esta cargando
                      return loading();          //Retorna animacion de cargando
                    } else {  
                      return SizedBox.shrink();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //Post al login del servlet
  Future<Tuple2<int, String>> callLogin(BuildContext context, String usr, String pwd) async {
    Provider.of<loginProvider>(context, listen: false).cambiar_cargando(true);

    try{
      final response = await http.post(
        Uri.parse('http://148.216.31.181:8080/siia/respLogin2'),
        body: {
          'usr': usr,
          'pwd': pwd,
          'B1': 'entrar',
          'TAB': '1',
        },
      );

      Provider.of<loginProvider>(context, listen: false).cambiar_cargando(false);
      var jsonResponse = json.decode(response.body);
      //Verificacion de la respuesta del servidor

      if (response.statusCode == 200) {
        
        if(jsonResponse.containsKey('ERROR')){
          return Tuple2(0, jsonResponse["ERROR"]);
        }

        if(jsonResponse.containsKey('OK')){
          context.read<loginProvider>().establece_idSesion(jsonResponse["JSESSIONID"],jsonResponse["USR"]);
          return Tuple2(1, "OK");
        }
      }
      return Tuple2(0, response.statusCode.toString());
    }
    catch(e){
        Provider.of<loginProvider>(context, listen: false).cambiar_cargando(false);
       return Tuple2(0, e.toString());
    }
  }

}





