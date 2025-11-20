import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/services/api_service_login.dart';
import 'login_event.dart';
import 'login_state.dart';
import '../../../../core/services/notificacion_service.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthService authService;
  
final NotificationService _notificationService = NotificationService();

  LoginBloc({required this.authService}) : super(LoginInitial()) {
    on<LoginButtonPressed>(_onLoginButtonPressed);
  }

  Future<void> _onLoginButtonPressed(LoginButtonPressed event, Emitter<LoginState> emit) async {
    
     if(event.email.isEmpty || event.password.isEmpty){
      emit(const LoginFailure(error: 'El correo y la contraseña son obligatorios.'));
      return;
     }

    emit(LoginLoading());
      
    try {
      final result = await authService.login(event.email, event.password);
      print("Datos obtenidos del endpoint de login: $result");


      if (result['success']) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', result['token']);
        await _notificationService.registerToken();
        emit(LoginSuccess());
      } else {
        emit(LoginFailure(error: result['message']));
      }
    } catch (error) {
      emit(const LoginFailure(error: 'Ocurrió un error inesperado.'));
    }
  }
}