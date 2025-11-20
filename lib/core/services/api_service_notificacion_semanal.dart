import 'package:dio/dio.dart';
import '../utils/connection.dart'; 
import 'token_service.dart';       

class ApiServiceNotificacionesSemana {
  final Dio _dio;
  final TokenService _tokenService = TokenService();

  ApiServiceNotificacionesSemana()
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        )) {
    
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          return handler.next(e);
        },
      ),
    );
  }

  Future<Map<String, dynamic>> getNotificacionesSemana() async {
    try {
      final response = await _dio.get('/usuarios/notificaciones/semana-actual');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Error del servidor: ${response.statusCode}',
        };
      }
    } on DioException catch (e) {
      String errorMsg = 'Error de conexión';
      if (e.response != null) {
        errorMsg = e.response?.data['message'] ?? 'Error del servidor';
      } else if (e.message != null) {
        errorMsg = e.message!;
      }
      return {
        'success': false,
        'message': errorMsg,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error inesperado: $e',
      };
    }
  }
}