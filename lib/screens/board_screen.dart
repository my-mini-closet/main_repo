import 'package:flutter/material.dart';

class BoardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '스타일 게시판',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // 검색 버튼 클릭하면 기능 구현 등등..
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // 알림 버튼 클릭하면 기능 구현
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionTitle('베스트 코디'),
            _buildBestCoordiList(),
            SizedBox(height: 20),
            _buildSectionTitle('내 글 등록하기'),
            _buildRoundedButton(context, '내 글 등록하기', _onRegisterPost),
            SizedBox(height: 20),
            _buildSectionTitle('퍼스널 컬러별 추천 코디'),
            _buildPersonalColorList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildBestCoordiList() {
    // 베스트 코디를 보여주기 -리스트
    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5, // 예시 아이템 개수
        itemBuilder: (context, index) {
          return Container(
            width: 150,
            margin: EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Center(
              child: Text(
                '코디 ${index + 1}',
                style: TextStyle(color: Colors.black),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoundedButton(BuildContext context, String text,
      VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey, Colors.black],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          padding: EdgeInsets.all(16.0),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  void _onRegisterPost() {
    // 내 글 등록하기 버튼 클릭 시 기능구현..?
    print('내 글 등록하기 클릭됨');
  }

  Widget _buildPersonalColorList() {
    // 퍼스널 컬러별 추천 코디를 보여주는 리스트
    final colors = ['여름 쿨톤', '겨울 쿨톤', '가을 웜톤', '봄 웜톤'];
    return Column(
      children: colors.map((color) {
        return Container(
          margin: EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: ListTile(
            title: Text(
              color,
              style: TextStyle(color: Colors.black),
            ),
            onTap: () {
              print('$color 클릭됨');
            },
          ),
        );
      }).toList(),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: BoardScreen(),
  ));
}
