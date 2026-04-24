import 'package:flutter/material.dart';
import '../core/session/session_manager.dart';
import '../widgets/menu_card.dart';
import 'auditorias_view.dart';
import 'base_datos_view.dart';
import 'clientes_view.dart';
import 'cortecaja_view.dart';
import 'inventario_view.dart';
import 'login_view.dart';
import 'pedidos_view.dart';
import 'productos_view.dart';
import 'proveedores_view.dart';
import 'reporte_view.dart';
import 'usuarios_view.dart';
import 'ventas_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("La Lomita"),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(
                SessionManager.currentUserName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              SessionManager.clear();
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
            MenuCard(
              title: "Productos",
              subtitle: "Gestion de productos",
              icon: Icons.inventory,
              color: const Color(0xFFF3E1C7),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProductosView()),
                );
              },
            ),
            MenuCard(
              title: "Clientes",
              subtitle: "Base de clientes",
              icon: Icons.people,
              color: const Color(0xFFEED5C4),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ClientesView()),
                );
              },
            ),
            MenuCard(
              title: "Ventas",
              subtitle: "Registrar ventas",
              icon: Icons.point_of_sale,
              color: const Color(0xFFF3E1C7),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const VentasView()),
                );
              },
            ),
            MenuCard(
              title: "Inventario",
              subtitle: "Control de inventario",
              icon: Icons.inventory_2,
              color: const Color(0xFFF3E1C7),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const InventarioView()),
                );
              },
            ),
            MenuCard(
              title: "Proveedores",
              subtitle: "Gestion de proveedores",
              icon: Icons.local_shipping,
              color: const Color(0xFFEED5C4),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProveedorView()),
                );
              },
            ),
            MenuCard(
              title: "Usuarios",
              subtitle: "Gestion de usuarios",
              icon: Icons.person,
              color: const Color(0xFFEED5C4),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UsuariosView()),
                );
              },
            ),
            MenuCard(
              title: "Corte de Caja",
              subtitle: "Resumen diario",
              icon: Icons.attach_money,
              color: const Color(0xFFEED5C4),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CorteCajaView()),
                );
              },
            ),
            MenuCard(
              title: "Reportes",
              subtitle: "Analisis",
              icon: Icons.bar_chart,
              color: const Color(0xFFEED5C4),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReporteView()),
                );
              },
            ),
            MenuCard(
              title: "Pedidos",
              subtitle: "Gestion de pedidos",
              icon: Icons.receipt_long,
              color: const Color(0xFFF3E1C7),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PedidosView()),
                );
              },
            ),
            MenuCard(
              title: "Auditorias",
              subtitle: "Seguimiento del sistema",
              icon: Icons.fact_check_outlined,
              color: const Color(0xFFFFEDBF),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AuditoriasView()),
                );
              },
            ),
            MenuCard(
              title: "Base de datos",
              subtitle: "Backup y restore",
              icon: Icons.storage_rounded,
              color: const Color(0xFFE8F0D5),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BaseDatosView()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
