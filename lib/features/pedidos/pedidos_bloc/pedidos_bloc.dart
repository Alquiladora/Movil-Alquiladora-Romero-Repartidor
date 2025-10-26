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
    on<FetchAssignedOrders>(_onFetchAssignedOrders);
    on<UpdateOrderStatus>(_onUpdateOrderStatus);
    on<CancelOrder>(_onCancelOrder);
    on<RegisterPayment>(_onRegisterPayment);
    on<PaymentRegistered>(_onPaymentRegistered);

  }


  Future<void> _onRegisterPayment(
    RegisterPayment event,
    Emitter<AssignedOrdersState> emit,
  ) async {
    final currentState = state;
  
    if (currentState is! AssignedOrdersLoading) {
        emit(AssignedOrdersLoading());
    }
    final List<Pedido> currentOrders = 
      currentState is AssignedOrdersLoaded ? currentState.orders : [];

    try {
      
      await _apiService.registrarPago(event.orderId, event.paymentData);
      
      
     emit(AssignedOrdersActionSuccess('Pago registrado con éxito.', currentOrders));
      
     
      add(PaymentRegistered()); 
      
    } catch (e) {
     final errorMessage = e.toString();
      
    
     if (currentState is AssignedOrdersLoaded) {
        emit(AssignedOrdersActionSuccess('Fallo al registrar pago: $errorMessage', currentOrders));
        // Volver inmediatamente al estado Loaded con los datos Viejos + mensaje
        emit(AssignedOrdersLoaded(currentOrders)); 
    } else {
        emit(AssignedOrdersError('Fallo al registrar pago: $errorMessage'));
    }
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
    final currentState = state;
    if (currentState is AssignedOrdersLoaded) {
      try {
        await _apiService.actualizarEstadoEspecial(event.orderId, event.newStatus);
        
        // Actualización optimista: modifica la lista local
        final updatedOrders = currentState.orders.map((order) {
          return order.id == event.orderId 
            ? order.copyWith(estadoPedido: event.newStatus)
            : order;
        }).toList();

        // Notificación de éxito y retorno al estado Loaded
        emit(AssignedOrdersActionSuccess('Estado actualizado a ${event.newStatus}', updatedOrders));
        emit(AssignedOrdersLoaded(updatedOrders));
        
      } catch (e) {
        emit(AssignedOrdersActionSuccess('Error: ${e.toString()}', currentState.orders));
        // Recarga para asegurar la consistencia si falla
        add(FetchAssignedOrders());
      }
    }
  }

  
  Future<void> _onCancelOrder(
    CancelOrder event,
    Emitter<AssignedOrdersState> emit,
  ) async {
    final currentState = state;
    if (currentState is AssignedOrdersLoaded) {
      try {
        await _apiService.cancelarPedido(event.orderId);
        
        final updatedOrders = currentState.orders.map((order) {
          return order.id == event.orderId 
            ? order.copyWith(estadoPedido: 'Cancelado')
            : order;
        }).toList();

        emit(AssignedOrdersActionSuccess('Pedido cancelado correctamente', updatedOrders));
        add(FetchAssignedOrders());
       
        
      } catch (e) {
        emit(AssignedOrdersActionSuccess('Error al cancelar: ${e.toString()}', currentState.orders));
      }
    }
  }

}