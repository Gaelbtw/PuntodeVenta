import 'package:flutter/material.dart';
import '../views/home_view.dart';

class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {

  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  void login() {
    if (userCtrl.text == "admin" && passCtrl.text == "1234") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeView()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Credenciales incorrectas")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Column(
        children: [
          TextField(controller: userCtrl, decoration: InputDecoration(labelText: "Usuario")),
          TextField(controller: passCtrl, decoration: InputDecoration(labelText: "Contraseña")),

          ElevatedButton(onPressed: login, child: Text("Entrar")),
        ],
      ),
    );
  }
}