import 'package:flutter/material.dart';
import 'productos_view.dart';
import 'clientes_view.dart';
import 'ventas_view.dart';
import 'inventario_view.dart';
import 'proveedor_view.dart';
import 'usuarios_view.dart';

class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Punto de Venta")),
      body: ListView(
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
            onTap: () => Navigator.push(context,MaterialPageRoute(builder: (_) => CorteCajaView()),),
          ),
          ListTile(
            title: Text("Reportes"),
            onTap: () => Navigator.push(context,MaterialPageRoute(builder: (_) => ReporteView()),),
          ),
        ],
      ),
    );
  }
}