import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/api_service_history.dart';
import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final HistoryService service;

  HistoryBloc(this.service) : super(HistoryLoading()) {
    on<LoadHistory>(_onLoad);
    on<RefreshHistory>(_onLoad);
  }

  Future<void> _onLoad(HistoryEvent event, Emitter<HistoryState> emit) async {
    emit(HistoryLoading());
    try {
      final pedidos = await service.fetchHistory();
      emit(HistoryLoaded(pedidos));
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }
}
