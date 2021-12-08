import 'package:flutter/material.dart';
import 'package:gasofast/src/bloc/change_password_bloc.dart';
import 'package:gasofast/src/bloc/provider.dart';

import 'package:gasofast/src/providers/usuario_provider.dart';
import 'package:gasofast/src/utils/utils.dart';

class ChangePasswordPage extends StatelessWidget {

  final usuarioProvider = UsuarioProvider();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(63, 114, 175, 1.0),
      floatingActionButton: _backButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: <Widget>[
              crearFondo(context),
              _changePasswordForm(context)
            ],
          ),
        ),
      ),
    );
  }

  //Botón para regresar a la pantalla de Inicio
  Widget _backButton(BuildContext context){
    return FloatingActionButton(
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Icon(Icons.arrow_back),
      onPressed: () => Navigator.of(context).pop(),
    );
  }

  //Widget que contiene todo el formulario Login
  Widget _changePasswordForm(BuildContext context){

    final bloc = Provider.ofChangePassword(context);

    final size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SafeArea(
            child: Container(
              height: 180.0,
            ),
          ),

          Container(
            width: size.width * 0.85,
            margin: EdgeInsets.only(top: 30.0, bottom: 5.0),
            padding: EdgeInsets.symmetric(vertical: 30.0),
            decoration: BoxDecoration(
              color: Color.fromRGBO(219, 226, 239, 1.0),
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 3.0,
                  offset: Offset(0.0, 5.0),
                  spreadRadius: 3.0
                )
              ]
            ),
            child: Column(
              children: <Widget>[
                Text('Cambiar Contraseña', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold )),
                  SizedBox(height: 10.0),
                  _crearPasswordA(bloc),
                  SizedBox(height: 20.0),
                  _crearPasswordN(bloc),
                  SizedBox(height: 20.0),
                  _crearPasswordNC(bloc),
                  SizedBox(height: 20.0),
                  _crearButton(bloc),
                  SizedBox(height: 10.0),
              ],
            ),
          ),

        ],
      ),
    );

  }

  //Widget para el TextField de la PasswordA
  Widget _crearPasswordA(ChangePasswordBloc bloc){
    return StreamBuilder<Object>(
      stream: bloc.passwordStream,
      builder: (BuildContext context, AsyncSnapshot snapshot){

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: TextField(
            obscureText: true,
            decoration: InputDecoration(
              icon: Icon(Icons.lock_outline_rounded),
              labelText: 'Contraseña actual',
              counterText: snapshot.data  != null ? 'Contraseña válida' : null,
                errorText: snapshot.error != null ? snapshot.error.toString() : null
            ),
            onChanged: bloc.changePassword,
          ),
        );
      }
    );
  }

  //Widget para el TextField de la PasswordN
  Widget _crearPasswordN(ChangePasswordBloc bloc){
    return StreamBuilder<Object>(
      stream: bloc.passwordNStream,
      builder: (BuildContext context, AsyncSnapshot snapshot){

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: TextField(
            obscureText: true,
            decoration: InputDecoration(
              icon: Icon(Icons.lock_outline_rounded),
              labelText: 'Contraseña nueva',
              counterText: snapshot.data  != null ? 'Contraseña válida' : null,
                errorText: snapshot.error != null ? snapshot.error.toString() : null
            ),
            onChanged: bloc.changePasswordN,
          ),
        );
      }
    );
  }

  //Widget para el TextField de la Password
  Widget _crearPasswordNC(ChangePasswordBloc bloc){
    return StreamBuilder<Object>(
      stream: bloc.passwordCStream,
      builder: (BuildContext context, AsyncSnapshot snapshot){

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: TextField(
            obscureText: true,
            decoration: InputDecoration(
              icon: Icon(Icons.lock_outline_rounded),
              labelText: 'Repetir contraseña nueva',
              counterText: snapshot.data  != null ? 'Contraseña válida' : null,
                errorText: snapshot.error != null ? snapshot.error.toString() : null
            ),
            onChanged: bloc.changePasswordC,
          ),
        );
      }
    );
  }

  //Widget para el ElevatedButton de Ingresar
  Widget _crearButton(ChangePasswordBloc bloc){

    final estiloBoton = ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled))
              return Colors.grey;//Color si está deshabilitado
            return Colors.white; //Color si está habilitado
          },
        ),
        elevation: MaterialStateProperty.all<double>(10.0),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)))
      );

    return StreamBuilder<Object>(
      stream: bloc.formValidStream,
        builder: (BuildContext context, AsyncSnapshot snapshot ){
        return Container(
          child: ElevatedButton(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 60.0, vertical: 15.0 ),
              child: Text('Cambiar', style: TextStyle(color: Colors.black) ,),
            ),
            style: estiloBoton,
            onPressed: snapshot.hasData ? () => _changePassword(bloc, context) : null
          ),
        );
      }
    );
  }

  //Método para autenticar inicio de sesión con Firebase
  _changePassword(ChangePasswordBloc bloc, BuildContext context) async {

    final info =  await usuarioProvider.actualizarPassword(bloc.password, bloc.passwordC, bloc.passwordN);

    if(info['ok']){
      //Escondemos el teclado
      FocusScopeNode currentFocus = FocusScope.of(context);

      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(info['mensaje']), backgroundColor: Colors.green.shade400,)
      );

      //Cerramos la pantalla
      Navigator.pop(context);
    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(info['mensaje']), backgroundColor: Colors.red.shade400,)
      );
    }
  }
}