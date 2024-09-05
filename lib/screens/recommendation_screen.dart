import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:myminicloset/imagerepository.dart';
import 'package:myminicloset/provider/userprovider.dart';
import 'package:provider/provider.dart';

class RecommendationScreen extends StatefulWidget {
  @override
  _RecommendationScreenState createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  final ImageRepository _imageRepository = ImageRepository();
  List<Map<String, dynamic>> _uploadedImages = [];
  List<Map<String, dynamic>> _selectedImages = [];
  bool _isLoading = false;
  late String userId;
  @override
  void initState() {
    super.initState();
    userId = Provider.of<UserProvider>(context, listen: false).userId;
    _fetchImages();
  }

  Future<void> _fetchImages() async {
    //String userId = '1234'; // 추후 로그인 기능 구현 시 userId를 사용하세요.
    try {
      List<Map<String, dynamic>> imagesData = await _imageRepository.getImages(userId);
      setState(() {
        _uploadedImages = imagesData;
      });
    } catch (e) {
      print('Error fetching images: $e');
    }
  }

  void _toggleSelection(Map<String, dynamic> image) {
    setState(() {
      if (_selectedImages.contains(image)) {
        _selectedImages.remove(image);
      } else {
        _selectedImages.add(image);
      }
    });
  }

  void _generateOutfit() async {
    setState(() {
      _isLoading = true;
    });

    // AI 코디 생성 로직 추가해야됨..
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isLoading = false;
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
            Text(
              '나만의 옷장으로 AI가 추천하는 코디를 받아보세요!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.yellow[100],
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: Colors.yellow, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '장바구니',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 120,
                    child: _selectedImages.isEmpty
                        ? Center(child: Text('선택된 사진이 없습니다. 옷을 담아보세요!'))
                        : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _selectedImages.map((image) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: CachedNetworkImage(
                                imageUrl: image['image'],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => CircularProgressIndicator(),
                                errorWidget: (context, url, error) => Icon(Icons.error),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _generateOutfit,
              child: Text(
                'AI 코디 생성하기',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                elevation: 5,
              ),
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
                  final image = _uploadedImages[index];
                  final isSelected = _selectedImages.contains(image);

                  return GestureDetector(
                    onTap: () => _toggleSelection(image),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: CachedNetworkImage(
                            imageUrl: image['image'],
                            placeholder: (context, url) => CircularProgressIndicator(),
                            errorWidget: (context, url, error) => Icon(Icons.error),
                            fit: BoxFit.cover,
                          ),
                        ),
                        if (isSelected)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Icon(Icons.check_circle, color: Colors.green, size: 30),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
