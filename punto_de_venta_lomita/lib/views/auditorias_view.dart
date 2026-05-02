import 'package:flutter/material.dart';
import '../controllers/auditoria_controller.dart';
import '../core/session/session_manager.dart';
import '../models/auditoria_model.dart';

const _headerStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w800,
  color: Color(0xFF3C3935),
);

class AuditoriasView extends StatefulWidget {
  const AuditoriasView({super.key});

  @override
  State<AuditoriasView> createState() => _AuditoriasViewState();
}

class _AuditoriasViewState extends State<AuditoriasView> {
  final controller = AuditoriaController();

  List<Auditoria> auditorias = [];
  String busqueda = "";
  String accionFiltro = "TODAS";

  @override
  void initState() {
    super.initState();
    cargar();
  }

  Future<void> cargar() async {
    final data = await controller.obtenerTodas();
    if (!mounted) return;
    setState(() => auditorias = data);
  }

  List<Auditoria> get auditoriasFiltradas {
    return auditorias.where((a) {
      final coincideBusqueda =
          a.usuario.toLowerCase().contains(busqueda.toLowerCase()) ||
          a.tabla.toLowerCase().contains(busqueda.toLowerCase()) ||
          a.descripcion.toLowerCase().contains(busqueda.toLowerCase()) ||
          (a.idRegistro?.toString().contains(busqueda) ?? false);

      final coincideAccion =
          accionFiltro == "TODAS" ? true : a.accion == accionFiltro;

      return coincideBusqueda && coincideAccion;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8F4),
        elevation: 0,
        leadingWidth: 110,
        leading: TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 18),
          label: const Text(
            "Volver",
            style: TextStyle(color: Colors.black87),
          ),
        ),
        title: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Color(0xFFF2C500),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              "La Lomita",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Text(
              " | Auditorias",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          _topInfo(Icons.calendar_today_outlined, _fechaLarga(now)),
          const SizedBox(width: 16),
          _topInfo(Icons.access_time, _hora(now)),
          const SizedBox(width: 20),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFE6E0D8)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  SessionManager.currentUserName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  SessionManager.currentUserRole.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    color: Color(0xFFCC9A00),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: 280,
                    child: TextField(
                      onChanged: (value) => setState(() => busqueda = value),
                      decoration: InputDecoration(
                        hintText: "Buscar por nombre, tabla o descripcion...",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: const Color(0xFFF8F6F2),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F6F2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: accionFiltro,
                        icon: const Icon(Icons.filter_list),
                        items: const [
                          DropdownMenuItem(
                            value: "TODAS",
                            child: Text("Todas las acciones"),
                          ),
                          DropdownMenuItem(
                            value: "CREATE",
                            child: Text("CREATE"),
                          ),
                          DropdownMenuItem(
                            value: "EDIT",
                            child: Text("EDIT"),
                          ),
                          DropdownMenuItem(
                            value: "DELETE",
                            child: Text("DELETE"),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => accionFiltro = value);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                "Realice un seguimiento de todas las acciones efectuadas en el sistema",
                style: TextStyle(
                  color: Color(0xFF6E6A64),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 24),
              _tablaHeader(),
              const Divider(height: 1),
              Expanded(
                child: auditoriasFiltradas.isEmpty
                    ? const Center(
                        child: Text("No hay movimientos para mostrar"),
                      )
                    : ListView.separated(
                        itemCount: auditoriasFiltradas.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (_, index) {
                          final auditoria = auditoriasFiltradas[index];
                          return _filaAuditoria(auditoria);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFFDA9B00)),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _tablaHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: const Row(
        children: [
          Expanded(flex: 22, child: Text("FECHA Y HORA", style: _headerStyle)),
          Expanded(flex: 16, child: Text("USUARIO", style: _headerStyle)),
          Expanded(flex: 14, child: Text("TABLA", style: _headerStyle)),
          Expanded(flex: 12, child: Text("ACCION", style: _headerStyle)),
          Expanded(flex: 12, child: Text("REGISTRO ID", style: _headerStyle)),
          Expanded(flex: 24, child: Text("DESCRIPCION", style: _headerStyle)),
        ],
      ),
    );
  }

  Widget _filaAuditoria(Auditoria auditoria) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      child: Row(
        children: [
          Expanded(flex: 22, child: Text(_fechaHora(auditoria.fechaHora))),
          Expanded(flex: 16, child: Text(auditoria.usuario)),
          Expanded(flex: 14, child: Text(auditoria.tabla)),
          Expanded(
            flex: 12,
            child: Text(
              auditoria.accion,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: _colorAccion(auditoria.accion),
              ),
            ),
          ),
          Expanded(
            flex: 12,
            child: Text(auditoria.idRegistro?.toString() ?? "-"),
          ),
          Expanded(flex: 24, child: Text(auditoria.descripcion)),
        ],
      ),
    );
  }

  Color _colorAccion(String accion) {
    switch (accion) {
      case "CREATE":
        return Colors.green.shade700;
      case "EDIT":
        return Colors.orange.shade800;
      case "DELETE":
        return Colors.red.shade700;
      default:
        return Colors.black87;
    }
  }

  String _fechaHora(String value) {
    final fecha = DateTime.tryParse(value);
    if (fecha == null) return value;

    final dd = fecha.day.toString().padLeft(2, '0');
    final mm = fecha.month.toString().padLeft(2, '0');
    final yyyy = fecha.year.toString();
    final hh = fecha.hour.toString().padLeft(2, '0');
    final min = fecha.minute.toString().padLeft(2, '0');

    return "$dd/$mm/$yyyy $hh:$min";
  }

  String _hora(DateTime value) {
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.hour >= 12 ? "p.m." : "a.m.";
    return "$hour:$minute $period";
  }

  String _fechaLarga(DateTime value) {
    const dias = [
      "lunes",
      "martes",
      "miercoles",
      "jueves",
      "viernes",
      "sabado",
      "domingo",
    ];
    const meses = [
      "enero",
      "febrero",
      "marzo",
      "abril",
      "mayo",
      "junio",
      "julio",
      "agosto",
      "septiembre",
      "octubre",
      "noviembre",
      "diciembre",
    ];

    final dia = dias[value.weekday - 1];
    final mes = meses[value.month - 1];
    return "$dia, ${value.day} de $mes";
  }
}
