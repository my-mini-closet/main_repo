import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myminicloset/imagerepository.dart';
import 'package:cached_network_image/cached_network_image.dart';  // 추가

class WardrobeScreen extends StatefulWidget {
  @override
  _WardrobeScreenState createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  final ImageRepository _imageRepository = ImageRepository();
  final List<String> _categories = ['상의', '하의', '모자', '신발', '액세서리'];
  Map<String, List<Map<String, dynamic>>> _categoryImages = {};
  String userId = '1234'; // 추후 로그인 기능 구현 시 userId를 사용하세요.

  @override
  void initState() {
    super.initState();
    _fetchImages();
  }

  Future<void> _fetchImages() async {
    List<Map<String, dynamic>> imagesData = await _imageRepository.getImages(userId);
    setState(() {
      _categoryImages = {
        for (var category in _categories)
          category: imagesData.where((data) => data['category'] == category).toList()
      };
    });
  }


  Future<void> _pickImage(String category, ImageSource source) async {
    String userId = '1234'; // 추후 로그인 기능 구현 시 userId를 사용하세요.
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
              children: _categories.map((category) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '나만의 작은 옷장',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
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
            child: ListView(
              padding: EdgeInsets.all(8.0),
              children: _categories.map((category) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25.0),
                    border: Border.all(color: Colors.black, width: 2.0),
                  ),
                  child: ExpansionTile(
                    title: Text(
                      category,
                      style: TextStyle(color: Colors.black),
                    ),
                    children: _categoryImages[category]?.map((item) {
                      return ListTile(
                        leading: CachedNetworkImage(  // CachedNetworkImage 사용
                          imageUrl: item['image'],
                          width: 50,
                          height: 50,
                          placeholder: (context, url) => CircularProgressIndicator(),  // 로딩 인디케이터 추가
                          errorWidget: (context, url, error) => Icon(Icons.error),  // 에러 아이콘 추가
                        ),
                        title: Text('Item', style: TextStyle(color: Colors.black)),
                      );
                    }).toList() ?? [],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
