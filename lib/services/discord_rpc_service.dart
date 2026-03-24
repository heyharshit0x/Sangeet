import 'package:get/get.dart';
import 'package:discord_rpc/discord_rpc.dart';
import 'package:sangeet/utils/helper.dart';

import '../ui/player/player_controller.dart';

class DiscordRPCService extends GetxService {
  late DiscordRPC rpc;
  final playerController = Get.find<PlayerController>();

  // Discord Application ID
  static const String applicationId = '1454504943120683109';

  bool _isInitialized = false;

  @override
  void onInit() {
    _initService();
    super.onInit();
  }

  Future<void> _initService() async {
    try {
      // Instantiate Discord RPC with your Application ID
      rpc = DiscordRPC(applicationId: applicationId);

      // Start the RPC connection
      rpc.start(autoRegister: true);
      _isInitialized = true;

      printINFO("Discord RPC initialized successfully - Sangeet Music");
      printINFO("Application ID: $applicationId");

      // Listen to player state changes
      playerController.buttonState.listen((state) {
        printINFO("Discord RPC: Playback state changed to $state");
        _updatePresence();
      });

      // Listen to current song changes
      playerController.currentSong.listen((song) {
        if (song != null) {
          printINFO("Discord RPC: Song changed to ${song.title}");
          _updatePresence();
        } else {
          // Clear presence when no song
          printINFO("Discord RPC: No song playing, clearing presence");
          if (_isInitialized) {
            rpc.clearPresence();
          }
        }
      });
    } catch (e) {
      printERROR("Failed to initialize Discord RPC: $e");
      _isInitialized = false;
    }
  }

  void _updatePresence() {
    if (!_isInitialized) return;

    try {
      final currentSong = playerController.currentSong.value;
      final buttonState = playerController.buttonState.value;

      if (currentSong == null) {
        // Clear presence if no song is playing
        rpc.clearPresence();
        return;
      }

      // Determine timestamps based on playback state
      int? startTimeStamp;
      int? endTimeStamp;

      switch (buttonState) {
        case PlayButtonState.playing:
          // Calculate timestamps for elapsed time
          // Discord RPC expects timestamps in SECONDS, not milliseconds
          final now = (DateTime.now().millisecondsSinceEpoch / 1000).round();
          final currentPosition =
              playerController.progressBarStatus.value.current.inSeconds;
          final totalDuration =
              playerController.progressBarStatus.value.total.inSeconds;

          // Start timestamp is current time minus current position
          startTimeStamp = now - currentPosition;
          // End timestamp is start time plus total duration
          if (totalDuration > 0) {
            endTimeStamp = startTimeStamp + totalDuration;
          }

          printINFO(
              "Discord RPC Timestamps: start=$startTimeStamp, end=$endTimeStamp, duration=$totalDuration sec");
          break;
        case PlayButtonState.paused:
          break;
        case PlayButtonState.loading:
          break;
      }

      // Extract metadata
      String artistName = currentSong.artist ?? "Unknown Artist";

      // Get album artwork URL
      String? rawArtUrl = currentSong.artUri?.toString();

      // Discord RPC ONLY supports external HTTP/HTTPS URLs or pre-uploaded asset keys.
      // It cannot load local file URIs (e.g., file:///) from the user's hard drive.
      bool isOnlineArt = rawArtUrl != null && rawArtUrl.startsWith('http');

      String finalLargeImageKey = isOnlineArt ? rawArtUrl : 'sangeet';
      String? finalSmallImageKey = isOnlineArt ? 'sangeet' : null;
      String finalLargeImageText = isOnlineArt
          ? (currentSong.album?.isNotEmpty == true
              ? currentSong.album!
              : currentSong.title)
          : 'Sangeet Music';
      String? finalSmallImageText = isOnlineArt ? 'Sangeet Music' : null;

      // Build state text based on playback status
      String state = artistName;
      if (buttonState == PlayButtonState.paused) {
        state = "Paused";
      } else if (buttonState == PlayButtonState.loading) {
        state = "Loading...";
      }

      // Build presence - Spotify style
      final presence = DiscordPresence(
        details: currentSong.title,
        state: state,
        startTimeStamp:
            buttonState == PlayButtonState.playing ? startTimeStamp : null,
        endTimeStamp:
            buttonState == PlayButtonState.playing ? endTimeStamp : null,
        largeImageKey: finalLargeImageKey,
        largeImageText: finalLargeImageText,
        smallImageKey: finalSmallImageKey,
        smallImageText: finalSmallImageText,
      );

      // Update Discord presence
      rpc.updatePresence(presence);

      printINFO(
          "Discord RPC updated: ${currentSong.title} - $artistName (State: $buttonState)");
    } catch (e) {
      printERROR("Failed to update Discord RPC: $e");
    }
  }

  @override
  void onClose() {
    if (_isInitialized) {
      try {
        rpc.clearPresence();
        rpc.shutDown();
        printINFO("Discord RPC shutdown");
      } catch (e) {
        printERROR("Error closing Discord RPC: $e");
      }
    }
    super.onClose();
  }
}
