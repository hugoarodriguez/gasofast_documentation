import 'dart:async';

import 'package:gasofast/src/bloc/validators.dart';
import 'package:rxdart/rxdart.dart';

class ChangePasswordBloc with Validators{

  final _passwordController    = BehaviorSubject<String>();
  final _passwordNController = BehaviorSubject<String>();
  final _passwordCController = BehaviorSubject<String>();

  //Recuperar los datos del Stream
  Stream<String> get passwordStream    => _passwordController.stream.transform(validarPassword);
  Stream<String> get passwordNStream => _passwordNController.stream.transform(validarPassword);
  Stream<String> get passwordCStream => _passwordCController.stream.transform(validarPasswordC);

  //Stream para validar el formulario, es decir, que todos los campos del formulario contengan datos correctos
  Stream<bool> get formValidStream =>  
      Rx.combineLatest3(passwordStream, passwordNStream, passwordCStream, (p, pn, pc) => true);//Con '(e, p) => true' retornamos true si emailStream (e) y passwordStream (p) contienen data

  //Insertar valores al Stream
  Function(String) get changePassword    => _passwordController.sink.add;
  Function(String) get changePasswordN => _passwordNController.sink.add;
  Function(String) get changePasswordC => _passwordCController.sink.add;

  //Obtener el último valor ingresado a los Streams
  String? get password => _passwordController.value;
  String? get passwordN => _passwordNController.value;
  String? get passwordC => _passwordCController.value;

  //Limpiar los Streams
  dispose(){
    _passwordController.close();
    _passwordNController.close();
    _passwordCController.close();
  }
}