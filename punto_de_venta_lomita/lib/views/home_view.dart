import 'package:flutter/material.dart';
import 'productos_view.dart';
import 'clientes_view.dart';
import 'ventas_view.dart';
import 'inventario_view.dart';
import 'provedores_view.dart';
import 'usuarios_view.dart';
import 'cortecaja_view.dart';
import 'reporte_view.dart';
import 'login_view.dart';

class HomeView extends StatelessWidget {
  const HomeView ({super.key});
  
  void logout(BuildContext context) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginView()),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("HOME REAL"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginView()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Column(
  children: [

    Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      color: Colors.red,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginView()),
            (route) => false,
          );
        },
        child: const Text("CERRAR SESIÓN"),
      ),
    ),

    // 🔽 TU MENÚ NORMAL
    Expanded(
      child: ListView(
        children: [
          ListTile(
            title: Text("Productos"),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductosView())),
          ),
          ListTile(
            title: Text("Clientes"),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ClientesView())),
          ),
          ListTile(
            title: Text("Ventas"),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VentasView())),
          ),
          ListTile(
            title: Text("Inventario"),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => InventarioView())),
          ),
          ListTile(
            title: Text("Proveedores"),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProveedorView())),
          ),
          ListTile(
            title: Text("Usuarios"),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UsuariosView())),
          ),
          ListTile(
            title: Text("Corte de Caja"),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CorteCajaView())),
          ),
          ListTile(
            title: Text("Reportes"),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReporteView())),
          ),
        ],
      ),
    )
  ],
),
);}}