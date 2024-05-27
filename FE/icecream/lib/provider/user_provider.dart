import 'package:flutter/material.dart';
import 'package:icecream/setting/widget/profile_image.dart';

class Child {
  final int userId;
  final String? profileImage;
  final String username;
  final String phoneNumber;

  Child({
    required this.userId,
    this.profileImage,
    required this.username,
    required this.phoneNumber,
  });

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      userId: json['user_id'],
      profileImage: json['profile_image'],
      username: json['username'],
      phoneNumber: json['phone_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'profile_image': profileImage ?? '',
      'username': username,
      'phone_number': phoneNumber,
    };
  }
}

class UserProvider extends ChangeNotifier {
  String _username = '';
  String _loginId = '';
  String _phoneNumber = '';
  String? _profileImage = '';
  bool _isParent = false;
  bool _isLoggedIn = false;
  List<Child> _children = [];
  int _userId = 0; // userId 추가

  String get username => _username;
  String get loginId => _loginId;
  String get phoneNumber => _phoneNumber;
  String? get profileImage => _profileImage;
  bool get isParent => _isParent;
  bool get isLoggedIn => _isLoggedIn;
  List<Child> get children => _children;
  int get userId => _userId; // userId getter 추가

  // 부모 profileImage에 대한 setter 추가
  set setProfileImage(String newImage) {
    if (_profileImage != newImage) {
      _profileImage = newImage;
      notifyListeners();
    }
  }

  // phoneNumber에 대한 setter 추가
  set setPhoneNumber(String newPhoneNumber) {
    if (_phoneNumber != newPhoneNumber) {
      _phoneNumber = newPhoneNumber;
      notifyListeners();
    }
  }

  void setUserData(Map<String, dynamic> userData) {
    _username = userData['username'];
    _loginId = userData['login_id'] ?? '';
    _phoneNumber = userData['phone_number'];
    _profileImage = userData['profile_image'] ?? '';
    _isParent = userData.containsKey('children');
    _isLoggedIn = true;
    _userId = userData['user_id']; // userId 설정

    if (_isParent) {
      _children = (userData['children'] as List<dynamic>)
          .map((child) => Child.fromJson(child))
          .toList();
    } else {
      _children = [];
    }
    notifyListeners();
  }

  void clearUserData() {
    _username = '';
    _loginId = '';
    _phoneNumber = '';
    _profileImage = '';
    _children = [];
    _isParent = false;
    _isLoggedIn = false;
    _userId = 0; // userId 초기화
    notifyListeners();
  }

  // 자녀 정보 업데이트
  void updateChildren(List<Child> children) {
    _children = children;
    notifyListeners();
  }

  // 특정 자녀의 프로필 업데이트
  void updateChildProfileImage(int childId, String newProfileImage) {
    int index = _children.indexWhere((child) => child.userId == childId);
    if (index != -1) {
      Child oldChild = _children[index];
      _children[index] = Child(
          userId: oldChild.userId,
          profileImage: newProfileImage,
          username: oldChild.username,
          phoneNumber: oldChild.phoneNumber);
      notifyListeners();
    }
  }

  // 특정 자녀의 이름 업데이트
  void updateChildName(int childId, String newName) {
    int index = _children.indexWhere((child) => child.userId == childId);
    if (index != -1) {
      Child oldChild = _children[index];
      _children[index] = Child(
          userId: oldChild.userId,
          profileImage: oldChild.profileImage,
          username: newName,
          phoneNumber: oldChild.phoneNumber);
      notifyListeners();
    }
  }

  // 특정 자녀의 전화번호 업데이트
  void updateChildPhoneNumber(int childId, String newPhoneNumber) {
    int index = _children.indexWhere((child) => child.userId == childId);
    if (index != -1) {
      Child oldChild = _children[index];
      _children[index] = Child(
          userId: oldChild.userId,
          profileImage: oldChild.profileImage,
          username: oldChild.username,
          phoneNumber: newPhoneNumber);
      notifyListeners();
    }
  }

  // 특정 자녀 연결 해제 업데이트
  Future<void> disconnectedChild(int childId) async {
    _children.removeWhere((child) => child.userId == childId);
    notifyListeners();
  }
}
