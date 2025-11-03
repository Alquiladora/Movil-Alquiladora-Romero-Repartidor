import 'dart:convert';
import 'package:http/http.dart' as http;

import '../utils/connection.dart';  // api('/api/...') y baseUrl
import 'token_service.dart';

class HistoryService {
  final TokenService _tokenService = TokenService();

  Future<List<Map<String, dynamic>>> fetchHistory() async {
    final token = await _tokenService.getToken();
    if (token == null) {
      throw Exception('Usuario no autenticado');
    }

    // Si tu backend usa el prefijo /api (que sí), mantenlo:
    final url = api('/api/repartidor/repartidor/pedidos-historico');

    final resp = await http
        .get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 25));

    if (resp.statusCode == 200) {
      final body = json.decode(resp.body) as Map<String, dynamic>;
      final List list = body['pedidos'] as List? ?? [];
      return list.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }
  }
}
