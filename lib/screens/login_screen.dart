import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned(
            top: -50,
            left: -50,
            child: _buildCircle(200, Colors.white.withOpacity(0.2)),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: _buildCircle(300, Colors.white.withOpacity(0.2)),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '나만의 작은 옷장',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 60),

                  // 로그인 폼 컨테이너
                  Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(color: Colors.black),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.black),
                            ),
                          ),
                          style: TextStyle(color: Colors.black),
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(color: Colors.black),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.black),
                            ),
                          ),
                          obscureText: true,
                          style: TextStyle(color: Colors.black),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          key: Key('loginButton'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          onPressed: () {
                            // 이메일 형식 검사
                            if (emailController.text.isNotEmpty &&
                                passwordController.text.isNotEmpty) {
                              // 이메일 형식 확인
                              if (RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                  .hasMatch(emailController.text)) {
                                // 로그인 된다면 메인화면으로 이동
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HomeScreen()),
                                );
                              } else {
                                // 잘못된 이메일 형식 경고
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('로그인 실패'),
                                    content: Text('올바른 이메일 형식을 입력해주세요.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('확인'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            } else {
                              // 이메일과 패스워드 필드가 비어있으면 경고하기
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('로그인 실패'),
                                  content: Text('이메일과 패스워드를 입력해주세요.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('확인'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                          child: Text('로그인',
                              style: TextStyle(color: Colors.black)),
                        ),

                        SizedBox(height: 20),
                        Divider(color: Colors.black, thickness: 1),
                        SizedBox(height: 20),

                        ElevatedButton(
                          key: Key('kakaoLoginButton'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black, backgroundColor: Colors.yellow,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () async {
                            try {
                              // 카카오톡으로 로그인 시도
                              if (await isKakaoTalkInstalled()) {
                                try {
                                  await UserApi.instance.loginWithKakaoTalk();
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => HomeScreen()),
                                  );
                                } catch (e) {
                                  // 카카오톡 로그인 실패 시 예외 처리
                                  print('카카오톡으로 로그인 실패: $e');
                                }
                              } else {
                                // 카카오톡 미설치 시 웹뷰로 로그인 시도
                                try {
                                  await UserApi.instance
                                      .loginWithKakaoAccount();
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => HomeScreen()),
                                  );
                                } catch (e) {
                                  // 카카오 웹뷰 로그인 실패 시 예외 처리
                                  print('카카오 계정으로 로그인 실패: $e');
                                }
                              }
                            } catch (e) {
                              // 로그인 실패 시 예외 처리
                              print('로그인 실패: $e');
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/kakao_icon.png',
                                width: 24,
                                height: 24,
                              ),
                              SizedBox(width: 8),
                              Text(
                                '카카오로 로그인',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),

                        // 회원가입 안내 문구와 버튼 추가
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '아직 계정이 없으신가요?',
                              style: TextStyle(color: Colors.black),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => RegisterScreen()),
                                );
                              },
                              child: Text(
                                '회원가입',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
