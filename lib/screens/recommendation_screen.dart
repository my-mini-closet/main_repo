import 'package:flutter/material.dart';

class RecommendationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('나만의 옷장으로 코디하기'),
      ),
      body: Center(
        child: Text('나만의 작은 옷장'),
      ),
    );
  }
}
