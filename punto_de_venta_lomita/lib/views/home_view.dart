import 'package:flutter/material.dart';
import 'productos_view.dart';
import 'clientes_view.dart';
import 'ventas_view.dart';
import 'inventario_view.dart';
import 'proveedores_view.dart';
import 'usuarios_view.dart';
import 'cortecaja_view.dart';
import 'reporte_view.dart';
import 'login_view.dart';
import '../widgets/menu_card.dart';
import 'pedidos_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

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

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.3,
          children: [

            // 🔹 PRODUCTOS
            MenuCard(
              title: "Productos",
              subtitle: "Gestión de productos",
              icon: Icons.inventory,
              color: const Color(0xFFF3E1C7),
              onTap: () {
                Navigator.push(context,
                  MaterialPageRoute(builder: (_) => ProductosView()));
              },
            ),

            // 🔹 CLIENTES
            MenuCard(
              title: "Clientes",
              subtitle: "Base de clientes",
              icon: Icons.people,
              color: const Color(0xFFEED5C4),
              onTap: () {
                Navigator.push(context,
                  MaterialPageRoute(builder: (_) => ClientesView()));
              },
            ),

            // 🔹 VENTAS
            MenuCard(
              title: "Ventas",
              subtitle: "Registrar ventas",
              icon: Icons.point_of_sale,
              color: const Color(0xFFF3E1C7),
              onTap: () {
                Navigator.push(context,
                  MaterialPageRoute(builder: (_) => VentasView()));
              },
            ),

            // 🔹 INVENTARIO
            MenuCard(
              title: "Inventario",
              subtitle: "Control de inventario",
              icon: Icons.inventory_2,
              color: const Color(0xFFF3E1C7),
              onTap: () {
                Navigator.push(context,
                  MaterialPageRoute(builder: (_) => InventarioView()));
              },
            ),

            // 🔹 PROVEEDORES
            MenuCard(
              title: "Proveedores",
              subtitle: "Gestión de proveedores",
              icon: Icons.local_shipping,
              color: const Color(0xFFEED5C4),
              onTap: () {
                Navigator.push(context,
                  MaterialPageRoute(builder: (_) => ProveedorView()));
              },
            ),

            // 🔹 USUARIOS
            MenuCard(
              title: "Usuarios",
              subtitle: "Gestión de usuarios",
              icon: Icons.person,
              color: const Color(0xFFEED5C4),
              onTap: () {
                Navigator.push(context,
                  MaterialPageRoute(builder: (_) => UsuariosView()));
              },
            ),

            // 🔹 CORTE DE CAJA
            MenuCard(
              title: "Corte de Caja",
              subtitle: "Resumen diario",
              icon: Icons.attach_money,
              color: const Color(0xFFEED5C4),
              onTap: () {
                Navigator.push(context,
                  MaterialPageRoute(builder: (_) => CorteCajaView()));
              },
            ),

            // 🔹 REPORTES
            MenuCard(
              title: "Reportes",
              subtitle: "Análisis",
              icon: Icons.bar_chart,
              color: const Color(0xFFEED5C4),
              onTap: () {
                Navigator.push(context,
                  MaterialPageRoute(builder: (_) => ReporteView()));
              },
            ),
            MenuCard(
              title: "Pedidos",
              subtitle: "Gestión de pedidos",
              icon: Icons.receipt_long,
              color: const Color(0xFFF3E1C7),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PedidosView()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}