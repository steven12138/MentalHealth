import 'package:flutter/material.dart';
import 'package:inner_peace/components/reg_card.dart';
import 'package:inner_peace/components/trophy_card.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ToDoCard extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  int f = 1;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 150),
      child: RegCard(
          title: Row(
            children: [
              Icon(Icons.check_circle_outline),
              const SizedBox(width: 10),
              const Text("待办"),
              const Spacer(),
              ButtonBar(
                children: [
                  IconButton(
                    onPressed: () {
                      //Confirm delete
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("确认清除待办记录？"),
                          content: const Text("清除后将无法恢复！"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("取消"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                SharedPreferences.getInstance().then((prefs) {
                                  prefs.remove("todoRecord");
                                  prefs.remove("finishedRecord");
                                  childKey.currentState?._refresh();
                                });
                              },
                              child: const Text(
                                "确认",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.delete),
                  ),
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("添加待办"),
                          content: TextField(
                            controller: _controller,
                            decoration: const InputDecoration(
                              labelText: "待办内容",
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("取消"),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.of(context).pop();
                                if (_controller.text.isEmpty) return;
                                var prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setStringList(
                                  "todoRecord",
                                  prefs.getStringList("todoRecord") ??
                                      <String>[]
                                    ..add(_controller.text),
                                );
                                childKey.currentState?._refresh();
                                _controller.clear();
                              },
                              child: const Text(
                                "确认",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                  ),
                  IconButton(
                    onPressed: () {
                      childKey.currentState?._refresh();
                    },
                    icon: const Icon(Icons.refresh),
                  )
                ],
              )
            ],
          ),
          child: ToDoList(key: childKey)),
    );
  }

  GlobalKey<_ToDoListState> childKey = GlobalKey<_ToDoListState>();
}

class ToDoList extends StatefulWidget {
  const ToDoList({Key? key}) : super(key: key);

  @override
  _ToDoListState createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  List<ToDoItem> todoItems = [];
  bool loaded = false;

  void _refresh() async {
    loaded = false;

    var prefs = await SharedPreferences.getInstance();
    var todoRecord = prefs.getStringList("todoRecord") ?? <String>[];
    var finishedRecord = prefs.getStringList("finishedRecord") ?? <String>[];
    todoItems = todoRecord
        .map((e) =>
            ToDoItem(description: e, isCompleted: finishedRecord.contains(e)))
        .toList();
    setState(() {
      loaded = true;
    });
    Provider.of<RefreshState>(context, listen: false).update();
  }

  void _save() async {
    var prefs = await SharedPreferences.getInstance();
    var todoRecord = todoItems.map((e) => e.description).toList();
    var finishedRecord = todoItems
        .where((element) => element.isCompleted)
        .map((e) => e.description)
        .toList();
    await prefs.setStringList("todoRecord", todoRecord);
    await prefs.setStringList("finishedRecord", finishedRecord);
    Provider.of<RefreshState>(context, listen: false).update();
  }

  @override
  void initState() {
    print("get");
    super.initState();
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return !loaded
        ? const Center(
            child: RefreshProgressIndicator(),
          )
        : Column(
            children: [
              if (todoItems.isEmpty)
                const Center(
                  child: Text("暂无待办"),
                ),
              for (var index = 0; index < todoItems.length; index++)
                ListTile(
                  title: Text(
                    todoItems[index].description,
                    style: todoItems[index].isCompleted
                        ? TextStyle(decoration: TextDecoration.lineThrough)
                        : null,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          setState(() {
                            todoItems.removeAt(index);
                            _save();
                          });
                        },
                      ),
                      Checkbox(
                        value: todoItems[index].isCompleted,
                        onChanged: (newValue) {
                          setState(() {
                            todoItems[index].isCompleted = newValue ?? false;
                            _save();
                          });
                        },
                      ),
                    ],
                  ),
                ),
            ],
          );
  }
}

class ToDoItem {
  String description;
  bool isCompleted;

  ToDoItem({required this.description, required this.isCompleted});
}
