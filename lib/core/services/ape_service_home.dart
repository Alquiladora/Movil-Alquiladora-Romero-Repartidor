import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/connection.dart';
import 'token_service.dart';
import 'dart:developer';

class HomeService {
  final TokenService _tokenService = TokenService();

  Future<Map<String, dynamic>> getHome() async {
    final token = await _tokenService.getToken();
    final url = Uri.parse('$baseUrl/usuarios/movil-home');

    if (token == null) {
      return {
        'success': false,
        'message': 'AUTH_REQUIRED_401',
        'isAuthError': true,
      };
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

    

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

       
        if (data != null && data is Map<String, dynamic>) {
          return {
            'success': true,
            'data': data,
          };
        } else {
          return {
            'success': false,
            'message': 'Formato de respuesta inválido.',
          };
        }
     } else if (response.statusCode == 401) {
        await _tokenService.deleteToken();
        log('❌ SESIÓN CADUCADA (401) en HomeService. Token eliminado.');
        return {
          'success': false,
          'message': 'AUTH_REQUIRED_401',
          'isAuthError': true, 
        };
      } 
      else {
        
        return {
          'success': false,
          'message':
            'Error del servidor (${response.statusCode}): ${response.body}',
        };
      }
    } catch (e) {
      log("❌ Error de conexión en HomeService: $e");
      return {
        'success': false,
        'message': 'No se pudo conectar al servidor.',
      };
    }
  }
}