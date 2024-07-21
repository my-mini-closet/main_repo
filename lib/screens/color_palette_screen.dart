import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ColorPaletteScreen extends StatelessWidget {
  final String tone;

  ColorPaletteScreen({required this.tone});

  @override
  Widget build(BuildContext context) {
    List<Color> palette = getColorPalette(tone);

    return Scaffold(
      appBar: AppBar(
        title: Text('$tone 패션 팔레트'),
      ),
      body: SingleChildScrollView(  //스크롤 가능하게
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: palette.map((color) {
                return Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: 20),
            Text(
              '색상 팔레트',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            FutureBuilder<String>(
              future: loadToneTips(tone),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('오류 발생: ${snapshot.error}');
                } else if (!snapshot.hasData) {
                  return Text('설명 없음');
                } else {
                  return Text(
                    snapshot.data!,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                    textAlign: TextAlign.center,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Color> getColorPalette(String tone) {
    switch (tone) {
      case '여름 쿨톤':
        return [
          Colors.lightBlue[100]!,
          Colors.deepPurple[100]!,
          Colors.lightGreen[100]!,
          Colors.pink[100]!,
          Colors.blue[200]!,
          Colors.purple[200]!,
          Colors.cyan[100]!,
          Colors.indigo[100]!,
          Colors.teal[100]!,
          Colors.purple[100]!,
        ];
      case '겨울 쿨톤':
        return [
          Colors.blue[800]!,
          Colors.purple[800]!,
          Colors.red[900]!,
          Colors.black,
          Colors.grey[700]!,
          Colors.deepPurple,
          Colors.blueGrey[800]!,
          Colors.deepPurple[900]!,
          Colors.deepOrange[900]!,
          Colors.brown[900]!,
        ];
      case '봄 웜톤':
        return [
          Colors.pink[100]!,
          Colors.orange[200]!,
          Colors.lightGreen[200]!,
          Colors.lightGreenAccent[100]!,
          Colors.pink[200]!,
          Colors.amber[200]!,
          Colors.lime[200]!,
          Colors.orangeAccent[100]!,
          Colors.redAccent[100]!,
          Colors.redAccent[100]!,
        ];
      case '가을 웜톤':
        return [
          Colors.orange[800]!,
          Colors.brown[800]!,
          Colors.green[700]!,
          Colors.red[700]!,
          Colors.amber[900]!,
          Colors.brown[600]!,
          Colors.deepOrange[700]!,
          Colors.yellow[700]!,
          Colors.lightGreen[700]!,
          Colors.brown[400]!,
        ];
      default:
        return [];
    }
  }

  Future<String> loadToneTips(String tone) async {
    String fileName = getToneTips(tone);
    return await rootBundle.loadString('assets/txt/$fileName');
  }

  String getToneTips(String tone) {
    switch (tone) {
      case '여름 쿨톤':
        return 'summer.txt';
      case '겨울 쿨톤':
        return 'winter.txt';
      case '봄 웜톤':
        return 'spring.txt';
      case '가을 웜톤':
        return 'fall.txt';
      default:
        return '';
    }
  }
}
