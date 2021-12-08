import 'package:flutter/material.dart';

import 'package:gasofast/src/utils/colors_utils.dart';

class AboutPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorAzulOscuro(),),
          onPressed: () => Navigator.of(context).pop()
        ),
        title: Text('Acerca De', style: TextStyle(color: colorAzulOscuro()),),
        centerTitle: true,
      ),
      body: Container(
        child: _content(),
      ),
    );
  }
}

Widget _content(){
  return Container(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Text('Esta Aplicación Fue Desarrollada Por', textAlign: TextAlign.center,style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold ),),
        ),
        _developers()
      ],
    ),
  );
}

Widget _developers(){
  return Column(
    children: <Widget>[
      _developer('Alvarado Henríquez, Sofía Michelle', '25-3152-2017'),
      SizedBox(height: 20.0,),
      _developer('Hernández Campos, Samuel Enrique', '25-3836-2017'),
      SizedBox(height: 20.0,),
      _developer('Palma Portillo, Bladimir Stanley', '25-0369-2017'),
      SizedBox(height: 20.0,),
      _developer('Rodríguez Cruz, Hugo Alexander', '25-0663-2017'),
      SizedBox(height: 20.0,),
      _developer('Rodríguez Sigüenza, Ámilton Abraham', '25-0259-2017'),
    ],
  );
}

Widget _developer(String developerName, String developerId){
  return Card(
    margin: EdgeInsets.symmetric(horizontal: 40.0),
    color: colorAzulOscuro(),
    elevation: 5.0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    child: Container(
      width: 300.0,
      height: 60.0,
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(developerName, style: TextStyle(color: Colors.white, fontSize: 14.0 ) ),
          SizedBox(height: 10.0,),
          Text(developerId, style: TextStyle(color: Colors.white, fontSize: 14.0 ),),
        ],
      ),
    ),
  );
}