import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class BoardScreen extends StatefulWidget {
  @override
  _BoardScreenState createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  String _selectedCategory = 'latest';
  List<Map<String, dynamic>> _posts = [
    {'image': 'https://via.placeholder.com/150', 'title': '여름 20대 남자 코디추천', 'author': '김무신사', 'description': '여름 패션 추천합니다.'},
    {'image': 'https://via.placeholder.com/150', 'title': '여름 20대 여자 코디추천', 'author': '김유저', 'description': '여름 여자 패션 추천합니다.'},
    {'image': 'https://via.placeholder.com/150', 'title': 'Title 3', 'author': 'User3', 'description': ''},
    {'image': 'https://via.placeholder.com/150', 'title': 'Title 4', 'author': 'User4', 'description': ''},
    {'image': 'https://via.placeholder.com/150', 'title': 'Title 5', 'author': 'User5', 'description': ''},
    {'image': 'https://via.placeholder.com/150', 'title': 'Title 6', 'author': 'User6', 'description': ''},
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
                image: NetworkImage(post['image'] ?? 'https://via.placeholder.com/150'),
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPostScreen(
          onPostAdded: (newPost) {
            setState(() {
              _posts.add(newPost);
            });
          },
        ),
      ),
    );
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
                  child: Text(
                    (widget.post['author'] as String?)?.substring(0, 1) ?? 'U',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  widget.post['author'] as String? ?? 'Unknown',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                widget.post['title'] as String? ?? 'No Title',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width * 0.6,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(widget.post['image'] as String? ?? 'https://via.placeholder.com/150'),
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
            SizedBox(height: 20),
            Text(
              widget.post['description'] as String? ?? '설명 없음',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}


class AddPostScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onPostAdded;

  AddPostScreen({required this.onPostAdded});

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  Future<void> _takePhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  void _submitPost() {
    if (_titleController.text.isNotEmpty && _imageFile != null) {
      final newPost = {
        'image': _imageFile!.path,
        'title': _titleController.text,
        'author': '유저',
        'description': _descriptionController.text.isNotEmpty ? _descriptionController.text : '설명 없음',
      };
      widget.onPostAdded(newPost);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('새 게시글 등록'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: '제목'),
            ),
            SizedBox(height: 10),
            _imageFile == null
                ? Text('사진을 선택하세요')
                : Image.file(_imageFile!),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('갤러리에서 선택'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _takePhoto,
                  child: Text('카메라로 촬영'),
                ),
              ],
            ),
            SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: '짧은 코멘트'),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitPost,
              child: Text('게시글 등록'),
            ),
          ],
        ),
      ),
    );
  }
}
