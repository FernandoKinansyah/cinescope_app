import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _keyUsers = 'users_list';
  static const String _keyCurrentUser = 'current_user';

  // ============ REGISTER ============
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Ambil semua user
    final String? usersJson = prefs.getString(_keyUsers);
    List<UserModel> users = [];

    if (usersJson != null) {
      final List<dynamic> decoded = jsonDecode(usersJson);
      users = decoded.map((e) => UserModel.fromJson(e)).toList();
    }

    // Cek email sudah ada
    if (users.any((u) => u.email.toLowerCase() == email.toLowerCase())) {
      return {'success': false, 'message': 'Email sudah terdaftar!'};
    }

    // Cek username sudah ada
    if (users.any((u) => u.username.toLowerCase() == username.toLowerCase())) {
      return {'success': false, 'message': 'Username sudah dipakai!'};
    }

    // Buat user baru
    final newUser = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      username: username,
      email: email,
      password: password,
    );

    users.add(newUser);

    // Simpan
    final encoded = jsonEncode(users.map((u) => u.toJson()).toList());
    await prefs.setString(_keyUsers, encoded);

    // Auto login
    await prefs.setString(_keyCurrentUser, jsonEncode(newUser.toJson()));

    return {'success': true, 'user': newUser, 'message': 'Register berhasil!'};
  }

  // ============ LOGIN ============
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final String? usersJson = prefs.getString(_keyUsers);
    if (usersJson == null) {
      return {'success': false, 'message': 'Belum ada akun. Silakan daftar dulu.'};
    }

    final List<dynamic> decoded = jsonDecode(usersJson);
    final List<UserModel> users =
        decoded.map((e) => UserModel.fromJson(e)).toList();

    // Cari user dengan email cocok
    try {
      final user = users.firstWhere(
        (u) => u.email.toLowerCase() == email.toLowerCase(),
      );

      if (user.password != password) {
        return {'success': false, 'message': 'Password salah!'};
      }

      // Simpan current user
      await prefs.setString(_keyCurrentUser, jsonEncode(user.toJson()));

      return {'success': true, 'user': user, 'message': 'Login berhasil!'};
    } catch (e) {
      return {'success': false, 'message': 'Email belum terdaftar!'};
    }
  }

  // ============ CURRENT USER ============
  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? currentJson = prefs.getString(_keyCurrentUser);
    if (currentJson == null) return null;
    return UserModel.fromJson(jsonDecode(currentJson));
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyCurrentUser);
  }

  // ============ LOGOUT ============
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCurrentUser);
  }
}