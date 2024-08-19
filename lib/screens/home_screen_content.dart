import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../provider/userprovider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'weather_model.dart';

class HomeScreenContent extends StatefulWidget {
  final Function(int) onTap;

  HomeScreenContent({required this.onTap});

  @override
  _HomeScreenContentState createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  Weather? _weather;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List<String>> _events = {};

  late String userNickName;

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  Future<void> fetchWeatherData() async {
    final apiKey = '3c555468757eb3f66d5a812f1e6bbbb0';
    final city = 'Seoul';
    final url = 'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _weather = Weather(
            temp: data['main']['temp'].toDouble(),
            tempMin: (data['main']['temp_min'] as num).toInt(),
            tempMax: (data['main']['temp_max'] as num).toInt(),
            weatherMain: data['weather'][0]['main'],
            icon: data['weather'][0]['icon'] ?? '01d',
          );
        });
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    userNickName = Provider.of<UserProvider>(context).userNickName;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '$userNickName님 안녕하세요!',
            style: TextStyle(
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              _weather != null
                  ? _buildWeatherInfo()
                  : Center(child: CircularProgressIndicator()),
              SizedBox(height: 10),
              Divider(
                color: Colors.black,
                thickness: 1,
              ),
              SizedBox(height: 10),
              _buildShortcutIcons(),
              SizedBox(height: 16),
              _buildCalendar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherInfo() {
    if (_weather == null) {
      return SizedBox.shrink();
    }

    final temp = _weather!.temp.toStringAsFixed(1);
    final tempMax = _weather!.tempMax.toStringAsFixed(1);
    final tempMin = _weather!.tempMin.toStringAsFixed(1);
    final icon = _weather!.icon;
    final weatherIcon = icon != null
        ? 'https://openweathermap.org/img/wn/${icon}@4x.png'
        : 'https://openweathermap.org/img/wn/01d@4x.png';

    return Container(
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.network(
            weatherIcon,
            width: 80,
            height: 80,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.error, size: 80, color: Colors.red);
            },
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '현재 온도',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${temp}°C',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '최고 온도: ${tempMax}°C',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 2),
              Text(
                '최저 온도: ${tempMin}°C',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutIcons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '바로가기',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildShortcutIcon(Icons.shopping_cart_outlined, '나만의 옷장', Colors.blue, 0),
            _buildShortcutIcon(Icons.message, '게시판', Colors.black, 1),
            _buildShortcutIcon(Icons.android, 'AI 코디하기', Colors.pink, 2),
            _buildShortcutIcon(Icons.palette, '퍼스널컬러', Color(0xFFFFEB3B), 3),
          ],
        ),
      ],
    );
  }

  Widget _buildShortcutIcon(IconData icon, String text, Color color, int index) {
    return GestureDetector(
      onTap: () => widget.onTap(index),
      child: Column(
        children: [
          Icon(icon, size: 48, color: color),
          SizedBox(height: 4),
          Text(
            text,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '내 일정 등록하기',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Container(
          constraints: BoxConstraints(maxHeight: 350),
          child: TableCalendar(
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _addEvent(context);
            },
            eventLoader: (day) {
              return _events[day] ?? [];
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.orangeAccent,
                shape: BoxShape.circle,
              ),
              markersAlignment: Alignment.bottomCenter,
              markerDecoration: BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
              rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekendStyle: TextStyle(color: Colors.red),
              weekdayStyle: TextStyle(color: Colors.black),
            ),
          ),
        ),
        SizedBox(height: 8),
        ..._getEventsForDay(_selectedDay).map(
              (event) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Row(
              children: [
                Icon(Icons.event, color: Colors.blueAccent),
                SizedBox(width: 8),
                Text(event),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<String> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  void _addEvent(BuildContext context) {
    final TextEditingController _eventController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('새 일정 추가'),
          content: TextField(
            controller: _eventController,
            decoration: InputDecoration(
              hintText: '일정 내용을 입력하세요',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                if (_eventController.text.isEmpty) return;
                setState(() {
                  if (_events[_selectedDay] != null) {
                    _events[_selectedDay]!.add(_eventController.text);
                  } else {
                    _events[_selectedDay] = [_eventController.text];
                  }
                });
                Navigator.pop(context);
              },
              child: Text('추가'),
            ),
          ],
        );
      },
    );
  }
}
