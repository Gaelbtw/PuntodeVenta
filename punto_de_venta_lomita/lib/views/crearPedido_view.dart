import 'package:flutter/material.dart';
import '../controllers/pedidos_controller.dart';
import '../models/pedidos_model.dart';

class CrearPedidoView extends StatefulWidget {
  const CrearPedidoView({super.key});

  @override
  State<CrearPedidoView> createState() => _CrearPedidoViewState();
}

class _CrearPedidoViewState extends State<CrearPedidoView> {

  final controller = PedidosController();

  final clienteCtrl = TextEditingController();
  final descripcionCtrl = TextEditingController();

  String tipo = "local";
  String metodoPago = "efectivo";

  void guardar() async {

    if (clienteCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cliente requerido")),
      );
      return;
    }

    final pedido = Pedidos(
      idCliente: int.tryParse(clienteCtrl.text) ?? 1,
      fecha: DateTime.now().toString(),
      estado: "pendiente",
    );

    await controller.crearPedido(pedido);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nuevo Pedido")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller: clienteCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "ID Cliente",
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: descripcionCtrl,
              decoration: const InputDecoration(
                labelText: "Descripción",
              ),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              initialValue: tipo,
              items: ["local", "domicilio"]
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => tipo = v!),
              decoration: const InputDecoration(labelText: "Tipo"),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              initialValue: metodoPago,
              items: ["efectivo", "tarjeta"]
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => metodoPago = v!),
              decoration: const InputDecoration(labelText: "Pago"),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: guardar,
                child: const Text("Guardar Pedido"),
              ),
            )
          ],
        ),
      ),
    );
  }
}