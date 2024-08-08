import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:myminicloset/screens/social_login.dart';

class MainViewModel {
  final SocialLogin _socialLogin;
  bool isLogined = false; // 처음에 로그인 안 되어 있음
  User? user; // 카카오톡에서 사용자 정보를 저장하는 객체 User를 nullable 변수로 선언

  MainViewModel(this._socialLogin);

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