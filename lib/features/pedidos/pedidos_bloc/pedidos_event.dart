import 'package:equatable/equatable.dart';
import '../../../core/models/model_pedidos.dart';

abstract class AssignedOrdersEvent extends Equatable {
  const AssignedOrdersEvent();

  @override
  List<Object> get props => [];
}

/// Disparado al iniciar la pantalla o para recargar la lista.
class FetchAssignedOrders extends AssignedOrdersEvent {}

/// Disparado para actualizar estados como 'En alquiler' o 'Devuelto'.
class UpdateOrderStatus extends AssignedOrdersEvent {
  final int orderId;
  final String newStatus;

  const UpdateOrderStatus(this.orderId, this.newStatus);

  @override
  List<Object> get props => [orderId, newStatus];
}

/// Disparado para cancelar un pedido.
class CancelOrder extends AssignedOrdersEvent {
  final int orderId;

  const CancelOrder(this.orderId);

  @override
  List<Object> get props => [orderId];
}


class RegisterPayment extends AssignedOrdersEvent {
  final int orderId;
  final Map<String, dynamic> paymentData;

  const RegisterPayment({required this.orderId, required this.paymentData});

  @override
  List<Object> get props => [orderId, paymentData];
}

class PaymentRegistered extends AssignedOrdersEvent {}