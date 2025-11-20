
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'api_service_notificacion.dart'; 
import 'dart:io';
import 'package:flutter/material.dart'; 
import '../utils/app_events.dart';



class NotificationService {
 
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final NotificationApiService _apiService = NotificationApiService();

  Future<void> initialize() async {
    
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
   
    if (Platform.isAndroid) {
    final androidImplementation = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission(); 
  }




    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', 
      'Notificaciones Importantes',
      description: 'Pedidos nuevos y alertas',
      importance: Importance.high,
      playSound: true,
    );

    final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(channel);

    // 3. Inicialización local notifications
    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'), 
        iOS: DarwinInitializationSettings(),
      ),
    );


    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
              color: const Color(0xFF00AA00),
            ),
            iOS: const DarwinNotificationDetails(),
          ),
        );
      }
       print("🔔 Notificación en primer plano: ${message.data}");
        if (message.data['tipo'] == 'nuevo_pedido') {
        final pedidoId = message.data['pedidoId'] ?? '';
        print("Nuevo pedido en primer plano → EventBus fire!");
        appEventBus.fire(NuevoPedidoEvent(pedidoId));
      }
    });

   
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notificación TOCADA: ${message.data}');

      if (message.data['tipo'] == 'nuevo_pedido') {
        final pedidoId = message.data['pedidoId'] ?? '';
        print("Notificación tocada → EventBus fire!");
        appEventBus.fire(NuevoPedidoEvent(pedidoId));
      }
    });
  }

  Future<void> registerToken() async {
    final token = await _messaging.getToken();
    if (token != null) {
      await _apiService.registerFcmToken(token);
    }
  }

  Future<void> logout() async {
    final localToken = await _apiService.getLocalFcmToken();
    if (localToken != null) {
      await _apiService.clearFcmToken(localToken);
    }
    await _messaging.deleteToken();
  }
}