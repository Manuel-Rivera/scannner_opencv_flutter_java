import 'package:flutter/material.dart';

class FormularioContenedor extends StatelessWidget {
  final Widget child;

  const FormularioContenedor({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        //height: 300,
        decoration: _formShape(),
        child: child,
      ),
    );
  }

  BoxDecoration _formShape() => BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 15,
              offset: Offset(0, 5),
            )
          ]);
}
