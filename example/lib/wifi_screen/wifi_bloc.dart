import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:esp_provisioning_softap/esp_provisioning_softap.dart';
import 'package:esp_provisioning_softap_example/softap_service.dart';
import 'package:esp_provisioning_softap_example/wifi_screen/wifi.dart';
import 'package:logger/logger.dart';

class WiFiBlocSoftAP extends Bloc<WifiEvent, WifiState> {
  WiFiBlocSoftAP() : super(WifiStateLoading()) {
    on<WifiEventLoadSoftAP>(_onLoadSoftAP);
    on<WifiEventStartProvisioningSoftAP>(_onStartProvisioningSoftAP);
  }

  Provisioning? prov;
  final log = Logger(printer: PrettyPrinter());
  final softApService = SoftAPService();

  Future<void> _onLoadSoftAP(
    WifiEventLoadSoftAP event,
    Emitter<WifiState> emit,
  ) async {
    emit(WifiStateConnecting());

    late final Provisioning prov;

    const pop = 'abcd1234';

    try {
      if (Platform.isIOS) {
        prov = await softApService.startProvisioning('wifi-prov.local', pop);
      } else {
        prov = await softApService.startProvisioning('192.168.4.1:80', pop);
      }
    } catch (e, st) {
      log.e('Error connecting to device $e');
      emit(const WifiStateError('Error connecting to device'));
      addError(e, st);
      return;
    }

    this.prov = prov;

    emit(WifiStateScanning());

    try {
      final listWifi = await prov.startScanWiFi();
      emit(WifiStateLoaded(wifiList: listWifi ?? []));
      log.t('Wifi $listWifi');
    } catch (e, st) {
      log.e('Error scan WiFi network $e');
      emit(const WifiStateError('Error scan WiFi network'));
      addError(e, st);
    }
  }

  Future<void> _onStartProvisioningSoftAP(
    WifiEventStartProvisioningSoftAP event,
    Emitter<WifiState> emit,
  ) async {
    if (prov == null) {
      throw StateError(
        'Provisioning is not initialized. '
        'Add event $WifiEventLoadSoftAP to initialize it.',
      );
    }

    emit(WifiStateProvisioning());
    final customData = utf8.encode('Some CUSTOM data0');
    final customBytes = Uint8List.fromList(customData);
    await prov!.sendReceiveCustomData(customBytes);
    await prov!.sendWifiConfig(ssid: event.ssid, password: event.password);
    await prov!.applyWifiConfig();
    await Future<void>.delayed(const Duration(seconds: 10));
    final connectionStatus = await prov!.getStatus();

    if (connectionStatus.state == WifiConnectionState.connected) {
      emit(WifiStateProvisionedSuccessfully());
    } else if (connectionStatus.state == WifiConnectionState.disconnected) {
      emit(WifiStateProvisioningDisconnected());
    } else if (connectionStatus.state == WifiConnectionState.connectionFailed) {
      if (connectionStatus.failedReason == WifiConnectFailedReason.authError) {
        emit(WifiStateProvisioningAuthError());
      } else if (connectionStatus.failedReason ==
          WifiConnectFailedReason.networkNotFound) {
        emit(WifiStateProvisioningNetworkNotFound());
      }
    }
  }

  @override
  Future<void> close() {
    prov!.dispose();
    return super.close();
  }
}
