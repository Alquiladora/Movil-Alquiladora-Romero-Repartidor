import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'core/widget/layaout_appbar.dart';
import 'core/services/api_service_login.dart';
import 'core/services/api_service_layaout.dart';
import 'features/authentication/presentation/screens/login_screen.dart';
import 'features/authentication/presentation/bloc/login_bloc.dart';
import 'features/layaout/layaout_bloc.dart';
import 'features/layaout/event_layaut.dart';



void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos MultiRepositoryProvider para proveer todos los servicios a la app
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthService>(
          create: (context) => AuthService(),
        ),
        RepositoryProvider<LayaoutService>( // <-- AÑADIMOS EL SERVICIO DEL LAYOUT
          create: (context) => LayaoutService(),
        ),
      ],
      child: MaterialApp(
        title: 'Alquiladora Romero Repartidor',
        debugShowCheckedModeBanner: false,
        theme: appTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => BlocProvider(
                create: (context) => LoginBloc(
                  // Leemos el servicio del contexto
                  authService: context.read<AuthService>(),
                ),
                child: const LoginScreen(),
              ),
          '/home': (context) => BlocProvider(
                create: (context) => LayoutBloc(

                  layoutService: context.read<LayaoutService>(),
                )..add(LoadLayoutData()), 
                child: const MainLayout(),
              ),
        },
      ),
    );
  }
}