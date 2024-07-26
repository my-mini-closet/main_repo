import 'package:flutter/material.dart';

class BoardScreen extends StatefulWidget {
  @override
  _BoardScreenState createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  String _selectedCategory = 'latest';

  List<Map<String, dynamic>> _posts = [
    //예시 이미지..
    {'image': 'https://via.placeholder.com/150', 'title': '여름 20대 남자 코디추천', 'author': '김무신사'},
    {'image': 'https://via.placeholder.com/150', 'title': '여름 20대 여자 코디추천', 'author': '김유저'},
    {'image': 'https://via.placeholder.com/150', 'title': 'Title 3', 'author': 'User3'},
    {'image': 'https://via.placeholder.com/150', 'title': 'Title 4', 'author': 'User4'},
    {'image': 'https://via.placeholder.com/150', 'title': 'Title 5', 'author': 'User5'},
    {'image': 'https://via.placeholder.com/150', 'title': 'Title 6', 'author': 'User6'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '스타일 게시판',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // 검색 버튼 클릭 시 기능 구현
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // 알림 버튼 클릭 시 기능 구현
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildCategorySelector(),
          ),
          Expanded(
            child: _buildPostGrid(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onRegisterPost,
        child: Icon(Icons.add),
        backgroundColor: Colors.pinkAccent,
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCategoryButton('최신순', 'latest'),
        _buildCategoryButton('인기순', 'popular'),
        _buildCategoryButton('내글', 'myPosts'),
      ],
    );
  }

  Widget _buildCategoryButton(String title, String category) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _selectedCategory == category ? Colors.black : Colors.grey,
      ),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildPostGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 1.0,
      ),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        var post = _posts[index];
        return GestureDetector(
          onTap: () {
            _onPostTap(context, post);
          },
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(post['image']),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        );
      },
    );
  }

  void _onPostTap(BuildContext context, Map<String, dynamic> post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailScreen(post: post),
      ),
    );
  }

  void _onRegisterPost() {
    print('내 글 등록하기 클릭됨');
  }
}

class PostDetailScreen extends StatefulWidget {
  final Map<String, dynamic> post;

  PostDetailScreen({required this.post});

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  int likes = 0;
  int dislikes = 0;
  bool isLiked = false;
  bool isDisliked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '게시글 상세',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  child: Text(widget.post['author'][0]),
                ),
                SizedBox(width: 8),
                Text(
                  widget.post['author'],
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                widget.post['title'],
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(widget.post['image']),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.thumb_up),
                  color: isLiked ? Colors.red : Colors.black,
                  onPressed: () {
                    setState(() {
                      if (isLiked) {
                        likes--;
                        isLiked = false;
                      } else {
                        if (isDisliked) {
                          dislikes--;
                          isDisliked = false;
                        }
                        likes++;
                        isLiked = true;
                      }
                    });
                  },
                ),

                Text(likes.toString()),
                IconButton(
                  icon: Icon(Icons.thumb_down),
                  color: isDisliked ? Colors.red : Colors.black,
                  onPressed: () {
                    setState(() {
                      if (isDisliked) {
                        dislikes--;
                        isDisliked = false;
                      } else {
                        if (isLiked) {
                          likes--;
                          isLiked = false;
                        }
                        dislikes++;
                        isDisliked = true;
                      }
                    });
                  },
                ),
                Text(dislikes.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: BoardScreen(),
  ));
}
