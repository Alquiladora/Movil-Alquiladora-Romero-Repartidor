import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import './pedidos_event.dart';
import './pedidos_stat.dart';
import '../../../core/services/api_service_pedidos.dart';
import '../../../core/models/model_pedidos.dart'; 

//Creamo sla clase
class AssignedOrdersBloc extends Bloc<AssignedOrdersEvent, AssignedOrdersState> {
  //Accedemos ala clase
  final ApiServicePedidos _apiService;

  //Creamos el constructur donde iniciamos las funciones
  AssignedOrdersBloc(this._apiService) : super(AssignedOrdersInitial()) {
    print("--- ¡¡¡AssignedOrdersBloc CREADO!!! ---");
    on<FetchAssignedOrders>(_onFetchAssignedOrders);
    on<UpdateOrderStatus>(_onUpdateOrderStatus);
    on<CancelOrder>(_onCancelOrder);
    on<RegisterPayment>(_onRegisterPayment);
    on<PaymentRegistered>(_onPaymentRegistered);
    on<SubmitOrderIncident>(
        _onSubmitOrderIncident);

  }


  Future<void> _onRegisterPayment(
    RegisterPayment event,
    Emitter<AssignedOrdersState> emit,
  ) async {
    
    try {
      
      await _apiService.registrarPago(event.orderId, event.paymentData);
      
      emit(const AssignedOrdersActionSuccess('Pago registrado con éxito.'));
     
      add(PaymentRegistered()); 
      
    } catch (e) {
    final errorMessage = e.toString();
    emit(AssignedOrdersActionFailure('Fallo al registrar pago: $errorMessage'));
  }
}
  
Future<void> _onPaymentRegistered(
    PaymentRegistered event,
    Emitter<AssignedOrdersState> emit,
  ) async {
 
    await _onFetchAssignedOrders(FetchAssignedOrders(), emit);
  }


  //Funcion de obtener pedido
   Future<void> _onFetchAssignedOrders(
    FetchAssignedOrders event,
    Emitter<AssignedOrdersState> emit,
  ) async {
    if (state is! AssignedOrdersLoading) {
        emit(AssignedOrdersLoading());
    }
    
    try {
      final orders = await _apiService.getPedidosAsignados();
      print("BLOC DIAGNÓSTICO: Pedidos recibidos: ${orders.length}");
      
      if (orders.isEmpty) {
        emit(const AssignedOrdersError('No hay pedidos asignados.'));
      } else {
        emit(AssignedOrdersLoaded(orders));
      }
    } catch (e) {
      emit(AssignedOrdersError(e.toString()));
    }
  }

    
  Future<void> _onUpdateOrderStatus(
    UpdateOrderStatus event,
    Emitter<AssignedOrdersState> emit,
  ) async {
    final capitalizedStatus = _capitalizeStatus(event.newStatus);
    print("Datos recbidos a actualizar $capitalizedStatus");
    if (capitalizedStatus == 'Incompleto' ||
        capitalizedStatus == 'Incidente') {
    
      emit(const AssignedOrdersActionFailure(
          'Use "Reportar" para incidentes.'));
      return;
    }
   
      try {
    
      if (capitalizedStatus == 'En alquiler' ||
          capitalizedStatus == 'Devuelto') {
      
        await _apiService.actualizarEstadoEspecial(
            event.orderId, capitalizedStatus);
      } else {
     
        await _apiService.actualizarEstadoGeneral(
            event.orderId, capitalizedStatus);
      }
     emit(AssignedOrdersActionSuccess(
          'Estado actualizado a $capitalizedStatus'));

      
      add(FetchAssignedOrders());
    } catch (e) {
     
      emit(AssignedOrdersActionFailure('Error al actualizar: ${e.toString()}'));
    }
  }

  Future<void> _onSubmitOrderIncident(
    SubmitOrderIncident event,
    Emitter<AssignedOrdersState> emit,
  ) async {
    try {
     
      final capitalizedStatus =
          _capitalizeStatus(event.incidentData.estadoPedido);
      final payload = {
        'entireOrderIssue': event.incidentData.entireOrderIssue,
        'orderObservations': event.incidentData.orderObservations,
        'productIssues': event.incidentData.entireOrderIssue
            ? [] 
            : event.incidentData
                .productIssues, 
        'estado_pedido': capitalizedStatus,
      };

    
      await _apiService.reportarIncidente(event.orderId, payload);

      
      emit(const AssignedOrdersActionSuccess('Incidente reportado con éxito'));

      
      add(FetchAssignedOrders());
    } catch (e) {
     
      emit(AssignedOrdersActionFailure(
          'Error al reportar incidente: ${e.toString()}'));
    }
  }

  
  Future<void> _onCancelOrder(
    CancelOrder event,
    Emitter<AssignedOrdersState> emit,
  ) async {
    if (state is! AssignedOrdersLoaded) return; 

  try {
    await _apiService.cancelarPedido(event.orderId);
    emit(const AssignedOrdersActionSuccess('Pedido cancelado correctamente'));
    add(FetchAssignedOrders()); 

  } catch (e) {
    emit(AssignedOrdersActionFailure('Error al cancelar: ${e.toString()}'));
  }
}

  String _capitalizeStatus(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

}