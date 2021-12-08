import 'package:flutter/material.dart';

Widget gasoFastIcon(Size size){
  return Container(
    height: size.height * 0.15,
    child: Stack(
      alignment: AlignmentDirectional.center,
      children: <Widget>[
        Image(
          image: AssetImage('assets/images/location.png'),
          color: Colors.white,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
          child: Image(
            image: AssetImage('assets/images/petrol.png'),
            height: size.height * 0.070,
          ),
        )
      ],
    )
  );
}

//Widget para el fondo de la pantalla
Widget crearFondo(BuildContext context){

  final size = MediaQuery.of(context).size;

  final fondoAzulOscuro = Container(
    height: size.height * 0.50,
    width: double.infinity,
    decoration: BoxDecoration(
      color: Color.fromRGBO(17, 45, 78, 1.0)
    ),
  );

  final fondo = Container(
    child: Stack(
      children: <Widget>[
        fondoAzulOscuro
      ],
    ),
    decoration: BoxDecoration(
      color: Color.fromRGBO(63, 114, 175, 1.0)
    ),
  );

  final header = Container(
      padding: EdgeInsets.only(top: size.height * 0.05),
      child: Column(
        children: <Widget>[
          gasoFastIcon(size),
          SizedBox(height: 10.0, width: double.infinity),
        ],
      ),
    );

    return Stack(
      children: <Widget>[
        fondo,
        header,
      ],
    );
}