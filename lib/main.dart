import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'imagerepository.dart'; // image.dart 파일을 import 합니다.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Storage',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FirebaseStorageScreen(), // 메인 화면으로 FirebaseStorageScreen 설정
    );
  }
}
