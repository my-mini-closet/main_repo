import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  BottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: Colors.black,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black.withOpacity(0.6),
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag, color: Colors.black),
          label: '나만의옷장',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.article, color: Colors.black),
          label: '게시판',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home, color: Colors.black),
          label: '홈화면',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.android, color: Colors.black),
          label: '코디하기',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.palette, color: Colors.black),
          label: '퍼스널 컬러',
        ),
      ],
    );
  }
}