import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'screens/login_screen.dart' as login;
import 'screens/home_screen.dart' as home;
import 'firebase_options.dart';
import 'imagerepository.dart'; // image.dart 파일을 import 합니다.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  KakaoSdk.init(nativeAppKey: '291ad7d498687655690b94b3dc6433e2'); //카카오개발자 사이트에 등록한 내 앱 네이티브 키

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fashion App',
      initialRoute: '/',
      routes: {
        '/': (context) => login.LoginScreen(),
        '/home': (context) => home.HomeScreen(),
      },
    );
  }
}
