import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RefreshState extends ChangeNotifier {
  void update() {
    notifyListeners();
  }

  Future<double> refresh() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int total = prefs.getStringList("todoRecord")?.length ?? 0;
    int finished = prefs.getStringList("finishedRecord")?.length ?? 0;
    return total != 0 ? finished / total : 0;
  }
}

class TrophyCard extends StatefulWidget {
  const TrophyCard({super.key});

  @override
  State<TrophyCard> createState() => _TrophyCardState();
}

class _TrophyCardState extends State<TrophyCard> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 150,
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.yellow[100],
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                const Icon(
                  Icons.emoji_events,
                  size: 100,
                  color: Colors.grey,
                ),
                Consumer<RefreshState>(
                  builder: (context, refreshState, _) {
                    return FutureBuilder(
                      future: refreshState.refresh(),
                      builder: (_, s) {
                        return TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          tween: Tween<double>(
                            begin: 0,
                            end: s.connectionState == ConnectionState.done
                                ? s.data as double
                                : 0,
                          ),
                          builder: (context, value, _) => ClipRect(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              heightFactor: value,
                              // 设置高度因子为0.5，即只显示下半部分
                              child: const Icon(
                                Icons.emoji_events,
                                size: 100,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '你的成就!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  '挑战与成就',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
