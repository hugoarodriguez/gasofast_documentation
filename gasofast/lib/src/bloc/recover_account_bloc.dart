import 'dart:async';

import 'package:gasofast/src/bloc/validators.dart';
import 'package:rxdart/rxdart.dart';

class RecoverAccountBloc with Validators{

  final _emailController    = BehaviorSubject<String>();

  //Recuperar los datos del Stream
  Stream<String> get emailStream    => _emailController.stream.transform(validarEmail);

  //Stream para validar el formulario, es decir, que todos los campos del formulario contengan datos correctos
  Stream<bool> get formValidStream => 
  Rx.combineLatest2(emailStream, emailStream, (e1, e2) => true);//Con '(e, p) => true' retornamos true si emailStream (e) y passwordStream (p) contienen data

  //Insertar valores al Stream
  Function(String) get changeEmail    => _emailController.sink.add;

  //Obtener el último valor ingresado a los Streams
  String? get email => _emailController.value;

  //Limpiar los Streams
  dispose(){
    _emailController.close();
  }
}