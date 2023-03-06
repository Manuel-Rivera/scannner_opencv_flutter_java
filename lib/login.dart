import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:document_scanner/main.dart';
import 'package:tuple/tuple.dart';



class LoginSesion extends StatelessWidget {
  LoginSesion({super.key});
  final TextEditingController userController   = TextEditingController();
  final TextEditingController paswordController   = TextEditingController();
  final GlobalKey<FormState> keyLogin = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
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
                print("ALGO:"+keyLogin.currentState!.validate().toString());
                if (!keyLogin.currentState!.validate()){
                  return;
                }
                  
                callLogin(context, userController.text, paswordController.text).then((tuple) {
                  int login = tuple.item1;
                  String mensaje = tuple.item2;
                  print("entero: "+login.toString());
                  print("myString: "+mensaje.toString());
    
                  if(login==1){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MyApp()),
                    );
                  }
                  else{
                    print("myString"+mensaje.toString());
                    muestraAlerta(context, mensaje.toString());
                  }
                });
              }, 
              child: Text("Entrar")),
          ],
        ),
      ),
      ),
    ),
    );
  }
}


Future<Tuple2<int, String>> callLogin(BuildContext context, String urs, String pwd) async {
  final response = await http.post(
    Uri.parse('http://192.168.56.1:8080/siia/respLogin'),
    body: {
      'usr': urs,
      'pwd': pwd,
      'B1': 'entrar',
      'TAB': '1',
    },
  );

  if (response.statusCode == 200) {
    
    if(response.body.contains("OK")){
      return Tuple2(1, "OK");
    }

    if(response.body.contains("No corresponde Contraseña")){
      return Tuple2(0, "No corresponde Contraseña");
    }
    else if ( response.body.contains("No existe Usuario")){
      return Tuple2(0, "No existe Usuario");
    }
  }
  return Tuple2(0, response.statusCode.toString());
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