import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ImageRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  /// 이미지를 선택하고 Firebase Storage에 업로드한 후, 이미지 URL과 경로를 반환합니다.
  Future<Map<String, String>?> uploadImage(String userId, ImageSource source) async {
    try {
      final String dateTime = DateTime.now().millisecondsSinceEpoch.toString();
      XFile? image = await _picker.pickImage(source: source);

      if (image != null) {
        String imageRef = "images/${userId}_$dateTime${_getFileExtension(image.path)}";
        File file = File(image.path);

        // 이미지 업로드
        UploadTask uploadTask = _storage.ref(imageRef).putFile(file);
        TaskSnapshot snapshot = await uploadTask;

        // 업로드된 이미지의 다운로드 URL 가져오기
        String imageUrl = await snapshot.ref.getDownloadURL();

        return {
          "image": imageUrl,
          "path": imageRef,
        };
      }
    } catch (e) {
      print("이미지 업로드 실패: $e");
    }
    return null;
  }

  /// Firestore에 이미지 정보를 저장합니다.
  Future<void> saveImageInfo({
    required String userId,
    required String docId,
    required String imageUrl,
    required String path,
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
    String? fit, String? printCategory,
    String? materialCategory,
    String? sleeveCategory,
    String? shirtSleeveCategory,
    String? neckLineCategory,
    String? collarCategory,
    String? fitCategory,
  }) async {
    try {
      await _firestore.collection("images").doc(docId).set({
        "userId": userId,
        "docId": docId,
        "image": imageUrl,
        "path": path,
        "dateTime": Timestamp.now(),
        "category": category,
        "weather": weather,
        "color": color,
        "subCategory": subCategory,
        "sleeve": sleeve,
        "subColor": subColor,
        "shirtSleeve": shirtSleeve,
        "detail": detail,
        "collar": collar,
        "material": material,
        "print": print,
        "neckLine": neckLine,
        "fit": fit,
      });
    } catch (e) {
      print!;
    }
  }

  /// 특정 문서 ID와 경로를 사용하여 이미지를 삭제합니다.
  Future<void> deleteImage(String docId, String path) async {
    try {
      // Firebase Storage에서 이미지 삭제
      await _storage.ref(path).delete();

      // Firestore에서 문서 삭제
      await _firestore.collection("images").doc(docId).delete();
    } catch (e) {
      print("이미지 삭제 실패: $e");
    }
  }

  /// 특정 사용자 ID에 해당하는 모든 이미지를 가져옵니다.
  Future<List<Map<String, dynamic>>> getImages(String userId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection("images")
          .where("userId", isEqualTo: userId)
          .orderBy("dateTime", descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print("이미지 가져오기 실패: $e");
      return [];
    }
  }

  /// 파일 경로에서 확장자를 추출합니다.
  String _getFileExtension(String path) {
    return path.contains('.') ? path.substring(path.lastIndexOf('.')) : '';
  }
}
