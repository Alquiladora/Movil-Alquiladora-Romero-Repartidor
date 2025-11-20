
import 'package:event_bus/event_bus.dart';

final EventBus appEventBus = EventBus();


class NuevoPedidoEvent {
  final String pedidoId;
  NuevoPedidoEvent(this.pedidoId);
}