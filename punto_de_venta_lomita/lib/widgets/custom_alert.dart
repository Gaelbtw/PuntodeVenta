import 'package:flutter/material.dart';

class CustomAlert extends StatelessWidget {
  final String titulo;
  final String mensaje;
  final IconData icono;

  final String textoConfirmar;
  final String? textoCancelar;

  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const CustomAlert({
    super.key,
    required this.titulo,
    required this.mensaje,
    required this.icono,
    this.textoConfirmar = "Confirmar",
    this.textoCancelar,
    this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.yellow.shade100,
                  child: Icon(icono, color: Colors.amber, size: 40),
                ),
                const SizedBox(height: 16),

                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  mensaje,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // BOTÓN CANCELAR (solo si existe)
                if (textoCancelar != null) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        if (onCancel != null) onCancel!();
                      },
                      child: Text(textoCancelar!),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],

                // BOTÓN CONFIRMAR
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      if (onConfirm != null) onConfirm!();
                    },
                    child: Text(textoConfirmar),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}