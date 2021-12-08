import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:gasofast/src/models/gasolinera_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher; 

import 'package:gasofast/src/providers/gasolinera_provider.dart';
import 'package:gasofast/src/utils/colors_utils.dart';
import 'package:gasofast/src/utils/styles_utils.dart';

// ignore: must_be_immutable
class FuelStation extends StatefulWidget {

  String gasStationId;
  Function callback;
  int widgetCaller;

  FuelStation({required this.gasStationId, required this.callback, required this.widgetCaller });

  @override
  State<FuelStation> createState() => _FuelStationState();
}

class _FuelStationState extends State<FuelStation> {
  final firebase_auth.FirebaseAuth auth = firebase_auth.FirebaseAuth.instance;

  final firebase_auth.User? user = firebase_auth.FirebaseAuth.instance.currentUser;

  final gasolineraProvider = GasolineraProvider();

  List<GasolineraModel> datosGasolinera = [];

  late Position _currentPosition;

  @override
  void initState() {
    super.initState();
    isFavorita();
    _getCurrentLocation();
  }

  
  Icon favoriteUnchecked = Icon(Icons.star_outline, color: colorAzulOscuro(), size: 20.0,);
  Icon favoriteChecked = Icon(Icons.star, color: colorAzulOscuro(), size: 20.0,);
  bool _favoriteIsChecked = false;

  @override
  Widget build(BuildContext context) {
    return _gasCardView(context);
  }

  void isFavorita() async{
    //Evaluamos si la gasolinera está marcada como favorita para este usuario
    _favoriteIsChecked = await gasolineraProvider.isFavorita(user!.uid, widget.gasStationId);
  }

  //Método para obtener ubicación actual del usuario
  void _getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
      .then((Position position) async {
        _currentPosition = position;
      });
  }

  //Método para abrir Google Maps con la dirección de la gasolinera
  void _launchMapsUrl(LatLng currentLocation, LatLng destinationLocation ) async {
    final url = 'https://www.google.com/maps/dir/${destinationLocation.latitude},+${destinationLocation.longitude}/${currentLocation.latitude},${currentLocation.longitude}/@${currentLocation.latitude},${currentLocation.longitude}';
    if (await url_launcher.canLaunch(url)) {
      await url_launcher.launch(url);
    } else {
      print('No se pudo ir a la ruta');
    }
  }

  Widget _gasCardView(BuildContext context){
    return FutureBuilder(
      future: gasolineraProvider.getGasolinera(widget.gasStationId),
      builder: (BuildContext context, AsyncSnapshot snapshot){

        if(snapshot.hasData) {

          //Obtenemos los datos de la gasolinera que se va a guardar o eliminar de favoritos
          if(datosGasolinera.length < 1){
            datosGasolinera.add(snapshot.data[0]);
          }

          return Card(
            margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0 ),
            elevation: 10.0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0) ),
            child: Column(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0) ),
                  child: FadeInImage(
                    image: NetworkImage(snapshot.data[0].coverImg),
                    placeholder: AssetImage('assets/images/jar-loading.gif'),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 80.0,
                    ),
                  ),
                _contentRow(context, snapshot.data[0].name, snapshot.data[0].schedule),
              ],
            ),
          );
        } else {
          return Card(
            margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0 ),
            elevation: 10.0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0) ),
            child: Column(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0) ),
                  child: Image(
                    image: AssetImage('assets/images/jar-loading.gif'),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 80.0,
                    ),
                  ),
                _contentRow(context, 'Cargando...', 'Cargando...'),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _contentRow(BuildContext context, String gasStationName, String gasStationSchedule){

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(gasStationName, style: TextStyle(color: colorAzulOscuro(), fontSize: 12.0, fontWeight: FontWeight.bold ),),
              IconButton(
                icon: _favoriteIsChecked ? favoriteChecked : favoriteUnchecked,
                onPressed: () async {

                  String uid = user!.uid;
                  bool r = false;

                  if(widget.widgetCaller == 0){
                    if (_favoriteIsChecked){

                      //Quitar de favoritos
                      r = await gasolineraProvider.elmGasolineraFavorita(uid, datosGasolinera[0]);

                    } else {

                      //Agregar a favoritos
                      r = await gasolineraProvider.aggGasolineraFavorita(uid, datosGasolinera[0]);
                    }
                    
                    setState((){
                      if (_favoriteIsChecked && r){

                        //Quitar de favoritos
                        _favoriteIsChecked = false;

                      } else if (!_favoriteIsChecked && r){

                        //Agregar a favoritos
                        _favoriteIsChecked = true;
                      }
                    });
                  } else if(widget.widgetCaller == 1){

                    if (_favoriteIsChecked){

                      print('Valor 2 de _favoriteIsChecked: $_favoriteIsChecked ');

                      GasolineraModel gasolineraModel = GasolineraModel(widget.gasStationId, '', '', '', 0.0, 0.0, 0.0, '', '');

                      //Quitar de favoritos
                      r = await gasolineraProvider.elmGasolineraFavorita(uid, gasolineraModel);
                    }

                    try {
                      widget.callback();
                    } catch (e) {
                      print('Error: ${e.toString()}');
                    }
                  }

                },
              )
            ],
          ),
          //Reemplazar por infomación dinámica
          Text(gasStationSchedule, style: TextStyle(color: colorVerdeClaro(), fontSize: 12.0, fontWeight: FontWeight.bold ),),
          SizedBox(height: 15.0) ,
          _buttonsRow(context)
        ],
      ),
    );
  }

  Widget _buttonsRow(BuildContext context){

    return Padding(
      padding: EdgeInsets.only(bottom: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buttonSize(
            ElevatedButton(
              child: Text('Indicaciones', style: TextStyle(color: Colors.white, fontSize: 10.0 ),),
              onPressed: () async {
                
                _getCurrentLocation();//Obtenemos la ubicación actual

                //Invocamos la búsqueda en Google Maps
                _launchMapsUrl(LatLng(_currentPosition.latitude, _currentPosition.longitude), 
                LatLng(double.parse(datosGasolinera[0].locationLatitude),double.parse(datosGasolinera[0].locationLongitude)) );

              },
              style: cardButtonStyleDark(),
            ),
          ),
          _buttonSize(
            ElevatedButton(
              child: Text('Precios', style: TextStyle(color: colorAzulOscuro(), fontSize: 10.0 ),),
              onPressed: (){
                //Redirigir a página "Precios"
                Navigator.pushNamed(context, 'prices', arguments: datosGasolinera[0]);
              },
              style: cardButtonStyleLight(),
            ),
          ),
          _buttonSize(
            ElevatedButton(
              child: Text('Ver ofertas', style: TextStyle(color: colorAzulOscuro(), fontSize: 10.0 ),),
              onPressed: (){
                //Redirigir a página "Ofertas"
                Navigator.pushNamed(context, 'offers', arguments: datosGasolinera[0]);
              },
              style: cardButtonStyleLight(),
            ),
          )
        ],
      ),
    );
  }

  Widget _buttonSize(ElevatedButton elevatedButtonP){
    return Container(
      width: 90.0,
      height: 25.0,
      child: elevatedButtonP,
    );
  }
}