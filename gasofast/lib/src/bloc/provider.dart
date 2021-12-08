import 'package:flutter/material.dart';
import 'package:gasofast/src/bloc/change_password_bloc.dart';

import 'package:gasofast/src/bloc/login_bloc.dart';
import 'package:gasofast/src/bloc/map_bloc.dart';
import 'package:gasofast/src/bloc/recover_account_bloc.dart';
import 'package:gasofast/src/bloc/register_bloc.dart';
export 'package:gasofast/src/bloc/login_bloc.dart';

class Provider extends InheritedWidget{

  final loginBloc = LoginBloc();
  final registerBloc = RegisterBloc();
  final changePasswordBloc = ChangePasswordBloc();
  final recoverAccountBloc = RecoverAccountBloc();
  final mapBloc = MapBloc();

  static late Provider _instancia;

  factory Provider({required Key key, required Widget child}){

    _instancia = new Provider._internal(key: key, child: child);

    return _instancia;
  }

  Provider._internal({required Key key, required Widget child}) : super(key: key, child: child);

  //Sobreescribimos el método para notificar los cambios en el Widget especificado
  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  //Esta función busca entre todo el árbol de Widgets y retorna la instancia del bloc 'loginBloc' basado en el 'context'
  static LoginBloc ofLogin ( BuildContext context ){
    final loginBlocN = LoginBloc();

    /*if(context.dependOnInheritedWidgetOfExactType<Provider>() != null){
      loginBlocN = context.dependOnInheritedWidgetOfExactType<Provider>().loginBloc;
    }*/

    return context.dependOnInheritedWidgetOfExactType<Provider>() != null 
    ? 
    context.dependOnInheritedWidgetOfExactType<Provider>()!.loginBloc
    :
    loginBlocN;
  }

  //Esta función busca entre todo el árbol de Widgets y retorna la instancia del bloc 'registerBloc' basado en el 'context'
  static RegisterBloc ofRegister ( BuildContext context ){
    final registerBlocN = RegisterBloc();

    return context.dependOnInheritedWidgetOfExactType<Provider>() != null 
    ? 
    context.dependOnInheritedWidgetOfExactType<Provider>()!.registerBloc
    :
    registerBlocN;
  }

  //Esta función busca entre todo el árbol de Widgets y retorna la instancia del bloc 'changePasswordBloc' basado en el 'context'
  static ChangePasswordBloc ofChangePassword ( BuildContext context ){
    final changePasswordBlocN = ChangePasswordBloc();

    return context.dependOnInheritedWidgetOfExactType<Provider>() != null 
    ? 
    context.dependOnInheritedWidgetOfExactType<Provider>()!.changePasswordBloc
    :
    changePasswordBlocN;
  }

  //Esta función busca entre todo el árbol de Widgets y retorna la instancia del bloc 'changePasswordBloc' basado en el 'context'
  static RecoverAccountBloc ofRecoverAccount ( BuildContext context ){
    final recoverAccountBlocN = RecoverAccountBloc();

    return context.dependOnInheritedWidgetOfExactType<Provider>() != null 
    ? 
    context.dependOnInheritedWidgetOfExactType<Provider>()!.recoverAccountBloc
    :
    recoverAccountBlocN;
  }

  //Esta función busca entre todo el árbol de Widgets y retorna la instancia del bloc 'mapBloc' basado en el 'context'
  static MapBloc ofMap ( BuildContext context ){
    final mapBlocN = MapBloc();

    return context.dependOnInheritedWidgetOfExactType<Provider>() != null 
    ? 
    context.dependOnInheritedWidgetOfExactType<Provider>()!.mapBloc
    :
    mapBlocN;
  }

}