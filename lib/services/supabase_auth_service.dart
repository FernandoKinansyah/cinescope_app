// lib/services/supabase_auth_service.dart

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  static SupabaseClient get _supabase => Supabase.instance.client;

  static final ValueNotifier<User?> currentUser =
      ValueNotifier<User?>(null);

  static void init() {
    currentUser.value = _supabase.auth.currentUser;
    _supabase.auth.onAuthStateChange.listen((data) {
      currentUser.value = data.session?.user;
    });
  }

  static bool isValidEmail(String email) {
    final regex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return regex.hasMatch(email);
  }

  /// Cek apakah user perlu verifikasi email
  static bool needEmailVerification(User user) {
    return user.emailConfirmedAt == null;
  }

  /// Register user baru
  /// Return null kalau sukses (langsung aktif)
  /// Return 'NEED_VERIFICATION' kalau user harus cek email dulu
  static Future<String?> register({
    required String username,
    required String email,
    required String password,
  }) async {
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      return 'Semua field harus diisi!';
    }
    if (username.length < 3) {
      return 'Username minimal 3 karakter!';
    }
    if (username.length > 20) {
      return 'Username maksimal 20 karakter!';
    }
    if (!isValidEmail(email)) {
      return 'Format email tidak valid! Contoh: nama@gmail.com';
    }
    if (password.length < 6) {
      return 'Password minimal 6 karakter!';
    }

    try {
      final existing = await _supabase
          .from('profiles')
          .select('id')
          .eq('email', email)
          .maybeSingle();

      if (existing != null) {
        return 'Email sudah digunakan. Silakan login.';
      }
    } catch (_) {}

    try {
      final res = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );

      if (res.user == null) {
        return 'Gagal mendaftar, coba lagi.';
      }

      // Simpan ke tabel profiles
      await _supabase.from('profiles').upsert({
        'id': res.user!.id,
        'username': username,
        'email': email,
        'role': 'user',
      });

      // Cek apakah email perlu diverifikasi
      if (res.session == null) {
        // Confirm Email ON → user harus verifikasi dulu
        return 'NEED_VERIFICATION';
      }

      // Confirm Email OFF → user langsung aktif
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    }
  }

  /// Login user
  static Future<String?> login({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      return 'Email dan password harus diisi!';
    }
    if (!isValidEmail(email)) {
      return 'Format email tidak valid!';
    }
    if (password.length < 6) {
      return 'Password minimal 6 karakter!';
    }

    try {
      final profile = await _supabase
          .from('profiles')
          .select('id, email')
          .eq('email', email)
          .maybeSingle();

      if (profile == null) {
        return 'Email belum terdaftar. Silakan daftar dulu.';
      }
    } catch (e) {
      return 'Terjadi kesalahan verifikasi: $e';
    }

    try {
      final res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user != null && res.user!.emailConfirmedAt == null) {
        await _supabase.auth.signOut();
        return 'EMAIL_NOT_VERIFIED';
      }

      return null;
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('invalid')) {
        return 'Email atau password salah!';
      }
      if (msg.contains('email not confirmed')) {
        return 'EMAIL_NOT_VERIFIED';
      }
      return e.message;
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    }
  }

  /// Kirim ulang email verifikasi
  static Future<String?> resendVerification(String email) async {
    try {
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: email,
      );
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Gagal kirim ulang: $e';
    }
  }

  static Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  static String getUsername() {
    final user = currentUser.value;
    if (user == null) return '';
    return user.userMetadata?['username'] as String? ??
        user.email?.split('@').first ??
        'User';
  }
}