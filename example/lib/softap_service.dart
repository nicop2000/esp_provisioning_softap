import 'dart:async';
import 'dart:io';
import 'package:esp_provisioning_softap/esp_provisioning_softap.dart';

class SoftAPService {
  SoftAPService();

  Future<Provisioning> startProvisioning(String hostname, String pop) async {
    Provisioning prov = Provisioning(
        transport: TransportHTTP(hostname: hostname), security: Security1(pop: pop));
    var success = await prov.establishSession();
    if (!success) {
      throw Exception('Error establishSession');
    }
    return prov;
  }
}