  import 'dart:convert';

  import 'package:flutter/material.dart';
  import 'package:flutter_dotenv/flutter_dotenv.dart';
  import 'package:image_picker/image_picker.dart';
  import 'dart:io';
  import 'package:http/http.dart' as http;
  import 'package:provider/provider.dart';

  import '../provider/boardpovider.dart';
import '../provider/userprovider.dart';

  class BoardScreen extends StatefulWidget {
    @override
    _BoardScreenState createState() => _BoardScreenState();
  }

  class _BoardScreenState extends State<BoardScreen> {
    String _selectedCategory = 'latest';

    @override
    void initState() {
      super.initState();
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
            _loadPosts();  // Load posts when category is changed
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
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    child: Text(
                      (widget.post['userNickName'] as String?)?.substring(0, 1) ?? 'U',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    widget.post['userNickName'] as String? ?? 'Unknown',
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
                      image: NetworkImage(imageUrl),
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
                widget.post['text'] as String? ?? '설명 없음',
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

        final response = await request.send();
        final responseBody = await response.stream.bytesToString();
        print('Response status: ${response.statusCode}');
        print('Response body: ${responseBody}');

        if (response.statusCode == 200) {
          final responseData = json.decode(responseBody);
          // 응답 데이터의 'imageUrls'를 사용
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


