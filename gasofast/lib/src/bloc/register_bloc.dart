import 'dart:async';

import 'package:gasofast/src/bloc/validators.dart';
import 'package:rxdart/rxdart.dart';

class RegisterBloc with Validators{

  final _emailController    = BehaviorSubject<String>();
  final _passwordController = BehaviorSubject<String>();
  final _passwordCController = BehaviorSubject<String>();

  //Recuperar los datos del Stream
  Stream<String> get emailStream    => _emailController.stream.transform(validarEmail);
  Stream<String> get passwordStream => _passwordController.stream.transform(validarPassword);
  Stream<String> get passwordCStream => _passwordCController.stream.transform(validarPasswordC);

  //Stream para validar el formulario, es decir, que todos los campos del formulario contengan datos correctos
  Stream<bool> get formValidStream =>  
      Rx.combineLatest3(emailStream, passwordStream, passwordCStream, (e, p, pc) => true);//Con '(e, p) => true' retornamos true si emailStream (e) y passwordStream (p) contienen data

  //Insertar valores al Stream
  Function(String) get changeEmail    => _emailController.sink.add;
  Function(String) get changePassword => _passwordController.sink.add;
  Function(String) get changePasswordC => _passwordCController.sink.add;

  //Obtener el último valor ingresado a los Streams
  String? get email => _emailController.value;
  String? get password => _passwordController.value;
  String? get passwordC => _passwordCController.value;

  //Limpiar los Streams
  dispose(){
    _emailController.close();
    _passwordController.close();
    _passwordCController.close();
  }
}