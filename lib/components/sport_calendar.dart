import 'package:flutter/material.dart';
import 'package:inner_peace/data/emotion_dao.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class SportCalendarPage extends StatefulWidget {
  const SportCalendarPage({Key? key}) : super(key: key);

  @override
  State<SportCalendarPage> createState() => _SportCalendarPageState();
}

class _SportCalendarPageState extends State<SportCalendarPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          centerTitle: true,
          title: const Text('运动日历'),
        ),
        body: TableCalendarCard());
  }
}

class TableCalendarCard extends StatefulWidget {
  const TableCalendarCard({super.key});

  @override
  _TableCalendarCardState createState() => _TableCalendarCardState();
}

class _TableCalendarCardState extends State<TableCalendarCard> {
  late final ValueNotifier<List<dynamic>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  SharedPreferences? prefs;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    SharedPreferences.getInstance().then((value) {
      prefs = value;
      setState(() {});
      _selectedEvents.value = _getEventsForDay(_selectedDay!);
    });
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  String sportKeyBuilder(DateTime date) {
    return "${date.year}${date.month}${date.day}SPORT";
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    if (prefs == null) return [];
    if (prefs!.getStringList("sportRecord") == null) {
      return [];
    }
    return prefs!.getStringList("sportRecord")!.contains(sportKeyBuilder(day))
        ? prefs!
            .getStringList(sportKeyBuilder(day))!
            .map((e) => {
                  "time": DateTime.parse(e.split("|")[0]),
                  "length": e.split("|")[1],
                  "step": int.parse(e.split("|")[2]),
                  "kar": int.parse(e.split("|")[2]) ~/ 25,
                })
            .toList()
        : [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null; // Important to clean those
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar<dynamic>(
          firstDay: kFirstDay,
          lastDay: kLastDay,
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          rangeStartDay: _rangeStart,
          rangeEndDay: _rangeEnd,
          calendarFormat: _calendarFormat,
          rangeSelectionMode: _rangeSelectionMode,
          eventLoader: _getEventsForDay,
          startingDayOfWeek: StartingDayOfWeek.monday,
          calendarStyle: const CalendarStyle(
            outsideDaysVisible: false,
          ),
          onDaySelected: _onDaySelected,
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() {
                _calendarFormat = format;
              });
            }
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
        ),
        const SizedBox(height: 8.0),
        Expanded(
          child: ValueListenableBuilder<List<dynamic>>(
            valueListenable: _selectedEvents,
            builder: (context, value, _) {
              return ListView.builder(
                itemCount: value.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: ListTile(
                      onTap: () => print('${value[index]}'),
                      title: Center(
                          child: Text(
                              "时长: ${value[index]['length']}, ${value[index]['step']}步, ${value[index]['kar']}千卡")),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year - 20, kToday.month, kToday.day);
final kLastDay = DateTime(kToday.year + 20, kToday.month, kToday.day);
