import 'package:flutter/material.dart';
import 'color_palette_screen.dart';
import 'diagnosis_screen.dart';

class PersonalColorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('퍼스널 컬러'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _buildDiagnosisButton(
              context: context,
              text: '내 퍼스널 컬러 진단하기!',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DiagnosisScreen(),
                  ),
                );
              },
            ),
            SizedBox(height: 40),
            Text(
              '컬러별 패션 팔레트 보기',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            _buildToneSelectionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosisButton({
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 80,
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 5,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(width: 10),
            Icon(Icons.arrow_forward_ios, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildToneSelectionButtons(BuildContext context) {
    final tones = [
      '여름 쿨톤',
      '겨울 쿨톤',
      '봄 웜톤',
      '가을 웜톤',
    ];

    return Wrap(
      spacing: 20,
      runSpacing: 20,
      alignment: WrapAlignment.center,
      children: tones.map((tone) {
        return Container(
          width: 120,
          height: 120,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _getToneColor(tone),
              shape: CircleBorder(),
              elevation: 5, // Shadow
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ColorPaletteScreen(tone: tone),
                ),
              );
            },
            child: Center(
              child: Text(
                tone,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getToneColor(String tone) {
    switch (tone) {
      case '여름 쿨톤':
        return Colors.lightBlue[100]!;
      case '겨울 쿨톤':
        return Colors.deepPurple[300]!;
      case '봄 웜톤':
        return Colors.pinkAccent[100]!;
      case '가을 웜톤':
        return Colors.brown[200]!;
      default:
        return Colors.grey[300]!;
    }
  }
}
