import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'weather_model.dart';

class HomeScreenContent extends StatefulWidget {
  final Function(int) onTap;

  HomeScreenContent({required this.onTap});

  @override
  _HomeScreenContentState createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  Weather? _weather;

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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '유저님 안녕하세요!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 25),
            _weather != null
                ? _buildWeatherInfo()
                : Center(child: CircularProgressIndicator()),
            SizedBox(height: 16),
            Divider(
              color: Colors.black,
              thickness: 1,
            ),
            SizedBox(height: 16),
            _buildShortcutIcons(),
            SizedBox(height: 45),
            GestureDetector(
              onTap: () => widget.onTap(0),
              child: Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 28),
                      SizedBox(width: 8),
                      Text(
                        '나만의 옷장',
                        style: TextStyle(color: Colors.white, fontSize: 22),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => widget.onTap(1),
                  child: Container(
                    width: MediaQuery.of(context).size.width / 2 - 20,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(color: Colors.black, width: 2.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.message, color: Colors.black, size: 28),
                          SizedBox(width: 8),
                          Text(
                            '게시판',
                            style: TextStyle(color: Colors.black, fontSize: 22),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => widget.onTap(3),
                  child: Container(
                    width: MediaQuery.of(context).size.width / 2 - 20,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.pink,
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.android, color: Colors.white, size: 28),
                          SizedBox(width: 8),
                          Text(
                            'AI 코디하기',
                            style: TextStyle(color: Colors.white, fontSize: 22),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: () => widget.onTap(4),
              child: Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  color: Color(0xFFFBC02D),
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.palette, color: Colors.white, size: 28),
                      SizedBox(width: 8),
                      Text(
                        '내 퍼스널컬러 진단하기',
                        style: TextStyle(color: Colors.white, fontSize: 22),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(20.0),
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
            width: 100,
            height: 100,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.error, size: 100, color: Colors.red);
            },
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '현재 온도',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${temp}°C',
                  style: TextStyle(
                    fontSize: 30,
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
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '최저 온도: ${tempMin}°C',
                style: TextStyle(
                  fontSize: 13,
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
            _buildShortcutIcon(Icons.shopping_cart_outlined, '나만의 옷장', 0),
            _buildShortcutIcon(Icons.message, '게시판', 1),
            _buildShortcutIcon(Icons.android, 'AI 코디하기', 3),
            _buildShortcutIcon(Icons.palette, '퍼스널컬러', 4),
          ],
        ),
      ],
    );
  }

  Widget _buildShortcutIcon(IconData icon, String text, int index) {
    return GestureDetector(
      onTap: () => widget.onTap(index),
      child: Column(
        children: [
          Icon(icon, size: 48),
          SizedBox(height: 4),
          Text(
            text,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
