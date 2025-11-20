import 'dart:async';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'perfil_event.dart'; 
import 'perfil_state.dart';
import '../../../core/services/api_service_perfil.dart'; 

class PerfilBloc extends Bloc<PerfilEvent, PerfilState> {
  final ApiServicePerfil _apiService;

  PerfilBloc(this._apiService) : super(PerfilInitial()) {
    on<FetchPerfilData>(_onFetchPerfilData);
  }

  Future<void> _onFetchPerfilData(
    FetchPerfilData event,
    Emitter<PerfilState> emit,
  ) async {
    emit(PerfilLoading());

    try {
      final results = await Future.wait([
        _apiService.getPerfilUsuario(),
        _apiService.getRepartidorEstadisticas(),
        _apiService.getRepartidorEstadisticasDatos(),
      ]);

      final Map<String, dynamic>? perfilUsuario = results[0];
      final Map<String, dynamic>? estadisticas = results[1];
      final Map<String, dynamic>? datosRepartidor = results[2];
      if (perfilUsuario != null && estadisticas != null && datosRepartidor != null) {
        emit(PerfilLoaded(
          perfilUsuario: perfilUsuario,
          estadisticas: estadisticas,
          datosRepartidor: datosRepartidor,
        ));
      } else {
        emit(const PerfilError('Fallo la carga de uno o más datos del perfil/estadísticas.'));
      }
    } catch (e, stacktrace) {
      log('Error catastrófico en PerfilBloc:', error: e, stackTrace: stacktrace);
      emit(PerfilError('Ocurrió un error inesperado al cargar el perfil: ${e.toString()}'));
    }
  }
}