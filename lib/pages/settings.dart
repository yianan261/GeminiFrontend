import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '/services/user_service.dart';
import '/pages/notifications_edit.dart';
import '/services/sign_out.dart';


class SettingsPage extends StatefulWidget {
  @override
  _SettingsPage createState() => _SettingsPage();
}

class _SettingsPage extends State<SettingsPage> {
  String? displayName;
  String? email;
  bool isTracking = false;

  @override
  void initState() {
    super.initState();
    checkNotifications();
    checkTrackingStatus();
  }

  Future<void> checkNotifications() async {
    Map<String, dynamic> user = await getUser();
    setState(() {
      email = user["email"];
      displayName = user['displayName'];
    });
  }

  Future<void> checkTrackingStatus() async {
    var status = await Permission.locationAlways.status;
    setState(() {
      isTracking = status.isGranted;
    });
  }

  void _editDisplayName(BuildContext context) async {
    final newName = await showDialog<String>(
      context: context,
      builder: (context) {
        TextEditingController controller = TextEditingController();
        return AlertDialog(
          title: Text('Edit Name'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Enter new display name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );

    if (newName != null && newName.isNotEmpty) {
      setState(() {
        updateUser({"displayName": newName});
        displayName = newName;
      });
    }
  }

  /*
  void _toggleTracking() {
    setState(() {
      isTracking = !isTracking;
    });
    if (isTracking) {
      _backgroundLocationService.start();
    } else {
      _backgroundLocationService.stop();
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Section(
            title: 'Account',
            items: [
              SettingsItem(
                title: 'Name',
                subtitle: displayName ?? "",
                icon: Icons.edit,
                onTap: () {
                  _editDisplayName(context);
                },
              ),
              SettingsItem(
                title: 'Email',
                subtitle: email ?? "",
                icon: Icons.email,
                onTap: () {},
              ),
            ],
          ),
          Section(
            title: 'Preferences',
            items: [
              SettingsItem(
                title: 'Google Takeout',
                subtitle: "",
                onTap: () {},
              ),
              SettingsItem(
                title: 'Notifications',
                subtitle: "",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NotificationSettingsPage()),
                  );
                },
              ),
            ],
          ),
          /*
          Section(
            title: 'Location Tracking',
            items: [
              SettingsItem(
                title: 'Background Location Tracking',
                subtitle: isTracking ? 'On' : 'Off',
                onTap: _toggleTracking,
                icon: isTracking ? Icons.location_on : Icons.location_off,
              ),
            ],
          ),*/
          Section(
            title: "",
            items: [
              SettingsItem(
                title: 'Privacy Notice',
                subtitle: "",
                onTap: () {},
              ),
              SettingsItem(
                title: 'Contact us',
                subtitle: "",
                onTap: () {},
              ),
            ],
          ),
          ListTile(
            title: Center(
              child: Text(
                'Log Out',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
            onTap: () async {
              await signOut(context);
            },
          ),
        ],
      ),
    );
  }
}

class Section extends StatelessWidget {
  final String title;
  final List<Widget> items;

  Section({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ...items,
        Divider(thickness: 1),
      ],
    );
  }
}

class SettingsItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final IconData icon;

  SettingsItem({required this.title, required this.subtitle, required this.onTap, this.icon = Icons.arrow_forward_ios});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
      trailing: Icon(icon),
      onTap: onTap,
    );
  }
}
