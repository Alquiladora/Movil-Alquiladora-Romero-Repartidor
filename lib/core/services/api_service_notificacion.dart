import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'token_service.dart';
import '../utils/connection.dart'; 

class NotificationApiService {
  final Dio _dio;
  final TokenService _tokenService = TokenService();

  static const String _registerTokenPath = '/usuarios/register-fcm-token';
  static const String _clearTokenPath = '/usuarios/clear-fcm-token';

  NotificationApiService()
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl, 
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          contentType: 'application/json',
          responseType: ResponseType.json,
        ));


  void _setupInterceptors() {
    _dio.interceptors.clear();
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          log('🔵 NOTIF REQUEST[${options.method}] => ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          log('🟢 NOTIF RESPONSE[${response.statusCode}] => ${response.realUri}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          log('🔴 NOTIF ERROR[${e.response?.statusCode ?? 'No response'}] => ${e.requestOptions.path} | Message: ${e.message}');
          return handler.next(e);
        },
      ),
    );
  }


  Future<bool> registerFcmToken(String fcmToken) async {
    _setupInterceptors();

    try {
      final response = await _dio.post(
        _registerTokenPath,
        data: {'fcmToken': fcmToken},
      );

      if (response.statusCode == 200) {
        log('✅ Token FCM registrado/actualizado correctamente en el servidor');
        await _saveLocalToken(fcmToken);
        return true;
      } else {
        log('⚠️ Respuesta inesperada al registrar token: ${response.statusCode}');
        return false;
      }
    } on DioException catch (e) {
      log('❌ Error Dio al registrar FCM token: $e');
      if (e.response != null) {
        log('Datos del error: ${e.response?.data}');
      }
      return false;
    } catch (e) {
      log('🔥 Excepción inesperada registerFcmToken: $e');
      return false;
    }
  }

  /// Desvincular el token del usuario (al hacer logout)
  Future<bool> clearFcmToken(String fcmToken) async {
    _setupInterceptors();

    try {
      final response = await _dio.post(
        _clearTokenPath,
        data: {'fcmToken': fcmToken},
      );

      if (response.statusCode == 200) {
        log('✅ Token FCM desvinculado correctamente del servidor');
        await _removeLocalToken();
        return true;
      } else {
        log('⚠️ Respuesta inesperada al desvincular token: ${response.statusCode}');
        return false;
      }
    } on DioException catch (e) {
      log('❌ Error Dio al desvincular FCM token: $e');
      return false;
    } catch (e) {
      log('🔥 Excepción clearFcmToken: $e');
      return false;
    }
  }

Future<void> _saveLocalToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_fcm_token', token);
  }

  Future<String?> getLocalFcmToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('current_fcm_token');
  }

  Future<void> _removeLocalToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_fcm_token');
  }
}