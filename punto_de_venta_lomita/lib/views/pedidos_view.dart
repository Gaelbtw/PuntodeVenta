import 'package:flutter/material.dart';
import 'package:punto_de_venta_lomita/controllers/pedidos_controller.dart';
import 'package:punto_de_venta_lomita/models/pedidos_model.dart';
import 'detallePedido_view.dart';
import 'crearPedido_view.dart';

class PedidosView extends StatefulWidget {
  const PedidosView({super.key});

  @override
  State<PedidosView> createState() => _PedidosViewState();
}

class _PedidosViewState extends State<PedidosView> {

  final controller = PedidosController();
  List<Pedidos> pedidos = [];

  @override
  void initState() {
    super.initState();
    cargar();
  }

  void cargar() async {
    final data = await controller.obtenerTodos();
    setState(() {
      pedidos = data;
    });
  }

  void crearPedido() async {
  await controller.crearPedido(
    Pedidos(
      idCliente: 1, // 🔥 luego lo cambias dinámico
      fecha: DateTime.now().toString(),
      estado: "pendiente",
    ),
  );

  cargar();
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pedidos")),
      body: ListView.builder(
        itemCount: pedidos.length,
        itemBuilder: (context, index) {
          final p = pedidos[index];

          return Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 4)
            ],
            
          ),
          child: ListTile(
              title: Text("Pedido #${p.idPedido}"),
              subtitle: Text("Estado: ${p.estado}"),
              trailing: IconButton(
                icon: const Icon(Icons.visibility),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetallePedidoView(pedido: p),
                    ),
                  );
                },
                  // 👉 ver detalle
                
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
          context,
            MaterialPageRoute(
              builder: (_) => const CrearPedidoView(),
            ),
          ).then((_) => cargar());
        },
          // 👉 ir a crear pedido
        
        child: const Icon(Icons.add),
      ),
    );
  }
}