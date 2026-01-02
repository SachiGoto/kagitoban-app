import 'package:flutter/material.dart';

/// Simple members screen with one named member and one random avatar.
class MembersScreen extends StatelessWidget {
  static const routeName = '/members';

  const MembersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Text('SG'),
              ),
              title: const Text('Sachi Goto'),
              subtitle: const Text('Member'),
              onTap: () {
                // Return the selected member name to the caller.
                Navigator.pop(context, 'Sachi Goto');
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                // Using a random avatar from pravatar.cc as a placeholder image.
                backgroundImage:
                    NetworkImage('https://i.pravatar.cc/150?img=5'),
              ),
              title: const Text('Random User'),
              subtitle: const Text('Random avatar'),
              onTap: () {
                Navigator.pop(context, 'Random User');
              },
            ),
          ),
        ],
      ),
    );
  }
}
