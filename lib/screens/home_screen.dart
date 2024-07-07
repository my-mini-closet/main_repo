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
  int _currentIndex = 0;

  final List<Widget> _screens = [
    wardrobe.WardrobeScreen(),
    BoardScreen(),
    HomeScreenContent(), // 홈 화면의 컨텐츠
    recommendation.RecommendationScreen(),
    PersonalColorScreen(),
  ];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
    );
  }
}

class HomeScreenContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Welcome to Home Screen!'),
    );
  }
}

