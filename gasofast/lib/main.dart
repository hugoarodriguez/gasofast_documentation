import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;

import 'package:gasofast/src/pages/about_page.dart';
import 'package:gasofast/src/pages/change_password_page.dart';
import 'package:gasofast/src/pages/favorites_page.dart';
import 'package:gasofast/src/pages/locations_page.dart';
import 'package:gasofast/src/pages/login_page.dart';
import 'package:gasofast/src/pages/offers_page.dart';
import 'package:gasofast/src/pages/prices_page.dart';
import 'package:gasofast/src/pages/recover_account_page.dart';
import 'package:gasofast/src/pages/signup_page.dart';

var initialRoute = '';
void main() async { 
  WidgetsFlutterBinding.ensureInitialized();
  await firebase_core.Firebase.initializeApp();

  //Evaluación de sesión iniciada
  if (firebase_auth.FirebaseAuth.instance.currentUser != null) {
    initialRoute = 'locations';
  }
  else {
    initialRoute = 'login';
  }
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gasofast',
      initialRoute: initialRoute,
      routes: {
        'login'       : (BuildContext context) => LoginPage(),
        'signup'      : (BuildContext context) => SignUpPage(),
        'recoveracc'  : (BuildContext context) => RecoverAccountPage(),
        'changepwd'   : (BuildContext context) => ChangePasswordPage(),
        'favorites'   : (BuildContext context) => FavoritesPage(),
        'prices'      : (BuildContext context) => PricesPage(),
        'about'       : (BuildContext context) => AboutPage(),
        'offers'      : (BuildContext context) => OffersPage(),
        'locations'   : (BuildContext context) => LocationsPage(),
      },
    );
  }
}