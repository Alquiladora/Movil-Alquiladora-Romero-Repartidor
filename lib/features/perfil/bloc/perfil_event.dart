import 'package:equatable/equatable.dart';

abstract class PerfilEvent extends Equatable {
  const PerfilEvent();

  @override
  List<Object> get props => [];
}

class FetchPerfilData extends PerfilEvent {
  const FetchPerfilData();
}