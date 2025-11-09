import 'package:flutter/material.dart';
import 'package:mobile/User/utils/utils.dart';

class SupportChat extends StatelessWidget {
  static const routeName = '/shipper/support';
  const SupportChat({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Chat'),
        backgroundColor: whiteColor,
        foregroundColor: primaryColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: const [
                ListTile(title: Text('Support: How can I help?')),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(hintText: 'Type message'),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.send, color: primaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
