import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../../Providers/login_provider.dart';
import '../../ui/input_decorations.dart';
import '../../widgets/widgets.dart';
import '../home_screen/home.dart';

//String idSesion ="";

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
                        onPressed: () {
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
                                .then((tuple) {
                              int login = tuple.item1;
                              String mensaje = tuple.item2;
                              //Login correcto
                              if (login == 1) {
                                //Llamada a una nueva ventana
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Home()),
                                );
                              } else {
                                //Error en login
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

  //Post al login del servlet
  Future<Tuple2<int, String>> callLogin(
      BuildContext context, String usr, String pwd) async {
    Provider.of<LoginProvider>(context, listen: false).cambiarCargando(true);

    try {
      final response = await http.post(
        Uri.parse('http://192.168.56.1:8080/siia/respLogin2'),
        body: {
          'usr': usr,
          'pwd': pwd,
          'B1': 'entrar',
          'TAB': '1',
        },
      );

      Provider.of<LoginProvider>(context, listen: false).cambiarCargando(false);
      var jsonResponse = json.decode(response.body);
      //Verificacion de la respuesta del servidor

      if (response.statusCode == 200) {
        if (jsonResponse.containsKey('ERROR')) {
          return Tuple2(0, jsonResponse["ERROR"]);
        }

        if (jsonResponse.containsKey('OK')) {
          context.read<LoginProvider>().estableceIdSesion(
              jsonResponse["JSESSIONID"], jsonResponse["USR"]);
          return const Tuple2(1, "OK");
        }
      }
      return Tuple2(0, response.statusCode.toString());
    } catch (e) {
      Provider.of<LoginProvider>(context, listen: false).cambiarCargando(false);
      return Tuple2(0, e.toString());
    }
  }
}
