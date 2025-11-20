import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/services/api_service_notificacion_semanal.dart';

class NotificacionScreen extends StatefulWidget {
  const NotificacionScreen({super.key});

  @override
  State<NotificacionScreen> createState() => _NotificacionScreenState();
}

class _NotificacionScreenState extends State<NotificacionScreen> {
  final ApiServiceNotificacionesSemana _service = ApiServiceNotificacionesSemana();

  List<dynamic> notificaciones = [];
  String semanaTexto = "Cargando...";
  bool loading = true;
  Map<String, dynamic> estadisticas = {};

  @override
  void initState() {
    super.initState();
    _cargarNotificaciones();
  }

  Future<void> _cargarNotificaciones() async {
    setState(() => loading = true);

    final result = await _service.getNotificacionesSemana();

    if (result['success']) {
      final data = result['data'];
      setState(() {
        notificaciones = data['notificaciones'] ?? [];
        semanaTexto = _formatearSemanaTexto(data['semana']);
        estadisticas = _calcularEstadisticas(notificaciones);
        loading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? "Error al cargar"),
          backgroundColor: const Color.fromARGB(255, 168, 159, 25),
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() => loading = false);
    }
  }

  String _formatearSemanaTexto(Map<String, dynamic> semana) {
    try {
      final desde = DateFormat('dd/MM').format(DateTime.parse(semana['desde']));
      final hasta = DateFormat('dd/MM').format(DateTime.parse(semana['hasta']));
      return '$desde - $hasta';
    } catch (e) {
      return "Esta Semana";
    }
  }

  Map<String, dynamic> _calcularEstadisticas(List<dynamic> notificaciones) {
    final completados = notificaciones.where((n) => n['estadoActual'] == 'En alquiler').length;
    final devueltos = notificaciones.where((n) => n['estadoActual'] == 'Devuelto').length;
    final incidencias = notificaciones.where((n) => n['estadoActual'] == 'Incompleto').length;
    final total = notificaciones.length;
    
    final rendimiento = total > 0 ? ((completados + devueltos) / total * 100).round() : 0;

    return {
      'completados': completados,
      'devueltos': devueltos,
      'incidencias': incidencias,
      'total': total,
      'rendimiento': rendimiento,
    };
  }

  // Determinar tipo de notificación por estadoActual
  ({IconData icon, Color color, String titulo, String subtitulo, Color bgColor}) _getNotificacionInfo(dynamic noti) {
    final estado = noti['estadoActual'] ?? '';

    switch (estado) {
      case 'Enviando':
      case 'Recogiendo':
        return (
          icon: Icons.local_shipping_rounded,
          color: const Color(0xFFFF9800),
          titulo: "Nuevo pedido asignado",
          subtitulo: "Prepárate para recoger el pedido",
          bgColor: const Color(0xFFFFF3E0)
        );
      case 'En alquiler':
        return (
          icon: Icons.check_circle_rounded,
          color: const Color(0xFF4CAF50),
          titulo: "Entrega realizada",
          subtitulo: "Cliente recibió el equipo",
          bgColor: const Color(0xFFE8F5E8)
        );
      case 'Devuelto':
        return (
          icon: Icons.assignment_return_rounded,
          color: const Color(0xFF2196F3),
          titulo: "Equipo devuelto",
          subtitulo: "Cliente devolvió el pedido",
          bgColor: const Color(0xFFE3F2FD)
        );
      case 'Incidente':
      case 'Incompleto':
        return (
          icon: Icons.warning_amber_rounded,
          color: const Color(0xFFF44336),
          titulo: "Incidente reportado",
          subtitulo: "Revisa el pedido inmediatamente",
          bgColor: const Color(0xFFFFEBEE)
        );
      default:
        return (
          icon: Icons.info_rounded,
          color: Colors.grey,
          titulo: "Actualización de pedido",
          subtitulo: "Estado: $estado",
          bgColor: const Color(0xFFF5F5F5)
        );
    }
  }

  String _getDayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final notificationDay = DateTime(date.year, date.month, date.day);

    if (notificationDay == today) return "Hoy";
    if (notificationDay == yesterday) return "Ayer";

    return DateFormat('EEE', 'es').format(date);
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM').format(date);
  }

  Widget _buildEstadisticasHeader() {
    final completados = estadisticas['completados'] ?? 0;
    final devueltos = estadisticas['devueltos'] ?? 0;
    final incidencias = estadisticas['incidencias'] ?? 0;
    final rendimiento = estadisticas['rendimiento'] ?? 0;

    return Container(
     
    
      decoration: BoxDecoration(
       
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.trending_up, color: Colors.blue[700], size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Rendimiento semanal",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "$rendimiento%",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: rendimiento >= 80 ? Colors.green[100] : 
                           rendimiento >= 60 ? Colors.orange[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    rendimiento >= 80 ? "Excelente" : 
                    rendimiento >= 60 ? "Bueno" : "Por mejorar",
                    style: TextStyle(
                      fontSize: 12,
                      color: rendimiento >= 80 ? Colors.green[800] : 
                             rendimiento >= 60 ? Colors.orange[800] : Colors.red[800],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, int value, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 6),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildNotificacionItem(dynamic noti, bool isSmallScreen) {
    final fecha = DateTime.parse(noti['fechaAsignacion']);
    final info = _getNotificacionInfo(noti);
    final idRastreo = noti['idRastreo']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: info.bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: info.color.withOpacity(0.2)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icono de estado
                Container(
                  width: isSmallScreen ? 40 : 44,
                  height: isSmallScreen ? 40 : 44,
                  decoration: BoxDecoration(
                    color: info.color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: info.color.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(info.icon, color: Colors.white, size: isSmallScreen ? 18 : 20),
                ),
                const SizedBox(width: 12),
                
                // Contenido
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header con ID y fecha
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              info.titulo,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 15 : 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _getDayLabel(fecha),
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 12 : 13,
                                  fontWeight: FontWeight.w600,
                                  color: info.color,
                                ),
                              ),
                              Text(
                                _formatDate(fecha),
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 10 : 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Subtítulo
                      Text(
                        info.subtitulo,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 13 : 14,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      
                      const SizedBox(height: 6),
                      
                      // Información del pedido
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.confirmation_number, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "Pedido #${noti['idPedido']}",
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 11 : 12,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.code, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              idRastreo.length > 8 ? '${idRastreo.substring(0, 8)}...' : idRastreo,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 10 : 11,
                                color: Colors.grey[600],
                                fontFamily: 'Monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Fechas de alquiler
                      if (noti['fechaInicio'] != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              "Alquiler: ${_formatDate(DateTime.parse(noti['fechaInicio']))} - ${_formatDate(DateTime.parse(noti['fechaEntrega']))}",
                              style: TextStyle(
                                fontSize: isSmallScreen ? 10 : 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(
              10, 
              MediaQuery.of(context).padding.top + 8, 
              10, 
              10
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color.fromARGB(255, 206, 156, 49)!, const Color.fromARGB(255, 209, 159, 51)!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.notifications_active, 
                          color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notificaciones',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 20 : 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            semanaTexto,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 13 : 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _cargarNotificaciones,
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.refresh_rounded, 
                            color: Colors.white, size: 22),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ESTADÍSTICAS
          if (estadisticas.isNotEmpty && estadisticas['total'] > 0) 
            _buildEstadisticasHeader(),

          // CONTADOR
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${notificaciones.length} notificaciones',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                if (!isSmallScreen)
                  Row(
                    children: [
                      Icon(Icons.swipe, size: 16, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        'Desliza para actualizar',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // LISTA DE NOTIFICACIONES
          Expanded(
            child: loading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: Colors.orange[600],
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Cargando notificaciones...",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : notificaciones.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.notifications_off, 
                                  size: 80, color: Colors.grey[300]),
                              const SizedBox(height: 20),
                              Text(
                                "No hay notificaciones",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Cuando tengas nuevos pedidos,\naparecerán aquí",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _cargarNotificaciones,
                        color: Colors.orange[600],
                        backgroundColor: Colors.white,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: notificaciones.length,
                          itemBuilder: (context, index) {
                            return _buildNotificacionItem(
                              notificaciones[index], 
                              isSmallScreen
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}