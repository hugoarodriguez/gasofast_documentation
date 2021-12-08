import 'package:flutter/material.dart';
import 'package:gasofast/src/bloc/provider.dart';
import 'package:gasofast/src/bloc/recover_account_bloc.dart';
import 'package:gasofast/src/providers/usuario_provider.dart';
import 'package:gasofast/src/utils/utils.dart';

class RecoverAccountPage extends StatelessWidget {

  final usuarioProvider = UsuarioProvider();

  final TextEditingController _emailController = TextEditingController();

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
              _recoverAccountForm(context)
            ],
          ),
        ),
      ),
    );
  }

  //Botón para regresar a la pantalla del Login
  Widget _backButton(BuildContext context){
    return FloatingActionButton(
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Icon(Icons.arrow_back),
      onPressed: () => Navigator.pushReplacementNamed(context, 'login'),
    );

    
  }

  //Widget que contiene todo el formulario Login
  Widget _recoverAccountForm(BuildContext context){

    final bloc = Provider.ofRecoverAccount(context);

    final textIndication1 = '''Ingresa el correo electrónico con el que te registraste y se te enviará una solicitud para que cambies tu contraseña.\n\n
Posteriormente tendrás que iniciar sesión con tu nueva contraseña''';

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
                Text('Recuperar Cuenta', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold )),
                  SizedBox(height: 10.0),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(textIndication1, 
                    )
                  ),
                  SizedBox(height: 20.0),
                  _crearEmail(bloc),
                  SizedBox(height: 20.0),
                  _crearButton(bloc),
                  SizedBox(height: 10.0),
              ],
            ),
          ),

          SizedBox(height: 20.0),

        ],
      ),
    );

  }

  //Widget para el TextField del Email
    Widget _crearEmail(RecoverAccountBloc bloc){
      return StreamBuilder(
        stream: bloc.emailStream,
        builder: (BuildContext context, AsyncSnapshot snapshot){
          
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                icon: Icon(Icons.alternate_email_rounded),
                hintText: 'ejemplo@correo.com',
                labelText: 'Correo',
                counterText: snapshot.data != null ? 'Correo válido' : null,
                errorText: snapshot.error != null ? snapshot.error.toString() : null
              ),
              onChanged: bloc.changeEmail,//El primer parámetro enviado al 'onChanged:' se pasa al 'bloc.changeEmail'
            ),
          );

        }
      );
    }

  //Widget para el ElevatedButton de Ingresar
  Widget _crearButton(RecoverAccountBloc bloc){

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

    return StreamBuilder(
      stream: bloc.formValidStream,
      builder: (BuildContext context, AsyncSnapshot snapshot ){
        return Container(
          child: ElevatedButton(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 60.0, vertical: 15.0 ),
              child: Text('Enviar Solicitud', style: TextStyle(color: Colors.black) ,),
            ),
            style: estiloBoton,            
            onPressed: snapshot.hasData ? () => _recoverAccount(bloc, context) : null
          ),
        );
      }
    );
  }

  //Método para enviar solicitud de recuperación de contraseña
  _recoverAccount(RecoverAccountBloc bloc, BuildContext context) async {

    final info =  await usuarioProvider.reestablecerPassword(bloc.email);

    if(info['ok']){
      //Escondemos el teclado
      FocusScopeNode currentFocus = FocusScope.of(context);

      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(info['mensaje']), backgroundColor: Colors.green.shade400,)
      );

      //Redireccionamos a la pantalla Login
      Navigator.pushNamed(context, 'login');
    } else {

      //Limpiamos los campos del formulario
      _emailController.text = '';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(info['mensaje']), backgroundColor: Colors.red.shade400,)
      );
    }
  }
}

