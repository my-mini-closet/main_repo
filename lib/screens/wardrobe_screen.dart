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
  final List<String> _categories = ['all', '상의', '하의', '아우터', '원피스'];
  final List<String> _styleCategories = [
    '레트로', '로맨틱', '리조트', '매니시', '모던', '밀리터리', '섹시', '소피스트케이티드',
    '스트리트', '스포티', '아방가르드', '오리엔탈', '웨스턴', '젠더리스', '컨트리', '클래식',
    '키치', '톰보이', '펑크', '페미닌', '프레피', '히피', '힙합'
  ];

  final Map<String, List<String>> _clothingCategories = {
    "상의": ["탑", "블라우스", "티셔츠", "니트웨어", "셔츠", "브라탑", "후드티"],
    "하의": ["청바지", "팬츠", "스커트", "래깅스", "조거팬츠"],
    "아우터": ["코트", "재킷", "점퍼", "패딩", "베스트", "가디건", "짚업"],
    "원피스": ["드레스", "점프수트"],
  };

  final List<String> _seasons = ['봄', '여름', '가을', '겨울'];

  // 상세 카테고리 목록
  final List<String> _colorCategories = [
    "블랙", "화이트", "그레이", "레드", "핑크", "오렌지", "베이지", "브라운",
    "옐로우", "그린", "카키", "민트", "블루", "네이비", "스카이블루", "퍼플",
    "라벤더", "와인", "네온", "골드"
  ];

  final List<String> _subColorCategories = [
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
    "크롭", "노말", "롱", "미니", "니렝스", "미디", "발목", "맥시"
  ];

  final List<String> _shirtSleeves = [
    "없음", "민소매", "반팔", "캡", "7부소매", "긴팔"
  ];

  final List<String> _necklineCategories = [
    "라운드넥", "유넥", "브이넥", "홀터넥", "오프숄더", "원숄더",
    "스퀘어넥", "노카라", "후드", "터틀넥", "보트넥", "스위트하트"
  ];

  final List<String> _collarCategories = [
    "셔츠칼라", "보우칼라", "세일러칼라", "숄칼라", "폴로칼라",
    "피터팬칼라", "너치드칼라", "차이나칼라", "테일러드칼라", "밴드칼라"
  ];

  final List<String> _fitCategories = [
    "노멀", "루즈", "오버사이즈", "스키니", "와이드", "타이트", "벨보텀"
  ];

  Map<String, List<Map<String, dynamic>>> _categoryImages = {};

  String _selectedCategory = 'all';

  String? _selectedSubColorCategory;
  String? _selectedStyleCategory;
  String? _selectedColorCategory;
  List<String>? _selectedDetailCategory;
  List<String>? _selectedPrintCategory;
  List<String>? _selectedMaterialCategory;
  String? _selectedSleeveCategory;
  String? _selectedShirtSleeveCategory;
  String? _selectedNecklineCategory;
  String? _selectedCollarCategory;
  String? _selectedFitCategory;
  List<String> _selectedSeasons = [];

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

  Future<void> _showCategoryDialog(Map<String, String> imageInfo) async {
    String? dialogSelectedCategory; // 다이얼로그 내에서 사용할 카테고리 변수
    String? dialogSelectedStyleCategory; // 다이얼로그 내에서 사용할 서브 카테고리 변수
    List<String> dialogSelectedSeasons = []; // 다이얼로그 내에서 선택된 계절

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
                    // 카테고리 선택
                    DropdownButton<String>(
                      value: dialogSelectedCategory,
                      hint: Text('의류 카테고리 선택'),
                      onChanged: (String? newValue) {
                        setState(() {
                          dialogSelectedCategory = newValue;
                          dialogSelectedStyleCategory = null; // 서브 카테고리 초기화
                          dialogSelectedSeasons.clear(); // 계절 초기화
                        });
                      },
                      isExpanded: true,
                      items: _categories
                          .where((c) => c != 'all') // 'all' 제외
                          .map<DropdownMenuItem<String>>((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),

                    // 서브 카테고리 선택 (카테고리가 선택된 경우에만 표시)
                    if (dialogSelectedCategory != null && dialogSelectedCategory != 'all') ...[
                      DropdownButton<String>(
                        value: dialogSelectedStyleCategory,
                        hint: Text('서브 카테고리 선택'),
                        onChanged: (String? newValue) {
                          setState(() {
                            dialogSelectedStyleCategory = newValue;
                          });
                        },
                        isExpanded: true,
                        items: _clothingCategories[dialogSelectedCategory]
                            ?.map<DropdownMenuItem<String>>((String subCategory) {
                          return DropdownMenuItem<String>(
                            value: subCategory,
                            child: Text(subCategory),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 20),

                      // 계절 선택
                      Text('계절 선택'),
                      ..._seasons.map((season) {
                        return CheckboxListTile(
                          title: Text(season),
                          value: dialogSelectedSeasons.contains(season),
                          onChanged: (bool? selected) {
                            setState(() {
                              if (selected == true) {
                                dialogSelectedSeasons.add(season);
                              } else {
                                dialogSelectedSeasons.remove(season);
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
                    // 상세 정보 입력하기 버튼
                    TextButton(
                      onPressed: () async {
                        if (dialogSelectedCategory != null) { // 카테고리가 선택된 경우에만 진행
                          Navigator.of(context).pop();
                          await _showDetailedInfoDialog(
                            imageInfo,
                            dialogSelectedCategory,
                            dialogSelectedSeasons,
                            dialogSelectedStyleCategory,
                          );
                        } else {
                          // 카테고리가 선택되지 않은 경우 사용자에게 알림 (선택을 요구)
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('카테고리를 선택해주세요.')),
                          );
                        }
                      },
                      child: Text('상세 정보 입력하기'),
                    ),
                    // 저장 버튼
                    TextButton(
                      onPressed: () async {
                        if (dialogSelectedCategory != null) { // 카테고리가 선택된 경우에만 진행
                          Navigator.of(context).pop();
                          // 저장 동작 수행
                          await _showDetailedInfoDialog(
                            imageInfo,
                            dialogSelectedCategory,
                            dialogSelectedSeasons,
                            dialogSelectedStyleCategory,
                          );
                        } else {
                          // 카테고리가 선택되지 않은 경우 사용자에게 알림
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('카테고리를 선택해주세요.')),
                          );
                        }
                      },
                      child: Text(
                        '저장',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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


  // 상세 정보 입력 다이얼로그
  Future<void> _showDetailedInfoDialog(
      Map<String, String> imageInfo,
      String? selectedCategory,
      List<String> selectedSeasons,
      String? selectedStyleCategory,
      ) async {
    // 다이얼로그 내에서 사용할 로컬 상태 변수임
    List<String> localDetailSelections = _selectedDetailCategory != null && _selectedDetailCategory!.isNotEmpty
        ? List.from(_selectedDetailCategory!)
        : ['']; // 최소 하나의 빈 드롭다운 생성

    List<String> localMaterialSelections = _selectedMaterialCategory != null && _selectedMaterialCategory!.isNotEmpty
        ? List.from(_selectedMaterialCategory!)
        : ['']; // 최소 하나의 빈 드롭다운 생성

    List<String> localPrintSelections = _selectedPrintCategory != null && _selectedPrintCategory!.isNotEmpty
        ? List.from(_selectedPrintCategory!)
        : ['']; // 최소 하나의 빈 드롭다운 생성

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            // Helper 함수: 드롭다운 추가
            void _addDropdown(List<String> list) {
              setState(() {
                list.add(''); // 빈 값을 추가하기.. 음
              });
            }

            // Helper 함수: 드롭다운 삭제
            void _removeDropdown(List<String> list, int index) {
              setState(() {
                if (list.length > 1) { // 최소 하나는 유지하기..?
                  list.removeAt(index);
                }
              });
            }

            // Helper 함수: 빌드 드롭다운 리스트
            Widget _buildDropdownList(
                String title,
                List<String> selections,
                List<String> options,
                ) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ...List.generate(selections.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: DropdownButton<String>(
                              value: selections[index].isEmpty ? null : selections[index],
                              hint: Text("선택하세요"),
                              isExpanded: true,
                              items: options.map((String option) {
                                return DropdownMenuItem<String>(
                                  value: option,
                                  child: Text(option),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selections[index] = newValue ?? '';
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 8),
                          IconButton(
                            icon: Icon(Icons.add, color: Colors.green),
                            onPressed: () {
                              _addDropdown(selections);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.remove, color: Colors.red),
                            onPressed: () {
                              _removeDropdown(selections, index);
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                  SizedBox(height: 10),
                ],
              );
            }

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
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedColorCategory = newValue;
                        });
                      },
                      items: _colorCategories.map<DropdownMenuItem<String>>((String color) {
                        return DropdownMenuItem<String>(
                          value: color,
                          child: Text(color),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),

                    // 서브 색상 선택
                    DropdownButton<String>(
                      value: _selectedSubColorCategory,
                      hint: Text('서브 색상 선택'),
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedSubColorCategory = newValue;
                        });
                      },
                      items: _subColorCategories.map<DropdownMenuItem<String>>((String subColor) {
                        return DropdownMenuItem<String>(
                          value: subColor,
                          child: Text(subColor),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),

                    _buildDropdownList(
                      '디테일 선택',
                      localDetailSelections,
                      _detailCategories,
                    ),

                    _buildDropdownList(
                      '프린트 선택',
                      localPrintSelections,
                      _printCategories,
                    ),

                    _buildDropdownList(
                      '소재 선택',
                      localMaterialSelections,
                      _materialCategories,
                    ),

                    // 기장 선택
                    DropdownButton<String>(
                      value: _selectedSleeveCategory,
                      hint: Text('기장 선택'),
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedSleeveCategory = newValue;
                        });
                      },
                      items: _sleeveCategories.map<DropdownMenuItem<String>>((String sleeve) {
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
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedShirtSleeveCategory = newValue;
                        });
                      },
                      items: _shirtSleeves.map<DropdownMenuItem<String>>((String shirtSleeve) {
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
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedNecklineCategory = newValue;
                        });
                      },
                      items: _necklineCategories.map<DropdownMenuItem<String>>((String neckline) {
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
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCollarCategory = newValue;
                        });
                      },
                      items: _collarCategories.map<DropdownMenuItem<String>>((String collar) {
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
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedFitCategory = newValue;
                        });
                      },
                      items: _fitCategories.map<DropdownMenuItem<String>>((String fit) {
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
                    // 선택된 카테고리와 기타 정보를 저장
                    await _saveImageInfo(
                      imageInfo: imageInfo,
                      category: selectedCategory!,
                      weather: selectedSeasons,
                      subCategory: selectedStyleCategory,
                      sleeve: _selectedSleeveCategory,
                      color: _selectedColorCategory,
                      subColor: _selectedSubColorCategory,
                      shirtSleeve: _selectedShirtSleeveCategory,
                      detail: localDetailSelections,
                      collar: _selectedCollarCategory,
                      material: localMaterialSelections,
                      print: localPrintSelections,
                      neckLine: _selectedNecklineCategory,
                      fit: _selectedFitCategory,
                    ); // 이미지 정보 저장
                    _fetchImages(); // 저장 후 이미지 다시 불러오기
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



  // 이미지 정보 저장 함수 (명명된 매개변수 사용)
  Future<void> _saveImageInfo({
    required Map<String, String> imageInfo,
    required String category,
    required List<String> weather,
    String? subCategory,
    String? sleeve,
    String? color,
    String? subColor,
    String? shirtSleeve,
    List<String>? detail,
    String? collar,
    List<String>? material,
    List<String>? print,
    String? neckLine,
    String? fit,
  }) async {
    await _imageRepository.saveImageInfo(
      userId: userId,
      docId: DateTime.now().millisecondsSinceEpoch.toString(), // 고유한 docId 생성
      imageUrl: imageInfo['image']!,
      path: imageInfo['path']!,
      category: category,  // 카테고리 저장
      weather: weather,    // 선택된 날씨 저장
      subCategory: subCategory ?? null,  // 선택된 값이 있으면 저장, 없으면 null
      sleeve: sleeve ?? null,
      color: color ?? null,
      subColor: subColor ?? null,
      shirtSleeve: shirtSleeve ?? null,
      detail: detail ?? null,
      collar: collar ?? null,
      material: material ?? null,
      print: print ?? null,
      neckLine: neckLine ?? null,
      fit: fit ?? null,
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