import 'package:flutter/material.dart';

import 'package:gasofast/src/models/gasolinera_model.dart';
import 'package:gasofast/src/providers/gasolinera_provider.dart';
import 'package:gasofast/src/utils/colors_utils.dart';

class OffersPage extends StatelessWidget {

  final gasolineraProvider = GasolineraProvider();

  @override
  Widget build(BuildContext context) {

    final gasolineraModel = ModalRoute.of(context)!.settings.arguments as GasolineraModel;

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorAzulOscuro(),),
          onPressed: () => Navigator.of(context).pop()
        ),
        title: Text('Ofertas', style: TextStyle(color: colorAzulOscuro()),),
        centerTitle: true,
      ),
      body: SingleChildScrollView(child: _content(gasolineraModel))
    );
  }

  Widget _content(GasolineraModel gasolineraModel){
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: Center(child: Text(gasolineraModel.name, textAlign: TextAlign.center,style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold ),)),
          ),
          _offers(gasolineraModel.id)
        ],
      ),
    );
  }

  Widget _offers(String id){
    return FutureBuilder(
      future: gasolineraProvider.getOfertasGasolineras(id),
      builder: (BuildContext context, AsyncSnapshot snapshot){

        if(!snapshot.hasData){
          return Column();
        }

        if(snapshot.hasData){

          List items = snapshot.data;

          List<Widget> ofertas = [];

          for (var item in items) {
            ofertas.add(_offer(item.coverImg));
            ofertas.add(SizedBox(height: 20.0,));
          }          

          return Column(
            children: ofertas
          );

        } else if(snapshot.hasError){

          return Column();

        } else {

          return Column();

        }

      }
    );
  }

  Widget _offer(String imageUrl){
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 40.0),
      color: colorCeleste(),
      elevation: 5.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Container(
        width: 300.0,
        height: 300.0,
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
        child: IconButton(
          icon: FadeInImage(
            placeholder: AssetImage('assets/images/loading.gif'),
            image: NetworkImage(imageUrl),
            fadeInDuration: Duration(milliseconds: 1000)
          ),
          onPressed: (){
            //Añadir función para expandir imagen en toda la pantalla
            print('Oferta Seleccionada');
          },
        )
      ),
    );
  }
}