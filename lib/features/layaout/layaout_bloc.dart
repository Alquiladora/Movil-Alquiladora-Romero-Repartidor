import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/services/api_service_layaout.dart'; 
import './stats_layaout.dart';
import './event_layaut.dart';

class LayoutBloc extends Bloc<LayoutEvent, LayoutState> {

  final LayaoutService layoutService;

  LayoutBloc({required this.layoutService}) : super(LayoutInicial()) {
    on<LoadLayoutData>(_onLoadLayoutData);
  }


  Future<void> _onLoadLayoutData(LoadLayoutData event, Emitter<LayoutState> emit) async {

    emit(LayoutLoading());

    try {
    
      final result = await layoutService.getFoto();

    
      if (result['success']) {
       
        emit(LayoutSuccess(
           nombre: result['nombre'] ?? 'Usuario',
          fotoPerfilUrl: result['fotoPerfilUrl'] ?? '',
        ));
      } else {
      
       emit(LayoutFailure(error: result['message'] ?? 'Error desconocido'));
      }
    } catch (error) {
    
      emit(const LayoutFailure(error: 'Ocurrió un error inesperado al cargar el perfil.'));
    }
  }
}
