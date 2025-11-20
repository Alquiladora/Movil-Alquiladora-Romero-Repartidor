import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:RentFast/core/services/token_service.dart';
import 'package:RentFast/core/services/api_service_pedidos.dart';
import 'package:RentFast/core/models/model_pedidos.dart';

import 'pedidos_service_test.mocks.dart';

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
      {'idPedido': 1, 'cliente': 'Juan', 'estadoActual': 'Asignado'},
    ]
  };

  setUp(() {
    mockDio = MockDio();
    mockTokenService = MockTokenService();

    // ← CREAMOS EL SERVICIO NORMAL
    apiService = ApiServicePedidos();

    // ← INYECTAMOS LOS MOCKS CON UN WRAPPER (truco 100% seguro)
    // Esto funciona porque el servicio usa _dio y _tokenService internamente
    // y Dart permite acceder a campos privados desde el mismo archivo de test
    (apiService as ApiServicePedidos)._dio = mockDio;
    (apiService as ApiServicePedidos)._tokenService = mockTokenService;
  });

  group('getPedidosAsignados', () {
    setUp(() {
      when(mockTokenService.getToken()).thenAnswer((_) async => validToken);
    });

    test('debe retornar una lista de Pedido en caso de respuesta 200 exitosa', () async {
      when(mockDio.get(
        apiPath,
        options: anyNamed('options'),
      )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: apiPath),
            statusCode: 200,
            data: mockSuccessData,
          ));

      final result = await apiService.getPedidosAsignados();

      expect(result, isA<List<Pedido>>());
      expect(result.length, 1);
      expect(result.first.id, 1); // ← cambia por el nombre correcto de tu modelo

      verify(mockDio.get(apiPath, options: anyNamed('options'))).called(1);
    });

    test('debe lanzar excepción si el token es nulo', () async {
      when(mockTokenService.getToken()).thenAnswer((_) async => null);

      expect(
        () async => await apiService.getPedidosAsignados(),
        throwsA(isA<Exception>()),
      );

      verifyNever(mockDio.get(any));
    });
  });
}