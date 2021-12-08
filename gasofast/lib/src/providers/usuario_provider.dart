import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart' as google_sign_in;

class UsuarioProvider{

  firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  google_sign_in.GoogleSignIn _googleSignIn = google_sign_in.GoogleSignIn();
  FacebookAuth _facebookAuth = FacebookAuth.instance;
  
  get currentUser => _auth.currentUser;

  Future<Map<String, dynamic>> login(String? email, String? password) async {

    try {
      if(email != null && password != null){

        String providerID = 'Nada';

        await firebase_auth.FirebaseAuth.instance.fetchSignInMethodsForEmail(email).then((value){

          if(value.toList().length > 0){
            providerID = value.toList()[0];
          } else {
            providerID = 'password';
          }

        });

        if(providerID == 'google.com'){

          return { 'ok': false, 'mensaje': '¡Este email posee una cuenta registrada con Google!' };

        } else if(providerID == 'facebook.com'){

          return { 'ok': false, 'mensaje': '¡Este email posee una cuenta registrada con Facebook!' };
           
        } else {

          await firebase_auth.FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: password
          );
          
          firebase_auth.User? user = firebase_auth.FirebaseAuth.instance.currentUser;

          if (user!= null && !user.emailVerified) {
            await user.sendEmailVerification();//Solicitamos la verificación del email
            return { 'ok': false, 'mensaje': '¡Debes verificar tu email (revisa tu bandeja de entrada)!' };
          }
          else {
            
            return { 'ok': true };
          }
        }

      } else {
        return { 'ok': false, 'mensaje': '¡Ingrese usuario y contraseña!' };
      }

      } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return { 'ok': false, 'mensaje': '¡No existe un usuario registrado con ese email!' };
      } else if (e.code == 'wrong-password') {
        return { 'ok': false, 'mensaje': '¡Contraseña incorrecta!' };
      } else {
        print('Error: ' + e.code);
      }
    }

    return { 'ok': false, 'mensaje': '¡No se pudo iniciar sesión intente mas tarde!' };
  }

  Future<Map<String, dynamic>> loginWithGoogle() async {

    try {
      final google_sign_in.GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();

      if(googleSignInAccount != null){

        String providerID = 'Nada';

        await firebase_auth.FirebaseAuth.instance.fetchSignInMethodsForEmail(googleSignInAccount.email).then((value){

          if(value.toList().length > 0){
            providerID = value.toList()[0];
          } else {
            providerID = 'google.com';
          }

        });

        if(providerID == 'google.com'){

          print('Valor: $providerID');

          final google_sign_in.GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
          
          final firebase_auth.AuthCredential credential = firebase_auth.GoogleAuthProvider.credential(
            accessToken: googleSignInAuthentication.accessToken,
            idToken: googleSignInAuthentication.idToken,
          );

          await _auth.signInWithCredential(credential);

          firebase_auth.User? user = firebase_auth.FirebaseAuth.instance.currentUser;

          if (user!= null && !user.emailVerified) {
            await user.sendEmailVerification();//Solicitamos la verificación del email
            return { 'ok': false, 'mensaje': '¡Debes verificar tu email (revisa tu bandeja de entrada)!' };
          } else {
            return { 'ok': true };
          }

        } else if(providerID == 'facebook.com'){

          return { 'ok': false, 'mensaje': '¡Este email posee una cuenta registrada con Facebook!' };

        } else {

          return { 'ok': false, 'mensaje': '¡Este email posee una cuenta registrada con Correo y Contraseña!' };
          
        }

      } else {
          return { 'ok': false, 'mensaje': '¡Cancelaste el inicio de sesión!' };
      }

      } on firebase_auth.FirebaseAuthException catch (e) {

        await signOut();

        if (e.code == 'sign_in_canceled') {
          return { 'ok': false, 'mensaje': '¡Cancelaste el inicio de sesión!' };
        } else if (e.code == 'account-exists-with-different-credential') {

        return { 'ok': false, 'mensaje': '¡Este correo ya está asociado a una cuenta creada con Google!' };
        } else {
          print('Error: ' + e.code);
        }
    }
    
    return { 'ok': false, 'mensaje': '¡No se pudo iniciar sesión intente mas tarde!' };
  }
  
  Future<Map<String, dynamic>> loginWithFacebook() async {

    try {

      final LoginResult loginResult = await _facebookAuth.login();

      if(loginResult.status == LoginStatus.success ){

        final data = await _facebookAuth.getUserData();

        print('Email: ${data['email']}');

        String providerID = 'Nada';

        await firebase_auth.FirebaseAuth.instance.fetchSignInMethodsForEmail(data['email']).then((value){

          if(value.toList().length > 0){
            providerID = value.toList()[0];
          } else {
            providerID = 'facebook.com';
          }

        });

        if(providerID == 'facebook.com' ){

          final firebase_auth.AuthCredential credential = 
           firebase_auth.FacebookAuthProvider.credential(loginResult.accessToken!.token);

          await _auth.signInWithCredential(credential);

          firebase_auth.User? user = firebase_auth.FirebaseAuth.instance.currentUser;

          if (user!= null && !user.emailVerified) {

            await user.sendEmailVerification();//Solicitamos la verificación del email

            return { 'ok': false, 'mensaje': '¡Debes verificar tu email (revisa tu bandeja de entrada)!' };

          } else {
            return { 'ok': true };
          }

        } else if(providerID == 'google.com' ){
          
          return { 'ok': false, 'mensaje': '¡Este email posee una cuenta registrada con Google!' };

        } else {

          return { 'ok': false, 'mensaje': '¡Este email posee una cuenta registrada con Correo y Contraseña!' };

        }

      } else if(loginResult.status == LoginStatus.cancelled ) {

        return { 'ok': false, 'mensaje': '¡Cancelaste el inicio de sesión!' };

      } else if(loginResult.status == LoginStatus.failed ) {

        print('Error: ${loginResult.message}');

        return { 'ok': false, 'mensaje': '¡No se pudo iniciar sesión intente mas tarde!' };

      }  else if(loginResult.status == LoginStatus.operationInProgress ) {

        return { 'ok': false, 'mensaje': '¡Iniciando sesión...!' };

      } else {

        return { 'ok': false, 'mensaje': '¡No se pudo iniciar sesión intente mas tarde!' };

      }

    } on firebase_auth.FirebaseAuthException catch (e) {

      await signOut();

      if (e.code == 'sign_in_canceled') {
        return { 'ok': false, 'mensaje': '¡Cancelaste el inicio de sesión!' };
      } else if (e.code == 'account-exists-with-different-credential') {
        
        return { 'ok': false, 'mensaje': '¡Este correo ya está asociado a una cuenta creada con Google!' };
      } else {
        print('Error: ' + e.code);
      }
    }
    
    return { 'ok': false, 'mensaje': '¡No se pudo iniciar sesión intente mas tarde!' };
  }

  Future<Map<String, dynamic>> nuevoUsuario(String? email, String? password, String? passwordc) async {

    try {
      if(email != null && password != null && passwordc != null){
        if(password == passwordc){

          String providerID = 'Nada';

          await firebase_auth.FirebaseAuth.instance.fetchSignInMethodsForEmail(email).then((value){

            if(value.toList().length > 0){
            providerID = value.toList()[0];
            } else {
              providerID = 'password';
            }

          });

          if(providerID == 'google.com' ){
            
            return { 'ok': false, 'mensaje': '¡Este email posee una cuenta registrada con Google!' };
            
          } else if(providerID == 'facebook.com'){
              
            return { 'ok': false, 'mensaje': '¡Este email posee una cuenta registrada con Facebook!' };

          } else {

            await firebase_auth.FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: email,
              password: password
            );

            firebase_auth.User? user = firebase_auth.FirebaseAuth.instance.currentUser;

            if (user!= null && !user.emailVerified) {
              await user.sendEmailVerification();//Solicitamos la verificación del email
              return { 'ok': true, 'mensaje': '¡Debes verificar tu email (revisa tu bandeja de entrada)!' };
            }
            else {
              
              return { 'ok': true, 'mensaje': '¡Cuenta registrada! Inicia sesión' };
            }

          }

        } else {
          return { 'ok': false, 'mensaje': '¡Las contraseñas deben coincidir!' };
        }
      } else {
        return { 'ok': false, 'mensaje': '¡Ingrese correo, contraseña y confirme la contraseña!' };
      }

      } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return { 'ok': false, 'mensaje': '¡Ya existe un usuario registrado con ese email!' };
      } else {
        print('Error: ' + e.code);
      }
    }

    return { 'ok': false, 'mensaje': '¡No se pudo crear la cuenta intente mas tarde!' };
  }

  Future<Map<String, dynamic>> actualizarPassword(String? password, String? passwordn, String? passwordc) async {

    try {

      firebase_auth.User? user = firebase_auth.FirebaseAuth.instance.currentUser;

      if(password != null && passwordn != null && passwordc != null){

        final info = await login(user!.email, password);

        if(info['ok']){
          if(passwordn == passwordc){
            await user.updatePassword(passwordn);
            
            return { 'ok': true, 'mensaje': '¡Contraseña actualizada satisfactoriamente!' };

          } else {
            return { 'ok': false, 'mensaje': '¡Las contraseñas deben coincidir!' };
          }
        } else {
          return { 'ok': info['ok'], 'mensaje': info['mensaje'] };
        }

      } else {
        return { 'ok': false, 'mensaje': '¡Ingrese la contraseña anterior, la contraseña nueva y confirme!' };
      }

      } on firebase_auth.FirebaseAuthException catch (e) {
        print('Error: ${e.toString()}');
        return { 'ok': false, 'mensaje': '¡No se pudo actualizar la contraseña intente mas tarde!' };
    }
  }

  Future<Map<String, dynamic>> reestablecerPassword(String? email) async {

    try {

      String emailData = email == null ? 'correoinvalido123@algo.com' : email;

      String providerID = 'Nada';

          await firebase_auth.FirebaseAuth.instance.fetchSignInMethodsForEmail(emailData).then((value){

            if(value.toList().length > 0){
            providerID = value.toList()[0];
            } else {
              providerID = 'password';
            }

          });

          if(providerID == 'google.com' ){
            
            return { 'ok': false, 'mensaje': '¡Este email posee una cuenta registrada con Google!' };
            
          } else if(providerID == 'facebook.com'){
              
            return { 'ok': false, 'mensaje': '¡Este email posee una cuenta registrada con Facebook!' };

          } else {

            await _auth.sendPasswordResetEmail(email: emailData);
            
            return { 'ok': true, 'mensaje': '¡Revisa la bandeja de entrada del correo electrónico proporcionado!' };

          }


    } on firebase_auth.FirebaseAuthException catch (e) {

      if(e.code == 'invalid-email'){

        return { 'ok': false, 'mensaje': '¡Formato de correo incorrecto!' };

      } else if(e.code == 'user-not-found'){

        return { 'ok': false, 'mensaje': '¡No existe un usuario registrado con ese email!' };

      } else {

        print('Error: ${e.toString()}');
        return { 'ok': false, 'mensaje': '¡No se pudo enviar la solicitud! Intenta más tarde.' };

      }
    }
  }

  //Cerrar sesión
  Future signOut() async {
    await _googleSignIn.signOut();
    await _facebookAuth.logOut();
    await _auth.signOut();
  }
}