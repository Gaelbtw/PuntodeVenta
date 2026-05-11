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
import 'compras_view.dart';
import 'configuracion_view.dart';
import '../widgets/nav_bar.dart';

class HomeView extends StatelessWidget {
  final String rol;

  const HomeView({
    super.key,
    required this.rol,
  });

  bool get esAdmin => rol == "Admin";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F4),

      appBar: CustomHeader(
        titulo: "Menu",
        mostrarVolver: false,
        extraActions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black87),
            onPressed: () {
              SessionManager.clear();

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => const LoginView(),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x11000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),

        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.3,

          children: [
  
            // 🔥 PRODUCTOS (TODOS)
            MenuCard(
              title: "Productos",
              subtitle: "Gestion de productos",
              icon: Icons.inventory,
              color: const Color(0xFFF3E1C7),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProductosView(),
                  ),
                );
              },
            ),

            // 🔥 VENTAS (TODOS)
            MenuCard(
              title: "Ventas",
              subtitle: "Registrar ventas",
              icon: Icons.point_of_sale,
              color: const Color(0xFFF3E1C7),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const VentasView(),
                  ),
                );
              },
            ),

            // 🔥 CONFIGURACION (TODOS)
            MenuCard(
              title: "Configuración",
              subtitle: "Preferencias del sistema",
              icon: Icons.settings,
              color: const Color(0xFFEED5C4),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ConfiguracionView(),
                  ),
                );
              },
            ),

            // 🔥 SOLO ADMIN
            if (esAdmin)
              MenuCard(
                title: "Clientes",
                subtitle: "Base de clientes",
                icon: Icons.people,
                color: const Color(0xFFEED5C4),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ClientesView(),
                    ),
                  );
                },
              ),

            if (esAdmin)
              MenuCard(
                title: "Inventario",
                subtitle: "Control de inventario",
                icon: Icons.inventory_2,
                color: const Color(0xFFF3E1C7),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const InventarioView(),
                    ),
                  );
                },
              ),

            if (esAdmin)
              MenuCard(
                title: "Proveedores",
                subtitle: "Gestion de proveedores",
                icon: Icons.local_shipping,
                color: const Color(0xFFEED5C4),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProveedorView(),
                    ),
                  );
                },
              ),

            if (esAdmin)
              MenuCard(
                title: "Usuarios",
                subtitle: "Gestion de usuarios",
                icon: Icons.person,
                color: const Color(0xFFEED5C4),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const UsuariosView(),
                    ),
                  );
                },
              ),

            if (esAdmin)
              MenuCard(
                title: "Reportes",
                subtitle: "Analisis",
                icon: Icons.bar_chart,
                color: const Color(0xFFEED5C4),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ReporteView(),
                    ),
                  );
                },
              ),

            if (esAdmin)
              MenuCard(
                title: "Compras",
                subtitle: "Compras a proveedores",
                icon: Icons.money,
                color: const Color(0xFFEED5C4),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ComprasView(),
                    ),
                  );
                },
              ),

            if (esAdmin)
              MenuCard(
                title: "Pedidos",
                subtitle: "Gestion de pedidos",
                icon: Icons.receipt_long,
                color: const Color(0xFFF3E1C7),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PedidosView(),
                    ),
                  );
                },
              ),

            if (esAdmin)
              MenuCard(
                title: "Auditorias",
                subtitle: "Seguimiento del sistema",
                icon: Icons.fact_check_outlined,
                color: const Color(0xFFFFEDBF),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AuditoriasView(),
                    ),
                  );
                },
              ),

            if (esAdmin)
              MenuCard(
                title: "Base de datos",
                subtitle: "Backup y restore",
                icon: Icons.storage_rounded,
                color: const Color(0xFFE8F0D5),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BaseDatosView(),
                    ),
                  );
                },
              ),

            if (esAdmin)
              MenuCard(
                title: "Corte de Caja",
                subtitle: "Resumen diario",
                icon: Icons.attach_money,
                color: const Color(0xFFEED5C4),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CorteCajaView(),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
      ),
    );
  }
}