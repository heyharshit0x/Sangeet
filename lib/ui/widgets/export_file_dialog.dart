import 'dart:io';

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/ui/screens/Settings/settings_screen_controller.dart';
import '/ui/widgets/loader.dart';
import '../../services/permission_service.dart';

class ExportFileDialog extends StatelessWidget {
  const ExportFileDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final exportFileDialogController = Get.put(ExportFileDialogController());
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
                              Icons.file_upload,
                              size: 28,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "exportDowloadedFiles".tr,
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
                                    if (exportFileDialogController
                                        .scanning.isTrue) {
                                      return Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const LoadingIndicator(),
                                          const SizedBox(height: 16),
                                          Text(
                                            "scanning".tr,
                                            style: theme.textTheme.bodyMedium,
                                          )
                                        ],
                                      );
                                    } else if (exportFileDialogController
                                        .ready.isTrue) {
                                      return Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.file_present,
                                            size: 48,
                                            color: theme.primaryColor,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            "${exportFileDialogController.filesToExport.length} ${"downFilesFound".tr}",
                                            style: theme.textTheme.titleMedium,
                                          ),
                                        ],
                                      );
                                    } else if (exportFileDialogController
                                        .exportRunning.isTrue) {
                                      return Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CircularProgressIndicator(
                                            value: exportFileDialogController
                                                    .exportProgress.value /
                                                exportFileDialogController
                                                    .filesToExport.length,
                                            backgroundColor: theme
                                                .colorScheme.surfaceContainerHighest,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            "${exportFileDialogController.exportProgress.toInt()}/${exportFileDialogController.filesToExport.length}",
                                            style: theme.textTheme.titleLarge
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: theme.primaryColor,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text("exporting".tr),
                                        ],
                                      );
                                    } else if (exportFileDialogController
                                            .exportProgress
                                            .toInt() ==
                                        exportFileDialogController
                                            .filesToExport.length) {
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
                                            "exportMsg".tr,
                                            style: theme.textTheme.titleMedium,
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  }),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Obx(() {
                                final isComplete = exportFileDialogController
                                        .exportProgress
                                        .toInt() ==
                                    exportFileDialogController
                                        .filesToExport.length;

                                return ElevatedButton(
                                  onPressed: () {
                                    if (isComplete) {
                                      Navigator.of(context).pop();
                                    } else {
                                      exportFileDialogController.export();
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
                                    isComplete ? "close".tr : "export".tr,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }),
                              const SizedBox(height: 30),
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

class ExportFileDialogController extends GetxController {
  final scanning = true.obs;
  final ready = false.obs;
  final exportRunning = false.obs;
  final exportProgress = (-1).obs;
  List<String> filesToExport = [];

  @override
  void onInit() {
    scanFilesToExport();
    super.onInit();
  }

  Future<void> scanFilesToExport() async {
    final supportDirPath = Get.find<SettingsScreenController>().supportDirPath;
    final filesEntityList =
        Directory("$supportDirPath/Music").listSync(recursive: false);
    final filesPath = filesEntityList.map((entity) => entity.path).toList();
    filesToExport.addAll(filesPath);
    scanning.value = false;
    ready.value = true;
  }

  Future<void> export() async {
    if (!await PermissionService.getExtStoragePermission()) {
      return;
    }

    exportProgress.value = 0;
    exportRunning.value = true;
    final exportDirPath =
        Get.find<SettingsScreenController>().exportLocationPath.toString();
    final length_ = filesToExport.length;
    for (int i = 0; i < length_; i++) {
      final filePath = filesToExport[i];
      final newFilePath = "$exportDirPath/${filePath.split("/").last}";
      await File(filePath).copy(newFilePath);
      exportProgress.value = i + 1;
    }
    exportRunning.value = false;
  }
}
