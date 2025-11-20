// lib/core/utils/auth_global_state.dart

import 'package:equatable/equatable.dart';
import '../../features/dashboard/presentation/home_bloc/home_state.dart'; 


// 🚨 CORRECCIÓN CLAVE: AuthSessionExpired ahora extiende HomeState.
class AuthSessionExpired extends HomeState {
  const AuthSessionExpired();
  @override
  List<Object> get props => [];
}