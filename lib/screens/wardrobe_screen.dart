import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myminicloset/imagerepository.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../provider/userprovider.dart';
import 'recommendation_screen.dart'; // RecommendationScreen 클래스 import

class WardrobeScreen extends StatefulWidget {
  @override
  _WardrobeScreenState createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  List<String> _selectedWeather = [];
  final ImageRepository _imageRepository = ImageRepository();
  final List<String> _categories = ['all', '상의', '하의', '모자', '신발', '액세서리'];
  Map<String, List<Map<String, dynamic>>> _categoryImages = {};
  String _selectedCategory = 'all';
  late String userId;
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() {
        userId = Provider.of<UserProvider>(context, listen: false).userId;
      });
      _fetchImages();
    });
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

  // 이미지 소스 선택 다이얼로그
  Future<void> _showImageSourceDialog() async {
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
                    _pickImage(ImageSource.gallery);  // 이미지 소스 선택 후, 카테고리 다이얼로그 호출
                  },
                ),
                ListTile(
                  title: Text('카메라'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera);  // 이미지 소스 선택 후, 카테고리 다이얼로그 호출
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

// 이미지를 선택하는 함수
  Future<void> _pickImage(ImageSource source) async {
    _selectedWeather = [];
    Map<String, String>? imageInfo = await _imageRepository.uploadImage(userId, source);
    if (imageInfo != null) {
      _showCategoryDialog(imageInfo);  // 이미지 업로드 후, 카테고리 선택 다이얼로그 호출
    }
  }

// 카테고리 선택 다이얼로그
  Future<void> _showCategoryDialog(Map<String, String> imageInfo) async {
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
                    _showWeatherDialog(imageInfo, category);  // 카테고리 선택 후, 날씨 선택 다이얼로그 호출
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

// 날씨 선택 다이얼로그
  Future<void> _showWeatherDialog(Map<String, String> imageInfo, String category) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder( // Dialog 내에서도 상태 관리를 할 수 있도록 StatefulBuilder 사용
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('계절 선택'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: ['봄', '여름', '가을', '겨울'].map((season) {
                    return CheckboxListTile(
                      title: Text(season),
                      value: _selectedWeather.contains(season),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedWeather.add(season);
                          } else {
                            _selectedWeather.remove(season);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await _saveImageInfo(imageInfo, category, _selectedWeather);  // 이미지 정보 저장
                    _fetchImages();  // 저장 후 이미지 다시 불러오기
                  },
                  child: Text('확인'),
                ),
              ],
            );
          },
        );
      },
    );
  }

// 이미지 정보 저장 함수
  Future<void> _saveImageInfo(Map<String, String> imageInfo, String category, List<String> weather) async {
    await _imageRepository.saveImageInfo(
      userId: userId,
      docId: DateTime.now().millisecondsSinceEpoch.toString(),  // 고유한 docId 생성
      imageUrl: imageInfo['image']!,
      path: imageInfo['path']!,
      category: category,  // 카테고리 저장
      weather: weather,    // 선택된 날씨 저장
    );
    _fetchImages();
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
    userId = Provider.of<UserProvider>(context).userId;
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
              onTap: _showImageSourceDialog,
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
