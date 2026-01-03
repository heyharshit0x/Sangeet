import 'dart:io';
import 'dart:ui';

import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:terminate_restart/terminate_restart.dart';

import '/ui/screens/Settings/settings_screen_controller.dart';
import '/utils/helper.dart';
import '/ui/widgets/loader.dart';
import '../../services/permission_service.dart';

class RestoreDialog extends StatelessWidget {
  const RestoreDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final restoreDialogController = Get.put(RestoreDialogController());
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.1),
            theme.colorScheme.secondary.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.4,
        maxChildSize: 0.8,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        (isDark ? Colors.black : theme.scaffoldBackgroundColor)
                            .withValues(alpha: 0.8),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Column(
                    children: [
                      // Drag Handle
                      Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.iconTheme.color?.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      // Title
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.restore,
                              size: 28,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "restoreAppData".tr,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      // Content
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                height: 120,
                                child: Center(
                                  child: Obx(() {
                                    if (restoreDialogController
                                        .processingFiles.isTrue) {
                                      return Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const LoadingIndicator(),
                                          const SizedBox(height: 16),
                                          Text(
                                            "processFiles".tr,
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                        ],
                                      );
                                    } else if (restoreDialogController
                                        .restoreRunning.isTrue) {
                                      return Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CircularProgressIndicator(
                                            value: restoreDialogController
                                                    .restoreProgress.value /
                                                restoreDialogController
                                                    .filesToRestore.value,
                                            backgroundColor: theme
                                                .colorScheme.surfaceContainerHighest,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            "${restoreDialogController.restoreProgress.toInt()}/${restoreDialogController.filesToRestore.toInt()}",
                                            style: theme.textTheme.titleLarge
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: theme.primaryColor,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text("restoring".tr),
                                        ],
                                      );
                                    } else if (restoreDialogController
                                                .restoreProgress
                                                .toInt() ==
                                            restoreDialogController
                                                .filesToRestore
                                                .toInt() &&
                                        restoreDialogController.filesToRestore
                                                .toInt() >
                                            0) {
                                      return Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            size: 48,
                                            color: Colors.green,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            "restoreMsg".tr,
                                            style: theme.textTheme.titleMedium,
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      );
                                    } else {
                                      return Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.settings_backup_restore,
                                            size: 48,
                                            color: theme.primaryColor,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            "letsStrart".tr,
                                            style: theme.textTheme.titleMedium,
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      );
                                    }
                                  }),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Obx(() {
                                final isRunning = restoreDialogController
                                        .processingFiles.isTrue ||
                                    restoreDialogController
                                        .restoreRunning.isTrue;
                                if (isRunning) return const SizedBox.shrink();

                                final isComplete = restoreDialogController
                                            .restoreProgress
                                            .toInt() ==
                                        restoreDialogController.filesToRestore
                                            .toInt() &&
                                    restoreDialogController.filesToRestore
                                            .toInt() >
                                        0;

                                return ElevatedButton(
                                  onPressed: () {
                                    if (isComplete) {
                                      GetPlatform.isAndroid
                                          ? TerminateRestart.instance
                                              .restartApp(
                                              options:
                                                  const TerminateRestartOptions(
                                                terminate: true,
                                              ),
                                            )
                                          : exit(0);
                                    } else {
                                      restoreDialogController.restore();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    backgroundColor: theme.primaryColor,
                                    foregroundColor:
                                        theme.colorScheme.onPrimary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: Text(
                                    isComplete ? "restartApp".tr : "restore".tr,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class RestoreDialogController extends GetxController {
  final restoreRunning = false.obs;
  final restoreProgress = (-1).obs;
  final filesToRestore = (0).obs;
  final processingFiles = false.obs;

  Future<void> restore() async {
    if (!await PermissionService.getExtStoragePermission()) {
      return;
    }

    if (!await PermissionService.getExtStoragePermission()) {
      return;
    }

    final FilePickerResult? pickedFileResult = await FilePicker.platform
        .pickFiles(
            dialogTitle: "Select backup file",
            type: GetPlatform.isWindows ? FileType.custom : FileType.any,
            allowedExtensions: GetPlatform.isWindows ? ['hmb'] : null,
            allowMultiple: false);

    final String? pickedFile = pickedFileResult?.files.first.path;

    // is this check necessary?
    if (pickedFile == '/' || pickedFile == null) {
      return;
    }
    processingFiles.value = true;
    await Future.delayed(const Duration(seconds: 4));
    final restoreFilePath = pickedFile.toString();
    final supportDirPath = Get.find<SettingsScreenController>().supportDirPath;
    final dbDirPath = await Get.find<SettingsScreenController>().dbDir;
    final Directory dbDir = Directory(dbDirPath);
    printInfo(info: dbDir.path);
    await Get.find<SettingsScreenController>().closeAllDatabases();

    //delele all the files with extension .hive
    for (final file in dbDir.listSync()) {
      if (file is File && file.path.endsWith('.hive')) {
        await file.delete();
      }
    }
    final bytes = await File(restoreFilePath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    filesToRestore.value = archive.length;
    restoreProgress.value = 0;
    processingFiles.value = false;
    restoreRunning.value = true;
    for (final file in archive) {
      final filename = file.name;
      printINFO(filename);
      if (file.isFile) {
        final data = file.content as List<int>;
        final targetFileDir =
            filename.endsWith(".m4a") || filename.endsWith(".opus")
                ? "$supportDirPath/Music"
                : filename.endsWith(".png")
                    ? "$supportDirPath/thumbnails"
                    : dbDirPath;
        final outputFile = File('$targetFileDir/$filename');
        await outputFile.create(recursive: true);
        await outputFile.writeAsBytes(data);
        restoreProgress.value++;
      }
    }
    // Clear file picker temp directory
    final tempFilePickerDirPath =
        "${(await getApplicationCacheDirectory()).path}/file_picker";
    final tempFilePickerDir = Directory(tempFilePickerDirPath);
    if (tempFilePickerDir.existsSync()) {
      await tempFilePickerDir.delete(recursive: true);
    }

    // change file download path to support dir path in songs if system is windows or linux
    if (GetPlatform.isWindows) {
      // open the restored box
      final newSongBox = await Hive.openBox("SongDownloads");
      final downloadedSongs = newSongBox.values.toList();
      for (final song in downloadedSongs) {
        final songPath = song["url"];
        if (songPath != null && songPath is String) {
          final fileName = songPath.split("/").last;
          final newFilePath = "$supportDirPath/Music/$fileName";
          song["url"] = newFilePath;
          song['streamInfo'][1]['url'] = newFilePath;
          await newSongBox.put(song["videoId"], song);
        }
      }
    }

    restoreRunning.value = false;
  }
}
