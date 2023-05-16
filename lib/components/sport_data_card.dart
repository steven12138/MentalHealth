import 'package:flutter/material.dart';
import 'package:inner_peace/components/reg_card.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SportSaveState extends ChangeNotifier {
  void update() {
    notifyListeners();
  }
}

class SportDataCard extends StatefulWidget {
  const SportDataCard({Key? key}) : super(key: key);

  @override
  State<SportDataCard> createState() => _SportDataCardState();
}

class _SportDataCardState extends State<SportDataCard> {
  Future<List<dynamic>> _refresh() async {
    var prefs = await SharedPreferences.getInstance();
    var sportKey =
        "${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}SPORT";
    var sportData = prefs.getStringList(sportKey) ?? [];
    return sportData
        .map((e) => {
              "time": DateTime.parse(e.split("|")[0]),
              "length": e.split("|")[1],
              "step": int.parse(e.split("|")[2]),
            })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return RegCard(
      title: Row(
        children: [
          ...const [
            Icon(Icons.sports),
            SizedBox(width: 10),
            Text('今日运动纪录'),
            Spacer(),
          ],
          IconButton(
              onPressed: () {
                Provider.of<SportSaveState>(context, listen: false).update();
              },
              icon: const Icon(Icons.refresh)),
        ],
      ),
      child: Consumer<SportSaveState>(
        builder: (context, sportSaveState, _) {
          return FutureBuilder(
            future: _refresh(),
            builder: (_, s) {
              if (s.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              return Column(
                  children: (s.data as List<dynamic>)
                      .reversed
                      .map((e) => Dismissible(
                            key: Key(e.hashCode.toString()),
                            onDismissed: (direction) async {
                              var prefs = await SharedPreferences.getInstance();
                              var sportKey =
                                  "${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}SPORT";
                              var sportData =
                                  prefs.getStringList(sportKey) ?? [];
                              sportData.removeWhere((element) =>
                                  element ==
                                  "${(e["time"] as DateTime).toIso8601String()}|${e["length"]}|${e["step"]}");
                              await prefs.setStringList(sportKey, sportData);
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('删除成功')),
                              );
                            },
                            background: Container(
                              color: Colors.red,
                              child: Icon(Icons.delete, color: Colors.white),
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.only(left: 16.0),
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.directions_run),
                              trailing: Text(
                                "${e["time"].hour}:${e["time"].minute}",
                                style: const TextStyle(fontSize: 20),
                              ),
                              title: Text(
                                "运动时长：${e["length"]}\n步数：${e["step"].toInt()}步",
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                          ))
                      .toList());
            },
          );
        },
      ),
    );
  }
}
