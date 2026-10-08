import 'package:flutter/foundation.dart';

class AuthUser {
  final String username;
  final String email;
  final String password;
  AuthUser({
    required this.username,
    required this.email,
    required this.password,
  });
}

class AuthStore {
  // User dummy untuk testing (nanti diganti API/database)
  static final List<AuthUser> _users = [
    AuthUser(username: 'demo', email: 'demo@mail.com', password: '123456'),
  ];

  /// ValueNotifier agar UI reaktif saat login/logout
  static final ValueNotifier<AuthUser?> currentUser =
      ValueNotifier<AuthUser?>(null);

  static String? register({
    required String username,
    required String email,
    required String password,
  }) {
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      return 'Semua field harus diisi!';
    }
    if (password.length < 6) {
      return 'Password minimal 6 karakter!';
    }
    if (!RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w\-]+').hasMatch(email)) {
      return 'Format email tidak valid!';
    }
    if (_users.any((u) => u.email == email)) {
      return 'Email sudah digunakan!';
    }
    _users.add(AuthUser(username: username, email: email, password: password));
    return null;
  }

  static String? login({required String email, required String password}) {
    if (email.isEmpty || password.isEmpty) {
      return 'Email dan password harus diisi!';
    }
    try {
      final user = _users.firstWhere(
        (u) => u.email == email && u.password == password,
      );
      currentUser.value = user;
      return null;
    } catch (_) {
      return 'Email atau password salah!';
    }
  }

  static void logout() {
    currentUser.value = null;
  }
}