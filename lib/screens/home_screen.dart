import 'package:flutter/material.dart';
import 'wardrobe_screen.dart' as wardrobe;
import 'board_screen.dart';
import 'recommendation_screen.dart' as recommendation;
import 'personal_color_screen.dart';
import '../widgets/bottom_nav_bar.dart';
import 'home_screen_content.dart';

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
