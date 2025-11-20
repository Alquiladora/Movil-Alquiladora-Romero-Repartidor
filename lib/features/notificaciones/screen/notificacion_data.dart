// Definición del Modelo de Notificación
class NotificationItem {
  final String id;
  final String title;
  final String body;
  final DateTime date;
  final NotificationType type;
  bool isRead; // Estado de lectura

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    required this.type,
    this.isRead = false,
  });
}

enum NotificationType { urgent, assigned, completed }