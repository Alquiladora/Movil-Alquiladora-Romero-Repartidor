import 'package:equatable/equatable.dart';

abstract class PerfilState extends Equatable {
  const PerfilState();

  @override
  List<Object> get props => [];
}


class PerfilInitial extends PerfilState {}


class PerfilLoading extends PerfilState {}


class PerfilLoaded extends PerfilState {
  final Map<String, dynamic> perfilUsuario; 
  final Map<String, dynamic> estadisticas;

  final Map<String, dynamic> datosRepartidor; 

  const PerfilLoaded({
    required this.perfilUsuario,
    required this.estadisticas,
    required this.datosRepartidor,
  });

  @override
  List<Object> get props => [perfilUsuario, estadisticas, datosRepartidor];
}


class PerfilError extends PerfilState {
  final String message;

  const PerfilError(this.message);

  @override
  List<Object> get props => [message];
}