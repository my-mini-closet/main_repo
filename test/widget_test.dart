import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:main_repo/main.dart';

void main() {
  testWidgets('Login screen renders correctly', (WidgetTester tester) async {

    await tester.pumpWidget(MyApp());

    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('Navigation to home screen', (WidgetTester tester) async {

    await tester.pumpWidget(MyApp());

    // 이메일 비번 넣기
    await tester.enterText(find.byType(TextField).first, 'test@example.com');
    await tester.enterText(find.byType(TextField).last, 'password');

    // 로그인버튼 누르기
    await tester.tap(find.byKey(Key('loginButton')));
    await tester.pumpAndSettle();

    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });
}
