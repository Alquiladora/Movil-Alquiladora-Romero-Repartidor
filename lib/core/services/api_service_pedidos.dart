import 'package:dio/dio.dart';
import 'dart:developer';
import 'token_service.dart';
import '../utils/connection.dart';
import '../models/model_pedidos.dart';

class ApiServicePedidos {
  final Dio _dio;
  final TokenService _tokenService = TokenService();

  ApiServicePedidos()
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          
          connectTimeout: const Duration(seconds: 45),
          receiveTimeout: const Duration(seconds: 45),
        ));

  Future<List<Pedido>> getPedidosAsignados() async {
    try {
    
      final token = await _tokenService.getToken();
      if (token == null) {
        throw Exception('Usuario no autenticado.');
      }

      final response = await _dio.get(
        '/repartidor/repartidor/pedidos-hoy',
        
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        }),
      );
      print("final resultado de pedidos $response");
      
      if (response.statusCode == 200 && response.data != null) {
      
        final responseModel = PedidosAsignadosResponse.fromJson(response.data);
        return responseModel.pedidos;
      } else {
        throw Exception('Respuesta inesperada del servidor.');
      }
    } on DioException catch (e) {
      log('Error en getPedidosAsignados: ${e.response?.data ?? e.message}');
      throw Exception('Error de red: No se pudo conectar al servidor.');
    }
  }

Future<void> registrarPago(int pedidoId, Map<String, dynamic> paymentData) async {
    try {
      final token = await _tokenService.getToken();
      if (token == null) {
        throw Exception('Usuario no autenticado.');
      }
      final response = await _dio.post(
        '/pedidos/pagos/registrar-movil', 
        data: paymentData,
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        }),
      );
      print("reposnse de ´pagos registro $response");

      if (response.statusCode != 200 || (response.data != null && response.data['success'] == false)) {
        final serverMessage = response.data?['message'] ?? 'Error al registrar el pago.';
        throw Exception(serverMessage);
      }
      
     
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['message'] ?? e.message ?? 'Error de red al registrar pago.';
      log('Error en registrarPago: $serverMessage');
      throw Exception(serverMessage);
    }
  }

  
  Future<void> actualizarEstadoEspecial(int pedidoId, String nuevoEstado) async {
    print("Datos recbidos de actualizar especial estado $pedidoId $nuevoEstado");
    try {
      final token = await _tokenService.getToken();
      if (token == null) throw Exception('Usuario no autenticado.');

      final normalizedStatus = nuevoEstado.toLowerCase().replaceAll(' ', '-');
      
      final response = await _dio.put(
        '/repartidor/pedidos/$pedidoId/status-movil/$normalizedStatus',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Error al actualizar el estado a $nuevoEstado.');
      }
    } on DioException catch (e) {
      log('Error en actualizarEstadoEspecial: ${e.response?.data ?? e.message}');
      throw Exception('Error de red al actualizar estado.');
    }
  }


Future<void> actualizarEstadoGeneral(int pedidoId, String nuevoEstado) async {
  try{
    final token = await _tokenService.getToken();
    if (token == null) throw Exception('Usuario no autenticado.');
   final response = await _dio.put(
        '/repartidor/pedidos/$pedidoId/status-movil',
        data: {'estado_pedido': nuevoEstado}, 
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al actualizar el estado (general).');
      }
    } on DioException catch (e) {
      final serverMessage =
          e.response?.data?['message'] ?? e.message ?? 'Error de red.';
      log('Error en actualizarEstadoGeneral: $serverMessage');
      throw Exception(serverMessage);
    }
  }

Future<void> reportarIncidente(int pedidoId, Map<String, dynamic> payload) async{
 try {
      final token = await _tokenService.getToken();
      if (token == null) throw Exception('Usuario no autenticado.');
      final response = await _dio.post(
        '/repartidor/pedidos/$pedidoId/incidente-movil',
        data: payload,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al reportar incidente.');
      }
    } on DioException catch (e) {
      final serverMessage =
          e.response?.data?['message'] ?? e.message ?? 'Error de red.';
      log('Error en reportarIncidente: $serverMessage');
      throw Exception(serverMessage);
    }
  }


  Future<void> cancelarPedido(int pedidoId) async {
    try {
      final token = await _tokenService.getToken();
      if (token == null) throw Exception('Usuario no autenticado.');

      final response = await _dio.put(
        '/repartidor/pedidos-movil/$pedidoId',
        data: {'estadoActual': 'Cancelado'},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );
      if (response.statusCode != 200) {
        throw Exception('Error al cancelar el pedido.');
      }
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['message'] ?? e.message ?? 'Error de red al cancelar el pedido.';
    log('Error en cancelarPedido: $serverMessage');
    throw Exception(serverMessage);
    }
  }

 
}