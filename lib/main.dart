import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'core/widget/layaout_appbar.dart';
import 'core/services/api_service_login.dart';
import 'core/services/api_service_layaout.dart';
import 'features/authentication/presentation/screens/login_screen.dart';
import 'features/authentication/presentation/bloc/login_bloc.dart';
import 'features/layaout/layaout_bloc.dart';
import 'features/layaout/event_layaut.dart';
import 'features/dashboard/presentation/home_bloc/home_bloc.dart';
import 'features/dashboard/presentation/home_bloc/home_event.dart';
import 'core/services/ape_service_home.dart';
import 'core/services/api_service_pedidos.dart';
import 'features/pedidos/pedidos_bloc/pedidos_bloc.dart';
import 'features/perfil/bloc/perfil_bloc.dart';
import 'features/perfil/bloc/perfil_event.dart';
import 'core/services/api_service_perfil.dart';
import './core/widget/auth_gate.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'package:firebase_messaging/firebase_messaging.dart';
import './core/services/notificacion_service.dart';


@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("🔔 [Background] Notificación recibida: ${message.notification?.title ?? 'Sin título'}");
  print("   Datos: ${message.data}");
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  
  try {
  
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    print("--- ERROR AL INICIALIZAR FIREBASE: $e ---");
  }
  
  try {
   await NotificationService().initialize();
  } catch (e) {
    print("--- ERROR AL INICIALIZAR NOTIFICATION SERVICE: $e ---");
  }
  
 
  try {
    await initializeDateFormatting('es', null);
   
  } catch (e) {
    print('--- ERROR AL INICIALIZAR FORMATO DE FECHA: $e ---'); 
  }

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
   
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthService>(
          create: (context) => AuthService(),
        ),
        RepositoryProvider<LayaoutService>(
        
          create: (context) => LayaoutService(),
        ),
        RepositoryProvider<HomeService>(create: (_) => HomeService()),
        
        RepositoryProvider<ApiServicePedidos>(create: (_) => ApiServicePedidos()), // Añadir el servicio de pedidos
       
       RepositoryProvider<ApiServicePerfil>(create: (_) => ApiServicePerfil()),
      ],
      child: MaterialApp(
        title: 'Alquiladora Romero Repartidor',
        debugShowCheckedModeBanner: false,
        theme: appTheme,
        initialRoute: '/',
        routes: {
        '/': (context) => const AuthGate(),
        '/login': (context) => BlocProvider(
            create: (context) => LoginBloc(
              authService: context.read<AuthService>(),
            ),
            child: const LoginScreen(),
          ),
          '/home': (context) => MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (context) => LayoutBloc(
                        layoutService: context.read<LayaoutService>())
                      ..add(LoadLayoutData()),
                  ),
                 BlocProvider(
      create: (context) => HomeBloc(
        homeservice: context.read<HomeService>(),
      )..add(const LoadHomeData()),
    ),
    BlocProvider<AssignedOrdersBloc>(
                create: (context) => AssignedOrdersBloc(
                  context.read<ApiServicePedidos>(),
                ),
              ),

              BlocProvider<PerfilBloc>(
                      create: (context) => PerfilBloc(
                        context.read<ApiServicePerfil>(), 
                      )..add(const FetchPerfilData()), 
                    ),

  ],
  
  child: const MainLayout(),
),
        },
      ),
    );
  }
}