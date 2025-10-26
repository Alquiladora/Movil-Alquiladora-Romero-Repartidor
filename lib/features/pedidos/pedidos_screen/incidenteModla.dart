import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Asegúrate que la ruta a tu modelo de pedidos sea correcta
import '../../../core/models/model_pedidos.dart';
// Asegúrate que la ruta a tus eventos del BLoC sea correcta
import '../pedidos_bloc/pedidos_event.dart';

// Clase auxiliar para manejar el estado de cada producto DENTRO del modal
class _ProductIssueState {
  final Producto productoOriginal;
  final TextEditingController quantityController = TextEditingController(text: '0');
  final TextEditingController observationsController = TextEditingController();
  bool selected = false;
  String status;

  _ProductIssueState({required this.productoOriginal})
      : status = productoOriginal.estado ?? 'Disponible';

  void dispose() {
    quantityController.dispose();
    observationsController.dispose();
  }

  Map<String, dynamic> toApiPayload() {
    int cantidadAfectada = 0;
    String nota = observationsController.text.trim();

    if (status == 'Incompleto') {
      cantidadAfectada = int.tryParse(quantityController.text) ?? 0;
      nota = '${cantidadAfectada} ${observationsController.text.trim()}'.trim();
    }

    return {
      'id': productoOriginal.id,
      'estado': status,
      'cantidad_afectada': cantidadAfectada,
      'nota': nota,
    };
  }
}


// --- El Widget Principal del Modal ---
class IncidentModal extends StatefulWidget {
  final Pedido order;
  final String incidentStatus;
  final Function(IncidentData) onSubmit;
  final bool isSubmitting; // Recibe el estado de carga

  const IncidentModal({
    super.key,
    required this.order,
    required this.incidentStatus,
    required this.onSubmit,
    this.isSubmitting = false,
  });

  @override
  State<IncidentModal> createState() => _IncidentModalState();
}

class _IncidentModalState extends State<IncidentModal> {
  late List<_ProductIssueState> _productIssuesState;
  bool _entireOrderIssue = false;
  final _orderObservationsController = TextEditingController();
  String? _error;
  final List<String> availableStatuses = const ['Incompleto', 'Incidente'];

  @override
  void initState() {
    super.initState();
    _initializeState();
  }

  @override
  void didUpdateWidget(covariant IncidentModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.order.id != widget.order.id || oldWidget.incidentStatus != widget.incidentStatus) {
       _initializeState();
    }
  }

  void _initializeState() {
    _productIssuesState = widget.order.productos
        .map((prod) => _ProductIssueState(productoOriginal: prod))
        .toList();
    _entireOrderIssue = false;
    _orderObservationsController.text = widget.order.observaciones ?? ''; // Precarga observaciones si existen
    _error = null;
  }

  @override
  void dispose() {
    _orderObservationsController.dispose();
    for (var issueState in _productIssuesState) {
      issueState.dispose();
    }
    super.dispose();
  }

  bool _validateInputs() {
    setState(() => _error = null); // Limpia error al validar

    if (_entireOrderIssue) {
      if (_orderObservationsController.text.trim().isEmpty) {
        setState(() => _error = 'Proporciona observaciones para el incidente del pedido.');
        return false;
      }
    } else {
      final selectedIssues = _productIssuesState.where((p) => p.selected).toList();
      if (selectedIssues.isEmpty) {
        setState(() => _error = 'Selecciona al menos un producto afectado.');
        return false;
      }
      for (var issue in selectedIssues) {
        if (issue.status == 'Disponible' && selectedIssues.length == 1) {
            // Considera si seleccionar un solo producto y dejarlo como 'Disponible' es válido
            // Si no lo es, añade una validación aquí.
            // setState(() => _error = 'Debes cambiar el estado de ${issue.productoOriginal.nombre} si lo seleccionas.');
            // return false;
        } else if (issue.status == 'Incompleto') {
          final quantity = int.tryParse(issue.quantityController.text) ?? 0;
          if (quantity <= 0 || quantity > issue.productoOriginal.cantidad) {
            setState(() => _error = 'Cantidad inválida para ${issue.productoOriginal.nombre}. Debe ser entre 1 y ${issue.productoOriginal.cantidad}.');
            return false;
          }
          if (issue.observationsController.text.trim().isEmpty) {
             setState(() => _error = 'Proporciona observaciones para ${issue.productoOriginal.nombre} (Incompleto).');
             return false;
          }
        } else if (issue.status == 'Incidente') {
           if (issue.observationsController.text.trim().isEmpty) {
             setState(() => _error = 'Proporciona observaciones para ${issue.productoOriginal.nombre} (Incidente).');
             return false;
          }
        }
      }
    }
    return true; // Pasa la validación
  }

  void _handleSubmit() {
    // Si ya se está enviando, no hacer nada (doble tap)
    if (widget.isSubmitting) return; 
    
    if (!_validateInputs()) return; // Si no es válido, no hace nada

    final incidentData = IncidentData(
      estadoPedido: widget.incidentStatus,
      entireOrderIssue: _entireOrderIssue,
      orderObservations: _orderObservationsController.text.trim(),
      productIssues: _entireOrderIssue
          ? []
          : _productIssuesState
              .where((p) => p.selected)
              .map((p) => p.toApiPayload())
              .toList(),
    );
    widget.onSubmit(incidentData); // Llama al callback que está en _showIncidentModal
                                    // Este callback ahora activará el spinner en la Card y cerrará el modal
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10), // Ajusta padding
      contentPadding: const EdgeInsets.symmetric(horizontal: 20), // Ajusta padding
      actionsPadding: const EdgeInsets.all(15), // Ajusta padding
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
          const SizedBox(width: 8),
          const Text('Reportar Incidente'),
        ],
      ),
      content: SizedBox( // Contenedor con ancho fijo
        // Usamos min para evitar que sea más ancho que la pantalla en dispositivos pequeños
        width: screenWidth * 0.9 > 500 ? 500 : screenWidth * 0.9, 
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min, // Importante para que Column no se expanda infinitamente
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Mensaje de Error ---
              if (_error != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_error!, style: TextStyle(color: Colors.red.shade800, fontSize: 13)),
                ),

              // --- Estado Seleccionado ---
               Text('Reportando como: ${widget.incidentStatus}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
               const SizedBox(height: 15),

              // --- Checkbox Orden Completa ---
              CheckboxListTile(
                 title: const Text('Incidente afecta todo el pedido', style: TextStyle(fontSize: 14)),
                 value: _entireOrderIssue,
                 onChanged: widget.isSubmitting ? null : (value) { // Deshabilita si carga
                   if (value != null) {
                     setState(() {
                       _entireOrderIssue = value;
                       _error = null;
                     });
                   }
                 },
                 controlAffinity: ListTileControlAffinity.leading,
                 contentPadding: EdgeInsets.zero,
                 dense: true, // Más compacto
              ),
              // --- CORRECCIÓN SizedBox ---
              const SizedBox(height: 10), // Corregido aquí
              // --- FIN CORRECCIÓN ---

              // --- Observaciones Generales ---
              if (_entireOrderIssue)
                TextField(
                  controller: _orderObservationsController,
                  enabled: !widget.isSubmitting, // Deshabilita si carga
                  decoration: InputDecoration(
                    labelText: 'Observaciones Generales del Pedido',
                    hintText: 'Describe el problema con el pedido completo...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),

              // --- Lista de Productos ---
              if (!_entireOrderIssue) ...[
                const Divider(height: 20, thickness: 1),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: const Text('Selecciona Productos Afectados:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _productIssuesState.length,
                  itemBuilder: (context, index) {
                    final issueState = _productIssuesState[index];
                    final product = issueState.productoOriginal;
                    final isSelected = issueState.selected;

                    return Card( // --- Card para cada producto ---
                      elevation: isSelected ? 3 : 1,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: isSelected
                            ? BorderSide(color: Colors.orange.shade400, width: 1.5)
                            : BorderSide(color: Colors.grey.shade300)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // --- Encabezado con Checkbox, Imagen, Nombre ---
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: isSelected,
                                  onChanged: widget.isSubmitting ? null : (value) { // Deshabilita si carga
                                    if (value != null) {
                                      setState(() {
                                         issueState.selected = value;
                                         _error = null;
                                      });
                                    }
                                  },
                                  visualDensity: VisualDensity.compact,
                                  activeColor: Colors.orange,
                                ),
                                if (product.foto != null && product.foto!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 10.0, top: 5), // Ajusta padding
                                    child: ClipRRect( // Para bordes redondeados
                                      borderRadius: BorderRadius.circular(4),
                                      child: Image.network(product.foto!, width: 45, height: 45, fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(width: 45, height: 45, color: Colors.grey.shade200, child: const Icon(Icons.broken_image, size: 24, color: Colors.grey)),
                                      ),
                                    ),
                                  ),
                                Expanded(
                                  child: Padding( // Padding para texto
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                         Text(product.nombre, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                         Text('Cantidad original: ${product.cantidad}', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ), // --- Fin Row Encabezado ---

                            // --- Campos si está Seleccionado ---
                            if (isSelected) ...[
                              const SizedBox(height: 12),
                              // Dropdown Estado Producto
                              DropdownButtonFormField<String>(
                                value: issueState.status,
                                items: ['Disponible', ...availableStatuses]
                                    .map((s) => DropdownMenuItem(value: s, child: Text(s, style: TextStyle(fontSize: 14))))
                                    .toList(),
                                onChanged: widget.isSubmitting ? null : (value) { // Deshabilita si carga
                                  if (value != null) {
                                    setState(() => issueState.status = value);
                                  }
                                },
                                decoration: InputDecoration(
                                  labelText: 'Estado Producto',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12), // Ajusta padding interno
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Campo Cantidad Afectada
                              if (issueState.status == 'Incompleto')
                                TextField(
                                  controller: issueState.quantityController,
                                  enabled: !widget.isSubmitting, // Deshabilita si carga
                                  decoration: InputDecoration(
                                    labelText: 'Cantidad Afectada',
                                    hintText: 'Máx: ${product.cantidad}',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                    filled: true,
                                    fillColor: Colors.grey.shade100,
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                ),

                              // Campo Observaciones Producto
                              if (issueState.status == 'Incidente' || issueState.status == 'Incompleto')
                                Padding(
                                  padding: EdgeInsets.only(top: issueState.status == 'Incompleto' ? 10.0 : 0),
                                  child: TextField(
                                    controller: issueState.observationsController,
                                    enabled: !widget.isSubmitting, // Deshabilita si carga
                                    decoration: InputDecoration(
                                      labelText: 'Observaciones Producto',
                                      hintText: 'Describe el problema...',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      isDense: true,
                                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                      filled: true,
                                      fillColor: Colors.grey.shade100,
                                    ),
                                    maxLines: 2,
                                    textCapitalization: TextCapitalization.sentences,
                                  ),
                                ),
                            ] 
                          ],
                        ),
                      ),
                    ); 
                  },
                ), 
              ] 
            ],
          ),
        ),
      ), // --- Fin SizedBox ---
      actionsAlignment: MainAxisAlignment.spaceBetween, 
      actions: <Widget>[
         TextButton(
           child: const Text('Cancelar'),
           onPressed: widget.isSubmitting ? null : () { Navigator.of(context).pop(); },
         ),
         ElevatedButton.icon(
           icon: widget.isSubmitting
                ? Container(width: 18, height: 18, padding: const EdgeInsets.all(2.0), child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.send, size: 18),
           label: Text(widget.isSubmitting ? 'Guardando...' : 'Guardar Cambios'),
           onPressed: widget.isSubmitting ? null : _handleSubmit,
           style: ElevatedButton.styleFrom(
             backgroundColor: Colors.purple,
             foregroundColor: Colors.white,
             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), 
             textStyle: const TextStyle(fontSize: 14) 
           ),
         ),
      ],
    );
  }
}