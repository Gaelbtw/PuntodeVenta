import 'package:flutter/material.dart';
import '../controllers/usuarios_controller.dart';
import '../models/usuarios_model.dart';
import '../widgets/nav_bar.dart';

class UsuariosView extends StatefulWidget {
  const UsuariosView({super.key});

  @override
  State<UsuariosView> createState() => _UsuariosViewState();
}

class _UsuariosViewState extends State<UsuariosView> {
  final usuariosController = UsuariosController();

  List<Usuarios> usuarios = [];

  String busqueda = "";

  @override
  void initState() {
    super.initState();
    cargarTodo();
  }

  void cargarTodo() async {
    final usr = await usuariosController.obtenerTodos();

    setState(() {
      usuarios = usr;
    });
  }

  // 🔥 FILTRO
  List<Usuarios> get filtrados {
    return usuarios.where((u) {
      return u.nombre.toLowerCase().contains(busqueda.toLowerCase());
    }).toList();
  }

  // 🔥 FORMULARIO
  void mostrarFormularioUsuario({Usuarios? usuario}) {
    final nombreCtrl = TextEditingController(text: usuario?.nombre ?? "");

    final contraCtrl = TextEditingController(text: usuario?.contra ?? "");

    String rolSeleccionado = usuario?.rol ?? "Cajero";

    showDialog(
      context: context,

      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          return Dialog(
            backgroundColor: Colors.transparent,

            child: Container(
              width: 560,

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
                          width: 58,
                          height: 58,

                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1BF),

                            borderRadius: BorderRadius.circular(18),
                          ),

                          child: const Icon(
                            Icons.people_alt_outlined,

                            color: Color(0xFFB88300),

                            size: 28,
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Text(
                                usuario == null
                                    ? "Nuevo Usuario"
                                    : "Editar Usuario",

                                style: const TextStyle(
                                  fontSize: 26,

                                  fontWeight: FontWeight.w800,

                                  color: Color(0xFF2D2B28),
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                usuario == null
                                    ? "Agregue un nuevo usuario al sistema"
                                    : "Actualice la información del usuario",

                                style: const TextStyle(
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

                    // 🔥 FORM
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,

                      children: [
                        SizedBox(
                          width: 496,

                          child: _inputFormulario(
                            controller: nombreCtrl,

                            label: "Nombre de usuario",

                            icon: Icons.person_outline,
                          ),
                        ),

                        SizedBox(
                          width: 496,

                          child: _inputFormulario(
                            controller: contraCtrl,

                            label: "Contraseña",

                            icon: Icons.lock_outline,

                            obscure: true,
                          ),
                        ),

                        SizedBox(
                          width: 496,

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 4, bottom: 8),

                                child: Text(
                                  "Rol",

                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,

                                    color: Color(0xFF3C3935),

                                    fontSize: 13,
                                  ),
                                ),
                              ),

                              DropdownButtonFormField<String>(
                                initialValue: rolSeleccionado,

                                decoration: InputDecoration(
                                  prefixIcon: const Icon(
                                    Icons.admin_panel_settings_outlined,

                                    color: Color(0xFFCC9600),
                                  ),

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

                                    borderSide: const BorderSide(
                                      color: Color(0xFFE7E1D8),
                                    ),
                                  ),

                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),

                                    borderSide: const BorderSide(
                                      color: Color(0xFFF2C500),
                                      width: 1.5,
                                    ),
                                  ),
                                ),

                                items: ["Admin", "Cajero"]
                                    .map(
                                      (r) => DropdownMenuItem(
                                        value: r,

                                        child: Text(r),
                                      ),
                                    )
                                    .toList(),

                                onChanged: (value) {
                                  if (value == null) {
                                    return;
                                  }

                                  setModalState(() {
                                    rolSeleccionado = value;
                                  });
                                },
                              ),
                            ],
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
                                contraCtrl.text.isEmpty) {
                              return;
                            }

                            final nuevo = Usuarios(
                              idUsuario: usuario?.idUsuario,

                              nombre: nombreCtrl.text,

                              contra: contraCtrl.text,

                              rol: rolSeleccionado,
                            );

                            if (usuario == null) {
                              await usuariosController.insertar(nuevo);
                            } else {
                              await usuariosController.actualizar(nuevo);
                            }

                            Navigator.pop(context);

                            cargarTodo();

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  usuario == null
                                      ? "Usuario agregado"
                                      : "Usuario actualizado",
                                ),
                              ),
                            );
                          },

                          icon: const Icon(Icons.save_outlined),

                          label: Text(
                            usuario == null
                                ? "Guardar Usuario"
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
          );
        },
      ),
    );
  }

  // 🔥 ELIMINAR
  void confirmarEliminar(Usuarios u) {
    showDialog(
      context: context,

      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,

        child: Container(
          width: 420,

          padding: const EdgeInsets.all(28),

          decoration: BoxDecoration(
            color: const Color(0xFFFAF8F4),

            borderRadius: BorderRadius.circular(30),
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              Container(
                width: 70,
                height: 70,

                decoration: BoxDecoration(
                  color: const Color(0xFFFFE5E5),

                  borderRadius: BorderRadius.circular(22),
                ),

                child: Icon(
                  Icons.delete_outline,
                  color: Colors.red.shade700,
                  size: 34,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Eliminar Usuario",

                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),

              const SizedBox(height: 10),

              Text(
                "¿Desea eliminar a ${u.nombre}?",

                textAlign: TextAlign.center,

                style: const TextStyle(color: Color(0xFF6E6A64)),
              ),

              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),

                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),

                        side: const BorderSide(color: Color(0xFFE7E1D8)),
                      ),

                      child: const Text("Cancelar"),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await usuariosController.eliminar(u.idUsuario!);

                        Navigator.pop(context);

                        cargarTodo();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Usuario eliminado")),
                        );
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFE5E5),

                        foregroundColor: Colors.red,

                        elevation: 0,

                        padding: const EdgeInsets.symmetric(vertical: 16),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),

                      child: const Text("Eliminar"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F4),

      appBar: CustomHeader(titulo: "Usuarios", mostrarVolver: true),

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
                          "Gestión de Usuarios",

                          style: TextStyle(
                            fontSize: 28,

                            fontWeight: FontWeight.w800,

                            color: Color(0xFF2D2B28),
                          ),
                        ),

                        SizedBox(height: 8),

                        Text(
                          "Administre usuarios y permisos del sistema",

                          style: TextStyle(
                            color: Color(0xFF6E6A64),

                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  ElevatedButton.icon(
                    onPressed: () => mostrarFormularioUsuario(),

                    icon: const Icon(Icons.person_add),

                    label: const Text("Nuevo Usuario"),

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
                  onChanged: (v) => setState(() => busqueda = v),

                  decoration: InputDecoration(
                    hintText: "Buscar usuario...",

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
                    ? const Center(child: Text("No hay usuarios registrados"))
                    : ListView.separated(
                        itemCount: filtrados.length,

                        separatorBuilder: (_, _) => const Divider(height: 1),

                        itemBuilder: (_, i) {
                          final u = filtrados[i];

                          return _filaUsuario(u);
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),

      child: const Row(
        children: [
          Expanded(
            flex: 4,

            child: Text(
              "USUARIO",

              style: TextStyle(
                fontWeight: FontWeight.w800,

                color: Color(0xFF3C3935),

                fontSize: 12,
              ),
            ),
          ),

          Expanded(
            flex: 3,

            child: Text(
              "ROL",

              style: TextStyle(
                fontWeight: FontWeight.w800,

                color: Color(0xFF3C3935),

                fontSize: 12,
              ),
            ),
          ),

          Expanded(
            flex: 3,

            child: Text(
              "ACCIONES",

              style: TextStyle(
                fontWeight: FontWeight.w800,

                color: Color(0xFF3C3935),

                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 FILA
  Widget _filaUsuario(Usuarios u) {
    final esAdmin = u.rol == "Admin";

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),

      child: Row(
        children: [
          Expanded(
            flex: 4,

            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,

                  decoration: BoxDecoration(
                    color: esAdmin
                        ? const Color(0xFFFFF1BF)
                        : const Color(0xFFEAEAEA),

                    borderRadius: BorderRadius.circular(14),
                  ),

                  child: Center(
                    child: Text(
                      u.nombre.substring(0, 1).toUpperCase(),

                      style: TextStyle(
                        fontWeight: FontWeight.w800,

                        fontSize: 18,

                        color: esAdmin
                            ? const Color(0xFFB88300)
                            : Colors.black87,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                Text(
                  u.nombre,

                  style: const TextStyle(
                    fontWeight: FontWeight.w700,

                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            flex: 3,

            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),

              decoration: BoxDecoration(
                color: esAdmin
                    ? const Color(0xFFFFF4CC)
                    : const Color(0xFFF3F3F3),

                borderRadius: BorderRadius.circular(14),
              ),

              child: Text(
                u.rol,

                textAlign: TextAlign.center,

                style: TextStyle(
                  fontWeight: FontWeight.w700,

                  color: esAdmin ? const Color(0xFF9B6A00) : Colors.black87,
                ),
              ),
            ),
          ),

          Expanded(
            flex: 3,

            child: Row(
              children: [
                IconButton(
                  onPressed: () => mostrarFormularioUsuario(usuario: u),

                  icon: const Icon(Icons.edit_outlined),

                  color: Colors.orange.shade800,
                ),

                IconButton(
                  onPressed: () => confirmarEliminar(u),

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

    bool obscure = false,
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

          obscureText: obscure,

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
