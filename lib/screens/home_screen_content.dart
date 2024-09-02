import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../provider/userprovider.dart';
import 'login_screen.dart';
import 'weather_model.dart';

class HomeScreenContent extends StatefulWidget {
  final Function(int) onTap;

  HomeScreenContent({required this.onTap});

  @override
  _HomeScreenContentState createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  Weather? _weather;
  late String userNickName;
  String? selectedColor;

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

  void _selectPersonalColor() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('퍼스널 컬러 선택'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: Text('여름 쿨톤'),
                    value: '여름 쿨톤',
                    groupValue: selectedColor,
                    onChanged: (value) {
                      setState(() {
                        selectedColor = value;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text('겨울 쿨톤'),
                    value: '겨울 쿨톤',
                    groupValue: selectedColor,
                    onChanged: (value) {
                      setState(() {
                        selectedColor = value;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text('가을 웜톤'),
                    value: '가을 웜톤',
                    groupValue: selectedColor,
                    onChanged: (value) {
                      setState(() {
                        selectedColor = value;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text('봄 웜톤'),
                    value: '봄 웜톤',
                    groupValue: selectedColor,
                    onChanged: (value) {
                      setState(() {
                        selectedColor = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('취소'),
                ),
                TextButton(
                  onPressed: () {

                    Navigator.of(context).pop();
                  },
                  child: Text('저장'),
                ),
              ],
            );
          },
        );
      },
    );
  }


  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
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
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.account_circle_rounded, color: Colors.blueAccent),
            onSelected: (value) {
              if (value == 'color') {
                _selectPersonalColor();
              } else if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'color',
                child: Text('퍼스널 컬러 선택'),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Text('로그아웃'),
              ),
            ],
          ),
        ],
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
              _buildRecommendationBox(),
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

  Widget _buildRecommendationBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오늘의 추천 코디',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(
              color: Colors.grey[400]!,
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              '추천 코디 이미지가 여기에 표시됩니다.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
