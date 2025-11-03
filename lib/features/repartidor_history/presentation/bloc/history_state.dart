abstract class HistoryState {}

class HistoryLoading extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final List<Map<String, dynamic>> pedidos;
  HistoryLoaded(this.pedidos);
}

class HistoryError extends HistoryState {
  final String message;
  HistoryError(this.message);
}
