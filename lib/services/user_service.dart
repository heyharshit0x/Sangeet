import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class UserService extends GetxController {
  final userName = ''.obs;
  final isFirstLaunch = true.obs;

  static const String supabaseUrl = '';
  static const String supabaseAnonKey =
      '';

  late final SupabaseClient _supabase;
  late final Box _appPrefs;

  @override
  void onInit() {
    super.onInit();
    _supabase = Supabase.instance.client;
    _appPrefs = Hive.box("AppPrefs");
    _loadUserName();
  }

  /// Initialize Supabase - call this in main.dart before runApp
  static Future<void> initSupabase() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  /// Check if this is first launch
  Future<bool> checkFirstLaunch() async {
    final hasUserName = _appPrefs.get('userName');
    isFirstLaunch.value = hasUserName == null;
    return isFirstLaunch.value;
  }

  /// Load user name from local storage
  void _loadUserName() {
    final name = _appPrefs.get('userName');
    if (name != null) {
      userName.value = name;
      isFirstLaunch.value = false;
    } else {
      userName.value = 'Music Lover';
      isFirstLaunch.value = true;
    }
  }

  /// Get user name (fallback to 'Music Lover')
  String getUserName() {
    return userName.value.isEmpty ? 'Music Lover' : userName.value;
  }

  /// Save user name locally and send to Supabase
  Future<void> saveUserName(String name) async {
    if (name.trim().isEmpty) return;

    // Save locally
    await _appPrefs.put('userName', name.trim());
    userName.value = name.trim();
    isFirstLaunch.value = false;

    // Send to Supabase
    await _sendUserAnalytics(name.trim());
  }

  /// Generate unique device ID
  Future<String> _getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    String deviceId = '';

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id; // Android ID
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? 'unknown_ios';
      } else if (Platform.isWindows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        deviceId = windowsInfo.deviceId;
      } else if (Platform.isLinux) {
        final linuxInfo = await deviceInfo.linuxInfo;
        deviceId = linuxInfo.machineId ?? 'unknown_linux';
      } else if (Platform.isMacOS) {
        final macInfo = await deviceInfo.macOsInfo;
        deviceId = macInfo.systemGUID ?? 'unknown_mac';
      }
    } catch (e) {
      // Fallback to timestamp-based ID
      deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}';
    }

    return deviceId;
  }

  /// Send user analytics to Supabase
  Future<void> _sendUserAnalytics(String name) async {
    try {
      final deviceId = await _getDeviceId();

      // Insert or update user in Supabase
      await _supabase.from('users').upsert({
        'device_id': deviceId,
        'user_name': name,
        'first_seen_at': DateTime.now().toIso8601String(),
      }, onConflict: 'device_id');

      print('✅ User analytics sent to Supabase: $name ($deviceId)');
    } catch (e) {
      print('❌ Failed to send analytics to Supabase: $e');
      // Don't block the user if Supabase fails
    }
  }
}
