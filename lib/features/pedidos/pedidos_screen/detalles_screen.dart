import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/model_pedidos.dart';

Map<String, dynamic> _getProductStatusStyle(String status) {
  final normalizedStatus = status.toLowerCase();

  if (normalizedStatus.contains('disponible')) {
    return {
      'color': Colors.green.shade600,
      'bgColor': Colors.green.shade50,
      'borderColor': Colors.green.shade100,
      'icon': Icons.check_circle_outline
    };
  } else if (normalizedStatus.contains('incompleto')) {
    return {
      'color': Colors.orange.shade600,
      'bgColor': Colors.orange.shade50,
      'borderColor': Colors.orange.shade100,
      'icon': Icons.error_outline
    };
  } else if (normalizedStatus.contains('incidente')) {
    return {
      'color': Colors.red.shade600,
      'bgColor': Colors.red.shade50,
      'borderColor': Colors.red.shade100,
      'icon': Icons.warning_amber_outlined
    };
  } else if (normalizedStatus.contains('faltante')) {
    return {
      'color': Colors.deepOrange.shade600,
      'bgColor': Colors.deepOrange.shade50,
      'borderColor': Colors.deepOrange.shade100,
      'icon': Icons.inventory_2_outlined
    };
  }
  return {
    'color': Colors.grey.shade600,
    'bgColor': Colors.grey.shade50,
    'borderColor': Colors.grey.shade100,
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: Colors.grey.shade700),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isAccent ? Colors.red.shade600 : Colors.black87,
              height: 1.3,
            ),
            maxLines: 2,
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
        ? MediaQuery.of(context).size.width * 0.95
        : MediaQuery.of(context).size.width * 0.80;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 8 : 16,
        vertical: isSmallScreen ? 8 : 16,
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxModalWidth,
          maxHeight: MediaQuery.of(context).size.height * 0.90,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- HEADER ---
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 16 : 24,
                vertical: isSmallScreen ? 16 : 20,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color.fromARGB(255, 249, 171, 37), const Color.fromARGB(255, 223, 179, 32)],
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
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.receipt_long,
                      color: Colors.white,
                      size: isSmallScreen ? 22 : 26,
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
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Detalles completos del pedido',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 14,
                            color: Colors.white.withOpacity(0.85),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: isSmallScreen ? 20 : 22,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // --- MAIN CONTENT WITH SCROLL ---
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // GENERAL INFORMATION SECTION
                    _buildSectionHeader(
                      title: 'Información General',
                      icon: Icons.info_outline,
                      color: Colors.blue.shade600,
                      isSmallScreen: isSmallScreen,
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 20),

                    // Responsive Grid
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = constraints.maxWidth < 400 ? 1 : 2;
                        return GridView.count(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: isSmallScreen ? 12 : 16,
                          mainAxisSpacing: isSmallScreen ? 12 : 16,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: crossAxisCount == 1
                              ? (isSmallScreen ? 3.0 : 3.5)
                              : (isSmallScreen ? 2.4 : 3.0),
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

                    // Special Observations
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

                    // PRODUCTS SECTION
                    _buildSectionHeader(
                      title: 'Productos (${order.productos.length})',
                      icon: Icons.inventory_2_outlined,
                      color: Colors.green.shade600,
                      isSmallScreen: isSmallScreen,
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 20),

                    // Product List
                    ...order.productos.asMap().entries.map((entry) {
                      final index = entry.key;
                      final product = entry.value;
                      final style = _getProductStatusStyle(product.estado);

                      return Container(
                        margin: EdgeInsets.only(
                          bottom: index == order.productos.length - 1 ? 0 : (isSmallScreen ? 12 : 16),
                        ),
                        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: style['borderColor']!),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Header
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 12 : 14,
                                      fontWeight: FontWeight.w700,
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
                                          fontWeight: FontWeight.w700,
                                          fontSize: isSmallScreen ? 15 : 17,
                                          height: 1.4,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: isSmallScreen ? 6 : 8),
                                      // Status Badge
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: isSmallScreen ? 10 : 12,
                                          vertical: isSmallScreen ? 5 : 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: style['bgColor'],
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: style['borderColor']!, width: 0.5),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              style['icon'],
                                              size: isSmallScreen ? 14 : 16,
                                              color: style['color'],
                                            ),
                                            SizedBox(width: isSmallScreen ? 4 : 6),
                                            Text(
                                              product.estado,
                                              style: TextStyle(
                                                color: style['color'],
                                                fontSize: isSmallScreen ? 11 : 12,
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
                                        fontWeight: FontWeight.w700,
                                        color: Colors.green.shade600,
                                        fontSize: isSmallScreen ? 17 : 19,
                                      ),
                                    ),
                                    Text(
                                      'Subtotal',
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 11 : 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: isSmallScreen ? 12 : 16),

                            // Product Details
                            Container(
                              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade100),
                              ),
                              child: isSmallScreen
                                  ? _buildProductDetailsVertical(product)
                                  : _buildProductDetailsHorizontal(product),
                            ),

                            // Product Note
                            if (product.nota != null && product.nota!.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(top: isSmallScreen ? 12 : 16),
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.orange.shade100),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.note_outlined,
                                        size: isSmallScreen ? 16 : 18,
                                        color: Colors.orange.shade700,
                                      ),
                                      SizedBox(width: isSmallScreen ? 8 : 10),
                                      Expanded(
                                        child: Text(
                                          product.nota!,
                                          style: TextStyle(
                                            fontSize: isSmallScreen ? 13 : 14,
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

                    // Final Spacing for Scroll
                    SizedBox(height: isSmallScreen ? 16 : 24),
                  ],
                ),
              ),
            ),

            // --- FOOTER ---
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 16 : 24,
                vertical: isSmallScreen ? 16 : 20,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(top: BorderSide(color: Colors.grey.shade100)),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
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
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: isSmallScreen ? 20 : 22,
            color: color,
          ),
        ),
        SizedBox(width: isSmallScreen ? 10 : 12),
        Text(
          title,
          style: TextStyle(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade900,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.shade100,
            Colors.grey.shade200,
            Colors.grey.shade100,
          ],
        ),
      ),
    );
  }

  Widget _buildProductDetailsHorizontal(Producto product) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Quantity
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
          Container(
            width: 1,
            height: 48,
            color: Colors.grey.shade200,
            margin: const EdgeInsets.symmetric(horizontal: 12),
          ),
          // Unit Price
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
          Container(
            width: 1,
            height: 48,
            color: Colors.grey.shade200,
            margin: const EdgeInsets.symmetric(horizontal: 12),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Column(
        children: [
          // Top Row
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
                height: 40,
                color: Colors.grey.shade200,
                margin: const EdgeInsets.symmetric(horizontal: 12),
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
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(vertical: 12),
            color: Colors.grey.shade100,
          ),
          // Bottom Row - Total
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
    bool isSmall,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon and Label
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: isSmall ? 14 : 16,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: isSmall ? 11 : 12,
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
          const SizedBox(height: 6),
          // Value
          Text(
            value,
            style: TextStyle(
              fontSize: isSmall ? 14 : 15,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          // Type/Unit
          Text(
            _getTypeText(type),
            style: TextStyle(
              fontSize: isSmall ? 10 : 11,
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

  Widget _buildFooterHorizontal(BuildContext context, Pedido order) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'VALOR TOTAL DEL PEDIDO',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '\$${order.totalAPagar.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.blue.shade700,
                height: 1.2,
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            shadowColor: Colors.blue.shade200,
          ),
          icon: const Icon(Icons.close, size: 20),
          label: const Text(
            'Cerrar Detalles',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '\$${order.totalAPagar.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.blue.shade700,
                height: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 207, 158, 10),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              shadowColor: const Color.fromARGB(255, 167, 105, 12),
            ),
            icon: const Icon(Icons.close, size: 20),
            label: const Text(
              'Cerrar Detalles',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}