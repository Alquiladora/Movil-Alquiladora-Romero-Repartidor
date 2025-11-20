
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import '../../../../';
import 'package:tu_proyecto/services/token_service.dart';
import 'package:tu_proyecto/models/model_pedidos.dart'; 

import 'api_service_pedidos_test.mocks.dart'; 



@GenerateMocks([Dio, TokenService])
void main() {

  late ApiServicePedidos apiService;
  late MockDio mockDio;
  late MockTokenService mockTokenService;


  const validToken = 'FAKE_JWT_TOKEN';
  const apiPath = '/repartidor/repartidor/pedidos-hoy';

  final mockSuccessData = {
    'success': true,
    'pedidos': [
      {'id': 1, 'cliente': 'Juan', 'estado': 'Asignado'},
    ]
  };

  // 2. SETUP: Se ejecuta antes de CADA prueba para asegurar un estado limpio
  setUp(() {
    mockDio = MockDio();
    mockTokenService = MockTokenService();
    
    // INYECTAMOS los objetos falsos en el servicio que vamos a probar
    apiService = ApiServicePedidos(dio: mockDio, tokenService: mockTokenService);
  });

  // =========================================================================
  // PRUEBAS PARA getPedidosAsignados
  // =========================================================================
  group('getPedidosAsignados', () {
    
    // CONFIGURACIÓN BASE: El token siempre debe ser válido para esta prueba
    setUp(() {
      when(mockTokenService.getToken()).thenAnswer((_) async => validToken);
    });

    test('debe retornar una lista de Pedido en caso de respuesta 200 exitosa', () async {
      // ARRANGE (Preparar): Simular la respuesta HTTP exitosa
      when(mockDio.get(
        apiPath,
        options: anyNamed('options'), // Captura cualquier opción, incluyendo headers
      )).thenAnswer((_) async => Response(
        requestOptions: RequestOptions(path: apiPath),
        statusCode: 200,
        data: mockSuccessData,
      ));

      // ACT (Actuar): Llamar al método
      final result = await apiService.getPedidosAsignados();

      // ASSERT (Verificar): Comprobar el resultado
      expect(result, isA<List<Pedido>>());
      expect(result.length, 1);
      expect(result.first.id, 1);
      
      // Verificar que el método Dio.get fue llamado
      verify(mockDio.get(apiPath, options: anyNamed('options'))).called(1); 
    });

    test('debe lanzar excepción si el token es nulo (no autenticado)', () async {
      // ARRANGE: Simular que el TokenService devuelve null
      when(mockTokenService.getToken()).thenAnswer((_) async => null);

      // ACT & ASSERT: Esperar una excepción
      expect(
        () async => await apiService.getPedidosAsignados(), 
        throwsA(predicate((e) => e is Exception && e.toString().contains('no autenticado'))),
      );
      
      // Verificar que Dio.get NO fue llamado
      verifyNever(mockDio.get(any)); 
    });

    test('debe lanzar excepción si Dio retorna un error 500', () async {
      // ARRANGE: Simular un error del servidor (DioException)
      when(mockDio.get(
        apiPath,
        options: anyNamed('options'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: apiPath),
        response: Response(statusCode: 500, requestOptions: RequestOptions(path: apiPath)),
        type: DioExceptionType.badResponse,
      ));

      // ACT & ASSERT: Esperar una excepción de red
      expect(
        () async => await apiService.getPedidosAsignados(), 
        throwsA(predicate((e) => e is Exception && e.toString().contains('Error de red'))),
      );
    });
  });
  
  // =========================================================================
  // PRUEBAS PARA registrarPago (Sección POST)
  // =========================================================================
  group('registrarPago', () {
    const validToken = 'FAKE_JWT_TOKEN';
    const pedidoId = 10;
    const paymentData = {'monto': 100.0, 'metodo': 'Efectivo'};

    setUp(() {
      when(mockTokenService.getToken()).thenAnswer((_) async => validToken);
    });

    test('debe completar sin errores si el servidor retorna 200 y success: true', () async {
      // ARRANGE: Simular la respuesta 200 OK con éxito en el body
      when(mockDio.post(
        '/pedidos/pagos/registrar-movil',
        data: anyNamed('data'),
        options: anyNamed('options'),
      )).thenAnswer((_) async => Response(
        requestOptions: RequestOptions(path: '/pedidos/pagos/registrar-movil'),
        statusCode: 200,
        data: {'success': true, 'message': 'Pago registrado'},
      ));

      // ACT & ASSERT: El método debe completarse sin errores
      expect(apiService.registrarPago(pedidoId, paymentData), completes);
    });

    test('debe lanzar excepción si el servidor retorna success: false', () async {
      // ARRANGE: Simular respuesta donde success es falso (Error de lógica de negocio)
      when(mockDio.post(
        '/pedidos/pagos/registrar-movil',
        data: anyNamed('data'),
        options: anyNamed('options'),
      )).thenAnswer((_) async => Response(
        requestOptions: RequestOptions(path: '/pedidos/pagos/registrar-movil'),
        statusCode: 200,
        data: {'success': false, 'message': 'Fondos insuficientes'},
      ));

      // ACT & ASSERT: Esperar la excepción con el mensaje del servidor
      expect(
        () async => await apiService.registrarPago(pedidoId, paymentData), 
        throwsA(predicate((e) => e is Exception && e.toString().contains('Fondos insuficientes'))),
      );
    });
  });
  
  // Agrega más grupos de pruebas para actualizarEstadoEspecial, reportarIncidente, etc.
}