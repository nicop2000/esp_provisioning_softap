import 'dart:async';
import 'package:esp_provisioning_softap/esp_provisioning_softap.dart';

class SoftAPService {
  SoftAPService();

  Future<Provisioning> startProvisioning(String hostname, String pop) async {
    final prov = Provisioning(
        transport: TransportHTTP(hostname: hostname), security: Security1(pop: pop),);
    final success = await prov.establishSession();
    if (!success) {
      throw Exception('Error establishSession');
    }
    return prov;
  }
}