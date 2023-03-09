import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Providers/document_provider.dart';
import 'Providers/login_provider.dart';
import 'Routes/routes.dart';
import 'Screens/login_screen/login.dart';

//Migración a provider
void main() {
  runApp(
    MultiProvider(
      providers: [
        /*
        ChangeNotifierProvider<ImagesProvider>(
          create: ((_) => ImagesProvider()),
          lazy: false,
        ),*/
        ChangeNotifierProvider<loginProvider>(
          create: ((_) => loginProvider()),
        ),
        ChangeNotifierProvider<DocumentProvider>(
          create: ((_) => DocumentProvider()),
          lazy: false,
        )
      ],
      child: const Scanner(),
    ),
  );
}

class Scanner extends StatelessWidget {
  const Scanner({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          appBarTheme: AppBarTheme(color: ThemeData.dark().canvasColor),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: ThemeData.dark().canvasColor),
          textSelectionTheme:
              const TextSelectionThemeData(selectionColor: Colors.blueGrey)),
      home: Login(),
      initialRoute: 'login',
      routes: Routes.getAppRoutes(),
      onGenerateRoute: (settings) => Routes.onGenerateRoute(settings),
    );
  }
}