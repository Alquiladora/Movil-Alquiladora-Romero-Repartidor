import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../pedidos_bloc/pedidos_bloc.dart';
import '../pedidos_bloc/pedidos_event.dart';
import '../pedidos_bloc/pedidos_stat.dart';
import '../../../core/models/model_pedidos.dart';
import 'dart:developer';
import './payment_screen.dart';
import './detalles_screen.dart';
import './incidenteModla.dart';

class PedidoScreen extends StatefulWidget {
  const PedidoScreen({super.key});

  @override
  State<PedidoScreen> createState() => _PedidoScreenState();
}

class _PedidoScreenState extends State<PedidoScreen> {
  //Creamos el evetno
  bool _showPedidosView = true;

  void _setView(bool isPedidosView) {
    setState(() {
      _showPedidosView = isPedidosView;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 18.0, vertical: 20.0),
            child: _buildViewSelector(),
          ),
          Expanded(
            child: _showPedidosView ? const PedidosView() : const MapaView(),
          ),
        ],
      ),
    );
  }

  Widget _buildViewSelector() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 224, 224, 224),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _setView(true),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color:
                        _showPedidosView ? Colors.orange : Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        color: _showPedidosView ? Colors.white : Colors.black54,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Pedidos',
                        style: TextStyle(
                          color:
                              _showPedidosView ? Colors.white : Colors.black54,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => _setView(false),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color:
                        !_showPedidosView ? Colors.orange : Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.map_outlined,
                        color:
                            !_showPedidosView ? Colors.white : Colors.black54,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Mapa',
                        style: TextStyle(
                          color:
                              !_showPedidosView ? Colors.white : Colors.black54,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PedidosView extends StatefulWidget {
  const PedidosView({super.key});

  @override
  State<PedidosView> createState() => _PedidosViewState();
}

class _PedidosViewState extends State<PedidosView>
    with AutomaticKeepAliveClientMixin {
  bool _isDataFetched = false;

  late String _newState;
  String _selectedOrderStatus = 'Todos';
  String _selectedMunicipio = 'Todos';
  final List<String> _orderStatusOptions = [
    'Todos',
    'Urgentes',
    'Enviando',
    'Recogiendo'
  ];
  final Set<String> _allowedProvinces = {'hidalgo', 'veracruz', 'tamaulipas'};

  List<Pedido> _allOrders = []; // Lista completa de pedidos
  List<String> _municipiosOptions = ['Todos']; 

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isDataFetched) {
      context.read<AssignedOrdersBloc>().add(FetchAssignedOrders());
      _isDataFetched = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilters(),
          const SizedBox(height: 24),
          BlocConsumer<AssignedOrdersBloc, AssignedOrdersState>(
            listener: (context, state) {
              if (state is AssignedOrdersActionSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            builder: (context, state) {
              if (state is AssignedOrdersLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is AssignedOrdersError) {
                return Center(
                  child: Text(state.message,
                      style: const TextStyle(color: Colors.red)),
                );
              }
              if (state is AssignedOrdersLoaded) {
                return _buildGroupedOrdersList(context, state.orders);
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedOrdersList(BuildContext context, List<Pedido> orders) {
  

    final UrgentOrder = orders.where((p) => p.isUrgente).toList();
    log('VIEW DIAGNÓSTICO: Pedidos totales urgentes: ${UrgentOrder.length}');

    final DeliverOrder = orders
        .where(
            (p) => !p.isUrgente && p.estadoPedido.toLowerCase() == 'enviando')
        .toList();

    log('VIEW DIAGNÓSTICO: Pedidos totales enviando: ${DeliverOrder.length}');

    final pickupOrders = orders
        .where(
            (p) => !p.isUrgente && p.estadoPedido.toLowerCase() == 'recogiendo')
        .toList();
    log('VIEW DIAGNÓSTICO: Pedidos totales recogiendo: ${pickupOrders.length}');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (UrgentOrder.isNotEmpty) ...[
          _buildSectionTitle(
            icon: Icons.warning_amber_rounded,
            title: 'Pedidos Urgentes (${UrgentOrder.length})',
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          ...UrgentOrder.map((pedido) => DynamicOrderCard(
                key: ValueKey(pedido.id),
                pedido: pedido,
                cardColor: Colors.red.shade300,
              )),
          const SizedBox(height: 24),
        ],
        if (DeliverOrder.isNotEmpty) ...[
          _buildSectionTitle(
            icon: Icons.local_shipping_outlined,
            title: 'Pedidos a Entregar (${DeliverOrder.length})',
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          ...DeliverOrder.map((pedido) => DynamicOrderCard(
                key: ValueKey(pedido.id),
                pedido: pedido,
                cardColor: Colors.orange.shade300,
              )),
          const SizedBox(height: 24),
        ],
        if (pickupOrders.isNotEmpty) ...[
          _buildSectionTitle(
            icon: Icons.schedule,
            title: 'Pedidos a Recoger (${pickupOrders.length})',
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          ...pickupOrders.map((pedido) => DynamicOrderCard(
                key: ValueKey(pedido.id),
                pedido: pedido,
                cardColor: Colors.green.shade300,
              )),
        ],
      ],
    );
  }

//Verificar ahorita es de filtrado
  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: 'Todos los estados',
                isExpanded: true,
                items: ['Todos los estados']
                    .map((String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value,
                              style: TextStyle(color: Colors.grey.shade700)),
                        ))
                    .toList(),
                onChanged: (_) {},
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: 'Todos los municipios',
                isExpanded: true,
                items: ['Todos los municipios']
                    .map((String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value,
                              style: TextStyle(color: Colors.grey.shade700)),
                        ))
                    .toList(),
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(
      {required IconData icon, required String title, required Color color}) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class DynamicOrderCard extends StatefulWidget {
  final Pedido pedido;
  final Color cardColor;
  

  const DynamicOrderCard(
      {super.key, required this.pedido, required this.cardColor});

  @override
  State<DynamicOrderCard> createState() => _DynamicOrderCardState();
}

class _DynamicOrderCardState extends State<DynamicOrderCard> {
  late String _newState;
  bool _isCancelling = false;
  bool _isUpdating = false;

  final List<String> incidentStates = ['Incompleto', 'Incidente'];

  @override
  void initState() {
    super.initState();
    _newState = widget.pedido.estadoPedido;
  }

@override
  void didChangeDependencies() {
    super.didChangeDependencies();
  
    context.watch<AssignedOrdersBloc>().stream.listen((state) {
      
      if (_isUpdating && (state is AssignedOrdersActionSuccess || state is AssignedOrdersActionFailure)) {
         if (mounted) {
           setState(() {
             _isUpdating = false;
           });
         }
      }
      
      if (_isCancelling && state is AssignedOrdersActionFailure && state.message.contains('Error al cancelar')) {
         if (mounted) {
            setState(() {
              _isCancelling = false;
            });
         }
      }
    });
  }



  @override
 void didUpdateWidget(covariant DynamicOrderCard oldWidget) {
     super.didUpdateWidget(oldWidget);
     if (oldWidget.pedido.estadoPedido != widget.pedido.estadoPedido) {
       _newState = widget.pedido.estadoPedido;
       _isUpdating = false; 
       _isCancelling = false; 
     } else if (oldWidget.pedido.id != widget.pedido.id) {
       _newState = widget.pedido.estadoPedido;
       _isUpdating = false;
       _isCancelling = false;
     }
  }
  
 void _showDetailsModal(BuildContext context, Pedido order) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
    
      return OrderDetailsModal(order: order);
    },
  );
}


  Map<String, dynamic> _getStatusBadgeStyle(String status) {
    final normalizedStatus = status.toLowerCase();

    if (normalizedStatus.contains('enviando')) {
      // Usa contains para ser más flexible
      return {
        'icon': Icons.local_shipping_outlined,
        'color': Colors.blue.shade700,
        'bgColor': Colors.blue.shade100,
        'label': 'Enviando',
      };
    } else if (normalizedStatus.contains('recogiendo')) {
      return {
        'icon': Icons.schedule,
        'color': Colors.green.shade700,
        'bgColor': Colors.green.shade100,
        'label': 'Recogiendo',
      };
    } else if (normalizedStatus.contains('alquiler') ||
        normalizedStatus.contains('entregado')) {
      return {
        'icon': Icons.check_circle_outline,
        'color': Colors.teal.shade700,
        'bgColor': Colors.teal.shade100,
        'label': 'En Alquiler / Entregado',
      };
    } else if (normalizedStatus.contains('cancelado')) {
      return {
        'icon': Icons.close,
        'color': Colors.red.shade700,
        'bgColor': Colors.red.shade100,
        'label': 'Cancelado',
      };
    } else if (normalizedStatus.contains('incidente') ||
        normalizedStatus.contains('incompleto')) {
      return {
        'icon': Icons.error_outline,
        'color': Colors.purple.shade700,
        'bgColor': Colors.purple.shade100,
        'label': 'Incidente',
      };
    }
    // Estado por defecto (e.g., Pendiente)
    return {
      'icon': Icons.pending_actions,
      'color': Colors.grey.shade700,
      'bgColor': Colors.grey.shade200,
      'label': status,
    };
  }

  Widget _buildCurrentStatusBadge(String status) {
    final style = _getStatusBadgeStyle(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: style['bgColor'],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: style['color'].withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize
            .min, 
        children: [
          Icon(
            style['icon'],
            color: style['color'],
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            style['label'],
            style: TextStyle(
              color: style['color'],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  List<String> get _getAvailableStatusOptions {
    final currentStatus = widget.pedido.estadoPedido;
    final normalizedStatus = currentStatus.toLowerCase();

    List<String> specificOptions = [];

    if (normalizedStatus == 'enviando') {
      specificOptions = ['En alquiler'];
    } else if (normalizedStatus == 'recogiendo') {
      specificOptions = ['Devuelto'];
    } else {
      return [currentStatus, ...incidentStates];
    }
    return [currentStatus, ...specificOptions, ...incidentStates];
  }

//Funcionde pagos
  void _showPaymentModal(BuildContext context, Pedido order) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
       
        final bloc = BlocProvider.of<AssignedOrdersBloc>(context);

        return PaymentModal(
          order: order,
      
          onPaymentRegistered: () {
            bloc.add(PaymentRegistered());
          },
        );
      },
    );
  }


// Funcion de cancelar
void _confirmCancellation(BuildContext context, Pedido pedido) {
  final bloc = BlocProvider.of<AssignedOrdersBloc>(context);

  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Confirmar Cancelación'),
        content: const Text('¿Estás seguro de que deseas cancelar este pedido? Esta acción no se puede deshacer.'),
        actions: <Widget>[
          TextButton(
            child: const Text('No, Mantener', style: TextStyle(color: Colors.grey)),
            onPressed: () {
              Navigator.of(dialogContext).pop(); 
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sí, Cancelar', style: TextStyle(color: Colors.white)),
            onPressed: () {
              Navigator.of(dialogContext).pop(); 
              if (mounted) { 
                    setState(() => _isCancelling = true); 
                 }
             
              bloc.add(CancelOrder(pedido.id)); 
            },
          ),
        ],
      );
    },
  );
}

//Modal reportar incidencias
void _showIncidentModal(BuildContext context, Pedido pedido, String nuevoEstadoIncidente ){
 print("DEBUG: Intentando abrir _showIncidentModal para pedido ${pedido.id} con estado $nuevoEstadoIncidente con pedido ${pedido}");
 final bloc= context.read<AssignedOrdersBloc>();
  bool seEnvioReporte = false;

showDialog(
      context: context,
    builder: (BuildContext dialogContext) {
   
      return IncidentModal(
        order: pedido,
        incidentStatus: nuevoEstadoIncidente,
        onSubmit: (IncidentData data) {
         
           if (mounted) {
             setState(() => _isUpdating = true);
           }
          
           seEnvioReporte = true; 

         
           bloc.add(SubmitOrderIncident(
             orderId: pedido.id,
             incidentData: data,
           ));

           Navigator.of(dialogContext).pop(); 
        },
      );
    
    },
  ).then((_) {
    
    if (mounted && _isUpdating && !seEnvioReporte) {
      setState(() => _isUpdating = false);
    }
   
  });
}


  @override
  Widget build(BuildContext context) {
    final pedido = widget.pedido;
    final bloc = context.read<AssignedOrdersBloc>();

    final bool isFullyPaid = pedido.totalPagado >= pedido.totalAPagar;
    final List<String> dynamicStates = _getAvailableStatusOptions;
    final DateFormat formatter = DateFormat('dd MMM yyyy');
    final String fechaFormateada = formatter.format(pedido.fechaEntrega);

    final bool isIncidentStateSelected = 
        incidentStates.contains(_newState);
    final bool isUpdatePending = _newState != pedido.estadoPedido;
    final bool isButtonEnabled = isIncidentStateSelected || isUpdatePending;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: widget.cardColor, width: 2),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    pedido.nombreCliente,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.cardColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                          pedido.isUrgente ? 'URGENTE' : pedido.estadoPedido,
                          style: TextStyle(
                              color: widget.cardColor,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    if (!isFullyPaid)
                      GestureDetector(
                          onTap: () {
                            _showPaymentModal(context, pedido);
                          },
                          child: const Icon(Icons.payment,
                              color: Color.fromARGB(255, 28, 255, 138),
                              size: 24)),
                  ],
                ),
              ],
            ),
            Text('#${pedido.id}',
                style: const TextStyle(color: Colors.grey)), 
            const SizedBox(height: 12),

            // --- Información de Contacto y Dirección ---
            _buildInfoRow(
              Icons.location_on_outlined,
              '${pedido.localidad} ${pedido.municipio} ${pedido.estado}',
            ),

            const SizedBox(height: 8),
            _buildInfoRow(Icons.calendar_today_outlined,
                fechaFormateada), 
            const SizedBox(height: 8),
            _buildInfoRow(
                Icons.phone_outlined, pedido.telefonoCliente), 
            const Divider(height: 24, thickness: 1, color: Colors.grey),

            _buildPaymentStatus(
                isFullyPaid, pedido.totalPagado, pedido.totalAPagar),
            const SizedBox(height: 16),

            // --- Selector de Estado ---

            Text('Estado actual:',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildCurrentStatusBadge(pedido.estadoPedido),
            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              value: dynamicStates.contains(_newState)
                  ? _newState
                  : dynamicStates.first,
              decoration: InputDecoration(
                labelText: 'Seleccionar nuevo estado',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              items: dynamicStates
                  .map((state) =>
                      DropdownMenuItem(value: state, child: Text(state)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _newState = value);
                }
              },
            ),

            const SizedBox(height: 8),

       
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
            
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _showDetailsModal(context, pedido);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 8),
                    ),
                    child: const Text('Detalles',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12)),
                  ),
                ),

                const SizedBox(width: 8), 

            
                Expanded(
                  child: ElevatedButton(
                    onPressed: (isButtonEnabled && !_isUpdating)
                    ? () {
                      if (mounted) {
                               setState(() => _isUpdating = true);
                            }

                      if (incidentStates.contains(_newState)) {
                             
                              _showIncidentModal(context, pedido, _newState);
                            } else {
                             
                              bloc.add(UpdateOrderStatus(
                                orderId: pedido.id,
                                newStatus: _newState, 
                              ));
                            }

                    } : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isIncidentStateSelected
                          ? Colors.purple
                          : isUpdatePending
                              ? Colors.blue
                              : Colors.grey,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 8), 
                    ),
                    child: _isUpdating
                        ? const SizedBox(
                            height: 14,
                            width: 14,
                            child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                        : Text(
                            isIncidentStateSelected ? 'Reportar' : 'Actualizar',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12)),
                  ),
                ),

                const SizedBox(width: 8), 

              
                Expanded(
                 child: ElevatedButton(
                    onPressed: _isCancelling ? null : () { 
                      _confirmCancellation(context, pedido);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 8), 
                    ),
                    child: _isCancelling
                           ? const SizedBox(height: 14, width: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                           : const Text('Cancelar', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Widget genérico para fila de info
Widget _buildInfoRow(IconData icon, String text) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: Colors.grey, size: 20),
      const SizedBox(width: 12),
      Expanded(
          child: Text(text, style: const TextStyle(color: Colors.black87))),
    ],
  );
}

// Widget para estado de pago
Widget _buildPaymentStatus(
    bool isFullyPaid, double paidAmount, double totalAmount) {
  if (isFullyPaid) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('PAGADO COMPLETO',
              style:
                  TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          Text('\$${totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                  color: Colors.green, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  } else {
    double percentage = (paidAmount / totalAmount) * 100;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.payment, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                  'Estado de \$${paidAmount.toStringAsFixed(2)} / \$${totalAmount.toStringAsFixed(2)}'),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: paidAmount / totalAmount,
            backgroundColor: Colors.grey.shade300,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            minHeight: 8,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  'Restante: \$${(totalAmount - paidAmount).toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.red)),
              Text('${percentage.toStringAsFixed(1)}% completado',
                  style: TextStyle(color: Colors.blue)),
            ],
          ),
        ],
      ),
    );
  }
}

class MapaView extends StatelessWidget {
  const MapaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Buscar Ubicación',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Escribir dirección del pedido...',
                          prefixIcon:
                              Icon(Icons.search, color: Colors.grey.shade600),
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        elevation: 2,
                      ),
                      child: const Text('Buscar',
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.my_location,
                        color: Colors.orange, size: 20),
                    label: const Text('Mi Ubicación Actual',
                        style: TextStyle(color: Colors.orange, fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.orange),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [Colors.blue.shade100, Colors.green.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: Stack(
                children: [
                  const GridLines(),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 5)
                            ],
                          ),
                          child: const Icon(Icons.add,
                              color: Colors.black54, size: 20),
                          padding: const EdgeInsets.all(8),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                            ),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 5)
                            ],
                          ),
                          child: const Icon(Icons.remove,
                              color: Colors.black54, size: 20),
                          padding: const EdgeInsets.all(8),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 80,
                    left: 40,
                    child: Column(
                      children: [
                        const Icon(Icons.location_pin,
                            color: Colors.blue, size: 40),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 5)
                            ],
                          ),
                          child: const Text('Repartidor',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GridLines extends StatelessWidget {
  const GridLines({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: GridPainter(),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 0.5;

    for (var i = 1; i < 5; i++) {
      final dy = i * size.height / 5;
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), paint);
    }

    for (var i = 1; i < 4; i++) {
      final dx = i * size.width / 4;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
