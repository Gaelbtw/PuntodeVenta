import 'package:flutter/material.dart';
import '../controllers/proveedor_controller.dart';
import '../models/proveedores_model.dart';

class ProveedorView extends StatefulWidget {
  const ProveedorView({super.key});
  
  @override
  _ProveedorViewState createState() => _ProveedorViewState();
}

class _ProveedorViewState extends State<ProveedorView> {
  final controller = ProveedorController();

  final nombreCtrl = TextEditingController();
  final telefonoCtrl = TextEditingController();
  final direccionCtrl = TextEditingController();

  List<Proveedores> proveedores = [];

  @override
  void initState() {
    super.initState();
    cargar();
  }


  void mostrarFormulario({Proveedores? proveedor}) {

  // 🔥 LIMPIAR SI ES NUEVO
  if (proveedor == null) {
    nombreCtrl.clear();
    telefonoCtrl.clear();
    direccionCtrl.clear();
  } else {
    nombreCtrl.text = proveedor.nombre;
    telefonoCtrl.text = proveedor.telefono ?? "";
    direccionCtrl.text = proveedor.direccion;
  }

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(proveedor == null ? "Nuevo proveedor" : "Editar proveedor"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nombreCtrl,
            decoration: const InputDecoration(labelText: "Nombre"),
          ),
          TextField(
            controller: telefonoCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: "Teléfono"),
          ),
          TextField(
            controller: direccionCtrl,
            decoration: const InputDecoration(labelText: "Dirección"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: () async {

            if (nombreCtrl.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Nombre obligatorio")),
              );
              return;
            }

            final nuevo = Proveedores(
              idProveedor: proveedor?.idProveedor,
              nombre: nombreCtrl.text,
              telefono: telefonoCtrl.text.isEmpty ? null : telefonoCtrl.text,
              direccion: direccionCtrl.text,
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
        ),
      ],
    ),
  );
}

  void cargar() async {
    final data  = await controller.obtenerTodos();

    setState(() {
      proveedores = data;
    });
  }

  void guardar() async {

    final proveedor = Proveedores(
        idProveedor: null, 
        nombre: nombreCtrl.text, 
        direccion: direccionCtrl.text,
        telefono: telefonoCtrl.text
        );

    await controller.insertar(proveedor);
    
    nombreCtrl.clear();
    telefonoCtrl.clear();
    direccionCtrl.clear();

    cargar();
  }

  void eliminar(int id) async {
    await controller.eliminar(id);
    cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Proveedores"),
      ),
      body: Column(
        children: [

          // 🔹 TARJETAS
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                _CardInfo(titulo: "TOTAL", valor: proveedores.length.toString()),
                _CardInfo(titulo: "CON TEL", valor: proveedores.where((p) => (p.telefono ?? "").isNotEmpty).length.toString()),
                _CardInfo(titulo: "SIN TEL", valor: proveedores.where((p) => (p.telefono ?? "").isEmpty).length.toString()),
              ],
            ),
          ),

          // 🔹 BUSCADOR + BOTÓN
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Buscar proveedor...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                  ),
                  onPressed: () => mostrarFormulario(),
                  child: const Text("Agregar"),
                ),
              ],
            ),
          ),

          // 🔹 LISTA
          Expanded(
            child: ListView(
              children: proveedores.map((p) {
                return _ItemProveedor(
                  proveedor: p,
                  onDelete: () => eliminar(p.idProveedor!),
                  onEdit: () => mostrarFormulario(proveedor: p),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// 🔸 CARD
class _CardInfo extends StatelessWidget {
  final String titulo;
  final String valor;

  const _CardInfo({required this.titulo, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Text(titulo),
              Text(valor, style: const TextStyle(fontSize: 20)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemProveedor extends StatelessWidget {
  final Proveedores proveedor;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _ItemProveedor({
    required this.proveedor,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(proveedor.nombre),
      subtitle: Text(
        (proveedor.telefono ?? "").isEmpty
            ? "Sin teléfono"
            : proveedor.telefono!,
          ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}