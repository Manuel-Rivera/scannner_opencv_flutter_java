import 'package:flutter/material.dart';


class formularioContenedor extends StatelessWidget {
  final Widget child;

  const formularioContenedor({
    Key? key, 
    required this.child
    }) : super(key:key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width*0.1),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        //height: 300,
        decoration: _formShape(),
        child: this.child,
      ),
    );
  }

  BoxDecoration _formShape() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 15,
        offset: Offset(0,5),
      )
    ]
  );

}