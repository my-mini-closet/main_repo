import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../provider/boardpovider.dart';
import '../provider/userprovider.dart';

class BoardScreen extends StatefulWidget {
  @override
  _BoardScreenState createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  String _selectedCategory = 'latest';

  late String userId;
  @override
  void initState() {
    super.initState();
    userId = Provider.of<UserProvider>(context, listen: false).userId;
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    final url = Uri.parse('${dotenv.env['API_URL']}/boards/all');
    final boardProvider = Provider.of<BoardProvider>(context, listen: false);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final List<dynamic> data = json.decode(decodedBody);
      print('Received data: $data'); // 서버에서 받아온 데이터를 로그로 출력
      boardProvider.setPosts(data.map((item) => item as Map<String, dynamic>).toList());
    } else {
      print('Failed to load posts: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  Future<void> _loadCategoryPosts(String selectedCategory) async {
    final url = Uri.parse('${dotenv.env['API_URL']}/boards/${userId}/$selectedCategory');
    final boardProvider = Provider.of<BoardProvider>(context, listen: false);
    final response = await http.get(url);
    print("url: $url");
    print("response status ${response.statusCode}");
    print("response body ${response.body}");

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final List<dynamic> data = json.decode(decodedBody);
      print('Received data: $data'); // 서버에서 받아온 데이터를 로그로 출력
      boardProvider.setPosts(data.map((item) => item as Map<String, dynamic>).toList());
    } else {
      print('Failed to load posts: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final boardProvider = context.watch<BoardProvider>();

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
            child: _buildPostGrid(boardProvider.posts),
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
          _loadCategoryPosts(_selectedCategory);  // Load posts when category is changed
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

  Widget _buildPostGrid(List<Map<String, dynamic>> posts) {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 1.0,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        var post = posts[index];
        var imageUrl = post['imageUrls'] != null && post['imageUrls'].isNotEmpty
            ? post['imageUrls'][0]
            : 'https://via.placeholder.com/150';

        return GestureDetector(
          onTap: () {
            _onPostTap(context, post);
          },
          onLongPress: () {
            _showDeleteConfirmationDialog(context, post['id']);
          },
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        );
      },
    );
  }


  void _showDeleteConfirmationDialog(BuildContext context, String postId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('삭제 확인'),
          content: Text('게시글을 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deletePost(postId);
              },
              child: Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  void _deletePost(String postId) {
    final boardProvider = Provider.of<BoardProvider>(context, listen: false);
    boardProvider.removePost(postId);
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
            final boardProvider = Provider.of<BoardProvider>(context, listen: false);
            boardProvider.addPost(newPost);
            _loadPosts();  // 게시글 목록을 새로 고침
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
  late int likes;
  late int dislikes;
  bool isLiked = false;
  bool isDisliked = false;
  String baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:8080/api';
  late String userId;

  @override
  void initState() {
    super.initState();
    userId = Provider.of<UserProvider>(context, listen: false).userId;
    likes = 0; // Initialize likes
    dislikes = 0; // Initialize dislikes
    _loadPreferences();
    _loadPostDetails();
    //print("likes: $likes, dislikes: $dislikes");
  }

  Future<void> _loadPostDetails() async {
    final url = Uri.parse('$baseUrl/boards/${widget.post['id']}'); // 게시글 세부 사항을 가져오는 URL입니다.
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> data = json.decode(decodedBody);
        setState(() {
          likes = data['likeCount'] ?? 0;
          dislikes = data['unlikeCount'] ?? 0;
        });
      } else {
        print('Failed to load post details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading post details: $e');
    }
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('isLiked: $isLiked, isDisLiked: $isDisliked');
    setState(() {
      isLiked = prefs.getBool('isLiked_${widget.post['id']}') ?? false;
      isDisliked = prefs.getBool('isDisliked_${widget.post['id']}') ?? false;
    });
    print('isLiked1: $isLiked, isDisLiked1: $isDisliked');
    print("likes: $likes, dislikes: $dislikes");
  }

  Future<void> _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLiked_${widget.post['id']}', isLiked);
    prefs.setBool('isDisliked_${widget.post['id']}', isDisliked);
  }

  Future<void> _likePost() async {
    if (isLiked) return;

    final url = Uri.parse('$baseUrl/boards/${widget.post['id']}/like?userId=$userId');
    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        setState(() {
          if (isDisliked) {
            dislikes--;
            isDisliked = false;
          }
          likes++;
          isLiked = true;
        });
        _savePreferences();
      } else {
        print('Failed to like the post: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error liking the post: $e');
    }
  }

  Future<void> _dislikePost() async {
    if (isDisliked) return;

    final url = Uri.parse('$baseUrl/boards/${widget.post['id']}/unlike?userId=$userId');
    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        setState(() {
          if (isLiked) {
            likes--;
            isLiked = false;
          }
          dislikes++;
          isDisliked = true;
        });
        _savePreferences();
      } else {
        print('Failed to dislike the post: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error disliking the post: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var imageUrl = widget.post['imageUrls'] != null && widget.post['imageUrls'].isNotEmpty
        ? widget.post['imageUrls'][0]
        : 'https://via.placeholder.com/150';

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
            Image.network(imageUrl),
            SizedBox(height: 8.0),
            Text(widget.post['title'] ?? 'No Title', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.0),
            Text(widget.post['text'] ?? 'No Description'),
            SizedBox(height: 16.0),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.thumb_up),
                  color: isLiked ? Colors.red : Colors.black,
                  onPressed: _likePost,
                ),
                Text(likes.toString()),
                IconButton(
                  icon: Icon(Icons.thumb_down),
                  color: isDisliked ? Colors.red : Colors.black,
                  onPressed: _dislikePost,
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
  String baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:8080/boardImages';

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

  Future<void> _submitPost() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.userId;
    final userNickName = userProvider.userNickName;

    if (_titleController.text.isNotEmpty && _imageFile != null) {
      final url = Uri.parse('${baseUrl}/boards/createwithimage');
      final request = http.MultipartRequest('POST', url)
        ..fields['title'] = _titleController.text
        ..fields['text'] = _descriptionController.text.isNotEmpty ? _descriptionController.text : '설명 없음'
        ..fields['userId'] = userId.toString()
        ..files.add(await http.MultipartFile.fromPath('files', _imageFile!.path));

      try {
        final response = await request.send();
        final responseBody = await response.stream.bytesToString();
        print('Response status: ${response.statusCode}');
        print('Response body: ${responseBody}');

        if (response.statusCode == 200) {
          final responseData = json.decode(responseBody);
          final imageUrls = responseData['imageUrls'] as List<dynamic>?;
          if (imageUrls != null && imageUrls.isNotEmpty) {
            final imageUrl = imageUrls[0] as String?;
            print("imageUrl: ${imageUrl}");

            widget.onPostAdded({
              'image': '${imageUrl}', // Complete the URL
              'title': _titleController.text,
              'author': userNickName,
              'description': _descriptionController.text.isNotEmpty
                  ? _descriptionController.text
                  : '설명 없음',
            });
            Navigator.pop(context);
          } else {
            print('이미지 URL이 없습니다.');
          }
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('게시물 업로드 실패'),
              content: Text('서버에서 오류가 발생했습니다.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('확인'),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        print('Error submitting post: $e');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('게시물 업로드 실패'),
            content: Text('네트워크 오류가 발생했습니다.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('확인'),
              ),
            ],
          ),
        );
      }
    } else {
      // 필수 입력값이 비어있을 경우 처리
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('게시물 등록 실패'),
          content: Text('제목 또는 이미지를 입력하세요.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('확인'),
            ),
          ],
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('새 게시글 등록'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
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
                  : Container(
                height: MediaQuery.of(context).size.height * 0.4,
                child: Image.file(
                  _imageFile!,
                  fit: BoxFit.contain,
                ),
              ),
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
      ),
    );
  }
}
