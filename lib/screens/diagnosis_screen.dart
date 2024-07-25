import 'package:flutter/material.dart';
import 'color_palette_screen.dart';
import 'package:http/http.dart' as http;

class DiagnosisScreen extends StatefulWidget {
  @override
  _DiagnosisScreenState createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  final String question = '나와 어울리는 색을 선택해주세요';

  final List<List<Color>> options = [
    // 여름 쿨톤 색상
    [Colors.lightBlue[100]!, Colors.deepPurple[100]!],
    [Colors.blue[100]!, Colors.purple[100]!],
    [Colors.cyan[200]!, Colors.teal[100]!],

    // 겨울 쿨톤 색상
    [Colors.blue[800]!, Colors.purple[800]!],
    [Colors.indigo[600]!, Colors.blueGrey[700]!],
    [Colors.blueGrey[300]!, Colors.cyan[700]!],

    // 봄 웜톤 색상
    [Colors.yellowAccent[100]!, Colors.pink[100]!],
    [Colors.orange[200]!, Colors.yellow[200]!],
    [Colors.amber[200]!, Colors.orange[300]!],

    // 가을 웜톤 색상
    [Colors.orange[800]!, Colors.yellow[800]!],
    [Colors.brown[700]!, Colors.deepOrange[700]!],
    [Colors.red[400]!, Colors.brown[300]!],

    // 추가 색상
    [Colors.green[300]!, Colors.lime[300]!],
    [Colors.purple[200]!, Colors.purpleAccent[200]!],
    [Colors.grey[300]!, Colors.blueGrey[300]!],
    [Colors.teal[300]!, Colors.green[400]!],
    [Colors.red[300]!, Colors.redAccent[200]!],
    [Colors.pink[300]!, Colors.deepOrange[300]!],
  ];
  int currentQuestionIndex = 0;
  List<int> selectedColorIndices = [];
  String result = '';

  void nextQuestion(int selectedIndex) {
    setState(() {
      if (selectedIndex >= 0 && selectedIndex < options[currentQuestionIndex].length) {
        selectedColorIndices.add(selectedIndex);
        if (currentQuestionIndex < options.length - 1) {
          currentQuestionIndex++;
        } else {
          result = diagnose(selectedColorIndices);
          showResultDialog(result);
        }
      }
    });
  }

  void showResultDialog(String result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('진단 결과'),
        content: Text('당신의 퍼스널 컬러는 $result 입니다!'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              savePersonalColor(result);
              if (result == '여름 쿨톤' || result == '겨울 쿨톤' || result == '봄 웜톤' || result == '가을 웜톤') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ColorPaletteScreen(tone: result),
                  ),
                );
              } else {
                resetDiagnosis();
              }
            },
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  void resetDiagnosis() {
    setState(() {
      currentQuestionIndex = 0;
      selectedColorIndices.clear();
    });
  }

  String diagnose(List<int> selectedColorIndices) {
    int coolLightCount = selectedColorIndices.where((index) => index == 0 || index == 4 || index == 8).length;
    int coolDeepCount = selectedColorIndices.where((index) => index == 1 || index == 5).length;
    int warmLightCount = selectedColorIndices.where((index) => index == 2 || index == 6).length;
    int warmDeepCount = selectedColorIndices.where((index) => index == 3 || index == 7 || index == 9).length;

    if (coolLightCount >= 2) {
      return '여름 쿨톤';
    } else if (coolDeepCount >= 2) {
      return '겨울 쿨톤';
    } else if (warmLightCount >= 2) {
      return '봄 웜톤';
    } else if (warmDeepCount >= 2) {
      return '가을 웜톤';
    }
    return '진단 결과 없음';
  }
  Future<void> savePersonalColor(String personalColor) async {
    final response = await http.post(
      Uri.parse('http://localhost:8080/api/users/updatePersonalColor'),
      body: {
        'email': 'your-email@example.com',  // 사용자의 이메일을 전달, 로그인 기능 구현시 추가
        'personalColor': personalColor,
      },
    );

    if (response.statusCode == 200) {
      print('Personal color updated successfully');
    } else {
      print('Failed to update personal color');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('퍼스널 컬러 진단'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                question,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              for (int i = 0; i < options[currentQuestionIndex].length; i++)
                GestureDetector(
                  onTap: () => nextQuestion(i),
                  child: Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      color: options[currentQuestionIndex][i],
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 4),
                          blurRadius: 10.0,
                        ),
                      ],
                    ),
                    margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}