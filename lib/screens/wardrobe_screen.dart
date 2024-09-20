import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myminicloset/imagerepository.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../provider/userprovider.dart';
import 'recommendation_screen.dart';

class WardrobeScreen extends StatefulWidget {
  @override
  _WardrobeScreenState createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  final ImageRepository _imageRepository = ImageRepository();
  final List<String> _categories = ['all', '상의', '하의', '아우터', '원피스'];
  final List<String> _styleCategories = [
    '레트로', '로맨틱', '리조트', '매니시', '모던', '밀리터리', '섹시', '소피스트케이티드',
    '스트리트', '스포티', '아방가르드', '오리엔탈', '웨스턴', '젠더리스', '컨트리', '클래식',
    '키치', '톰보이', '펑크', '페미닌', '프레피', '히피', '힙합'
  ];

  final List<String> _seasons = ['봄', '여름', '가을', '겨울'];
  Map<String, List<Map<String, dynamic>>> _categoryImages = {};
  String _selectedCategory = 'all';
  String? _selectedStyleCategory;
  String? _selectedColorCategory;
  List<String> _selectedSeasons = [];
  String? _selectedDetailCategory;
  bool _isDetailVisible = false;
  late String userId;
  XFile? _pickedImage;
  String? _pickedImageUrl;
  String? _pickedImagePath;

  // 상세 카테고리 목록
  final List<String> _colorCategories = [
    "블랙", "화이트", "그레이", "레드", "핑크", "오렌지", "베이지", "브라운",
    "옐로우", "그린", "카키", "민트", "블루", "네이비", "스카이블루", "퍼플",
    "라벤더", "와인", "네온", "골드"
  ];

  final List<String> _detailCategories = [
    '프릴', '퍼프', '드롭숄더', '러플', '포켓', '띠', '셔링', '단추', '슬릿',
    '비대칭', '자수', 'X스트랩', '리본', '스트링', '버클', '니트꽈베기', '플레어',
    '체인', '비즈', '태슬', '패치워크', '컷아웃', '롤업', '스티치', '레이스',
    '플리츠', '글리터', '싱글브레스티드', '지퍼', '페플럼', '폼폼', '더블브레스티드',
    '퀄팅', '레이스업', '퍼트리밍', '디스트로이드', '스터드', '스팽글', '프린지',
    '드롭웨이스트'
  ];

  // 기타 상세 카테고리 목록 (예: 프린트, 소재 등)
  final List<String> _printCategories = [
    '도트', '믹스', '플로럴', '무지', '스트라이프', '레터링', '그래픽', '깅엄',
    '아가일', '체크', '호피', '타이다이', '페이즐리', '하트', '지그재그',
    '그라데이션', '지브라', '하운즈 투스', '카무플라쥬', '뱀피', '해골'
  ];

  final List<String> _materialCategories = [
    "패딩", "퍼", "무스탕", "스웨이드", "앙고라", "코듀로이", "시퀸/글리터",
    "데님", "저지", "트위드", "벨벳", "비닐/PVC", "울/캐시미어", "합성섬유",
    "헤어 니트", "니트", "레이스", "린넨", "메시", "플리스", "네오프렌",
    "실크", "스판덱스", "자카드", "가죽", "면", "시폰", "우븐"
  ];

  final List<String> _sleeveCategories = [
    "크롭", "노멀", "롱", "미니", "니렝스", "미디", "발목", "맥시"
  ];

  final List<String> _shirtSleeves = [
    "없음", "민소매", "반팔", "캡", "7부소매", "긴팔"
  ];

  final List<String> _necklineCategories = [
    "라운드넥", "유넥", "브이넥", "홀토넥", "오프숄더", "원 숄더",
    "스퀘어넥", "노카라", "후드", "터틀넥", "보트넥", "스위트하트"
  ];

  final List<String> _collarCategories = [
    "셔츠칼라", "보우칼라", "세일러칼라", "숄칼라", "폴로칼라",
    "피터팬칼라", "너치드칼라", "차이나칼라", "테일러칼라", "밴드칼라"
  ];

  final List<String> _fitCategories = [
    "노멀", "루즈", "오버사이즈", "스키니", "와이드", "타이트", "벨보텀"
  ];

  // 추가된 상태 변수
  String? _selectedPrintCategory;
  String? _selectedMaterialCategory;
  String? _selectedSleeveCategory;
  String? _selectedShirtSleeveCategory;
  String? _selectedNecklineCategory;
  String? _selectedCollarCategory;
  String? _selectedFitCategory;

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

  Future<void> _pickImage(ImageSource source) async {
    _pickedImage = await ImagePicker().pickImage(source: source);
    if (_pickedImage != null) {
      // 이미지 업로드
      Map<String, String>? imageInfo = await _imageRepository.uploadImage(userId, source);
      if (imageInfo != null) {
        setState(() {
          _pickedImageUrl = imageInfo['image'];
          _pickedImagePath = imageInfo['path'];
        });
        _showCategoryAndSeasonDialog();
      }
    }
  }

  Future<void> _showCategoryAndSeasonDialog() async {
    _selectedStyleCategory = null;
    _selectedSeasons.clear();
    _selectedDetailCategory = null;
    _isDetailVisible = false;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('카테고리 및 계절 선택'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    DropdownButton<String>(
                      value: _selectedCategory,
                      hint: Text('의류 카테고리 선택'),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCategory = newValue!;
                          // 카테고리 변경 시 스타일 및 계절 초기화
                          _selectedStyleCategory = null;
                          _selectedSeasons.clear();
                          _selectedDetailCategory = null;
                          _isDetailVisible = false;
                        });
                      },
                      items: _categories.map<DropdownMenuItem<String>>((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category == 'all' ? '전체' : category),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),
                    if (_selectedCategory != 'all') ...[
                      DropdownButton<String>(
                        value: _selectedStyleCategory,
                        hint: Text('스타일 카테고리 선택'),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedStyleCategory = newValue;
                          });
                        },
                        items: _styleCategories.map<DropdownMenuItem<String>>((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 20),
                      Text('계절 선택'),
                      ..._seasons.map((season) {
                        return CheckboxListTile(
                          title: Text(season),
                          value: _selectedSeasons.contains(season),
                          onChanged: (bool? selected) {
                            setState(() {
                              if (selected == true) {
                                _selectedSeasons.add(season);
                              } else {
                                _selectedSeasons.remove(season);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ],
                  ],
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showDetailedInfoDialog();
                      },
                      child: Text(
                        '상세정보 등록하기',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showDetailedInfoDialog();
                      },
                      child: Text(
                        '저장',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }


  Future<void> _showDetailedInfoDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('상세 정보 선택'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 색상 선택
                    DropdownButton<String>(
                      value: _selectedColorCategory,
                      hint: Text('색상 선택'),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedColorCategory = newValue;
                        });
                      },
                      items: _colorCategories
                          .map<DropdownMenuItem<String>>((String color) {
                        return DropdownMenuItem<String>(
                          value: color,
                          child: Text(color),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),

                    // 상세 카테고리 선택
                    DropdownButton<String>(
                      value: _selectedDetailCategory,
                      hint: Text('상세 카테고리 선택'),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedDetailCategory = newValue;
                        });
                      },
                      items: _detailCategories
                          .map<DropdownMenuItem<String>>((String detail) {
                        return DropdownMenuItem<String>(
                          value: detail,
                          child: Text(detail),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),

                    // 프린트 선택
                    DropdownButton<String>(
                      value: _selectedPrintCategory,
                      hint: Text('프린트 선택'),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedPrintCategory = newValue;
                        });
                      },
                      items: _printCategories
                          .map<DropdownMenuItem<String>>((String print) {
                        return DropdownMenuItem<String>(
                          value: print,
                          child: Text(print),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),

                    // 소재 선택
                    DropdownButton<String>(
                      value: _selectedMaterialCategory,
                      hint: Text('소재 선택'),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedMaterialCategory = newValue;
                        });
                      },
                      items: _materialCategories
                          .map<DropdownMenuItem<String>>((String material) {
                        return DropdownMenuItem<String>(
                          value: material,
                          child: Text(material),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),

                    // 기장 선택
                    DropdownButton<String>(
                      value: _selectedSleeveCategory,
                      hint: Text('기장 선택'),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedSleeveCategory = newValue;
                        });
                      },
                      items: _sleeveCategories
                          .map<DropdownMenuItem<String>>((String sleeve) {
                        return DropdownMenuItem<String>(
                          value: sleeve,
                          child: Text(sleeve),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),

                    // 소매기장 선택
                    DropdownButton<String>(
                      value: _selectedShirtSleeveCategory,
                      hint: Text('소매기장 선택'),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedShirtSleeveCategory = newValue;
                        });
                      },
                      items: _shirtSleeves
                          .map<DropdownMenuItem<String>>((String shirtSleeve) {
                        return DropdownMenuItem<String>(
                          value: shirtSleeve,
                          child: Text(shirtSleeve),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),

                    // 넥라인 선택
                    DropdownButton<String>(
                      value: _selectedNecklineCategory,
                      hint: Text('넥라인 선택'),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedNecklineCategory = newValue;
                        });
                      },
                      items: _necklineCategories
                          .map<DropdownMenuItem<String>>((String neckline) {
                        return DropdownMenuItem<String>(
                          value: neckline,
                          child: Text(neckline),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),

                    // 옷깃 선택
                    DropdownButton<String>(
                      value: _selectedCollarCategory,
                      hint: Text('옷깃 선택'),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCollarCategory = newValue;
                        });
                      },
                      items: _collarCategories
                          .map<DropdownMenuItem<String>>((String collar) {
                        return DropdownMenuItem<String>(
                          value: collar,
                          child: Text(collar),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),

                    // 핏 선택
                    DropdownButton<String>(
                      value: _selectedFitCategory,
                      hint: Text('핏 선택'),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedFitCategory = newValue;
                        });
                      },
                      items: _fitCategories
                          .map<DropdownMenuItem<String>>((String fit) {
                        return DropdownMenuItem<String>(
                          value: fit,
                          child: Text(fit),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await _saveImageInfo();
                  },
                  child: Text('저장'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// 이미지 정보 저장 메서드
  Future<void> _saveImageInfo() async {
    if (_pickedImageUrl != null && _pickedImagePath != null) {
      await _imageRepository.saveImageInfo(
        userId: userId,
        docId: DateTime.now().millisecondsSinceEpoch.toString(),
        imageUrl: _pickedImageUrl!,
        path: _pickedImagePath!,
        category: _selectedCategory,
        weather: _selectedSeasons,
        color: _selectedColorCategory,
        detail: _selectedDetailCategory != null ? [_selectedDetailCategory!] : null,
        printCategory: _selectedPrintCategory,
        materialCategory: _selectedMaterialCategory,
        sleeveCategory: _selectedSleeveCategory,
        shirtSleeveCategory: _selectedShirtSleeveCategory,
        collarCategory: _selectedCollarCategory,
        fitCategory: _selectedFitCategory,
      );
      _fetchImages();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지 업로드에 실패했습니다. 다시 시도해주세요.')),
      );
    }
  }

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
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  title: Text('카메라'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera);
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
