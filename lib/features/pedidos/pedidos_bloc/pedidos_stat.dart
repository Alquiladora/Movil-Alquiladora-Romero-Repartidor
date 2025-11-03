// Archivo: assigned_orders_state.dart

import 'package:equatable/equatable.dart';
import '../../../core/models/model_pedidos.dart'; 

abstract class AssignedOrdersState extends Equatable {
  const AssignedOrdersState();

  @override
  List<Object> get props => [];
}


class AssignedOrdersInitial extends AssignedOrdersState {}

class AssignedOrdersLoading extends AssignedOrdersState {}


class AssignedOrdersLoaded extends AssignedOrdersState {
  final List<Pedido> orders;
  

  const AssignedOrdersLoaded(this.orders);

  @override
  List<Object> get props => [orders];
}


class AssignedOrdersError extends AssignedOrdersState {
  final String message;

  const AssignedOrdersError(this.message);

  @override
  List<Object> get props => [message];
}

class AssignedOrdersActionSuccess extends AssignedOrdersState {
  final String message;
  const AssignedOrdersActionSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class AssignedOrdersActionFailure extends AssignedOrdersState {
  final String message;

  const AssignedOrdersActionFailure(this.message);

  @override
  List<Object> get props => [message];
}