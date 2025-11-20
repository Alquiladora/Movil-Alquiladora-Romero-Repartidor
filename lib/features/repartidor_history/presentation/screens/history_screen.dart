import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/history_bloc.dart';
import '../bloc/history_state.dart';
import '../bloc/history_event.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String? filtroEstado;
  String? filtroMunicipio;
  String? filtroTipo;
  String? filtroEstatus;

  @override
  void initState() {
    super.initState();
    context.read<HistoryBloc>().add(LoadHistory());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: BlocBuilder<HistoryBloc, HistoryState>(
          builder: (context, state) {
            if (state is HistoryLoading) {
              return _buildLoadingState();
            }
            if (state is HistoryError) {
              return _buildErrorState(state);
            }

            final loaded = state as HistoryLoaded;
            final pedidos = loaded.pedidos;

            final estados = _unique(pedidos.map((e) => '${e['estado'] ?? ''}'));
            final municipios = _unique(
              pedidos
                  .where((e) => filtroEstado == null || e['estado'] == filtroEstado)
                  .map((e) => '${e['municipio'] ?? ''}'),
            );
            final tipos = _unique(pedidos.map((e) => '${e['tipo_pedido'] ?? ''}'));
            final estatus = _unique(pedidos.map((e) => '${e['estado_pedido'] ?? ''}'));

            final filtrados = pedidos.where((p) {
              final okEstado    = filtroEstado == null    || p['estado'] == filtroEstado;
              final okMunicipio = filtroMunicipio == null || p['municipio'] == filtroMunicipio;
              final okTipo      = filtroTipo == null      || p['tipo_pedido'] == filtroTipo;
              final okEstatus   = filtroEstatus == null   || _cap(p['estado_pedido']) == _cap(filtroEstatus);
              return okEstado && okMunicipio && okTipo && okEstatus;
            }).toList();

            final totalPedidos = filtrados.length;
            final montoTotal = filtrados.fold<double>(0, (acc, p) {
              final v = double.tryParse('${p['total_a_pagar']}') ?? 0;
              return acc + v;
            });

            return Column(
              children: [
                // Header fijo
                _buildAppBar(),
                
                // Contenido desplazable
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      // Resumen
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: _SummaryCard(totalPedidos: totalPedidos, montoTotal: montoTotal),
                        ),
                      ),

                      // Filtros
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _FiltrosRow(
                            estados: estados,
                            municipios: municipios,
                            tipos: tipos,
                            estatus: estatus,
                            filtroEstado: filtroEstado,
                            filtroMunicipio: filtroMunicipio,
                            filtroTipo: filtroTipo,
                            filtroEstatus: filtroEstatus,
                            onChangeEstado: (v) => setState(() {
                              filtroEstado = v?.isEmpty == true ? null : v;
                              filtroMunicipio = null;
                            }),
                            onChangeMunicipio: (v) => setState(() {
                              filtroMunicipio = v?.isEmpty == true ? null : v;
                            }),
                            onChangeTipo: (v) => setState(() {
                              filtroTipo = v?.isEmpty == true ? null : v;
                            }),
                            onChangeEstatus: (v) => setState(() {
                              filtroEstatus = v?.isEmpty == true ? null : v;
                            }),
                            onClear: () => setState(() {
                              filtroEstado = null;
                              filtroMunicipio = null;
                              filtroTipo = null;
                              filtroEstatus = null;
                            }),
                          ),
                        ),
                      ),

                      // Lista de pedidos
                      if (filtrados.isEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: _EmptyCard(texto: 'No hay pedidos para los filtros seleccionados'),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.all(16),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _OrderTile(
                                  p: filtrados[index],
                                  onViewDetails: () => _showDetails(context, filtrados[index]),
                                ),
                              ),
                              childCount: filtrados.length,
                            ),
                          ),
                        ),
                      
                      // Espacio final
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 24),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator.adaptive(),
          const SizedBox(height: 16),
          Text(
            'Cargando historial...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(HistoryError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Ocurrió un error',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.read<HistoryBloc>().add(LoadHistory()),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
           
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Historial de Pedidos',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ),
            IconButton(
              onPressed: () => context.read<HistoryBloc>().add(LoadHistory()),
              icon: const Icon(Icons.refresh_rounded),
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey[100],
              ),
              tooltip: 'Actualizar',
            ),
          ],
        ),
      ),
    );
  }

  void _showDetails(BuildContext context, Map<String, dynamic> p) {
    final fechaRaw = (p['fecha_entrega'] ?? '').toString();
    final fechaCorta = fechaRaw.contains('T') ? fechaRaw.split('T').first : fechaRaw;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Pedido #${p['id'] ?? ''}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Información principal
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${p['descripcion'] ?? 'Sin descripción'}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(Icons.location_on, '${p['direccion'] ?? ''}'),
                        _buildInfoRow(Icons.place, '${p['localidad'] ?? ''}, ${p['municipio'] ?? ''}, ${p['estado'] ?? ''}'),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Chips de estado
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _chip(_cap(p['estado_pedido']), 
                      color: _getStatusColor(p['estado_pedido'])),
                    if (fechaCorta.isNotEmpty) 
                      _chip(fechaCorta, color: Colors.blue[50], textColor: Colors.blue[800]),
                    _chip('Días: ${p['diasAlquiler'] ?? 0}', 
                      color: Colors.orange[50], textColor: Colors.orange[800]),
                  ],
                ),
                
                const SizedBox(height: 20),
                const Divider(),
                
                // Productos
                const Text(
                  'Productos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                Expanded(
                  child: ListView.builder(
                    itemCount: (p['productos'] as List? ?? []).length,
                    itemBuilder: (context, index) {
                      final pr = (p['productos'] as List? ?? [])[index];
                      return _ProductoItem(producto: pr);
                    },
                  ),
                ),
                
                const SizedBox(height: 16),
                // Total
                Card(
                  color: Colors.green[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total del pedido:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '\$${_money(p['total_a_pagar'])}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color? _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completado':
        return Colors.green[50];
      case 'pendiente':
        return Colors.orange[50];
      case 'cancelado':
        return Colors.red[50];
      default:
        return Colors.grey[50];
    }
  }
}

// ---------- Widgets mejorados ----------

class _SummaryCard extends StatelessWidget {
  final int totalPedidos;
  final double montoTotal;
  const _SummaryCard({required this.totalPedidos, required this.montoTotal});

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 400;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFB300), Color(0xFFFF6F00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: isSmall ? _buildSmallLayout() : _buildLargeLayout(),
    );
  }

  Widget _buildLargeLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen del Historial',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Todos tus pedidos en un solo lugar',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
        Row(
          children: [
            _pill('Total Pedidos', '$totalPedidos'),
            const SizedBox(width: 16),
            _pill('Monto Total', '\$${montoTotal.toStringAsFixed(0)}'),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resumen del Historial',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _pill('Total Pedidos', '$totalPedidos'),
            _pill('Monto Total', '\$${montoTotal.toStringAsFixed(0)}'),
          ],
        ),
      ],
    );
  }

  Widget _pill(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FiltrosRow extends StatelessWidget {
  final List<String> estados;
  final List<String> municipios;
  final List<String> tipos;
  final List<String> estatus;

  final String? filtroEstado;
  final String? filtroMunicipio;
  final String? filtroTipo;
  final String? filtroEstatus;

  final ValueChanged<String?> onChangeEstado;
  final ValueChanged<String?> onChangeMunicipio;
  final ValueChanged<String?> onChangeTipo;
  final ValueChanged<String?> onChangeEstatus;
  final VoidCallback onClear;

  const _FiltrosRow({
    required this.estados,
    required this.municipios,
    required this.tipos,
    required this.estatus,
    required this.filtroEstado,
    required this.filtroMunicipio,
    required this.filtroTipo,
    required this.filtroEstatus,
    required this.onChangeEstado,
    required this.onChangeMunicipio,
    required this.onChangeTipo,
    required this.onChangeEstatus,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 600;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.filter_alt_rounded, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Filtros',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: onClear,
                  icon: const Icon(Icons.clear_all_rounded, size: 16),
                  label: const Text('Limpiar'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isSmall) _buildSingleColumn() else _buildDoubleColumn(),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleColumn() {
    return Column(
      children: [
        _dd('Estado', estados, filtroEstado, onChangeEstado),
        const SizedBox(height: 12),
        _dd('Municipio', municipios, filtroMunicipio, onChangeMunicipio),
        const SizedBox(height: 12),
        _dd('Tipo de pedido', tipos, filtroTipo, onChangeTipo),
        const SizedBox(height: 12),
        _dd('Estatus', estatus, filtroEstatus, onChangeEstatus),
      ],
    );
  }

  Widget _buildDoubleColumn() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        SizedBox(width: 180, child: _dd('Estado', estados, filtroEstado, onChangeEstado)),
        SizedBox(width: 180, child: _dd('Municipio', municipios, filtroMunicipio, onChangeMunicipio)),
        SizedBox(width: 180, child: _dd('Tipo de pedido', tipos, filtroTipo, onChangeTipo)),
        SizedBox(width: 180, child: _dd('Estatus', estatus, filtroEstatus, onChangeEstatus)),
      ],
    );
  }

  Widget _dd(
    String hint,
    List<String> items,
    String? value,
    ValueChanged<String?> onChanged,
  ) {
    final opts = [''].followedBy(items).toList();
    return DropdownButtonFormField<String>(
      value: value ?? '',
      isDense: true,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: opts.map((e) {
        final text = e.isEmpty ? 'Todos' : e;
        return DropdownMenuItem(
          value: e.isEmpty ? '' : e,
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String texto;
  const _EmptyCard({required this.texto});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_rounded,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  final Map<String, dynamic> p;
  final VoidCallback onViewDetails;
  const _OrderTile({required this.p, required this.onViewDetails});

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 400;
    final id = p['id'] ?? '';
    final desc = p['descripcion'] ?? 'Sin descripción';
    final estadoPedido = _cap(p['estado_pedido']);
    final total = double.tryParse('${p['total_a_pagar']}') ?? 0;
    final dir = p['direccion'] ?? '';
    final muni = p['municipio'] ?? '';
    final edo  = p['estado'] ?? '';
    final fechaRaw = (p['fecha_entrega'] ?? '').toString();
    final fecha = fechaRaw.contains('T') ? fechaRaw.split('T').first : fechaRaw;
    final dias = p['diasAlquiler'] ?? 0;

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onViewDetails,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isSmall ? _buildSmallLayout() : _buildLargeLayout(),
        ),
      ),
    );
  }

  Widget _buildLargeLayout() {
    final id = p['id'] ?? '';
    final desc = p['descripcion'] ?? 'Sin descripción';
    final estadoPedido = _cap(p['estado_pedido']);
    final total = double.tryParse('${p['total_a_pagar']}') ?? 0;
    final dir = p['direccion'] ?? '';
    final muni = p['municipio'] ?? '';
    final edo  = p['estado'] ?? '';
    final fechaRaw = (p['fecha_entrega'] ?? '').toString();
    final fecha = fechaRaw.contains('T') ? fechaRaw.split('T').first : fechaRaw;
    final dias = p['diasAlquiler'] ?? 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Información principal
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '#$id',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      desc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('$dir, $muni, $edo'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: [
                  _chip(estadoPedido, color: _getStatusColor(p['estado_pedido'])),
                  if (fecha.isNotEmpty) _chip(fecha, color: Colors.blue[50], textColor: Colors.blue[800]),
                  _chip('Días: $dias', color: Colors.orange[50], textColor: Colors.orange[800]),
                ],
              ),
            ],
          ),
        ),
        
        // Lado derecho con total y botón
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${_money(total)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: onViewDetails,
              child: const Text('Ver detalles'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallLayout() {
    final id = p['id'] ?? '';
    final desc = p['descripcion'] ?? 'Sin descripción';
    final estadoPedido = _cap(p['estado_pedido']);
    final total = double.tryParse('${p['total_a_pagar']}') ?? 0;
    final dir = p['direccion'] ?? '';
    final muni = p['municipio'] ?? '';
    final edo  = p['estado'] ?? '';
    final fechaRaw = (p['fecha_entrega'] ?? '').toString();
    final fecha = fechaRaw.contains('T') ? fechaRaw.split('T').first : fechaRaw;
    final dias = p['diasAlquiler'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '#$id',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            Text(
              '\$${_money(total)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          desc,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text('$dir, $muni, $edo', maxLines: 2),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          children: [
            _chip(estadoPedido, color: _getStatusColor(p['estado_pedido'])),
            if (fecha.isNotEmpty) _chip(fecha, color: Colors.blue[50], textColor: Colors.blue[800]),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.tonal(
            onPressed: onViewDetails,
            child: const Text('Ver detalles'),
          ),
        ),
      ],
    );
  }

  Color? _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completado':
        return Colors.green[50];
      case 'pendiente':
        return Colors.orange[50];
      case 'cancelado':
        return Colors.red[50];
      default:
        return Colors.grey[50];
    }
  }
}

class _ProductoItem extends StatelessWidget {
  final Map<String, dynamic> producto;
  
  const _ProductoItem({required this.producto});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Icono del producto
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.inventory_2_rounded, size: 20),
            ),
            const SizedBox(width: 12),
            
            // Información del producto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${producto['nombre'] ?? 'Producto'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Cantidad: ${producto['cantidad'] ?? 0} • '
                    'Color: ${producto['color'] ?? 'N/A'} • '
                    '${_cap(producto['estado'] ?? 'Disponible')}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            // Subtotal
            Text(
              '\$${_money(producto['subtotal'])}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- helpers ----------
List<String> _unique(Iterable<String> it) {
  final s = <String>{};
  for (final v in it) {
    final vv = v.trim();
    if (vv.isNotEmpty) s.add(vv);
  }
  final list = s.toList()..sort();
  return list;
}

String _cap(dynamic s) {
  final t = (s ?? '').toString();
  if (t.isEmpty) return 'Pendiente';
  return t[0].toUpperCase() + t.substring(1).toLowerCase();
}

String _money(dynamic n) {
  final d = double.tryParse('$n') ?? 0;
  return d.toStringAsFixed(2);
}

Widget _chip(String text, {Color? color, Color? textColor}) => Chip(
  label: Text(
    text,
    style: TextStyle(
      color: textColor ?? Colors.grey[800],
      fontSize: 12,
    ),
  ),
  backgroundColor: color ?? Colors.grey[100],
  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  visualDensity: VisualDensity.compact,
);