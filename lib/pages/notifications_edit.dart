import 'package:flutter/material.dart';
import 'package:wander_finds_gemini/services/user_service.dart';

class NotificationSettingsPage extends StatefulWidget {
  @override
  _NotificationSettingsPageState createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    checkNotifications();
  }

  Future<void> checkNotifications() async {
    Map<String, dynamic> user = await getUser();
    setState(() {
      notificationsEnabled = user['notificationAllowed'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Settings'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous page
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Turn Notifications On/Off',
                  style: TextStyle(fontSize: 16),
                ),
                Switch(
                  value: notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      notificationsEnabled = value;
                      updateUser({"notificationAllowed": value});
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'To receive notifications about nearby places, allow us to track your location by going to Settings > Wander Finds Gemini > Allow Location Access: Always',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
