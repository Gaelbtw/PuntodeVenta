import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../core/database/database_helper.dart';
import '../services/ticket_service.dart';
import '../services/ticket_compras_service.dart' as ticket_compras_service;
import '../widgets/nav_bar.dart';

class ReporteView extends StatefulWidget {
  const ReporteView({super.key});

  @override
  _ReporteViewState createState() => _ReporteViewState();
}

class _ReporteViewState extends State<ReporteView> {
  DateTime desde = DateTime.now().subtract(const Duration(days: 6));
  DateTime hasta = DateTime.now();
  bool cargando = false;

  int paginaSeleccionada = 0;

  int totalVentas = 0;
  double ingresosTotales = 0;
  List<Map<String, dynamic>> productosVendidos = [];
  List<Map<String, dynamic>> ventasRecientes = [];

  int totalCompras = 0;
  double gastoTotal = 0;
  List<Map<String, dynamic>> productosComprados = [];
  List<Map<String, dynamic>> comprasRecientes = [];

  String get rangoTexto {
    return '${_formatDate(desde)} - ${_formatDate(hasta)}';
  }

  String get tituloReporte {
    return paginaSeleccionada == 0 ? 'Reporte de Ventas' : 'Reporte de Compras';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  void initState() {
    super.initState();
    _cargarReportes();
  }

  Future<void> _cargarReportes() async {
    setState(() {
      cargando = true;
    });

    try {
      if (paginaSeleccionada == 0) {
        await _cargarReportesVentas();
      } else {
        await _cargarReportesCompras();
      }
    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }

  Future<void> _cargarReportesVentas() async {
    final db = await DatabaseHelper().database;
    final fechaInicio = desde.toIso8601String().substring(0, 10);
    final fechaFin = hasta.toIso8601String().substring(0, 10);

    final summary = await db.rawQuery(
      '''
      SELECT
        COUNT(*) as ventas,
        IFNULL(SUM(total), 0) as ingresos
      FROM Ventas
      WHERE date(fecha) BETWEEN date(?) AND date(?)
    ''',
      [fechaInicio, fechaFin],
    );

    final productos = await db.rawQuery(
      '''
      SELECT Producto.nombre, SUM(Detalle_Venta.cantidad) as total
      FROM Detalle_Venta
      INNER JOIN Ventas ON Ventas.id_venta = Detalle_Venta.id_venta
      INNER JOIN Producto ON Producto.id_producto = Detalle_Venta.id_producto
      WHERE date(Ventas.fecha) BETWEEN date(?) AND date(?)
      GROUP BY Producto.nombre
      ORDER BY total DESC
      LIMIT 10
    ''',
      [fechaInicio, fechaFin],
    );

    final ventas = await db.rawQuery(
      '''
      SELECT
        Ventas.id_venta,
        Ventas.fecha,
        Ventas.total,
        Ventas.metodo_pago,
        Clientes.nombre as cliente
      FROM Ventas
      LEFT JOIN Clientes ON Clientes.id_cliente = Ventas.id_cliente
      WHERE date(fecha) BETWEEN date(?) AND date(?)
      ORDER BY fecha DESC
      LIMIT 10
    ''',
      [fechaInicio, fechaFin],
    );

    if (!mounted) return;
    setState(() {
      totalVentas = summary.first['ventas'] as int? ?? 0;
      ingresosTotales = (summary.first['ingresos'] as num?)?.toDouble() ?? 0;
      productosVendidos = productos;
      ventasRecientes = ventas;
      productosComprados = [];
      comprasRecientes = [];
    });
  }

  Future<void> _cargarReportesCompras() async {
    final db = await DatabaseHelper().database;
    final fechaInicio = desde.toIso8601String().substring(0, 10);
    final fechaFin = hasta.toIso8601String().substring(0, 10);

    final summary = await db.rawQuery(
      '''
      SELECT
        COUNT(*) as compras,
        IFNULL(SUM(total), 0) as gasto
      FROM Compras
      WHERE date(fecha) BETWEEN date(?) AND date(?)
    ''',
      [fechaInicio, fechaFin],
    );

    final productos = await db.rawQuery(
      '''
      SELECT Producto.nombre, COUNT(Detalle_Compra.id_detalle) as total
      FROM Detalle_Compra
      INNER JOIN Compras ON Compras.id_compra = Detalle_Compra.id_compra
      INNER JOIN Producto ON Producto.id_producto = Detalle_Compra.id_producto
      WHERE date(Compras.fecha) BETWEEN date(?) AND date(?)
      GROUP BY Producto.nombre
      ORDER BY total DESC
      LIMIT 10
    ''',
      [fechaInicio, fechaFin],
    );

    final compras = await db.rawQuery(
      '''
      SELECT
        Compras.id_compra,
        Compras.fecha,
        Compras.total,
        Proveedores.nombre as proveedor
      FROM Compras
      LEFT JOIN Proveedores ON Proveedores.id_proveedor = Compras.id_proveedor
      WHERE date(Compras.fecha) BETWEEN date(?) AND date(?)
      ORDER BY Compras.fecha DESC
      LIMIT 10
    ''',
      [fechaInicio, fechaFin],
    );

    if (!mounted) return;
    setState(() {
      totalCompras = summary.first['compras'] as int? ?? 0;
      gastoTotal = (summary.first['gasto'] as num?)?.toDouble() ?? 0;
      productosComprados = productos;
      comprasRecientes = compras;
      productosVendidos = [];
      ventasRecientes = [];
    });
  }

  Future<void> _seleccionarRango(int diasAtras) async {
    final now = DateTime.now();
    setState(() {
      desde = now.subtract(Duration(days: diasAtras - 1));
      hasta = now;
    });
    await _cargarReportes();
  }

  Future<void> _seleccionarFechasPersonalizadas() async {
    final fechaInicio = await showDatePicker(
      context: context,
      initialDate: desde,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (fechaInicio == null) return;

    final fechaFin = await showDatePicker(
      context: context,
      initialDate: hasta,
      firstDate: fechaInicio,
      lastDate: DateTime.now(),
    );
    if (fechaFin == null) return;

    setState(() {
      desde = fechaInicio;
      hasta = fechaFin;
    });
    await _cargarReportes();
  }

  Future<void> _mostrarRecibo(
    int idVenta,
    String metodoPago,
    double total,
    String cliente,
    String fecha,
  ) async {
    final db = await DatabaseHelper().database;
    final detalles = await db.rawQuery(
      '''
      SELECT Producto.nombre, Detalle_Venta.cantidad, Detalle_Venta.precio
      FROM Detalle_Venta
      INNER JOIN Producto ON Producto.id_producto = Detalle_Venta.id_producto
      WHERE Detalle_Venta.id_venta = ?
    ''',
      [idVenta],
    );

    final carrito = detalles.map((item) {
      return {
        'id_producto': null,
        'nombre': item['nombre'],
        'precio': item['precio'],
        'cantidad': item['cantidad'],
      };
    }).toList();

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Recibo de venta #$idVenta'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cliente: ${cliente.isNotEmpty ? cliente : 'Consumidor final'}',
                ),
                Text('Fecha: ${_formatDate(DateTime.parse(fecha))}'),
                Text('Método: $metodoPago'),
                const SizedBox(height: 12),
                const Text('Productos:'),
                const SizedBox(height: 8),
                ...carrito.map((item) {
                  return Text(
                    '${item['cantidad']} x ${item['nombre']} - \$${(item['precio'] as num).toStringAsFixed(2)}',
                  );
                }),
                const SizedBox(height: 12),
                Text('Total: \$${total.toStringAsFixed(2)}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
            TextButton(
              onPressed: () async {
                final pdf = await TicketService.generarTicket(
                  carrito: carrito,
                  total: total,
                  metodoPago: metodoPago,
                  recibido: total,
                  cambio: 0,
                );
                await Printing.layoutPdf(
                  onLayout: (PdfPageFormat format) async => pdf.save(),
                );
              },
              child: const Text('Imprimir'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _mostrarReciboCompra(
    int idCompra,
    String proveedor,
    double total,
    String fecha,
  ) async {
    final db = await DatabaseHelper().database;
    final detalles = await db.rawQuery(
      '''
      SELECT Producto.nombre, Detalle_Compra.cantidad, Detalle_Compra.precio
      FROM Detalle_Compra
      INNER JOIN Producto ON Producto.id_producto = Detalle_Compra.id_producto
      WHERE Detalle_Compra.id_compra = ?
    ''',
      [idCompra],
    );

    final carrito = detalles.map((item) {
      return {
        'nombre': item['nombre'],
        'cantidad': item['cantidad'],
        'precio_compra': item['precio'],
      };
    }).toList();

    try {
      if (carrito.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se encontraron productos para esta compra.'),
            ),
          );
        }
        return;
      }

      final pdf = await ticket_compras_service.TicketService.generarTicket(
        carrito: carrito,
        total: total,
        proveedor: proveedor,
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al abrir el ticket de compra: $e')),
        );
      }
    }
  }

  Widget _buildSummaryCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomHeader(titulo: tituloReporte, mostrarVolver: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: cargando
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => _seleccionarRango(7),
                        child: const Text('Última semana'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _seleccionarRango(30),
                        child: const Text('Último mes'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: _seleccionarFechasPersonalizadas,
                        child: const Text('Rango personalizado'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Rango: $rangoTexto',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Ventas'),
                        selected: paginaSeleccionada == 0,
                        onSelected: (_) async {
                          setState(() => paginaSeleccionada = 0);
                          await _cargarReportes();
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Compras'),
                        selected: paginaSeleccionada == 1,
                        onSelected: (_) async {
                          setState(() => paginaSeleccionada = 1);
                          await _cargarReportes();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (paginaSeleccionada == 0)
                        _buildSummaryCard(
                          'Ventas',
                          '$totalVentas',
                          const Color(0xFFF2C500),
                        )
                      else
                        _buildSummaryCard(
                          'Compras',
                          '$totalCompras',
                          const Color(0xFFF2C500),
                        ),
                      const SizedBox(width: 12),
                      if (paginaSeleccionada == 0)
                        _buildSummaryCard(
                          'Ingresos',
                          '\$${ingresosTotales.toStringAsFixed(2)}',
                          const Color(0xFFD9A600),
                        )
                      else
                        _buildSummaryCard(
                          'Gasto',
                          '\$${gastoTotal.toStringAsFixed(2)}',
                          const Color(0xFFD9A600),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    paginaSeleccionada == 0
                        ? 'Productos más vendidos'
                        : 'Productos más comprados',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if ((paginaSeleccionada == 0
                          ? productosVendidos
                          : productosComprados)
                      .isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        paginaSeleccionada == 0
                            ? 'No hay ventas en el rango seleccionado.'
                            : 'No hay compras en el rango seleccionado.',
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        separatorBuilder: (_, _) => const Divider(),
                        itemCount:
                            (paginaSeleccionada == 0
                                    ? productosVendidos
                                    : productosComprados)
                                .length,
                        itemBuilder: (_, index) {
                          final item = (paginaSeleccionada == 0
                              ? productosVendidos
                              : productosComprados)[index];
                          return ListTile(
                            title: Text(item['nombre'] ?? ''),
                            trailing: Text('${item['total']} uds'),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    paginaSeleccionada == 0
                        ? 'Ventas recientes'
                        : 'Compras recientes',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child:
                        (paginaSeleccionada == 0
                                ? ventasRecientes
                                : comprasRecientes)
                            .isEmpty
                        ? Center(
                            child: Text(
                              paginaSeleccionada == 0
                                  ? 'No hay ventas recientes para este rango.'
                                  : 'No hay compras recientes para este rango.',
                            ),
                          )
                        : ListView.separated(
                            separatorBuilder: (_, _) => const Divider(),
                            itemCount:
                                (paginaSeleccionada == 0
                                        ? ventasRecientes
                                        : comprasRecientes)
                                    .length,
                            itemBuilder: (_, index) {
                              if (paginaSeleccionada == 0) {
                                final venta = ventasRecientes[index];
                                final fecha =
                                    DateTime.tryParse(venta['fecha'] ?? '') ??
                                    DateTime.now();
                                return ListTile(
                                  title: Text(
                                    'Venta #${venta['id_venta']} - \$${(venta['total'] as num).toStringAsFixed(2)}',
                                  ),
                                  subtitle: Text(
                                    'Fecha: ${_formatDate(fecha)} · Cliente: ${venta['cliente'] ?? 'Final'} · Pago: ${venta['metodo_pago'] ?? 'efectivo'}',
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.receipt_long),
                                    onPressed: () => _mostrarRecibo(
                                      venta['id_venta'] as int,
                                      venta['metodo_pago'] as String? ??
                                          'efectivo',
                                      (venta['total'] as num).toDouble(),
                                      venta['cliente'] as String? ?? '',
                                      venta['fecha'] as String? ?? '',
                                    ),
                                  ),
                                );
                              }

                              final compra = comprasRecientes[index];
                              final fecha =
                                  DateTime.tryParse(compra['fecha'] ?? '') ??
                                  DateTime.now();
                              return ListTile(
                                title: Text(
                                  'Compra #${compra['id_compra']} - \$${(compra['total'] as num).toStringAsFixed(2)}',
                                ),
                                subtitle: Text(
                                  'Fecha: ${_formatDate(fecha)} · Proveedor: ${compra['proveedor'] ?? 'Sin proveedor'}',
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
