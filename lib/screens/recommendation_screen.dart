import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:myminicloset/imagerepository.dart';
import 'package:image_picker/image_picker.dart';

class RecommendationScreen extends StatefulWidget {
  @override
  _RecommendationScreenState createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  final ImageRepository _imageRepository = ImageRepository();
  List<Map<String, dynamic>> _uploadedImages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchImages();
  }

  Future<void> _fetchImages() async {
    String userId = '1234'; // 추후 로그인 기능 구현 시 userId를 사용하세요.
    try {
      List<Map<String, dynamic>> imagesData = await _imageRepository.getImages(userId);
      setState(() {
        _uploadedImages = imagesData;
      });
    } catch (e) {
      print('Error fetching images: $e');
    }
  }

  Future<void> _uploadImage() async {
    setState(() {
      _isLoading = true;
    });

    String userId = '1234'; // 추후 로그인 기능 구현 시 userId를 사용하세요.
    Map<String, String>? imageData = await _imageRepository.uploadImage(userId, ImageSource.gallery);

    if (imageData != null) {
      await _imageRepository.saveImageInfo(
        userId: userId,
        docId: DateTime.now().millisecondsSinceEpoch.toString(),
        imageUrl: imageData['image']!,
        path: imageData['path']!,
        category: 'uploaded',
      );
      _fetchImages();
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _generateOutfit() async {
    setState(() {
      _isLoading = true;
    });

    // AI 코디 추천 로직 추가
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      _uploadedImages.add({
        'image': 'https://via.placeholder.com/150', // 예시 이미지 URL
        'category': 'AI 코디 결과'
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('나만의 옷장으로 코디하기', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('나만의 옷장으로 AI가 추천하는 코디를 받아보세요!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildButton(
                  icon: Icons.upload_file,
                  label: '옷 사진 업로드',
                  color: Colors.pinkAccent,
                  onPressed: _uploadImage,
                ),
                _buildButton(
                  icon: Icons.style,
                  label: 'AI 코디 생성',
                  color: Colors.purple,
                  onPressed: _generateOutfit,
                ),
              ],
            ),

            SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _uploadedImages.isEmpty
                  ? Center(child: Text('업로드된 옷이 없습니다.'))
                  : GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _uploadedImages.length,
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: CachedNetworkImage(
                      imageUrl: _uploadedImages[index]['image'],
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
            if (!_isLoading && _uploadedImages.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text('AI 추천 코디:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            if (!_isLoading && _uploadedImages.isNotEmpty)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey[200],
                ),
                child: Center(
                  child: Text(
                    'AI 코디 결과 이미지',
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: Size(150, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
    );
  }
}
