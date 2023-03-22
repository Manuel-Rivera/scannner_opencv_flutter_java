import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../../Providers/login_provider.dart';
import '../../Providers/tipo_documentos_provider.dart';
import '../../ui/input_decorations.dart';
import '../../widgets/widgets.dart';
import '../home_screen/home.dart';
import '../../Request/request.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController userController = TextEditingController();
  final TextEditingController paswordController = TextEditingController();
  final GlobalKey<FormState> keyLogin = GlobalKey<FormState>();
  //bool cargando = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    int login = -1;
    String mensaje = "";
    return Scaffold(
      body: AuthBackground(
        formulario: SingleChildScrollView(
          child: Form(
            key: keyLogin,
            child: Column(
              children: [
                SizedBox(height: size.height * 0.3),
                FormularioContenedor(
                    child: Column(
                  children: [
                    Text('Ingreso',
                        style: Theme.of(context).textTheme.headline4),
                    const SizedBox(
                        height: 16), // Add some space between the text fields
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Usuario faltante';
                        }
                        return null;
                      },
                      maxLines: 1,
                      autocorrect: false,
                      controller: userController,
                      decoration: InputDecorations.authInputDecoration(
                        hintText: "Usuario",
                        prefixIcon: Icons.account_circle_rounded,
                      ),
                    ),
                    const SizedBox(
                        height: 16), // Add some space between the text fields
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Contraseña faltante';
                        }
                        return null;
                      },
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
                    const SizedBox(
                        height: 16), // Add some space between the text fields
                    ElevatedButton(
                        onPressed: () async {
                          FocusManager.instance.primaryFocus
                              ?.unfocus(); //Oculta el teclado
                          //Validacion de los campos del formulario (que no esten vacios)
                          if (!keyLogin.currentState!.validate()) {
                            return;
                          }
                          if (!context
                              .read<LoginProvider>()
                              .obtenerCargando()) {
                            //Evita una multiples llamadas al Login si ya hay una en proceso}
                            //Llamada al login
                            callLogin(context, userController.text,
                                    paswordController.text)
                                .then((tuple) async {
                               login = tuple.item1;
                               mensaje = tuple.item2;

                              //Login correcto
                              if (login == 1) {
                                //Consulta la lista de Tipos de documentos de la base de datos
                                Tuple2<int,List<DropdownMenuItem<String>>> response = await StringToDropdownlist(context);
                                if(response.item1 == 1){
                                  //Almacena la lista en un Provider en forma de list<DropdownMenuItem<String>>
                                  Provider.of<tipoDocumentoProvider>(context, listen: false).setListaTDocums(response.item2);
                                  //Cambia el estado del login para que no este cargando
                                  Provider.of<LoginProvider>(context, listen: false).cambiarCargando(false);
                                  //Llamada a una nueva ventana
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Home()),
                                  );
                                }
                                else{
                                    Provider.of<LoginProvider>(context, listen: false).cambiarCargando(false);
                                    muestraAlerta(context, "Error del servidor: Carga de tipos de documentos ");
                                }
                              } else {
                                //Error en login
                                Provider.of<LoginProvider>(context, listen: false).cambiarCargando(false);
                                muestraAlerta(context, mensaje.toString());
                              }
                            }); 
                          }
                        },
                        child: const Text("Entrar")),
                  ],
                )),
                //Construye la animacion de cargando cuando sea necesario
                Consumer<LoginProvider>(
                  builder: (context, provider, child) {
                    if (provider.obtenerCargando()) {
                      //Si esta cargando
                      return const Loading(); //Retorna animacion de cargando
                    } else {
                      return const SizedBox.shrink();
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

  
//Funcion que crea una lista de DropdownMenuItem en base a una peticion POST a la base de datos
Future<Tuple2<int,List<DropdownMenuItem<String>>>> StringToDropdownlist(BuildContext context) async{
  Tuple2<int, String> resultado = await stringTdocum(context);
  int result = resultado.item1;
  String resp = resultado.item2;

  if(result==1){
    // Obtiene una cadena en forma de JSON que representa todos los tipos de documentos 
    String tdocum = resp;
    // Elimina caracteres inecesarios 
    List<String> parts = tdocum.replaceAll(RegExp(r'[{}"]+'), '').replaceAll(",OK:OK", "").split(', ');
    parts[0] = parts[0].substring(parts[0].lastIndexOf(":")+1);
    // Ordena la lista alfabeticamente por las subcadenas que representan el "NOMBRE" del tipo de documento
    parts.sort((a, b) => a.substring(a.lastIndexOf("=")).compareTo(b.substring(b.lastIndexOf("="))));
    List<DropdownMenuItem<String>> dropdownItems = parts.map((part) {
    List<String> pair = part.split("=");
    return DropdownMenuItem(
        value: pair[0],
        child: Text(pair[1]),
      );
    }).toList();

    return Tuple2(result, dropdownItems);
  }

  return Tuple2(0, []);

}

}
