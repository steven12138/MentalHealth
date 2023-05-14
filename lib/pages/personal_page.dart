import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersonalPage extends StatefulWidget {
  const PersonalPage({super.key});

  @override
  State<PersonalPage> createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage> {
  final _controller = TextEditingController();

  String username = "Default";

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage("https://robohash.org/robot"),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(
                    child: SizedBox(),
                  ),
                  Text(
                    username,
                    style: TextStyle(fontSize: 18),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () {
                          // show dialog to edit username
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Edit Username'),
                                  content: TextField(
                                    controller: _controller,
                                    decoration: const InputDecoration(
                                      hintText: '请输入昵称',
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        // handle cancel
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        var username = _controller.text;
                                        var prefs = await SharedPreferences
                                            .getInstance();
                                        setState(() {
                                          prefs.setString('username', username);
                                          this.username = username;
                                        });
                                      },
                                      child: const Text('Confirm'),
                                    ),
                                  ],
                                );
                              });
                        },
                        icon: Icon(Icons.edit),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(),
        ListTile(
          leading: Icon(Icons.sports_basketball),
          title: Text('Sport Calendar'),
          onTap: () {
            // Handle sport calendar tap
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.emoji_emotions),
          title: Text('Emotion Calendar'),
          onTap: () {
            // Handle emotion calendar tap
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.timeline),
          title: Text('Meditation Statistic & Calendar'),
          onTap: () {
            // Handle meditation statistics and calendar tap
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('Settings'),
          onTap: () {
            // Handle settings tap
          },
        ),
      ],
    );
  }

  void _loadUsername() {
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        username = prefs.getString('username') ?? 'Default';
      });
    });
  }
}
