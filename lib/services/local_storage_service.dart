import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/post_model.dart';
import '../models/user_model.dart';

class LocalStorageService {
  static late final SharedPreferences _prefs;

  static const String _userKey = 'logged_in_user';
  static const String _postsKey = 'saved_posts';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveUser(UserModel user) async {
    await _prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  static Future<UserModel?> getUser() async {
    final jsonString = _prefs.getString(_userKey);
    if (jsonString == null || jsonString.isEmpty) return null;

    final data = jsonDecode(jsonString);
    if (data is! Map<String, dynamic>) {
      return null;
    }

    return UserModel.fromJson(data);
  }

  static Future<void> clearUser() async {
    await _prefs.remove(_userKey);
  }

  static Future<void> savePosts(List<PostModel> posts) async {
    final encodedPosts = posts.map((post) => post.toJson()).toList();
    await _prefs.setString(_postsKey, jsonEncode(encodedPosts));
  }

  static Future<List<PostModel>> getPosts() async {
    final jsonString = _prefs.getString(_postsKey);
    if (jsonString == null || jsonString.isEmpty) return [];

    final decoded = jsonDecode(jsonString);
    if (decoded is! List) return [];

    return decoded
        .map((item) => PostModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  static Future<void> addPost(PostModel post) async {
    final posts = await getPosts();
    posts.insert(0, post);
    await savePosts(posts);
  }

  static Future<void> removePost(String postId) async {
    final posts = await getPosts();
    posts.removeWhere((post) => post.id == postId);
    await savePosts(posts);
  }

  static Future<void> clearPosts() async {
    await _prefs.remove(_postsKey);
  }
}
