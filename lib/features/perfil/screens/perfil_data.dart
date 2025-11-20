class PerfilData {
  final String nombreCompleto;
  final String email;
  final String telefono;
  final String fechaAlta;
  final double rendimientoMensual;
  final double rendimientoSemanal;
  final int pedidosPendientes;
  final int pedidosCompletados;
  final int clientesAtendidos;
  final String? fotoUrl;

  PerfilData({
    required this.nombreCompleto,
    required this.email,
    required this.telefono,
    required this.fechaAlta,
    required this.rendimientoMensual,
    required this.rendimientoSemanal,
    required this.pedidosPendientes,
    required this.pedidosCompletados,
    required this.clientesAtendidos,
    required this.fotoUrl,
  });

  
}