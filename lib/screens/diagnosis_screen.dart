import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import '../provider/userprovider.dart';
import 'color_palette_screen.dart';
import 'package:http/http.dart' as http;

class DiagnosisScreen extends StatefulWidget {
  @override
  _DiagnosisScreenState createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  final List<List<Color>> options = [
    [Colors.lightBlue[100]!, Colors.deepPurple[100]!], // Cool Tone
    [Colors.blue[100]!, Colors.purple[100]!],         // Cool Tone
    [Colors.cyan[200]!, Colors.teal[100]!],           // Cool Tone
    [Colors.blue[800]!, Colors.purple[800]!],         // Cool Tone
    [Colors.indigo[600]!, Colors.blueGrey[700]!],     // Cool Tone
    [Colors.blueGrey[300]!, Colors.cyan[700]!],       // Cool Tone
    [Colors.purple[200]!, Colors.purpleAccent[200]!], // Cool Tone
    [Colors.grey[300]!, Colors.blueGrey[300]!],       // Cool Tone
    [Colors.lightGreen[200]!, Colors.cyanAccent[100]!], // Cool Tone
    [Colors.yellow[300]!, Colors.indigo[400]!],       // Cool Tone

    [Colors.yellowAccent[100]!, Colors.pink[100]!],   // Warm Tone
    [Colors.orange[200]!, Colors.yellow[200]!],       // Warm Tone
    [Colors.amber[200]!, Colors.orange[300]!],        // Warm Tone
    [Colors.orange[800]!, Colors.deepOrange[800]!],   // Warm Tone
    [Colors.brown[700]!, Colors.deepOrange[700]!],    // Warm Tone
    [Colors.red[400]!, Colors.brown[300]!],           // Warm Tone
    [Colors.green[300]!, Colors.lime[300]!],          // Warm Tone
    [Colors.teal[300]!, Colors.green[400]!],          // Warm Tone
    [Colors.red[300]!, Colors.redAccent[200]!],       // Warm Tone
    [Colors.pink[300]!, Colors.deepOrange[300]!],     // Warm Tone
  ];

  int currentQuestionIndex = 0;
  List<int> selectedColorIndices = [];
  String result = '';
  late String userId;
  String baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:8080/api';

  void nextQuestion(int selectedIndex) {
    setState(() {
      if (selectedIndex >= 0 && selectedIndex < options[currentQuestionIndex].length) {
        selectedColorIndices.add(currentQuestionIndex + selectedIndex);
        if (currentQuestionIndex < options.length - 1) {
          currentQuestionIndex++;
        } else {
          result = diagnose(selectedColorIndices);
          showResultDialog(result);
        }
      }
    });
  }

  String diagnose(List<int> selectedQuestionIndices) {
    int coolCount = 0;
    int warmCount = 0;

    for (int questionIndex in selectedQuestionIndices) {
      if (questionIndex < 10) {
        coolCount++;
      } else {
        warmCount++;
      }
    }

    print('Selected Indices: $selectedQuestionIndices');
    print('Cool Count: $coolCount, Warm Count: $warmCount');

    if (coolCount >= warmCount) {
      int summerCoolCount = selectedQuestionIndices.where((index) => [0, 1, 6, 8].contains(index)).length;
      int winterCoolCount = selectedQuestionIndices.where((index) => [3, 4, 7, 9].contains(index)).length;

      print('Summer Cool Count: $summerCoolCount, Winter Cool Count: $winterCoolCount');

      if (summerCoolCount >= winterCoolCount) {
        return '여름 쿨톤';
      } else {
        return '겨울 쿨톤';
      }
    } else {
      int springWarmCount = selectedQuestionIndices.where((index) => [10, 11, 16, 18].contains(index)).length;
      int autumnWarmCount = selectedQuestionIndices.where((index) => [12, 13, 14, 19].contains(index)).length;

      print('Spring Warm Count: $springWarmCount, Autumn Warm Count: $autumnWarmCount');

      if (springWarmCount >= autumnWarmCount) {
        return '봄 웜톤';
      } else {
        return '가을 웜톤';
      }
    }
  }

  void resetDiagnosis() {
    setState(() {
      currentQuestionIndex = 0;
      selectedColorIndices.clear();
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

  Future<void> savePersonalColor(String personalColor) async {
    userId = Provider.of<UserProvider>(context, listen: false).userId; // Obtain userId from UserProvider
    final url = '$baseUrl/users/updatePersonalColor';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'userId': userId,
        'personalColor': personalColor,
      }),
    );
    print("userId: $userId, personalColor: $personalColor");
    print("response status: ${response.statusCode}");
    print("response body: ${response.body}");
    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final data = json.decode(decodedBody);
      print('Received data: $data'); // Server response
      String userId = data['userId'].toString(); // Extract userId
      String personalColor = data['personalColor'];
      print("userId: ${userId}");
      print("personalColor: ${personalColor}");
    } else {
      print('Failed to update personal color');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('나와 어울리는 색을 선택해주세요!'),
        ),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Flexible(
              flex: 1,
              child: GestureDetector(
                onTap: () => nextQuestion(0),
                child: Container(
                  width: double.infinity,
                  color: options[currentQuestionIndex][0],
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: GestureDetector(
                onTap: () => nextQuestion(1),
                child: Container(
                  width: double.infinity,
                  color: options[currentQuestionIndex][1],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
