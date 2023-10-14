import 'package:esp_provisioning_softap_example/softap_screen/softap_event.dart';
import 'package:esp_provisioning_softap_example/softap_screen/softap_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SoftApBloc extends Bloc<SoftApEvent, SoftApState> {
  SoftApBloc() : super(SoftApStateLoaded()) {
    on<SoftApEvent>((event, emit) {});
  }
}
