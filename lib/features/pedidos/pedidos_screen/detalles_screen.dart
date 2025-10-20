import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/model_pedidos.dart'; 

Map<String, dynamic> _getProductStatusStyle(String status) {
  final normalizedStatus = status.toLowerCase();

  if (normalizedStatus.contains('disponible')) {
    return {
      'color': Colors.green.shade700, 
      'bgColor': Colors.green.shade50, 
      'borderColor': Colors.green.shade200,
      'icon': Icons.check_circle_outlined
    };
  } else if (normalizedStatus.contains('incompleto')) {
    return {
      'color': Colors.orange.shade700, 
      'bgColor': Colors.orange.shade50, 
      'borderColor': Colors.orange.shade200,
      'icon': Icons.error_outline
    };
  } else if (normalizedStatus.contains('incidente')) {
    return {
      'color': Colors.red.shade700, 
      'bgColor': Colors.red.shade50, 
      'borderColor': Colors.red.shade200,
      'icon': Icons.warning_amber_outlined
    };
  } else if (normalizedStatus.contains('faltante')) {
    return {
      'color': Colors.deepOrange.shade700, 
      'bgColor': Colors.deepOrange.shade50, 
      'borderColor': Colors.deepOrange.shade200,
      'icon': Icons.inventory_2_outlined
    };
  }
  return {
    'color': Colors.grey.shade700, 
    'bgColor': Colors.grey.shade50, 
    'borderColor': Colors.grey.shade200,
    'icon': Icons.help_outline
  };
}

class OrderDetailsModal extends StatelessWidget {
  final Pedido order;

  const OrderDetailsModal({super.key, required this.order});

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Widget _buildInfoCard(String label, String value, {IconData? icon, bool isAccent = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1, // Aseguramos que el label no desborde si es largo
                overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isAccent ? Colors.red.shade700 : Colors.black87,
              height: 1.3,
            ),
            maxLines: 2, // <-- Limitamos la dirección a 2 líneas
          overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;
    final double maxModalWidth = isSmallScreen 
        ? MediaQuery.of(context).size.width * 0.98
        : MediaQuery.of(context).size.width * 0.85;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 20,
        vertical: isSmallScreen ? 12 : 20,
      ),
      elevation: 8,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxModalWidth,
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- ENCABEZADO ---
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 20 : 24,
                vertical: isSmallScreen ? 16 : 20,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade600, Colors.orange.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.shade300,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.receipt_long, 
                      color: Colors.white, 
                      size: isSmallScreen ? 20 : 24
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 8 : 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pedido #${order.id}',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Detalles completos del pedido',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 11 : 13,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close, 
                        color: Colors.white, 
                        size: isSmallScreen ? 18 : 20
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 40),
                  ),
                ],
              ),
            ),
            
            // --- CONTENIDO PRINCIPAL CON SCROLL ---
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SECCIÓN INFORMACIÓN GENERAL
                    _buildSectionHeader(
                      title: 'Información General',
                      icon: Icons.info_outline,
                      color: Colors.blue.shade600,
                      isSmallScreen: isSmallScreen,
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 20),

                    // Grid de información responsive
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = constraints.maxWidth < 400 ? 1 : 2;
                        return GridView.count(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: isSmallScreen ? 12 : 16,
                          mainAxisSpacing: isSmallScreen ? 12 : 16,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: crossAxisCount == 1 ? 
                            (isSmallScreen ? 2.8 : 3.2) : 
                            (isSmallScreen ? 2.2 : 2.8),
                          children: [
                            _buildInfoCard(
                              'Descripción',
                              order.descripcion,
                              icon: Icons.description_outlined,
                            ),
                            _buildInfoCard(
                              'Ubicación',
                              '${order.localidad}, ${order.municipio}, ${order.estado}',
                              icon: Icons.location_on_outlined,
                            ),
                            _buildInfoCard(
                              'Fecha de Entrega',
                              _formatDate(order.fechaEntrega),
                              icon: Icons.calendar_today_outlined,
                            ),
                            _buildInfoCard(
                              'Dirección',
                              order.direccion,
                              icon: Icons.home_outlined,
                            ),
                          ],
                        );
                      },
                    ),

                    // Observaciones especiales
                    if (order.observaciones != null && order.observaciones!.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: isSmallScreen ? 16 : 20),
                        child: _buildInfoCard(
                          'Observaciones Especiales',
                          order.observaciones!,
                          icon: Icons.warning_amber_outlined,
                          isAccent: true,
                        ),
                      ),
                    
                    SizedBox(height: isSmallScreen ? 24 : 32),
                    _buildDivider(),
                    SizedBox(height: isSmallScreen ? 24 : 32),

                    // SECCIÓN PRODUCTOS
                    _buildSectionHeader(
                      title: 'Productos (${order.productos.length})',
                      icon: Icons.inventory_2_outlined,
                      color: Colors.green.shade600,
                      isSmallScreen: isSmallScreen,
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 20),

                    // Lista de productos
                    ...order.productos.asMap().entries.map((entry) {
                      final index = entry.key;
                      final product = entry.value;
                      final style = _getProductStatusStyle(product.estado);
                      
                      return Container(
                        margin: EdgeInsets.only(
                          bottom: index == order.productos.length - 1 ? 0 : 
                                 (isSmallScreen ? 12 : 16),
                        ),
                        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: style['borderColor']!),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade100,
                              blurRadius: 12,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Encabezado del producto
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 10 : 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade800,
                                    ),
                                  ),
                                ),
                                SizedBox(width: isSmallScreen ? 8 : 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.nombre,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold, 
                                          fontSize: isSmallScreen ? 14 : 16,
                                          height: 1.4,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: isSmallScreen ? 6 : 8),
                                      // Estado con icono
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: isSmallScreen ? 8 : 10,
                                          vertical: isSmallScreen ? 4 : 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: style['bgColor'],
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              style['icon'],
                                              size: isSmallScreen ? 12 : 14,
                                              color: style['color'],
                                            ),
                                            SizedBox(width: isSmallScreen ? 4 : 6),
                                            Text(
                                              product.estado,
                                              style: TextStyle(
                                                color: style['color'], 
                                                fontSize: isSmallScreen ? 10 : 12, 
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '\$${product.subtotal.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold, 
                                        color: Colors.green.shade600,
                                        fontSize: isSmallScreen ? 16 : 18,
                                      ),
                                    ),
                                    Text(
                                      'Subtotal',
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 10 : 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: isSmallScreen ? 12 : 16),

                            // Detalles del producto
                            Container(
                              padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: isSmallScreen 
                                  ? _buildProductDetailsVertical(product)
                                  : _buildProductDetailsHorizontal(product),
                            ),
                            
                            // Nota del producto
                            if (product.nota != null && product.nota!.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(top: isSmallScreen ? 12 : 16),
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.orange.shade200),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.note_outlined,
                                        size: isSmallScreen ? 14 : 16,
                                        color: Colors.orange.shade700,
                                      ),
                                      SizedBox(width: isSmallScreen ? 6 : 8),
                                      Expanded(
                                        child: Text(
                                          product.nota!,
                                          style: TextStyle(
                                            fontSize: isSmallScreen ? 12 : 13, 
                                            color: Colors.orange.shade800,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),

                    // Espacio final para scroll
                    SizedBox(height: isSmallScreen ? 8 : 16),
                  ],
                ),
              ),
            ),
            
            // --- PIE DE PÁGINA ---
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 16 : 24,
                vertical: isSmallScreen ? 16 : 20,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: isSmallScreen 
                  ? _buildFooterVertical(context, order)
                  : _buildFooterHorizontal(context, order),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title, 
    required IconData icon, 
    required Color color,
    required bool isSmallScreen,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon, 
            size: isSmallScreen ? 18 : 20, 
            color: color
          ),
        ),
        SizedBox(width: isSmallScreen ? 8 : 12),
        Text(
          title,
          style: TextStyle(
            fontSize: isSmallScreen ? 15 : 17,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.shade200,
            Colors.grey.shade300,
            Colors.grey.shade200,
          ],
        ),
      ),
    );
  }


Widget _buildProductDetailsHorizontal(Producto product) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Cantidad
        Expanded(
          child: _buildEnhancedProductDetail(
            'Cantidad',
            '${product.cantidad}',
            Icons.format_list_numbered_outlined,
            Colors.blue.shade600,
            'und',
            false,
          ),
        ),
        
        // Separador
        Container(
          width: 1,
          height: 40,
          color: Colors.grey.shade300,
          margin: const EdgeInsets.symmetric(horizontal: 8),
        ),
        
        // Precio Unitario
        Expanded(
          child: _buildEnhancedProductDetail(
            'Precio Unit.',
            '\$${product.precio.toStringAsFixed(2)}',
            Icons.attach_money_outlined,
            Colors.green.shade600,
            'c/u',
            false,
          ),
        ),
        
        // Separador
        Container(
          width: 1,
          height: 40,
          color: Colors.grey.shade300,
          margin: const EdgeInsets.symmetric(horizontal: 8),
        ),
        
        // Total
        Expanded(
          child: _buildEnhancedProductDetail(
            'Total',
            '\$${product.subtotal.toStringAsFixed(2)}',
            Icons.calculate_outlined,
            Colors.orange.shade600,
            'subtotal',
            false,
          ),
        ),
      ],
    ),
  );
}

Widget _buildProductDetailsVertical(Producto product) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
    child: Column(
      children: [
        // Fila superior
        Row(
          children: [
            Expanded(
              child: _buildEnhancedProductDetail(
                'Cantidad',
                '${product.cantidad}',
                Icons.format_list_numbered_outlined,
                Colors.blue.shade600,
                'und',
                true,
              ),
            ),
            Container(
              width: 1,
              height: 30,
              color: Colors.grey.shade300,
              margin: const EdgeInsets.symmetric(horizontal: 8),
            ),
            Expanded(
              child: _buildEnhancedProductDetail(
                'Precio Unit.',
                '\$${product.precio.toStringAsFixed(2)}',
                Icons.attach_money_outlined,
                Colors.green.shade600,
                'c/u',
                true,
              ),
            ),
          ],
        ),
        
        // Separador entre filas
        Container(
          height: 1,
          margin: const EdgeInsets.symmetric(vertical: 8),
          color: Colors.grey.shade200,
        ),
        
        // Fila inferior - Total
        _buildEnhancedProductDetail(
          'Total del Producto',
          '\$${product.subtotal.toStringAsFixed(2)}',
          Icons.calculate_outlined,
          Colors.orange.shade600,
          'total',
          true,
        ),
      ],
    ),
  );
}

Widget _buildEnhancedProductDetail(
  String label, 
  String value, 
  IconData icon, 
  Color color, 
  String type,
  bool isSmall
) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey.shade100),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icono y etiqueta
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon, 
                size: isSmall ? 12 : 14, 
                color: color,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: isSmall ? 10 : 11,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 4),
        
        // Valor
        Text(
          value,
          style: TextStyle(
            fontSize: isSmall ? 13 : 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 2),
        
        // Tipo/Unidad
        Text(
          _getTypeText(type),
          style: TextStyle(
            fontSize: isSmall ? 9 : 10,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

String _getTypeText(String type) {
  switch (type) {
    case 'und':
      return 'unidades';
    case 'c/u':
      return 'cada uno';
    case 'subtotal':
      return 'subtotal';
    case 'total':
      return 'total producto';
    default:
      return '';
  }
}


  Widget _buildProductDetail(String label, String value, IconData icon, Color color, bool isSmall) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon, 
            size: isSmall ? 12 : 14, 
            color: color
          ),
        ),
        SizedBox(height: isSmall ? 4 : 6),
        Text(
          label,
          style: TextStyle(
            fontSize: isSmall ? 9 : 10,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: isSmall ? 11 : 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildFooterHorizontal(BuildContext context, Pedido order) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'VALOR TOTAL DEL PEDIDO',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '\$${order.totalAPagar.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                  height: 1.2,
                ),
              ),
           
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.grey.shade800,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            elevation: 1,
            shadowColor: Colors.grey.shade200,
          ),
          icon: const Icon(Icons.close, size: 18),
          label: const Text(
            'Cerrar Detalles',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterVertical(BuildContext context, Pedido order) {
    return Column(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'VALOR TOTAL DEL PEDIDO',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '\$${order.totalAPagar.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade700,
                height: 1.2,
              ),
            ),
          
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.grey.shade800,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              elevation: 1,
            ),
            icon: const Icon(Icons.close, size: 18),
            label: const Text(
              'Cerrar Detalles',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}