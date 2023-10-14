import 'dart:async';
import 'package:esp_provisioning_softap/esp_provisioning_softap.dart';

class SoftAPService {
  SoftAPService();

  Future<Provisioning> startProvisioning(String hostname, String pop) async {
    final prov = Provisioning(
      transport: TransportHTTP(hostname: hostname),
      security: Security1(pop: pop),
    );
    await prov.establishSession();

    return prov;
  }
}
