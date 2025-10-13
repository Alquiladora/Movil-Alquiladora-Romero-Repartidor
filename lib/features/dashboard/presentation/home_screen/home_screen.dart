import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../dashboard/presentation/home_bloc/home_bloc.dart';
import '../../../dashboard/presentation/home_bloc/home_event.dart';
import '../../../dashboard/presentation/home_bloc/home_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  //Funcion de hora saludo
  String _getGreeting() {
    final now = DateTime.now().toLocal();
    final hour = now.hour;
    if (hour >= 5 && hour < 12) {
      return "¡Buenos días!";
    } else if (hour >= 12 && hour < 19) {
      return "¡Buenas tardes!";
    } else {
      return "¡Buenas noches!";
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is HomeError) {
              return Center(
                child: Text(
                  "❌ ${state.message}",
                  style: const TextStyle(color: Colors.red),
                ),
              );
            } else if (state is HomeSuccess) {
             
              final responseData = state.data;
               print("Datos de recibidos edi1 $responseData");
                 final data = responseData['data'];

              final nombre = data['nombre'] ?? 'Usuario';
              final apellidoP = data['apellidoP'] ?? 'Anonimo';
              final total = data['total_pedidos']?.toString() ?? '0';
              final completados =
                  data['pedidos_completados']?.toString() ?? '0';
              final pendientes = data['pedidos_pendientes']?.toString() ?? '0';
              final incidencias =
                  data['pedidos_incidencias']?.toString() ?? '0';
              final rendimientos =
                  data['rendimiento_semanal']?.toString() ?? '0';
              final activo = data['activo']?.toString() ?? '0';
              final List<double> mockWeeklyData = [
            double.parse((data['dia_6'] ?? '0').toString()), 
              double.parse((data['dia_5'] ?? '0').toString()), 
              double.parse((data['dia_4'] ?? '0').toString()), 
              double.parse((data['dia_3'] ?? '0').toString()), 
              double.parse((data['dia_2'] ?? '0').toString()), 
              double.parse((data['dia_1'] ?? '0').toString()),
              double.parse((data['dia_0'] ?? '0').toString()), 
            ];


              return ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildWelcomeHeader(
                    "$nombre $apellidoP", 
                    _getGreeting(),
                    activo, 
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Estadísticas del Día"),
                  const SizedBox(height: 16),
                  _buildStatsGrid(
                    total,
                    completados,
                    pendientes,
                    incidencias,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Rendimiento Semanal",
                      trailing: "+$rendimientos%"),
                  const SizedBox(height: 16),
               _buildWeeklyChart(mockWeeklyData), 
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      
    );
  }

  Widget _buildWelcomeHeader(String userName, String greeting, String activo) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        gradient: const LinearGradient(
          colors: [Colors.amber, Colors.orange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white24,
            child: Icon(Icons.local_shipping, size: 30, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.lightGreenAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      activo == '1' ? "En servicio" : "Desactivado",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {String? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        if (trailing != null)
          Row(
            children: [
              const Icon(Icons.trending_up, color: Colors.green, size: 20),
              const SizedBox(width: 4),
              Text(
                trailing,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          )
      ],
    );
  }

  Widget _buildStatsGrid(
    String total,
    String completados,
    String pendientes,
    String incidencias,
  ) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      // Devolvemos el aspect ratio a un valor visualmente agradable
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          icon: Icons.inventory_2_outlined,
          value: total,
          label: "Pedidos Realizados",
          iconColor: Colors.orange,
        ),
        _buildStatCard(
          icon: Icons.check_circle_outline,
          value: completados,
          label: "Pedidos Completados",
          iconColor: Colors.green,
        ),
        _buildStatCard(
          icon: Icons.timer_outlined,
          value: pendientes,
          label: "Pedidos Pendientes",
          iconColor: Colors.amber.shade800,
        ),
        _buildStatCard(
          icon: Icons.warning_amber_rounded,
          value: incidencias,
          label: "Incidencias",
          iconColor: Colors.red,
        ),
      ],
    );
  }

  // ✅ WIDGET CORREGIDO CON LA SOLUCIÓN DEFINITIVA
  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        border: Border(left: BorderSide(color: iconColor, width: 5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 32, color: iconColor),
          // Usamos Expanded en lugar de Spacer para darle todo el espacio sobrante al contenido flexible
          Expanded(
            // ✅ LA CORRECCIÓN DEFINITIVA ESTÁ AQUÍ
            // Envolvemos el texto en un FittedBox para que se escale y quepa siempre.
            child: FittedBox(
              fit: BoxFit
                  .scaleDown, // Encoge el contenido si es necesario, pero no lo agranda
              alignment: Alignment
                  .bottomLeft, // Alinea el contenido abajo a la izquierda
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
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


Widget _buildWeeklyChart(List<double> weeklyData) {
    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          // --- Estilo de la línea ---
          lineBarsData: [
            LineChartBarData(
              spots: weeklyData.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value);
              }).toList(),
              isCurved: true,
              color: Colors.amber,
              barWidth: 4,
              isStrokeCapRound: true,
              belowBarData: BarAreaData(
                show: true,
                color: Colors.amber.withOpacity(0.2),
              ),
              dotData: FlDotData(show: false),
            ),
          ],
          
          // --- Ocultar la cuadrícula y ajustar bordes ---
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          
          // --- Títulos en los ejes X e Y ---
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  const style = TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  );
                  String text;
                  switch (value.toInt()) {
                    case 0: text = 'L'; break;
                    case 1: text = 'M'; break;
                    case 2: text = 'M'; break;
                    case 3: text = 'J'; break;
                    case 4: text = 'V'; break;
                    case 5: text = 'S'; break;
                    case 6: text = 'D'; break;
                    default: return Container();
                  }
                  return SideTitleWidget(axisSide: meta.axisSide, child: Text(text, style: style));
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

}
