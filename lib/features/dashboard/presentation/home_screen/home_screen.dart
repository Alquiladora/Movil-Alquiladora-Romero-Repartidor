import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos un Scaffold para darle un fondo y estructura a la pantalla
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Un gris muy claro para el fondo
      // Usamos ListView para que la pantalla sea desplazable en dispositivos pequeños
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- Tarjeta de Bienvenida ---
          _buildWelcomeHeader("Carlos Rodríguez"),
          const SizedBox(height: 24),

          // --- Sección de Estadísticas del Día ---
          _buildSectionTitle("Estadísticas del Día"),
          const SizedBox(height: 16),
          _buildStatsGrid(),
          const SizedBox(height: 24),

          // --- Sección de Rendimiento Semanal ---
          _buildSectionTitle("Rendimiento Semanal", trailing: "+12%"),
          const SizedBox(height: 16),
          _buildWeeklyChartPlaceholder(),
        ],
      ),
    );
  }

  // Widget para la cabecera de bienvenida
  Widget _buildWelcomeHeader(String userName) {
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
                const Text(
                  "¡Buenos días!",
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
                    const Text(
                      "En servicio",
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

  // Widget para los títulos de las secciones
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

  // Widget para la cuadrícula de estadísticas
  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2, // 2 columnas
      shrinkWrap: true, // Para que funcione dentro de un ListView
      physics: const NeverScrollableScrollPhysics(), // Deshabilita el scroll de la cuadrícula
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.2, // Ajusta la proporción de las tarjetas
      children: [
        _buildStatCard(
          icon: Icons.inventory_2_outlined,
          value: "127",
          label: "Pedidos Realizados",
          color: Colors.orange.shade100,
          iconColor: Colors.orange,
        ),
        _buildStatCard(
          icon: Icons.check_circle_outline,
          value: "98",
          label: "Pedidos Completados",
          color: Colors.green.shade100,
          iconColor: Colors.green,
        ),
        _buildStatCard(
          icon: Icons.timer_outlined,
          value: "12",
          label: "Pedidos Pendientes",
          color: Colors.yellow.shade200,
          iconColor: Colors.amber.shade800,
        ),
        _buildStatCard(
          icon: Icons.warning_amber_rounded,
          value: "3",
          label: "Incidencias",
          color: Colors.red.shade100,
          iconColor: Colors.red,
        ),
      ],
    );
  }

  // Plantilla para cada tarjeta de estadística
  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 32, color: iconColor),
          Column(
             crossAxisAlignment: CrossAxisAlignment.start,
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
                maxLines: 2,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget para simular la gráfica de barras
  Widget _buildWeeklyChartPlaceholder() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16.0),
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
      child: const Center(
        child: Text(
          "Aquí iría una gráfica semanal.\nPuedes usar un paquete como 'fl_chart'.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      ),
    );
  }
}