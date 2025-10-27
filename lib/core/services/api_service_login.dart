import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import '../utils/connection.dart'; 
import 'dart:io'; 
import 'token_service.dart';


class AuthService {
  final TokenService _tokenService = TokenService();

  //cREAMOS FUNCION
  Future<Map<String, String>> _getDeviceAndIpInfo() async {
    String deviceType = 'unknown';
    String ip = '0.0.0.0';

    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceType = 'Android: ${androidInfo.model}';
    } else if (Platform.isIOS) {
      final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceType = 'iOS: ${iosInfo.utsname.machine}';
    }
    try {
      final ipResponse = await http.get(Uri.parse('https://api.ipify.org'));
      if (ipResponse.statusCode == 200) {
        ip = ipResponse.body;
      }
    } catch (e) {
      print("No se pudo obtener la IP pública: $e");
      ip = 'ip_not_found';
    }

    return {'deviceType': deviceType, 'ip': ip};

  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    print("Iniciando petición de login para: $email, $password"); 

    try {
      final deviceAndIpInfo = await _getDeviceAndIpInfo();
         print("url deviceAndIpInfo: $deviceAndIpInfo");
      final deviceType = deviceAndIpInfo['deviceType']!;
       print("url deviceType: $deviceType");
      final ip = deviceAndIpInfo['ip']!;
        print("url ip: $ip");
      final url = Uri.parse('$baseUrl/api/usuarios/login-movil');

      print("url de login: $url");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'contrasena': password,
          'deviceType':deviceType,
          'ip': ip,
        }),
      );

      final responseData = json.decode(response.body);
      print("Respuesta del servidor: $responseData");

      if (response.statusCode == 200 && responseData.containsKey('token')) {
        await _tokenService.saveToken(responseData['token']);
        return {'success': true, 'token': responseData['token']};
      } else {
        return {'success': false, 'message': responseData['message'] ?? 'Error desconocido'};
      }
    } catch (e) {
      print("Error capturado en AuthService: ${e.toString()}");
      return {'success': false, 'message': 'No se pudo conectar al servidor.'};
    }
  }
  
}
