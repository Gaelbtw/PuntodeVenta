class Configuracion {
  final String horaInicioMatutino;
  final String horaFinMatutino;
  final String horaInicioVespertino;
  final String horaFinVespertino;
  final int stockMinimo;
  final double fondoCaja;

  Configuracion({
    required this.horaInicioMatutino,
    required this.horaFinMatutino,
    required this.horaInicioVespertino,
    required this.horaFinVespertino,
    required this.stockMinimo,
    required this.fondoCaja,
  });
}
