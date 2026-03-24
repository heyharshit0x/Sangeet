import 'package:get/get.dart';
import 'package:sangeet/utils/helper.dart';

import '../ui/player/player_controller.dart';

// NOTE: This service previously used smtc_windows for Windows media controls
// It has been removed to resolve dependency conflicts with Discord RPC
// Windows taskbar media controls are no longer available, but Discord Rich Presence is now supported

class WindowsAudioService extends GetxService {
  final playerController = Get.find<PlayerController>();

  @override
  void onInit() {
    printINFO(
        "WindowsAudioService initialized (SMTC disabled for Discord RPC compatibility)");
    super.onInit();
  }

  @override
  void onClose() {
    printINFO("WindowsAudioService closed");
    super.onClose();
  }
}
