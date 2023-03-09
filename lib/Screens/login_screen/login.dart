import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:http/http.dart' as http;
import '../../Providers/login_provider.dart';
import 'dart:convert';


import '../../ui/input_decorations.dart';
import '../../widgets/widgets.dart';
import '../home_screen/home_.dart';


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
                //Imagen de carga
                if(context.read<loginProvider>().obtener_cargando())
                  const _loading(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //Post al login del servlet
  Future<Tuple2<int, String>> callLogin(BuildContext context, String usr, String pwd) async {
  
    
    //cargando = true;
    context.read<loginProvider>().cambiar_cargando(true);
    //setState(() {});
    //await Future.delayed(const Duration(seconds: 5));
    
    final response = await http.post(
      Uri.parse('http://192.168.56.1:8080/siia/respLogin2'),
      body: {
        'usr': usr,
        'pwd': pwd,
        'B1': 'entrar',
        'TAB': '1',
      },
    );

    //cargando = false;
    context.read<loginProvider>().cambiar_cargando(false);
    setState(() {});                                        //Es necesario para que elimine la animacion de cargando
    var jsonResponse = json.decode(response.body);
    
    //Verificacion de la respuesta del servidor
    if (response.statusCode == 200) {
      
      if(jsonResponse.containsKey('ERROR')){
        return Tuple2(0, jsonResponse["ERROR"]);
      }

      if(jsonResponse.containsKey('OK')){
        //idSesion=jsonResponse["JSESSIONID"]; //Obtencion del Id de la sesion 
        context.read<loginProvider>().establece_idSesion(jsonResponse["JSESSIONID"]);
        return Tuple2(1, "OK");
      }
      
    }
    return Tuple2(0, response.statusCode.toString());
  }

}


class _loading extends StatelessWidget {
  const _loading({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0),
          shape: BoxShape.circle
        ),
        child: const CircularProgressIndicator(
          color: Colors.blue,
        ),
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




