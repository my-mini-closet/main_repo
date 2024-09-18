import 'package:flutter/material.dart';

class RecommendationScreen extends StatefulWidget {
  @override
  _RecommendationScreenState createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  String? selectedCategory;
  String? selectedSeason;
  bool _isLoading = false;

  final Map<String, List<String>> styleCategories = {
    "클래식": ["클래식", "프레피"],
    "매니시": ["매니시", "톰보이"],
    "엘레강스": ["엘레강스", "소피스케이티드", "글래머러스"],
    "에스닉": ["에스닉", "히피", "오리엔탈"],
    "모던": ["모던", "미니멀"],
    "내추럴": ["내추럴", "컨트리", "리조트"],
    "로맨틱": ["로맨틱", "섹시"],
    "스포티": ["스포티", "애슬레져", "밀리터리"],
    "문화": ["뉴트로", "힙합", "키티/키덜트", "맥시멈", "펑크/로커"],
    "캐주얼": ["캐주얼", "놈코어"]
  };

  final List<String> seasons = ["봄", "여름", "가을", "겨울"];

  void _generateOutfit() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildSeasonButton(String season) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedSeason = season;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: selectedSeason == season ? Colors.blueAccent : Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 3,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              season,
              style: TextStyle(
                color: selectedSeason == season ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'AI 코디 생성기',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI가 추천하는 코디를 받아보세요!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: DropdownButton<String>(
                value: selectedCategory,
                hint: Text('카테고리 선택'),
                isExpanded: true,
                underline: SizedBox(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCategory = newValue;
                  });
                },
                items: styleCategories.keys.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: seasons.map((season) => _buildSeasonButton(season)).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _generateOutfit,
              child: Text(
                'AI 코디 생성하기!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 23,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                minimumSize: Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                elevation: 5,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Center(
                child: _isLoading
                    ? CircularProgressIndicator()
                    : Container(
                  width: double.infinity,
                  height: 500,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Center(
                    child: Text(
                      '코디 화면 (대체 이미지)',
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
