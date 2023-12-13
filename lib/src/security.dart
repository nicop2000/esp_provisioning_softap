import 'dart:typed_data';

import 'package:esp_provisioning_softap/src/proto/dart/session.pb.dart';

// Enum for state of protocomm_security1 FSM
enum SecurityState {
  request1,
  response1Request2,
  response2,
  finished,
}

abstract class Security {
  Future<Uint8List> encrypt(Uint8List data);

  Future<Uint8List> decrypt(Uint8List data);

  Future<SessionData?> securitySession(SessionData? responseData);
}
