import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:myminicloset/screens/social_login.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../provider/userprovider.dart';

class MainViewModel {
  final SocialLogin _socialLogin;
  final UserProvider _userProvider;
  bool isLogined = false; // 처음에 로그인 안 되어 있음
  User? user; // 카카오톡에서 사용자 정보를 저장하는 객체 User를 nullable 변수로 선언

  MainViewModel(this._socialLogin, this._userProvider);
  Future<bool> loginWithEmail(String email, String password) async {
    String baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:8080/api';
    final url = '${baseUrl}/users/login';
    // 서버로 로그인 요청을 보내고 응답을 처리합니다.
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json', // JSON 형식으로 요청
        },
        body: jsonEncode({
          'userEmail': email,
          'password': password,
        }),
      );
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedBody);
        print('Received data: $data'); // 서버에서 받아온 데이터를 로그로 출력// JSON 응답 파싱
        String userId = data['userId'].toString(); // 사용자 ID 추출
        String userNickName = data['userNickname'];
        print("userId: ${userId}");
        print("userNickName: ${userNickName}");
        _userProvider.setUserId(userId);
        _userProvider.setUserNickName(userNickName);
        return true;
      } else {
        // 로그인 실패
        return false;
      }
    } catch (e) {
      print('Login failed: $e');
      return false;
    }
  }
  Future<bool> login() async {
    try {
      isLogined = await _socialLogin.login(); // 로그인 시도하기
      if (isLogined) {
        // 로그인 성공 시 사용자 정보 요청
        user = await UserApi.instance.me();
        print('사용자 정보 요청 성공'
            '\n회원번호: ${user?.id}'
            '\n닉네임: ${user?.kakaoAccount?.profile?.nickname}'
            '\n이메일: ${user?.kakaoAccount?.email}');
      }
      return isLogined;
    } catch (error) {
      print('로그인 실패 또는 사용자 정보 요청 실패 $error');
      isLogined = false;
      user = null;
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _socialLogin.logout();
      isLogined = false;
      user = null;
    } catch (error) {
      print('로그아웃 실패 $error');
    }
  }
}