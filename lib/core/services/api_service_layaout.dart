import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/connection.dart'; 
import 'dart:io';
import 'token_service.dart'; 


class LayaoutService{
  final TokenService _tokenService= TokenService();

  Future<Map<String,dynamic>> getFoto() async{
   
    final token = await _tokenService.getToken();
     print("Datos obtenidos de token 1 $token ");
    final url = Uri.parse('$baseUrl/usuarios/perfil-simple');

     if (token == null) {
      return {'success': false, 'message': 'Usuario no autenticado.'};
    }
    print("Datos obtenidos de token $token ");
    try
    {
    final response = await http.get(
      url,
      headers: {
         'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
      },
    );

     print("Datos obtenidos DE RESPONSE  $response ");
  
     if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('user') && data['user'].containsKey('fotoPerfil')) {
          final user = data['user'];
          return {
            'success': true,
            'nombre': user['nombre'],
            'fotoPerfilUrl': user['fotoPerfil']
          };
        } else {
          return {'success': false, 'message': 'Datos de usuario no encontrados en la respuesta.'};
        }
      } else {
        print("Error del servidor (Perfil): ${response.body}");
        return {'success': false, 'message': 'Error al obtener los datos del perfil.'};
      }
    } catch (e) {
      print("Error de conexión en LayoutService: ${e.toString()}");
      return {'success': false, 'message': 'No se pudo conectar al servidor.'};
    }
  }
}
