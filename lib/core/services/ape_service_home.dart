import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/connection.dart';
import 'token_service.dart';

class HomeService {
  final TokenService _tokenService = TokenService();

  Future<Map<String, dynamic>> getHome() async {
    final token = await _tokenService.getToken();
    final url = Uri.parse('$baseUrl/api/usuarios/movil-home');

    if (token == null) {
      return {
        'success': false,
        'message': 'Usuario no autenticado',
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

      print("📡 Respuesta del servidor (status): ${response.statusCode}");
      print("📄 Body recibido: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Validar estructura del JSON recibido
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
      } else {
        return {
          'success': false,
          'message':
              'Error del servidor (${response.statusCode}): ${response.body}',
        };
      }
    } catch (e) {
      print("❌ Error de conexión en HomeService: $e");
      return {
        'success': false,
        'message': 'No se pudo conectar al servidor.',
      };
    }
  }
}
