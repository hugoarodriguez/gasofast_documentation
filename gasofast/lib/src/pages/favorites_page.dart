import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:gasofast/src/models/gasolinera_model.dart';

import 'package:gasofast/src/providers/gasolinera_provider.dart';
import 'package:gasofast/src/utils/colors_utils.dart';
import 'package:gasofast/src/widgets/fuel_station_widget.dart';

class FavoritesPage extends StatefulWidget {

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  GasolineraProvider gasolineraProvider = GasolineraProvider();
  ListView _listView = ListView();

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
        title: Text('Favoritos', style: TextStyle(color: colorAzulOscuro()),),
        centerTitle: true,
      ),
      body: Container(
        child: _favoritesGasStations(),
      )
    );
  }

  void callback() {
    setState(() {
    });
  }

  Widget _favoritesGasStations(){
    
    final firebase_auth.User? user = firebase_auth.FirebaseAuth.instance.currentUser;

    return FutureBuilder(
      future: gasolineraProvider.getGasolinerasFavoritas(user!.uid),
      builder: (BuildContext context, AsyncSnapshot snapshot){
        if(snapshot.hasData){

          List<GasolineraModel> data = snapshot.data;

          _listView = ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, i) => FuelStation(gasStationId: data[i].id, callback: callback, widgetCaller: 1,),
          );

          return _listView;

        } else {

          return Container();
          
        }
      },
    );
  }
}