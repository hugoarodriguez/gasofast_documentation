import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:gasofast/src/bloc/map_bloc.dart';
import 'package:gasofast/src/bloc/provider.dart';
import 'package:gasofast/src/widgets/search_delegate.dart';
import 'package:gasofast/src/providers/gasolinera_provider.dart';
import 'package:gasofast/src/providers/usuario_provider.dart';
import 'package:gasofast/src/utils/colors_utils.dart';

//Creamos un enum con las opciones del Menú
  enum MenuOptions { favorites, changepwd, about, exit }

class LocationsPage extends StatefulWidget {
  @override
  State<LocationsPage> createState() => _LocationsPageState();
}

class _LocationsPageState extends State<LocationsPage> {

  //Manejar el foco del Input de Búsqueda
  FocusNode keyboarFocusNode = new FocusNode();
  
  final usuarioProvider = UsuarioProvider();
  final gasolineraProvider = GasolineraProvider();
  List<Widget> _listadoWidgets = [];
  // ignore: unused_field
  late Position _currentPosition;

  Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController mapController;

  MapType mapType = MapType.normal;

  //Marcadores
  Set<Marker> markers = Set<Marker>();

  CameraPosition puntoInicial = CameraPosition(
    target: LatLng(13.753179687211007, -88.89428556435283),
    zoom: 15,
    tilt: 50.0,
  );

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    final mapBloc = Provider.ofMap(context);

    return Scaffold(
      body: Container(
        child: _fullContent(context, mapBloc)
      ),
    );
  }

  //Función callback vacía para FavoritosPage
  void callback(){}

  //Función para eliminar último Widget agregado
  void _removeFuelStationWidget(){
    setState(() {
      if(_listadoWidgets.length > 4){
        _listadoWidgets.removeLast();
      }
    });
  }

  //Método para quitar foco del input
  _removeFocus(){

    keyboarFocusNode.unfocus();
  }

  //Método para obtener la ubicacion actual del usuario
  _getCurrentLocation() async {

    //Solicitamos permisos al usuario
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {

      //Incocamos la el método para solicitar permisos
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        //Si los permisos se denegaron únicamente esta vez
        print('Los permisos de ubicación fueron denegados');
      }
      else if (permission == LocationPermission.deniedForever) {
        //Si los permisos fueron denegados permanentemente
        print('Los permisos de ubicación fueron denegados permanentemente, no se puden solicitar permisos.');
      } else {
        //Si ninguna de las opciones anteriores se ejecutó, indica que obtuvimos los permisos necesario
        await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
            .then((Position position) async {

          setState(() {
            // Store the position in the variable
            _currentPosition = position;

            // For moving the camera to current location
            mapController.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: LatLng(position.latitude, position.longitude),
                  zoom: 15,
                  tilt: 50.0,
                ),
              ),
            );
            
          });

        }).catchError((e) {
          print(e);
        });
      }
    } else {
      //Si ninguna de las opciones anteriores se ejecutó, indica que obtuvimos los permisos necesario
      await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
          .then((Position position) async {

        setState(() {
          // Store the position in the variable
          _currentPosition = position;

          // For moving the camera to current location
          mapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(position.latitude, position.longitude),
                zoom: 15,
                tilt: 50.0,
              ),
            ),
          );
        });

      }).catchError((e) {
        print(e);
      });
    }
  }

  Widget _fullContent(BuildContext context, MapBloc bloc){
    return FutureBuilder(
      future: gasolineraProvider.getGasolineras(),
      builder: (BuildContext context, AsyncSnapshot snapshot){

        if(snapshot.hasData){

          bloc.createMarkers(snapshot.data, _listadoWidgets, keyboarFocusNode, callback);

          return StreamBuilder(
            stream: bloc.markersStream,
            builder: (BuildContext context, AsyncSnapshot snapshotMarkers){

              if(snapshotMarkers.hasData){

                markers = snapshotMarkers.data;

                _listadoWidgets = [
                  GoogleMap(
                    markers: Set<Marker>.of(
                      snapshotMarkers.data.length > 0 
                      ? snapshotMarkers.data
                      : []),
                    compassEnabled: false,
                    mapToolbarEnabled: false,
                    zoomControlsEnabled: false,
                    myLocationEnabled: true,
                    mapType: mapType,
                    initialCameraPosition: puntoInicial,
                    onMapCreated: (GoogleMapController controller) async {
                      _controller.complete(controller);
                      mapController = controller;

                      await _getCurrentLocation();
                      
                    },
                    onTap: (value) => _removeFocus(),
                  ),
                  _favoritesFAB(context),
                  _locateFAB(context, bloc),
                  _frontContent(context),
                  
                ];
                
                bloc.createWidgetList(_listadoWidgets);

                return SafeArea(
                  child: StreamBuilder<Object>(
                    stream: bloc.listaWidgetStream,
                    builder: (BuildContext context, AsyncSnapshot snapshotWidgets) {

                      if(snapshotWidgets.hasData){
                        return Stack(
                          children: snapshotWidgets.data,
                        );
                      } else {
                        return Stack(
                          children: _listadoWidgets,
                        );
                      }
                    }
                  ),
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      }
    );
  }

  Widget _frontContent(BuildContext context){
    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: <Widget>[
            _searchBar(context),
          ],
        ),
      ),
    );
  }

  Widget _searchBar(BuildContext context){

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0 ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.white,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black,
            blurRadius: 5.0,
            offset: Offset(0.0, 2.0),
            spreadRadius: 1.0
          )
        ]
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0 ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                readOnly: true,
                focusNode: keyboarFocusNode,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Buscar gasolinera',
                ),
                onTap: (){

                  setState(() {

                    for (var item in markers) {
                      mapController.hideMarkerInfoWindow(item.markerId);
                    }

                    if(_listadoWidgets.length > 4){
                      _listadoWidgets.removeLast();
                    }
                    
                    showSearch(context: context, delegate: DataSearch(googleMapController: mapController));
                  });
                },
              ),
            ),
            _popUpMenu(context)
          ],
        ),
      ),
    );
  }

  Widget _popUpMenu(BuildContext context){


    return PopupMenuButton<MenuOptions>(
      offset: Offset(0.0, 55.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0),),
      icon: CircleAvatar(
        child: Icon(Icons.person_outlined),
        backgroundColor: colorAzulOscuro(),
      ),
      onSelected: (MenuOptions result) { 

        if(result.index == 0){
          Navigator.pushNamed(context, 'favorites');
        } else if(result.index == 1){
          Navigator.pushNamed(context, 'changepwd');
        } else if(result.index == 2){
          Navigator.pushNamed(context, 'about');
        } else if(result.index == 3){

          usuarioProvider.signOut();
          Navigator.pushReplacementNamed(context, 'login');
          
        }

      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<MenuOptions>>[
        PopupMenuItem<MenuOptions>(
          value: MenuOptions.favorites,
          child: Row(
            children: [
              Icon(Icons.star, size: 16.0,),
              SizedBox(width: 5.0,),
              Text('Favoritos', style: TextStyle(fontSize: 12.0)),
            ],
          ),
          height: 20.0,
        ),
        PopupMenuItem<MenuOptions>(
          value: MenuOptions.changepwd,
          child: Row(
            children: [
              Icon(Icons.lock_outline_rounded, size: 16.0,),
              SizedBox(width: 5.0,),
              Text('Contraseña', style: TextStyle(fontSize: 12.0)),
            ],
          ),
          height: 20.0,
        ),
        PopupMenuItem<MenuOptions>(
          value: MenuOptions.about,
          child: Row(
            children: [
              Icon(Icons.info, size: 16.0,),
              SizedBox(width: 5.0,),
              Text('Acerca de', style: TextStyle(fontSize: 12.0)),
            ],
          ),
          height: 20.0,
        ),
        PopupMenuItem<MenuOptions>(
          value: MenuOptions.exit,
          child: Row(
            children: [
              Icon(Icons.exit_to_app, size: 16.0,),
              SizedBox(width: 5.0,),
              Text('Salir', style: TextStyle(fontSize: 12.0)),
            ],
          ),
          height: 20.0,
        ),
      ],
    );
  }

  Widget _favoritesFAB(BuildContext context){
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.only(top: size.height * 0.87,left: size.width * 0.80),
      child: FloatingActionButton(
        heroTag: 'favoritesFAB',
        backgroundColor: colorAzulOscuro(),
        child: Icon(Icons.star, size: 32.0,),
        onPressed: ()  {

          _removeFuelStationWidget();

          _removeFocus();
          Navigator.pushNamed(context, 'favorites'); 
          
        },
      ),
    );
  }

  Widget _locateFAB(BuildContext context, MapBloc bloc){
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.only(top: size.height * 0.78,left: size.width * 0.80),
      child: FloatingActionButton(
        heroTag: 'locateFAB',
        backgroundColor: colorAzulOscuro(),
        child: Icon(Icons.my_location, size: 32.0,),
        onPressed: () async {

          _removeFocus();

          //Obtenemos la ubicación actual
          await _getCurrentLocation();

        },
      ),
    );
  }
}

