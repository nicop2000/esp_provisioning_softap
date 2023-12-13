import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

typedef ItemTapCallback = void Function(
  Map<String, dynamic> item,
  BuildContext context,
);

class ScanList extends StatelessWidget {
  const ScanList(
    this.items,
    this.icon, {
    required this.onTap,
    required this.disableLoading,
    super.key,
  });

  final List<Map<String, dynamic>> items;
  final IconData icon;
  final ItemTapCallback onTap;
  final bool disableLoading;

  Widget _buildItem(
    BuildContext context,
    Map<String, dynamic> item,
    IconData icon, {
    required ItemTapCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(4),
        child: Icon(
          icon,
          color: Colors.blueAccent,
        ),
      ),
      title: Text(
        (item['name'] as String?) ?? (item['ssid']! as String),
        style: TextStyle(color: Theme.of(context).colorScheme.secondary),
      ),
      trailing: Text(item['rssi'].toString()),
      onTap: () {
        print('tap');
        onTap(item, context);
      }, //showModel(context, bleDevice),
    );
  }

  Widget _buildList(BuildContext context) {
    return Column(
      children: <Widget>[
        if (disableLoading)
          Container()
        else
          SizedBox(
            child: Container(
              padding: const EdgeInsets.all(4),
              height: 80,
              child: Align(
                child: SpinKitRipple(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
        Expanded(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) {
              return _buildItem(context, items[index], icon, onTap: onTap);
            },
            separatorBuilder: (context, index) => Divider(
              color: Theme.of(context).dividerColor,
              height: 1,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildList(context);
  }
}
