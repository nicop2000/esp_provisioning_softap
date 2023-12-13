import 'package:esp_provisioning_softap_example/wifi_screen/password_form_field.dart';
import 'package:flutter/material.dart';

class WifiDialog extends StatefulWidget {
  const WifiDialog({
    required this.wifiName,
    required this.onSubmit,
    super.key,
  });

  final String wifiName;
  final void Function(String ssid, String password) onSubmit;

  @override
  _WifiDialogState createState() => _WifiDialogState();
}

class _WifiDialogState extends State<WifiDialog> {
  String ssid = '';
  String password = '';
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    ssid = widget.wifiName;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 5,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ), //this right here
      child: Container(
        height: 320,
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Password for WiFi',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  onSaved: (text) {
                    ssid = text ?? '';
                  },
                  initialValue: widget.wifiName,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                PasswordFormField(
                  initialValue: password,
                  onSaved: (text) {
                    password = text ?? '';
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: MaterialButton(
                    color: Colors.lightBlueAccent,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        widget.onSubmit(ssid, password);
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Provision'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
