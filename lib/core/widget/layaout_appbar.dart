import 'package:RentFast/core/services/notificacion_service.dart';
import 'package:RentFast/features/repartidor_history/presentation/bloc/history_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/dashboard/presentation/home_screen/home_screen.dart';
import '../../features/layaout/layaout_bloc.dart';
import '../../features/layaout/stats_layaout.dart';
import '../../features/pedidos/pedidos_screen/pedidos_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/repartidor_history/presentation/screens/history_screen.dart';
import '../../features/repartidor_history/presentation/bloc/history_bloc.dart';
import '../../core/services/api_service_history.dart';
import '../../features/perfil/screens/screen_perfil.dart';
import '../../features/notificaciones/screen/notificacion_screen.dart';
import '../../features/dashboard/presentation/home_bloc/home_bloc.dart';
import '../../features/dashboard/presentation/home_bloc/home_state.dart';
import '../utils/connection.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/token_service.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

bool _isLoggingOut = false;

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  void _handleAuthRedirect() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Sesión expirada. Redirigiendo...'),
          backgroundColor: Colors.red),
    );
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  bool _isAuthErrorState(dynamic state) {
    if (state is HomeError && state.message == 'AUTH_REQUIRED_401') return true;
    return false;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onProfileTapped() {
    setState(() {
      _selectedIndex = 2;
    });
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: _isLoggingOut
            ? const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFFF7BC3C)),
                  SizedBox(width: 20),
                  Text("Cerrando sesión..."),
                ],
              )
            : const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: _isLoggingOut
            ? null 
            : [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () async {
                    setState(() {
                      _isLoggingOut = true; 
                    });

                    final navigator = Navigator.of(context);

                    try {
                      await NotificationService().logout();
                    

                      final tokenService = TokenService();
                      final authToken = await tokenService.getToken();

                      if (authToken != null) {
                        await Dio().post(
                          '$baseUrl/usuarios/Delete/login-movil',
                          options: Options(
                            headers: {
                              'Cookie': 'sesionToken=$authToken',
                            },
                            followRedirects: false,
                            validateStatus: (status) => status! < 500,
                          ),
                        );
                      
                      }

                      await tokenService.deleteToken();
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear();

                      if (!mounted) return;
                      navigator.pushNamedAndRemoveUntil(
                          '/login', (route) => false);
                    } catch (e) {
                      print("Error al cerrar sesión: $e");
                      if (!mounted) return;
                      navigator.pushNamedAndRemoveUntil(
                          '/login', (route) => false);
                    }
                  },
                  child: const Text('Cerrar Sesión'),
                ),
              ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      const HomeScreen(),
      const PedidoScreen(),
      const RepartidorProfileScreen(),
      BlocProvider(
        create: (_) => HistoryBloc(HistoryService())..add(LoadHistory()),
        child: const HistoryScreen(),
      ),
      const NotificacionScreen(),
    ];

    return MultiBlocListener(
      listeners: [
        BlocListener<HomeBloc, HomeState>(
          listener: (context, state) {
            if (_isAuthErrorState(state)) {
              _handleAuthRedirect();
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: AppBar(
            backgroundColor: const Color.fromARGB(255, 247, 188, 60),
            automaticallyImplyLeading: false,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'BIENVENIDO',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
                ClipRRect(
                    borderRadius: BorderRadius.circular(11.0),
                    child: Image.asset('assets/images/LogoOriginal.png',
                        height: 40)),
                IconButton(
                    icon: const Icon(Icons.logout, color: Colors.black87),
                    onPressed: _showLogoutDialog),
              ],
            ),
          ),
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: widgetOptions,
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: null,
          onPressed: _onProfileTapped,
          backgroundColor: const Color.fromARGB(255, 0, 0, 0),
          elevation: 2.0,
          shape: const CircleBorder(),
          child: BlocBuilder<LayoutBloc, LayoutState>(
            builder: (context, state) {
              //Cargamos Datos
              if (state is LayoutLoading || state is LayoutInicial) {
                return const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.0,
                );
              }
              if (state is LayoutSuccess) {
                final hasPhoto = state.fotoPerfilUrl.isNotEmpty;
                final hasName = state.nombre.isNotEmpty;

                if (hasPhoto) {
                  return ClipOval(
                    child: Image.network(
                      state.fotoPerfilUrl,
                      fit: BoxFit.cover,
                      width: 56,
                      height: 56,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                            child: Text(state.nombre[0].toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)));
                      },
                    ),
                  );
                } else if (hasName) {
                  return Text(
                    state.nombre[0].toUpperCase(),
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  );
                }
              }
              return const Icon(Icons.person, color: Colors.white, size: 30);
            },
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: _buildFancyBottomNavBar(),
      ),
    );
  }

  Widget _buildFancyBottomNavBar() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: const Color.fromARGB(169, 252, 253, 253),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildNavItem(Icons.home, 'Inicio', 0),
          _buildNavItem(Icons.article, 'Pedidos', 1),
          const SizedBox(width: 56),
          _buildNavItem(Icons.history, 'Historial', 3),
          _buildNavItem(Icons.notifications, 'Notificaciones', 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    final color = isSelected
        ? const Color.fromARGB(255, 247, 188, 60)
        : const Color.fromARGB(255, 0, 0, 0);

    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 4,
              width: isSelected ? 30 : 0,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 247, 188, 60),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Spacer(),
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
