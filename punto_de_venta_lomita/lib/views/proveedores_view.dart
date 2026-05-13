import 'package:flutter/material.dart';
import '../controllers/proveedor_controller.dart';
import '../models/proveedores_model.dart';
import '../widgets/nav_bar.dart';

class ProveedorView extends StatefulWidget {
  const ProveedorView({super.key});

  @override
  State<ProveedorView> createState() => _ProveedorViewState();
}

class _ProveedorViewState extends State<ProveedorView> {
  final controller = ProveedorController();

  List<Proveedores> proveedores = [];
  List<Proveedores> filtrados = [];

  @override
  void initState() {
    super.initState();
    cargar();
  }

  void cargar() async {
    final data = await controller.obtenerTodos();

    setState(() {
      proveedores = data;
      filtrados = data;
    });
  }

  void buscar(String query) {
    if (query.isEmpty) {
      setState(() => filtrados = proveedores);
      return;
    }

    final resultado = proveedores.where((p) {
      return p.nombre.toLowerCase().contains(query.toLowerCase()) ||
          p.rfc.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() => filtrados = resultado);
  }

  // 🔥 FORMULARIO
  void abrirFormulario({Proveedores? proveedor}) {
    final nombreCtrl = TextEditingController(text: proveedor?.nombre ?? "");

    final rfcCtrl = TextEditingController(text: proveedor?.rfc ?? "");

    final telefonoCtrl = TextEditingController(text: proveedor?.telefono ?? "");

    final direccionCtrl = TextEditingController(
      text: proveedor?.direccion ?? "",
    );

    final direccionFiscalCtrl = TextEditingController(
      text: proveedor?.direccionFiscal ?? "",
    );

    showDialog(
      context: context,

      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,

        child: Container(
          width: 650,

          padding: const EdgeInsets.all(28),

          decoration: BoxDecoration(
            color: const Color(0xFFFAF8F4),

            borderRadius: BorderRadius.circular(30),

            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 30,
                offset: Offset(0, 10),
              ),
            ],
          ),

          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // 🔥 HEADER
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,

                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1BF),

                        borderRadius: BorderRadius.circular(18),
                      ),

                      child: const Icon(
                        Icons.local_shipping_outlined,

                        color: Color(0xFFB88300),

                        size: 30,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            proveedor == null
                                ? "Nuevo Proveedor"
                                : "Editar Proveedor",

                            style: const TextStyle(
                              fontSize: 28,

                              fontWeight: FontWeight.w800,

                              color: Color(0xFF2D2B28),
                            ),
                          ),

                          const SizedBox(height: 4),

                          const Text(
                            "Administre la información de proveedores del sistema",

                            style: TextStyle(
                              color: Color(0xFF6E6A64),

                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // 🔥 FORMULARIO
                Wrap(
                  spacing: 16,
                  runSpacing: 16,

                  children: [
                    SizedBox(
                      width: 290,

                      child: _inputFormulario(
                        controller: nombreCtrl,

                        label: "Nombre",

                        icon: Icons.business_outlined,
                      ),
                    ),

                    SizedBox(
                      width: 290,

                      child: _inputFormulario(
                        controller: rfcCtrl,

                        label: "RFC",

                        icon: Icons.badge_outlined,
                      ),
                    ),

                    SizedBox(
                      width: 290,

                      child: _inputFormulario(
                        controller: telefonoCtrl,

                        label: "Teléfono",

                        icon: Icons.phone_outlined,
                      ),
                    ),

                    SizedBox(
                      width: 290,

                      child: _inputFormulario(
                        controller: direccionCtrl,

                        label: "Dirección",

                        icon: Icons.location_on_outlined,
                      ),
                    ),

                    SizedBox(
                      width: 596,

                      child: _inputFormulario(
                        controller: direccionFiscalCtrl,

                        label: "Dirección Fiscal",

                        icon: Icons.receipt_long_outlined,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // 🔥 BOTONES
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,

                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),

                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),

                      child: const Text(
                        "Cancelar",

                        style: TextStyle(
                          color: Colors.black87,

                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    ElevatedButton.icon(
                      onPressed: () async {
                        if (nombreCtrl.text.isEmpty ||
                            rfcCtrl.text.isEmpty ||
                            telefonoCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Completa los campos obligatorios"),
                            ),
                          );
                          return;
                        }

                        if (telefonoCtrl.text.length < 10) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Teléfono inválido")),
                          );
                          return;
                        }

                        final existentes = await controller.obtenerTodos();

                        final duplicado = existentes.any(
                          (p) =>
                              p.nombre.toLowerCase() ==
                                  nombreCtrl.text.toLowerCase() &&
                              p.idProveedor != proveedor?.idProveedor,
                        );

                        if (duplicado) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Proveedor duplicado"),
                            ),
                          );
                          return;
                        }

                        final nuevo = Proveedores(
                          idProveedor: proveedor?.idProveedor,

                          nombre: nombreCtrl.text,

                          rfc: rfcCtrl.text,

                          direccion: direccionCtrl.text,

                          direccionFiscal: direccionFiscalCtrl.text,

                          telefono: telefonoCtrl.text,
                        );

                        if (proveedor == null) {
                          await controller.insertar(nuevo);
                        } else {
                          await controller.actualizar(nuevo);
                        }

                        cargar();

                        Navigator.pop(context);
                      },

                      icon: const Icon(Icons.save_outlined),

                      label: Text(
                        proveedor == null
                            ? "Guardar Proveedor"
                            : "Guardar Cambios",
                      ),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF2C500),

                        foregroundColor: Colors.black87,

                        elevation: 0,

                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 18,
                        ),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔥 ELIMINAR
  void eliminar(int id) async {
    await controller.eliminar(id);
    cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F4),

      appBar: CustomHeader(titulo: "Proveedores", mostrarVolver: true),

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
              // 🔥 HEADER
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: const [
                        Text(
                          "Gestión de Proveedores",

                          style: TextStyle(
                            fontSize: 28,

                            fontWeight: FontWeight.w800,

                            color: Color(0xFF2D2B28),
                          ),
                        ),

                        SizedBox(height: 8),

                        Text(
                          "Administre y controle todos los proveedores registrados",

                          style: TextStyle(
                            color: Color(0xFF6E6A64),

                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  ElevatedButton.icon(
                    onPressed: () => abrirFormulario(),

                    icon: const Icon(Icons.add),

                    label: const Text("Agregar Proveedor"),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF2C500),

                      foregroundColor: Colors.black87,

                      elevation: 0,

                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 18,
                      ),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 🔥 BUSCADOR
              SizedBox(
                width: 320,

                child: TextField(
                  onChanged: buscar,

                  decoration: InputDecoration(
                    hintText: "Buscar proveedor...",

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

              const SizedBox(height: 24),

              // 🔥 TABLA
              _headerTabla(),

              const Divider(height: 1),

              Expanded(
                child: filtrados.isEmpty
                    ? const Center(
                        child: Text("No hay proveedores registrados"),
                      )
                    : ListView.separated(
                        itemCount: filtrados.length,

                        separatorBuilder: (_, _) => const Divider(height: 1),

                        itemBuilder: (_, i) {
                          final p = filtrados[i];

                          return _filaProveedor(p);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 HEADER TABLA
  Widget _headerTabla() {
    const headerStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w800,
      color: Color(0xFF3C3935),
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),

      child: const Row(
        children: [
          Expanded(flex: 3, child: Text("PROVEEDOR", style: headerStyle)),

          Expanded(flex: 2, child: Text("RFC", style: headerStyle)),

          Expanded(flex: 2, child: Text("TELÉFONO", style: headerStyle)),

          Expanded(flex: 3, child: Text("DIRECCIÓN", style: headerStyle)),

          Expanded(flex: 2, child: Text("ACCIONES", style: headerStyle)),
        ],
      ),
    );
  }

  // 🔥 FILA
  Widget _filaProveedor(Proveedores p) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),

      child: Row(
        children: [
          Expanded(
            flex: 3,

            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,

                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1BF),

                    borderRadius: BorderRadius.circular(14),
                  ),

                  child: const Icon(
                    Icons.local_shipping_outlined,

                    color: Color(0xFFB88300),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Text(
                    p.nombre,

                    style: const TextStyle(
                      fontWeight: FontWeight.w700,

                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(flex: 2, child: Text(p.rfc)),

          Expanded(flex: 2, child: Text(p.telefono)),

          Expanded(
            flex: 3,

            child: Text(p.direccion.isEmpty ? "-" : p.direccion),
          ),

          Expanded(
            flex: 2,

            child: Row(
              children: [
                IconButton(
                  onPressed: () => abrirFormulario(proveedor: p),

                  icon: const Icon(Icons.edit_outlined),

                  color: Colors.orange.shade800,
                ),

                IconButton(
                  onPressed: () => eliminar(p.idProveedor!),

                  icon: const Icon(Icons.delete_outline),

                  color: Colors.red.shade700,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 INPUT
  Widget _inputFormulario({
    required TextEditingController controller,

    required String label,

    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),

          child: Text(
            label,

            style: const TextStyle(
              fontWeight: FontWeight.w700,

              color: Color(0xFF3C3935),

              fontSize: 13,
            ),
          ),
        ),

        TextField(
          controller: controller,

          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFFCC9600)),

            filled: true,

            fillColor: Colors.white,

            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 16,
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),

              borderSide: BorderSide.none,
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),

              borderSide: const BorderSide(color: Color(0xFFE7E1D8)),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),

              borderSide: const BorderSide(
                color: Color(0xFFF2C500),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
