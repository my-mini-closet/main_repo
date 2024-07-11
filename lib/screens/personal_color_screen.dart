import 'package:flutter/material.dart';

class PersonalColorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내 퍼스널 컬러는? '),
      ),
      body: Center(
        child: Text('퍼스널 컬러 진단하기'),
      ),
    );
  }
}
