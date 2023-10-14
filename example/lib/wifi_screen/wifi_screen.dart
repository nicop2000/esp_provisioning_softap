import 'package:esp_provisioning_softap_example/scan_list.dart';
import 'package:esp_provisioning_softap_example/wifi_screen/wifi.dart';
import 'package:esp_provisioning_softap_example/wifi_screen/wifi_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class WiFiScreenSoftAP extends StatefulWidget {
  const WiFiScreenSoftAP({super.key});
  @override
  _WiFiScreenSoftAPState createState() => _WiFiScreenSoftAPState();
}

class _WiFiScreenSoftAPState extends State<WiFiScreenSoftAP> {
  Future<void> _showDialog(Map<String, dynamic> wifi, BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return WifiDialog(
          wifiName: wifi['ssid']! as String,
          onSubmit: (ssid, password) {
            print('ssid =$ssid, password = $password');
            BlocProvider.of<WiFiBlocSoftAP>(context).add(
              WifiEventStartProvisioningSoftAP(ssid: ssid, password: password),
            );
          },
        );
      },
    );
  }

  Widget _buildStepper(int step, WifiState state) {
    final statusWidget0 = <Widget>[
      Column(
        children: <Widget>[
          ElevatedButton.icon(
            onPressed: () {},
            icon: const SpinKitFoldingCube(
              color: Colors.lightBlueAccent,
              size: 20,
            ),
            label: const Text('Connecting..'),
          ),
        ],
      ),
      Column(
        children: <Widget>[
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(
              Icons.check,
              color: Colors.white38,
            ),
            label: const Text(
              'Connected',
              style: TextStyle(
                color: Colors.white38,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const SpinKitFoldingCube(
              color: Colors.lightBlueAccent,
              size: 20,
            ),
            label: const Text('Scanning...'),
          ),
        ],
      ),
    ];

    late Widget wifiList;

    if (state is WifiStateLoaded) {
      wifiList = Expanded(
        child: ScanList(
          state.wifiList,
          Icons.wifi,
          disableLoading: true,
          onTap: _showDialog,
        ),
      );
    }

    Widget body = Expanded(child: Container());

    Widget? statusWidget;
    if (step < 2) {
      statusWidget = Expanded(child: statusWidget0[step]);
      body = Expanded(
        child: SpinKitDoubleBounce(
          color: Theme.of(context).colorScheme.secondary,
        ),
      );
    } else {
      body = wifiList;
    }

    return Column(
      children: <Widget>[
        Center(
          child: Text(
            'Select Wifi network',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        body,
        statusWidget ?? Container(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.black, //change your color here
        ),
        backgroundColor: Colors.transparent,
        title: Text(
          'Provisioning...',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      body: BlocProvider(
        create: (BuildContext context) =>
            WiFiBlocSoftAP()..add(WifiEventLoadSoftAP()),
        child: BlocBuilder<WiFiBlocSoftAP, WifiState>(
          builder: (BuildContext context, WifiState state) {
            if (state is WifiStateConnecting) {
              return _buildStepper(0, state);
            }
            if (state is WifiStateScanning) {
              return _buildStepper(1, state);
            }
            if (state is WifiStateLoaded) {
              return _buildStepper(2, state);
            }
            if (state is WifiStateProvisioning) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SpinKitThreeBounce(
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                    Text(
                      'Provisioning',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              );
            }
            if (state is WifiStateProvisionedSuccessfully) {
              return Center(
                child: MaterialButton(
                  color: Colors.lightBlueAccent,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Done'),
                ),
              );
            }
            if (state is WifiStateProvisioningAuthError) {
              return Center(
                child: MaterialButton(
                  color: Colors.redAccent,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Auth Error'),
                ),
              );
            }
            if (state is WifiStateProvisioningNetworkNotFound) {
              return Center(
                child: MaterialButton(
                  color: Colors.redAccent,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Network Not Found'),
                ),
              );
            }
            if (state is WifiStateProvisioningDisconnected) {
              return Center(
                child: MaterialButton(
                  color: Colors.redAccent,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Device Disconnected'),
                ),
              );
            }
            return Center(
              child: SpinKitThreeBounce(
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
            );
          },
        ),
      ),
    );
  }
}
