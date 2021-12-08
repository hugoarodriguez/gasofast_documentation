import 'package:cloud_firestore/cloud_firestore.dart' as cloud_firestore;
import 'package:gasofast/src/models/gasolinera_model.dart';

class GasolineraProvider{

  final cloud_firestore.FirebaseFirestore _firestore = cloud_firestore.FirebaseFirestore.instance;

  //Agregar Gasolinera Favorita
  Future<bool> aggGasolineraFavorita(String uid, GasolineraModel gasolineraModel) async {
    
    cloud_firestore.CollectionReference reference  = _firestore.collection('favorite_gas_stations');

    try{
      
      //Registrar
      await reference.doc(gasolineraModel.id + uid).set({
        'id_user'             : uid,
        'id_gas_station'      : gasolineraModel.id,
        'location_latitude'   : gasolineraModel.locationLatitude,
        'location_longitude'  : gasolineraModel.locationLongitude,
        'name'                : gasolineraModel.name,
        'price_diesel'        : gasolineraModel.priceDiesel,
        'price_especial'      : gasolineraModel.priceEspecial,
        'price_regular'       : gasolineraModel.priceRegular,
        'cover_img'           : gasolineraModel.coverImg,
        'schedule'           : gasolineraModel.schedule,
      });
      //Si la subida salió bien se retorna 'true'
      return true;
      
    } on cloud_firestore.FirebaseException catch(e){
      //Si hubo error en la subida se retorna 'false'
      print(e);
      return false;
    }
  }

  //Eliminar Gasolinera Favorita
  Future<bool> elmGasolineraFavorita(String uid, GasolineraModel gasolineraModel) async {
    
    cloud_firestore.CollectionReference reference  = _firestore.collection('favorite_gas_stations');

    try{
      
      //Eliminar
      await reference.doc(gasolineraModel.id + uid).delete();

      //Si la subida salió bien se retorna 'true'
      return true;
      
    } on cloud_firestore.FirebaseException catch(e){
      //Si hubo error en la subida se retorna 'false'
      print(e);
      return false;
    }
  }

  //Evaluamos si la gasolinera es favorita
  Future<bool> isFavorita(String uid, String idGasolinera) async {

    String idGasolineraFinal = idGasolinera;

    if(idGasolinera.contains('(')){
      int indexParentesis1 = idGasolinera.indexOf('(');
      int indexParentesis2 = idGasolinera.indexOf(')');
      idGasolineraFinal = idGasolinera.substring(indexParentesis1 + 1, indexParentesis2);
    }

    cloud_firestore.CollectionReference reference  = _firestore.collection('favorite_gas_stations');
    bool r = false;

    try{
      
      //Consultar
      final cloud_firestore.DocumentSnapshot documentSnapshot = await reference.doc(idGasolineraFinal + uid).get();

      r = documentSnapshot.exists;//Retorna 'true' si existe, 'false' si no
      
      return r;
      
    } on cloud_firestore.FirebaseException catch(e){
      //Si hubo error en la consulta retorna 'false', indica que no existe
      print(e);
      return false;
    }
  }

  Future<List<GasolineraModel>> getGasolineras() async {
    List<GasolineraModel> gasolinerasList = [];

    cloud_firestore.CollectionReference reference  = _firestore.collection('gas_stations');

    final cloud_firestore.QuerySnapshot result = await reference.get();
    final List<cloud_firestore.DocumentSnapshot> documents = result.docs;
    
    for (var doc in documents) { 
      gasolinerasList.add(GasolineraModel(doc.reference.id, doc['location_latitude'], doc['location_longitude'], 
      doc['name'], doc['price_diesel'], doc['price_especial'], doc['price_regular'], doc['cover_img'], doc['schedule']));
    }

    return gasolinerasList;
  }

  //Obtiene las gasolineras marcadas como favoritas por un usuario
  Future<List<GasolineraModel>> getGasolinerasFavoritas(String uid) async {
    List<GasolineraModel> gasolinerasList = [];

    try {
      cloud_firestore.CollectionReference reference  = _firestore.collection('favorite_gas_stations');

      final cloud_firestore.QuerySnapshot result = await reference.where('id_user', isEqualTo: uid).get();
      final List<cloud_firestore.DocumentSnapshot> documents = result.docs;
      
      for (var doc in documents) { 
        gasolinerasList.add(GasolineraModel(doc['id_gas_station'], doc['location_latitude'], doc['location_longitude'], 
        doc['name'], doc['price_diesel'], doc['price_especial'], doc['price_regular'], doc['cover_img'], doc['schedule']));
      }
    } catch (e) {
      print(e.toString());
    }

    return gasolinerasList;
  }

  //Obtiene las gasolineras marcadas como favoritas por un usuario
  Future<List<GasolineraModel>> searchGasolineras(String name) async {
    List<GasolineraModel> gasolinerasList = [];

    try {
      cloud_firestore.CollectionReference reference  = _firestore.collection('gas_stations');

      final cloud_firestore.QuerySnapshot result = await reference.get();
      final List<cloud_firestore.DocumentSnapshot> documents = result.docs;
      
      for (var doc in documents) { 
        gasolinerasList.add(GasolineraModel(doc.reference.id, doc['location_latitude'], doc['location_longitude'], 
        doc['name'], doc['price_diesel'], doc['price_especial'], doc['price_regular'], doc['cover_img'], doc['schedule']));
      }

      //Filtramos los resultados
      gasolinerasList = name.isEmpty
      ? []
      : gasolinerasList.where((p) => p.name.toLowerCase().contains(name.toLowerCase())).toList();


    } catch (e) {
      print(e.toString());
    }

    return gasolinerasList;
  }

  //Método para obtener los datos de las OFERTAS de las gasolineras
  Future<List<GasolineraModel>> getOfertasGasolineras(String idGasolinera) async {

    String idGasolineraFinal = idGasolinera;

    if(idGasolinera.contains('(')){
      int indexParentesis1 = idGasolinera.indexOf('(');
      int indexParentesis2 = idGasolinera.indexOf(')');
      idGasolineraFinal = idGasolinera.substring(indexParentesis1 + 1, indexParentesis2);
    }

    List<GasolineraModel> gasolinerasList = [];

    cloud_firestore.CollectionReference reference  = _firestore.collection('gas_stations_offers');

    final cloud_firestore.QuerySnapshot result = await reference.where('id_gas_station', isEqualTo: idGasolineraFinal).get();
    final List<cloud_firestore.DocumentSnapshot> documents = result.docs;
    
    for (var doc in documents) {
      gasolinerasList.add(GasolineraModel.offers(doc['id_gas_station'], doc['cover_img']));
    }

    return gasolinerasList;
  }

  Future<List<GasolineraModel>> getGasolinera(String idGasolinera) async {

    String idGasolineraFinal = idGasolinera;

    if(idGasolinera.contains('(')){
      int indexParentesis1 = idGasolinera.indexOf('(');
      int indexParentesis2 = idGasolinera.indexOf(')');
      idGasolineraFinal = idGasolinera.substring(indexParentesis1 + 1, indexParentesis2);
    }

    List<GasolineraModel> gasolinerasList = [];

    try {
      cloud_firestore.CollectionReference reference  = _firestore.collection('gas_stations');

      final cloud_firestore.DocumentSnapshot doc = await reference.doc(idGasolineraFinal).get();
      
      gasolinerasList.add(GasolineraModel(doc.reference.id, doc['location_latitude'], doc['location_longitude'], 
        doc['name'], doc['price_diesel'], doc['price_especial'], doc['price_regular'], doc['cover_img'], doc['schedule']));

    } catch (e) {
      print(e.toString());
    }
    
    return gasolinerasList;
  }
}