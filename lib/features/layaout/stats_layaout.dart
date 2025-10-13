import 'package:equatable/equatable.dart';

abstract class LayoutState extends Equatable{
 const LayoutState();
   @override
  List<Object> get props => [];
}

class LayoutInicial extends LayoutState {}

class LayoutLoading extends LayoutState {}



class LayoutSuccess extends LayoutState {
  final String nombre;
  final String fotoPerfilUrl;

  const LayoutSuccess({required this.nombre, required this.fotoPerfilUrl});

  @override
  List<Object> get props => [nombre, fotoPerfilUrl];
}


class LayoutFailure extends LayoutState {
  final String error;

  const LayoutFailure({required this.error});

  @override
  List<Object> get props => [error];
}