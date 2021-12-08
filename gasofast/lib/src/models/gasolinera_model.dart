// ignore_for_file: non_constant_identifier_names, prefer_initializing_formals

class GasolineraModel{
  String id = '';
  String locationLatitude = '';
  String locationLongitude = ''; 
  String name = ''; 
  double priceDiesel = 0.0;
  double priceEspecial = 0.0;
  double priceRegular = 0.0;
  String coverImg = '';
  String schedule = '';

  GasolineraModel(String id, String locationLatitude, String locationLongitude, String name, double priceDiesel, 
  double priceEspecial, double priceRegular, String coverImg, String schedule){
    this.id = id;
    this.locationLatitude = locationLatitude;
    this.locationLongitude = locationLongitude;
    this.name = name;
    this.priceDiesel = priceDiesel;
    this.priceEspecial = priceEspecial;
    this.priceRegular = priceRegular;
    this.coverImg = coverImg;
    this.schedule = schedule;
  }

  GasolineraModel.offers(String id, String coverImg){
    this.id = '';
    this.locationLatitude = '';
    this.locationLongitude = '';
    this.name = '';
    this.priceDiesel = 0.0;
    this.priceEspecial = 0.0;
    this.priceRegular = 0.0;
    this.coverImg = coverImg;
    this.schedule = '';
  }
}