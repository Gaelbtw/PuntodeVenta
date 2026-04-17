import 'package:flutter/material.dart';
import 'productos_view.dart';
import 'clientes_view.dart';
import 'ventas_view.dart';
import 'inventario_view.dart';
import 'provedores_view.dart';
import 'usuarios_view.dart';
import 'cortecaja_view.dart';
import 'reporte_view.dart';
import '../widgets/menu_card.dart';

class HomeView extends StatelessWidget {

  const HomeView ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Punto de Venta")),
      body: Padding(

        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.3,
        
        children: [
          MenuCard(
            title: "Productos",
            subtitle: "Gestion de productos",
            icon: Icons.inventory,
            color: const Color(0xFFF3E1C7),
            onTap: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => ProductosView()),
              ),
          ),
          MenuCard(
            title: "Clientes",
            subtitle: "Base de clientes",
            icon: Icons.people,
            color: const Color(0xFFEED5C4),
            onTap: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => ClientesView()), 
              ),
          ),
          MenuCard(
            title: "Ventas",
            subtitle: "Registrar ventas",
            icon: Icons.point_of_sale,
            color: const Color(0xFFF3E1C7),
            onTap: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => VentasView()), 
              ),
          ),
          MenuCard(
            title: "Inventario",
            subtitle: "Control de inventario",
            icon: Icons.inventory_2,
            color: const Color(0xFFF3E1C7),
            onTap: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => InventarioView()),
              ),
          ),
          MenuCard(
            title: "Proveedores",
            subtitle: "Gestion de proveedores",
            icon: Icons.local_shipping,
            color: const Color(0xFFEED5C4),
            onTap: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => ProveedorView()),
              ),
          ),
          MenuCard(
            title: "Usuarios",
            subtitle: "Gestion de usuarios",
            icon: Icons.person,
            color: const Color(0xFFEED5C4),
            onTap: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => UsuariosView()),
              ),
          ),
          MenuCard(
            title: "Corte de Caja",
            subtitle: "Resumen diario",
            icon: Icons.attach_money,
            color: const Color(0xFFEED5C4),
            onTap: () => Navigator.push(context,MaterialPageRoute(builder: (_) => CorteCajaView())),
          ),
          MenuCard(
            title: "Reportes",
            subtitle: "Analisis",
            icon: Icons.bar_chart,
            color: const Color(0xFFEED5C4),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ReporteView()),
              ),
          ),
        ],
      ),
    ),
  );
}
}