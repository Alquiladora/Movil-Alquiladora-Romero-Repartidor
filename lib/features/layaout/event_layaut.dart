import 'package:equatable/equatable.dart';

abstract class LayoutEvent extends Equatable{
  const LayoutEvent();

  @override
  List<Object> get props => [];

}

class LoadLayoutData extends LayoutEvent {}
