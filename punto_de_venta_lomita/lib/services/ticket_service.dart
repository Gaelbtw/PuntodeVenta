import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class TicketService {
  static Future<pw.Document> generarTicket({
    required List<Map<String, dynamic>> carrito,
    required double total,
    required String metodoPago,
    required double recibido,
    required double cambio
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80, // 👈 ticket térmico
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // 🏪 ENCABEZADO
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      "Tortilleria la Lomita",
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text("Direccion: Calle 25 Avenida 22"),
                    pw.Text("Telefono: 633"),
                    pw.SizedBox(height: 5),
                    pw.Text("Ticket de venta"),
                  ],
                ),
              ),

              pw.Divider(),

              // 📦 PRODUCTOS
              ...carrito.map((item) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        flex: 3,
                        child: pw.Text(item['nombre']),
                      ),
                      pw.Text("${item['cantidad']}"),
                      pw.Text("\$${item['precio']}"),
                    ],
                  ),
                );
              }),

              pw.Divider(),

              // 💳 MÉTODO DE PAGO
              pw.Text("Método de pago: $metodoPago"),

              pw.SizedBox(height: 5),

              // 💰 TOTAL GRANDE
              pw.Center(
                child: pw.Text(
                  "TOTAL: \$${total.toStringAsFixed(2)}",
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),

              pw.Text("Efectivo:  $recibido"),
              pw.Text("Cambio: $cambio"),

              pw.SizedBox(height: 20),

              // 🙏 MENSAJE FINAL
              pw.Center(
                child: pw.Text("¡Gracias por su compra!"),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }
}