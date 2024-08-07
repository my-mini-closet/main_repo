import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myminicloset/imagerepository.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'recommendation_screen.dart'; // RecommendationScreen 클래스 import

class WardrobeScreen extends StatefulWidget {
  @override
  _WardrobeScreenState createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  final ImageRepository _imageRepository = ImageRepository();
  final List<String> _categories = ['all', '상의', '하의', '모자', '신발', '액세서리'];
  Map<String, List<Map<String, dynamic>>> _categoryImages = {};
  String userId = '1234';
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _fetchImages();
  }

  Future<void> _fetchImages() async {
    List<Map<String, dynamic>> imagesData = await _imageRepository.getImages(userId);
    setState(() {
      _categoryImages = {
        for (var category in _categories.where((c) => c != 'all'))
          category: imagesData.where((data) => data['category'] == category).toList()
      };
    });
  }

  Future<void> _pickImage(String category, ImageSource source) async {
    Map<String, String>? imageInfo = await _imageRepository.uploadImage(userId, source);
    if (imageInfo != null) {
      await _imageRepository.saveImageInfo(
        userId: userId,
        docId: DateTime.now().millisecondsSinceEpoch.toString(),  // 고유한 docId 생성
        imageUrl: imageInfo['image']!,
        path: imageInfo['path']!,
        category: category,  // 카테고리 저장
      );
      _fetchImages();
    }
  }

  Future<void> _showCategoryDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('카테고리 선택'),
          content: SingleChildScrollView(
            child: ListBody(
              children: _categories.where((c) => c != 'all').map((category) {
                return ListTile(
                  title: Text(category),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showImageSourceDialog(category);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showImageSourceDialog(String category) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('이미지 소스 선택'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                ListTile(
                  title: Text('갤러리'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(category, ImageSource.gallery);
                  },
                ),
                ListTile(
                  title: Text('카메라'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(category, ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToRecommendationScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RecommendationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> displayedImages = _selectedCategory == 'all'
        ? _categoryImages.values.expand((images) => images).toList()
        : _categoryImages[_selectedCategory] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '나만의 작은 옷장',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          DropdownButton<String>(
            value: _selectedCategory,
            icon: Icon(Icons.arrow_downward, color: Colors.white),
            dropdownColor: Colors.blue,
            underline: Container(),
            onChanged: (String? newCategory) {
              if (newCategory != null && _categories.contains(newCategory)) {
                setState(() {
                  _selectedCategory = newCategory;
                });
              }
            },
            items: _categories.map<DropdownMenuItem<String>>((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category == 'all' ? '전체' : category),
              );
            }).toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(16.0),
            padding: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(25.0),
              border: Border.all(color: Colors.white),
            ),
            child: ListTile(
              leading: Icon(Icons.camera_alt, color: Colors.white, size: 40),
              title: Center(
                child: Text(
                  '내 옷 등록하기!',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              onTap: _showCategoryDialog,
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 1.0,
              ),
              itemCount: displayedImages.length,
              itemBuilder: (context, index) {
                var item = displayedImages[index];
                return CachedNetworkImage(
                  imageUrl: item['image'],
                  fit: BoxFit.cover,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToRecommendationScreen,
        label: Text('코디하기'),
        backgroundColor: Colors.lightBlueAccent,
        icon: Icon(Icons.android),
      ),
    );
  }
}
