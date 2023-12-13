import 'package:equatable/equatable.dart';

sealed class SoftApState extends Equatable {
  const SoftApState();

  @override
  List<Object> get props => [];
}

class SoftApStateLoaded extends SoftApState {}
