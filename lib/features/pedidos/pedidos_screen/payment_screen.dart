import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:developer';

// Asegúrate de que estas rutas sean correctas
import '../../../core/models/model_pedidos.dart';
import '../../../core/services/api_service_pedidos.dart';
import '../pedidos_bloc/pedidos_event.dart';
import '../pedidos_bloc/pedidos_bloc.dart';

// =========================================================================
// 1. PAYMENT MODAL PRINCIPAL
// =========================================================================

class PaymentModal extends StatefulWidget {
  final Pedido order;
  final VoidCallback onPaymentRegistered;

  const PaymentModal({
    super.key,
    required this.order,
    required this.onPaymentRegistered,
  });

  @override
  State<PaymentModal> createState() => _PaymentModalState();
}


class _PaymentModalState extends State<PaymentModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _montoController = TextEditingController();
  
  // Accede al servicio a través del contexto
  ApiServicePedidos get _apiService => context.read<ApiServicePedidos>(); 
  
  double _montoPago = 0.0;
  String? _formaPago;
  String _metodoPago = '';
  String _detallesPago = '';
  
  bool _loading = false;
  String? _errorMessage;
  bool _success = false;

  late double _pendiente;

  @override
  void initState() {
    super.initState();
    _pendiente = widget.order.totalAPagar - widget.order.totalPagado;
    _montoPago = _pendiente > 0 ? _pendiente : 0.0;
    _montoController.text = _montoPago.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _montoController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _montoPago = widget.order.totalAPagar - widget.order.totalPagado; 
    _formaPago = null;
    _metodoPago = '';
    _detallesPago = '';
    
    _montoController.text = _montoPago.toStringAsFixed(2);
    _formKey.currentState?.reset(); 
}

  String? _validateMonto(String? value) {
    if (value == null || value.isEmpty) return 'El monto no puede estar vacío.';
    
    // Validar que sea numérico
    final numValue = double.tryParse(value);
    if (numValue == null) return 'Ingresa un valor numérico válido.';
    
    if (numValue <= 0) {
      return "El monto debe ser mayor a 0.";
    }
    if (numValue > _pendiente) {
      return 'El monto no puede exceder \$${_pendiente.toStringAsFixed(2)}.';
    }
    return null;
  }

  void _setFullPayment() {
    setState(() {
      _montoPago = _pendiente;
      _montoController.text = _pendiente.toStringAsFixed(2);
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    print("Datos recibidos  $_formaPago, $_metodoPago");
    
    if (_formaPago == null ) {
      setState(() => _errorMessage = 'Por favor completa todos los campos requeridos.');
      return;
    }
    
    setState(() {
      _loading = true;
      _errorMessage = null;
      _success = false;
    });

    final payload = {
      'idPedido': widget.order.id, 
      'monto': _montoPago,
      'formaPago': _formaPago,
      'metodoPago': _detallesPago.trim(),
      'detallesPago': _detallesPago.trim(),
    };

    try {
      await context.read<ApiServicePedidos>().registrarPago(widget.order.id, payload);
      setState(() => _success = true);
      
      Future.delayed(const Duration(milliseconds: 1500), () {
        // Dispara el evento del BLoC para recargar la lista de pedidos
       widget.onPaymentRegistered();
       Navigator.of(context).pop();
      });
      
    } catch (e) {
      log('Error al registrar pago: $e');
      setState(() => _errorMessage = e.toString().contains('401') 
          ? 'Sesión expirada. Vuelve a iniciar sesión.' 
          : e.toString().contains('Error de red')
              ? 'Error de conexión. Verifica la red.'
              : 'Error desconocido al procesar pago.');
    } finally {
      setState(() => _loading = false);
    }
  }


  IconData _getPaymentIcon(String? forma) {
    switch ((forma ?? "").toLowerCase()) {
      case "tarjeta":
        return FontAwesomeIcons.creditCard;
      case "efectivo":
        return FontAwesomeIcons.moneyBillWave;
      case "transferencia":
        return FontAwesomeIcons.moneyCheckAlt;
      default:
        return FontAwesomeIcons.moneyCheckAlt;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;
    final double maxModalWidth = isSmallScreen 
        ? MediaQuery.of(context).size.width * 0.95
        : MediaQuery.of(context).size.width * 0.5;

    // Si la orden ya está totalmente pagada, mostramos la vista de historial/completo
    if (_pendiente <= 0 && !_success) {
      return _buildPaymentCompletedView(maxModalWidth);
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxModalWidth,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- HEADER ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade700, Colors.amber.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.payment, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Registrar Pago - Pedido #${widget.order.id}', 
                      style: const TextStyle(
                        color: Colors.white, 
                        fontWeight: FontWeight.bold, 
                        fontSize: 18
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 24),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 40),
                  ),
                ],
              ),
            ),

            // --- CONTENT ---
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // --- RESUMEN DE MONTOS ---
                      _buildAmountSummary(),
                      const SizedBox(height: 24),

                      // --- MENSAJES DE ESTADO ---
                      if (_errorMessage != null)
                        _buildMessageBadge(Icons.error_outline, _errorMessage!, Colors.red),
                      if (_success)
                        _buildMessageBadge(Icons.check_circle, '¡Pago registrado exitosamente!', Colors.green),

                      // --- MONTO A PAGAR ---
                      _buildAmountInput(),
                      const SizedBox(height: 20),

                      // --- FORMA DE PAGO ---
                      _buildPaymentMethodDropdown(),
                      const SizedBox(height: 20),

                      // --- DETALLES DEL PAGO ---
                      _buildPaymentDetails(),
                      const SizedBox(height: 32),

                      // --- BOTONES DE ACCIÓN ---
                      _buildActionButtons(isSmallScreen),
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

  
  Widget _buildAmountSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAmountRow('Monto total:', widget.order.totalAPagar.toStringAsFixed(2)),
          _buildAmountRow('Ya pagado:', widget.order.totalPagado.toStringAsFixed(2)),
          const Divider(height: 16, thickness: 1),
          _buildAmountRow(
            'Pendiente:', 
            _pendiente.toStringAsFixed(2),
            isBold: true,
            color: _pendiente > 0 ? Colors.red.shade700 : Colors.green.shade700,
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '\$$value',
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? (isBold ? Colors.blue.shade800 : Colors.grey.shade800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monto a Pagar *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _montoController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: '0.00',
                  prefixText: '\$ ',
                  prefixStyle: const TextStyle(fontWeight: FontWeight.bold),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.amber.shade600, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                validator: _validateMonto,
                onSaved: (value) => _montoPago = double.tryParse(value!) ?? 0.0,
                onChanged: (value) {
                  final error = _validateMonto(value);
                  setState(() => _errorMessage = error);
                  if (error == null) {
                    _montoPago = double.tryParse(value) ?? 0.0;
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            if (_pendiente > 0)
              ElevatedButton(
                onPressed: _loading ? null : _setFullPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade50,
                  foregroundColor: Colors.blue.shade800,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.blue.shade300),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                child: Text(
                  'Pagar Todo',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade800,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentMethodDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Forma de Pago *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.amber.shade600, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          value: _formaPago,
          items: const [
            DropdownMenuItem(
              value: 'efectivo',
              child: Row(
                children: [
                  Icon(Icons.money, color: Colors.green, size: 20),
                  SizedBox(width: 12),
                  Text('Efectivo'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'transferencia',
              child: Row(
                children: [
                  Icon(Icons.account_balance, color: Colors.blue, size: 20),
                  SizedBox(width: 12),
                  Text('Transferencia Bancaria'),
                ],
              ),
            ),
          ],
          onChanged: (value) {
            setState(() => _formaPago = value);
            if (value == 'efectivo') {
              _detallesPago = 'Pago en efectivo'; 
            } else {
              _detallesPago = '';
            }
          },
          validator: (value) => value == null ? 'Selecciona la forma de pago.' : null,
          onSaved: (value) => _formaPago = value,
        ),
      ],
    );
  }

  Widget _buildPaymentDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detalles del Pago *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          maxLines: 2,
          decoration: InputDecoration(
            hintText: _formaPago == 'efectivo' 
                ? 'Pago en efectivo' 
                : 'Ej: Referencia bancaria, número de transacción...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.amber.shade600, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          validator: (value) => (value == null || value.trim().isEmpty) 
              ? 'Este campo es requerido.' 
              : null,
          onSaved: (value) => _detallesPago = value!,
          onChanged: (value) => _detallesPago = value,
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isSmallScreen) {
    if (isSmallScreen) {
      // Diseño vertical para pantallas pequeñas
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade600,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.receipt_long, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Registrar Pago',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _loading ? null : () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade600,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Cancelar'),
            ),
          ),
        ],
      );
    } else {
      // Diseño horizontal para pantallas grandes
      return Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: _loading ? null : () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade600,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Cancelar'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _loading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade600,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.receipt_long, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Registrar Pago',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      );
    }
  }


  Widget _buildMessageBadge(IconData icon, String message, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCompletedView(double maxModalWidth) {
    final historial = widget.order.historialPagos;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxModalWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade600, Colors.green.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Pedido Completamente Pagado',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 24),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 40),
                  ),
                ],
              ),
            ),

            // CONTENT
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade600, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Este pedido ha sido cubierto totalmente.',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(height: 1),
                  const SizedBox(height: 20),
                  
                  Text(
                    'Historial de Pagos',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  if (historial.isNotEmpty)
                    ...historial.map((pago) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.attach_money,
                                color: Colors.green.shade700,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '\$${pago.monto.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                  Text(
                                    '${pago.metodo} • ${pago.fecha}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )).toList()
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'No hay pagos registrados aún.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),

            // FOOTER
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Cerrar'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}