import 'package:equatable/equatable.dart';

sealed class SoftApEvent extends Equatable {
  const SoftApEvent();

  @override
  List<Object> get props => [];
}

class SoftApEventStart extends SoftApEvent {}
