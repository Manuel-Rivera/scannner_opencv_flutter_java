import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget{
  final Widget formulario;
  const AuthBackground({
    Key? key,
    required this.formulario
  }):super(key:key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
      return Container(
        color: Colors.grey[200],
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            _cajaSuperior(),
            _iconoEncabezadoLogin(),
            this.formulario,
          ],
        ),
      ); 
  }
}

class _iconoEncabezadoLogin extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Container(
        width: double.infinity,
        child: Image.asset(
              'lib/Model/images/UMSNH_icon.png',
              width: size.width*0.5,
              height: size.width*0.5,
              
            )
        //lib/Model/images/UMSNH_icon.png
      ),
    );
  }
}


class _cajaSuperior extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      height: size.height * 0.4,
      decoration: _loginBackground(),
      child: Stack(
        children: [
          Positioned(child: _Burbujas(), top: 90, left: 30),
          Positioned(child: _Burbujas(), top: -40, left: -30),
          Positioned(child: _Burbujas(), top: -50, right: -20),
          Positioned(child: _Burbujas(), bottom: -50, left: 10),
          Positioned(child: _Burbujas(), bottom: 120, right: 20),
        ],
      ),
    );
  }

  BoxDecoration _loginBackground() => BoxDecoration(
    gradient: LinearGradient(
      colors:[
        Color.fromRGBO(63,63,156, 1),
        Color.fromRGBO(90,90,178, 1),
      ] 
    ),
  );
}



class _Burbujas extends StatelessWidget{
  @override
  Widget build (BuildContext context){
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: Color.fromRGBO(255, 255, 255, 0.05),
      ),
    );
  }

}