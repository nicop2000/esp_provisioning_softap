import 'package:esp_provisioning_softap_example/softap_screen/softap_screen.dart';
import 'package:flutter/material.dart';

typedef ItemTapCallback = void Function(Map<String, dynamic> item);

void main() {
  runApp(const MaterialApp(home: HomeScreen()));
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightBlue,
          title: const Text('ESP SoftAp Provisioning'),
        ),
        body: Center(
          child: MaterialButton(
            color: Colors.lightBlueAccent,
            elevation: 5,
            padding: const EdgeInsets.all(15),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => const SoftApScreen(),),);
            },
            child: Text(
              'Start Provisioning',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(color: Colors.white),
            ),
          ),
        ),);
  }
}
