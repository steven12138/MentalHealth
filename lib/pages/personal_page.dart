import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersonalPage extends StatefulWidget {
  const PersonalPage({super.key});

  @override
  State<PersonalPage> createState() => _PersonalPageState();
}

class Options {
  String title;
  IconData icon;
  String router;

  Options({required this.title, required this.icon, required this.router});
}

class _PersonalPageState extends State<PersonalPage> {
  final _controller = TextEditingController();

  String username = "Default";

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  void push(String name) {
    Navigator.of(context).pushNamed(name);
  }

  var options = [
    Options(
      title: "运动日历",
      icon: Icons.sports_basketball,
      router: "/sport",
    ),
    Options(
      title: "情绪日历",
      icon: Icons.mood,
      router: '/emotion',
    ),
    Options(
      title: "冥想日历",
      icon: Icons.assistant_photo,
      router: '/meditation',
    ),
    Options(
      title: "设置",
      icon: Icons.settings,
      router: '/setting',
    ),
  ];

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
                    style: const TextStyle(fontSize: 18),
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
                        icon: const Icon(Icons.edit),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        ...options
            .expand(
              (e) => [
                const Divider(),
                ListTile(
                  leading: Icon(e.icon),
                  title: Text(e.title),
                  onTap: () => push(e.router),
                  trailing: const Icon(Icons.arrow_forward_ios),
                ),
              ],
            )
            .toList(),
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
