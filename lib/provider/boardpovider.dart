import 'package:flutter/cupertino.dart';

class BoardProvider with ChangeNotifier {
  List<Map<String, dynamic>> _posts = [];

  List<Map<String, dynamic>> get posts => _posts;

  void setPosts(List<Map<String, dynamic>> posts) {
    _posts = posts;
    notifyListeners();
  }

  void updatePost(Map<String, dynamic> updatedPost) {
    final index = _posts.indexWhere((post) => post['id'] == updatedPost['id']);
    if (index != -1) {
      _posts[index] = updatedPost;
      notifyListeners();
    }
  }

  void addPost(Map<String, dynamic> post) {
    _posts.add(post);
    notifyListeners();
  }

  void removePost(int postId) {
    _posts.removeWhere((post) => post['id'] == postId);
    notifyListeners();
  }
}
