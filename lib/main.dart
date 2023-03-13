import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Providers/document_provider.dart';
import 'Routes/routes.dart';
import 'Screens/login_screen/login.dart';

//Migración a provider
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppState());
}

class AppState extends StatelessWidget {
  const AppState({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ImagesProvider>(
            create: ((_) => ImagesProvider())),
        ChangeNotifierProvider<GlobalKeyStore>(
          create: ((_) => GlobalKeyStore()),
        )
      ],
      child: const Scanner(),
    );
  }
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
      home: const Login(),
      initialRoute: 'home',
      routes: Routes.getAppRoutes(),
      onGenerateRoute: (settings) => Routes.onGenerateRoute(settings),
    );
  }
}
