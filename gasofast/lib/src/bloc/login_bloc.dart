import 'dart:async';

import 'package:gasofast/src/bloc/validators.dart';
import 'package:rxdart/rxdart.dart';

class LoginBloc with Validators{

  final _emailController    = BehaviorSubject<String>();
  final _passwordController = BehaviorSubject<String>();

  //Recuperar los datos del Stream
  Stream<String> get emailStream    => _emailController.stream.transform(validarEmail);
  Stream<String> get passwordStream => _passwordController.stream.transform(validarPassword);

  //Stream para validar el formulario, es decir, que todos los campos del formulario contengan datos correctos
  Stream<bool> get formValidStream =>  
      Rx.combineLatest2(emailStream, passwordStream, (e, p) => true);//Con '(e, p) => true' retornamos true si emailStream (e) y passwordStream (p) contienen data

  //Insertar valores al Stream
  Function(String) get changeEmail    => _emailController.sink.add;
  Function(String) get changePassword => _passwordController.sink.add;

  //Obtener el último valor ingresado a los Streams
  String? get email => _emailController.value;
  String? get password => _passwordController.value;

  //Limpiar los Streams
  dispose(){
    _emailController.close();
    _passwordController.close();
  }
}