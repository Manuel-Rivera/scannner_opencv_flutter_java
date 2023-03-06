import 'package:flutter/material.dart';

import '../Model/option_routes_model.dart';
import '../Screens/alert_screen/alert_screen.dart';
import '../Screens/home_screen/home_.dart';
import '../Screens/login_screen/login.dart';

class Routes {
  static const initialRoute = "home";
  static final optionRoutes = [
    OptionsRoutes(
        route: 'login',
        icon: Icons.login_outlined,
        name: "Login",
        screen: const Login()),
    OptionsRoutes(
        route: 'home',
        icon: Icons.home_filled,
        name: "Home",
        screen: const Home())
  ];

  static Map<String, Widget Function(BuildContext)> getAppRoutes() {
    Map<String, Widget Function(BuildContext)> appRoutes = {};
    for (var element in optionRoutes) {
      appRoutes.addAll({element.route: (context) => element.screen});
    }
    return appRoutes;
  }

  static Route<dynamic> onGenerateRoute(settings) =>
      MaterialPageRoute(builder: (context) => const AlertScreen());
}
