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
        telefono: int.tryParse(telefonoCtrl.text) 
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
              children: const [
                _CardInfo(titulo: "TOTAL", valor: "12"),
                _CardInfo(titulo: "CATEGORÍAS", valor: "5"),
                _CardInfo(titulo: "ACTIVOS", valor: "10"),
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
                  onPressed: guardar,
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
                  p.nombre,
                  p.telefono?.toString() ?? "Sin teléfono",
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

// 🔸 ITEM LISTA
class _ItemProveedor extends StatelessWidget {
  final String nombre;
  final String rfc;

  const _ItemProveedor(this.nombre, this.rfc);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(nombre),
      subtitle: Text("RFC: $rfc"),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.edit),
          SizedBox(width: 10),
          Icon(Icons.delete),
        ],
      ),
    );
  }
}