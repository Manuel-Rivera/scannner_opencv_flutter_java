import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Providers/document_provider.dart';
import 'Routes/routes.dart';
import 'Screens/login_screen/login.dart';

void main() {
  runApp(MaterialApp(
    title: 'Navigation Basics',
    home: Login(),
  ));
}



class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: DocumentProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            appBarTheme: AppBarTheme(color: ThemeData.dark().canvasColor),
            floatingActionButtonTheme: FloatingActionButtonThemeData(
                backgroundColor: ThemeData.dark().canvasColor),
            textSelectionTheme:
                const TextSelectionThemeData(selectionColor: Colors.blueGrey)),
        home: Login(),
        initialRoute: 'home',
        routes: Routes.getAppRoutes(),
        onGenerateRoute: (settings) => Routes.onGenerateRoute(settings),
      ),
    );
  }
}
