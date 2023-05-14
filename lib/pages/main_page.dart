import 'package:flutter/material.dart';
import 'package:inner_peace/pages/emotional_page.dart';
import 'package:inner_peace/utils/configurations.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class PageWithDesc {
  Widget component;
  String name;
  IconData icon;

  PageWithDesc(this.component, this.name, this.icon);
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  final List<PageWithDesc> _pages = [
    PageWithDesc(const EmotionalPage(), "心理与冥想", Icons.home),
    PageWithDesc(PlaceholderWidget(color: Colors.blue), "挑战与成就", Icons.emoji_events),
    PageWithDesc(PlaceholderWidget(color: Colors.yellow), "运动健康", Icons.directions_run),
    PageWithDesc(PlaceholderWidget(color: Colors.green), "个人中心", Icons.person),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Center(child: Text('心理与运动健康')),
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
          physics: const CustomPageScrollPhysics(
              dragForce: 0.4, parent: AlwaysScrollableScrollPhysics()),
          children: _pages.map((page) => page.component).toList(),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (int index) {
            setState(() {
              _currentIndex = index;
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
              );
            });
          },
          items: _pages
              .map((e) => BottomNavigationBarItem(
                    icon: Icon(e.icon),
                    label: e.name,
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class PlaceholderWidget extends StatelessWidget {
  final Color color;

  const PlaceholderWidget({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
    );
  }
}
