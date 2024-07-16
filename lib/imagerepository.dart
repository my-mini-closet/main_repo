import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ImageRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  Future<Map<String, String>?> uploadImage(String userId, ImageSource source) async {
    final String dateTime = DateTime.now().millisecondsSinceEpoch.toString();
    XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      String imageRef = "images/${userId}_$dateTime";
      File file = File(image.path);
      await _storage.ref(imageRef).putFile(file);
      String imageUrl = await _storage.ref(imageRef).getDownloadURL();
      return {
        "image": imageUrl,
        "path": imageRef,
      };
    }
    return null;
  }

  Future<void> saveImageInfo({
    required String userId,
    required String docId,
    required String imageUrl,
    required String path,
    required String category,
  }) async {
    await _firestore.collection("images").doc(docId).set({
      "userId": userId,
      "docId": docId,
      "image": imageUrl,
      "path": path,
      "dateTime": Timestamp.now(),
      "category": category,
    });
  }

  Future<void> deleteImage(String docId, String path) async {
    await _storage.ref(path).delete();
    await _firestore.collection("images").doc(docId).delete();
  }

  Future<List<Map<String, dynamic>>> getImages(String userId) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection("images")
        .where("userId", isEqualTo: userId)  // 사용자 ID로 필터링
        .orderBy("dateTime", descending: true)
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

}
