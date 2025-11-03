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
              return const Center(child: CircularProgressIndicator());
            }
            if (state is HistoryError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Error: ${state.message}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              );
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

            return ListView(
              padding: const EdgeInsets.all(12),
              children: [
                _SummaryCard(totalPedidos: totalPedidos, montoTotal: montoTotal),
                const SizedBox(height: 12),

                _FiltrosRow(
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

                const SizedBox(height: 8),
                if (filtrados.isEmpty)
                  const _EmptyCard(texto: 'No hay pedidos para los filtros seleccionados')
                else
                  ...filtrados.map((p) => _OrderTile(
                        p: p,
                        onViewDetails: () => _showDetails(context, p),
                      )),
                const SizedBox(height: 24),
              ],
            );
          },
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
          constraints: const BoxConstraints(maxHeight: 520),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pedido #${p['id'] ?? ''}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('${p['descripcion'] ?? 'Sin descripción'}',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text('${p['direccion'] ?? ''}'),
                Text('${p['localidad'] ?? ''}, ${p['municipio'] ?? ''}, ${p['estado'] ?? ''}'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _chip(_cap(p['estado_pedido'])),
                    if (fechaCorta.isNotEmpty) _chip(fechaCorta),
                    _chip('Días: ${p['diasAlquiler'] ?? 0}'),
                  ],
                ),
                const Divider(height: 20),
                const Text('Productos', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Expanded(
                  child: ListView(
                    children: [
                      for (final pr in (p['productos'] as List? ?? []))
                        ListTile(
                          isThreeLine: true,
                          dense: true,
                          title: Text('${pr['nombre'] ?? 'Producto'}'),
                          subtitle: Text(
                            'Cant: ${pr['cantidad'] ?? 0}  •  '
                            'Color: ${pr['color'] ?? 'N/A'}  •  '
                            '${_cap(pr['estado'] ?? 'Disponible')}',
                          ),
                          trailing: Text('\$${_money(pr['subtotal'])}'),
                        ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cerrar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------- Widgets de apoyo ----------

class _SummaryCard extends StatelessWidget {
  final int totalPedidos;
  final double montoTotal;
  const _SummaryCard({required this.totalPedidos, required this.montoTotal});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFB300), Color(0xFFFF6F00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: Colors.orange.withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 6)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Resumen del Historial',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            Row(
              children: [
                _pill('Total Pedidos', '$totalPedidos'),
                const SizedBox(width: 12),
                _pill('Monto Total', '\$${montoTotal.toStringAsFixed(0)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: LayoutBuilder(
          builder: (context, c) {
            const spacing = 8.0;

            // 1 columna en pantallas angostas
            final bool singleColumn = c.maxWidth < 360;
            final double itemWidth = singleColumn
                ? c.maxWidth
                : (c.maxWidth - spacing) / 2; // 2 columnas

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                _dd('Estado', estados, filtroEstado, onChangeEstado, itemWidth),
                _dd('Municipio', municipios, filtroMunicipio, onChangeMunicipio, itemWidth),
                _dd('Tipo', tipos, filtroTipo, onChangeTipo, itemWidth),
                _dd('Estatus', estatus, filtroEstatus, onChangeEstatus, itemWidth),
                TextButton.icon(
                  onPressed: onClear,
                  icon: const Icon(Icons.filter_alt_off),
                  label: const Text('Limpiar'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _dd(
    String hint,
    List<String> items,
    String? value,
    ValueChanged<String?> onChanged,
    double width,
  ) {
    final opts = [''].followedBy(items).toList(); // '' = "Todos"
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 0, maxWidth: width),
      child: SizedBox(
        width: width,
        child: DropdownButtonFormField<String>(
          value: value ?? '',
          isDense: true,
          isExpanded: true, // se ajusta al ancho disponible
          decoration: const InputDecoration(
            labelText: '',
            hintText: 'Todos',
            border: OutlineInputBorder(),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          items: opts.map((e) {
            final text = e.isEmpty ? 'Todos' : e;
            return DropdownMenuItem(value: e.isEmpty ? '' : e, child: Text(text));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
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
        padding: const EdgeInsets.all(16),
        child: Center(child: Text(texto)),
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
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        isThreeLine: true, // más alto para evitar overflow
        title: Text(desc, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$dir\n$muni, $edo', maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: [
                _chip(estadoPedido),
                if (fecha.isNotEmpty) _chip(fecha),
                _chip('Días: $dias'),
              ],
            ),
          ],
        ),
        trailing: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 0, maxWidth: 96),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('#$id', style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text('\$${_money(total)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                TextButton(onPressed: onViewDetails, child: const Text('Detalles')),
              ],
            ),
          ),
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

Widget _chip(String text) => Chip(label: Text(text));
