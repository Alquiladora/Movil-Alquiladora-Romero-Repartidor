import 'package:dio/dio.dart';
import 'dart:developer'; 
import 'token_service.dart'; 
import '../utils/connection.dart'; 

class ApiServicePerfil {
  final Dio _dio;
  final TokenService _tokenService = TokenService();
  

  static const String _repartidorStatsPath = '/repartidor/repartidor/estadistica-movil';
  static const String _repartidorStatDatos = '/repartidor/repartidor/estadisticas';
  static const String _userProfilePath = '/usuarios/perfil';

  ApiServicePerfil()
      : _dio = Dio(BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 45),
            receiveTimeout: const Duration(seconds: 45),
          ));

 
  void _setupInterceptors() {
    _dio.interceptors.clear(); 
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          log('REQUEST[${options.method}] => PATH: ${options.path}');
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          log('ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}');
          return handler.next(e);
        },
      ),
    );
  }

  Future<Map<String, dynamic>?> getRepartidorEstadisticas() async {
    _setupInterceptors();
    try {
      final response = await _dio.get(_repartidorStatsPath);
      
      if (response.statusCode == 200) {
         print("Datos obtenidos de perfil estadisticas $response.data");
        return response.data as Map<String, dynamic>;
       
      }
      return null;
    } on DioException catch (e) {
   
      log('Error al obtener estadísticas del repartidor: $e');
      return null;
    }
  }


Future<Map<String, dynamic>?> getRepartidorEstadisticasDatos() async {
    _setupInterceptors();
    try {
      final response = await _dio.get(_repartidorStatDatos);
      
      if (response.statusCode == 200) {
         print("Datos obtenidos de perfil estadisticas Datos $response.data");

        return response.data as Map<String, dynamic>;
      }
      return null;
    } on DioException catch (e) {
   
      log('Error al obtener datos del repartidor: $e');
      return null;
    }
  }

 
Future<Map<String, dynamic>?> getPerfilUsuario() async {
  _setupInterceptors();
  try {
    final response = await _dio.get(_userProfilePath);
    
    if (response.statusCode == 200) {
      print("Datos obtenidos de perfil ${response.data}");
      final responseData = response.data;
      if (responseData is Map<String, dynamic> && responseData.containsKey('user')) {
        print("Perfil de usuario extraído correctamente.");
        return responseData['user'] as Map<String, dynamic>; 
      }
      return null;
    }
    return null;
  } on DioException catch (e) {
    log('Error al obtener el perfil del usuario: $e');
    return null;
  }
}

}