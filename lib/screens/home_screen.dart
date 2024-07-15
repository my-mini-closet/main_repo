import 'package:flutter/material.dart';
import 'wardrobe_screen.dart' as wardrobe;
import 'board_screen.dart';
import 'recommendation_screen.dart' as recommendation;
import 'personal_color_screen.dart';
import '../widgets/bottom_nav_bar.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 2;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      wardrobe.WardrobeScreen(),
      BoardScreen(),
      HomeScreenContent(onTap: (int index) {
        setState(() {
          _currentIndex = index;
        });
      }),
      recommendation.RecommendationScreen(),
      PersonalColorScreen(),
    ];
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
    );
  }
}

class HomeScreenContent extends StatelessWidget {
  final Function(int) onTap;

  HomeScreenContent({required this.onTap});

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
            SizedBox(height: 45),
            GestureDetector(
              onTap: () => onTap(0),
              child: Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20.0),
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
                  onTap: () => onTap(1),
                  child: Container(
                    width: MediaQuery.of(context).size.width / 2 - 20,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(color: Colors.black, width: 2.0),
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
                  onTap: () => onTap(3),
                  child: Container(
                    width: MediaQuery.of(context).size.width / 2 - 20,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.pink,
                      borderRadius: BorderRadius.circular(20.0),
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
              onTap: () => onTap(4),
              child: Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  color: Color(0xFFFBC02D),
                  borderRadius: BorderRadius.circular(20.0),
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
}
