import 'package:flutter/material.dart';
import '../controllers/proveedor_controller.dart';
import '../models/proveedores_model.dart';

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

  void abrirFormulario({Proveedores? proveedor}) {
    final nombreCtrl = TextEditingController(text: proveedor?.nombre ?? "");
    final rfcCtrl = TextEditingController(text: proveedor?.rfc ?? "");
    final telefonoCtrl = TextEditingController(text: proveedor?.telefono ?? "");
    final direccionCtrl = TextEditingController(text: proveedor?.direccion ?? "");
    final direccionFiscalCtrl = TextEditingController(text: proveedor?.direccionFiscal ?? "");

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(proveedor == null ? "Agregar Proveedor" : "Editar Proveedor"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: "Nombre")),
              TextField(controller: rfcCtrl, decoration: const InputDecoration(labelText: "RFC")),
              TextField(controller: telefonoCtrl, decoration: const InputDecoration(labelText: "Teléfono")),
              TextField(controller: direccionCtrl, decoration: const InputDecoration(labelText: "Dirección")),
              TextField(controller: direccionFiscalCtrl, decoration: const InputDecoration(labelText: "Dirección Fiscal")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {

              if (nombreCtrl.text.isEmpty ||
                  rfcCtrl.text.isEmpty ||
                  telefonoCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Completa los campos")),
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

              final duplicado = existentes.any((p) =>
                p.nombre.toLowerCase() == nombreCtrl.text.toLowerCase() &&
                p.idProveedor != proveedor?.idProveedor
              );

              if (duplicado) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Proveedor duplicado")),
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

              Navigator.pop(context);
              cargar();
            },
            child: const Text("Guardar"),
          )
        ],
      ),
    );
  }

  void eliminar(int id) async {
    await controller.eliminar(id);
    cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Proveedores")),
      body: Column(
        children: [

          // 🔍 BUSCADOR
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Buscar proveedor...",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: buscar,
            ),
          ),

          // ➕ BOTÓN
          Padding(
            padding: const EdgeInsets.all(10),
            child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => abrirFormulario(),
                icon: const Icon(Icons.add),
                label: const Text("Agregar Proveedor"),
              ),
            ),
          ),

          // 📋 LISTA
          Expanded(
            child: filtrados.isEmpty
                ? const Center(child: Text("No hay proveedores"))
                : ListView.builder(
                    itemCount: filtrados.length,
                    itemBuilder: (_, i) {
                      final p = filtrados[i];

                      return Card(
                        child: ListTile(
                          title: Text(p.nombre),
                          subtitle: Text(
                            "RFC: ${p.rfc}\nTel: ${p.telefono}\nDir: ${p.direccion}",
                          ),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => abrirFormulario(proveedor: p),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => eliminar(p.idProveedor!),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}