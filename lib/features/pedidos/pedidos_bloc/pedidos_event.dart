import 'package:equatable/equatable.dart';
import '../../../core/models/model_pedidos.dart';

abstract class AssignedOrdersEvent extends Equatable {
  const AssignedOrdersEvent();

  @override
  List<Object> get props => [];
}

class FetchAssignedOrders extends AssignedOrdersEvent {}

class UpdateOrderStatus extends AssignedOrdersEvent {
  final int orderId;
  final String newStatus;

  const UpdateOrderStatus({required this.orderId, required this.newStatus});

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

class IncidentData extends Equatable {
  final String estadoPedido; 
  final bool entireOrderIssue;
  final String orderObservations;

  final List<Map<String, dynamic>> productIssues;

  const IncidentData({
    required this.estadoPedido,
    required this.entireOrderIssue,
    required this.orderObservations,
    required this.productIssues,
  });

  @override
  List<Object> get props => [
        estadoPedido,
        entireOrderIssue,
        orderObservations,
        productIssues
      ];
}

class SubmitOrderIncident extends AssignedOrdersEvent {
  final int orderId;
  final IncidentData incidentData;

  const SubmitOrderIncident({required this.orderId, required this.incidentData});

  @override
  List<Object> get props => [orderId, incidentData];
}