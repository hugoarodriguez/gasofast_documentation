// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:gasofast/src/models/gasolinera_model.dart';

import 'package:gasofast/src/providers/gasolinera_provider.dart';
import 'package:gasofast/src/utils/colors_utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DataSearch extends SearchDelegate{

  GoogleMapController googleMapController;

  DataSearch({required this.googleMapController});

  @override
  String get searchFieldLabel => 'Búscar...';

  String seleccion = '';
  final gasolinerasProvider = GasolineraProvider();


  @override
  List<Widget> buildActions(BuildContext context) {
      // Las acciones de nuestro AppBar
      
      return [
        IconButton(
          icon: const Icon(Icons.clear), 
          onPressed: (){
            query = '';
          },
        )
      ];
    }
  
    @override
    Widget buildLeading(BuildContext context) {
      // Icono a la izquierda del AppBar
      
      //Escondemos el teclado al invocar este método, de esta forma no muestra el error de 'RenderFlex overflowed'
      //Esta es una alternativa a usar si el Expanded del card_swiper_widget.dart no funciona
      //FocusScope.of(context).requestFocus(new FocusNode());

      return IconButton(
        icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow,
          progress: transitionAnimation,
        ), 
        onPressed: (){
          close(context, null);
        }
      );
    }
  
    @override
    Widget buildResults(BuildContext context) {
      // Crea los resultados que vamos a mostrar

      if(query.isEmpty) return Container(); 
      
      return buildSuggestions(context);
    }
  
    @override
    Widget buildSuggestions(BuildContext context) {
    // Son las sugerencias que aparecen cuando la persona escribe

    List<GasolineraModel>? gasolineras;
    
    if(query.isEmpty){
      if(gasolineras != null){
        gasolineras.clear();
      }
      
      return Container();
    }

    return FutureBuilder(
      future: gasolinerasProvider.searchGasolineras(query),
      builder: (BuildContext context, AsyncSnapshot<List<GasolineraModel>> snapshot) {

        if(snapshot.hasData){

          gasolineras = snapshot.data;

          return ListView(
            children: gasolineras!.map((gasolinera){

              return ListTile(
                leading: FadeInImage(
                  image: NetworkImage(gasolinera.coverImg),
                  placeholder: const AssetImage('assets/images/loading.gif'),
                  width: 50.0,
                  fit: BoxFit.cover,
                ),
                title: Text(gasolinera.name, style: TextStyle(color: Colors.black),),
                subtitle: Text(gasolinera.schedule, style: TextStyle(color: colorVerdeClaro()),),
                onTap: (){

                  close(context, null);//Cerramos el búscador
                  
                  this.googleMapController.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: LatLng(double.parse(gasolinera.locationLatitude), double.parse(gasolinera.locationLongitude)),
                        zoom: 15,
                        tilt: 50.0,
                      ),
                    ),
                  );

                },
              );
            }).toList()
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }

      },
    );
  }
}