import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/ui/screens/Artists/artist_screen.dart' show AboutArtist;
import '../../navigator.dart';
import '../../widgets/loader.dart';
import '../../widgets/separate_tab_item_widget.dart';
import '../../widgets/artist/modern_artist_header.dart';
import '../../widgets/artist/modern_artist_tabs.dart';
import 'package:share_plus/share_plus.dart';
import '../../widgets/snackbar.dart';
import 'artist_screen_controller.dart';

class ArtistScreenBN extends StatelessWidget {
  const ArtistScreenBN(
      {super.key, required this.artistScreenController, required this.tag});
  final ArtistScreenController artistScreenController;
  final String tag;
  @override
  Widget build(BuildContext context) {
    final separatedContent = artistScreenController.sepataredContent;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: Theme.of(context).canvasColor,
        leading: IconButton(
          onPressed: () {
            Get.nestedKey(ScreenNavigationSetup.id)!.currentState!.pop();
          },
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        elevation: 0,
      ),
      body: Obx(
        () => artistScreenController.isArtistContentFetced.isTrue
            ? Column(
                children: [
                  // Modern Artist Header
                  ModernArtistHeader(
                    artistName: artistScreenController.artist_.name,
                    thumbnailUrl: artistScreenController.artist_.thumbnailUrl,
                    description: "",
                    isBookmarked: artistScreenController.isAddedToLibrary.value,
                    onBookmarkTap: () {
                      final add =
                          artistScreenController.isAddedToLibrary.isFalse;
                      artistScreenController
                          .addNremoveFromLibrary(add: add)
                          .then((value) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(snackbar(
                          context,
                          value
                              ? add
                                  ? "artistBookmarkAddAlert".tr
                                  : "artistBookmarkRemoveAlert".tr
                              : "operationFailed".tr,
                          size: SanckBarSize.MEDIUM,
                        ));
                      });
                    },
                    onShareTap: () {
                      Share.share(
                          "https://music.youtube.com/channel/${artistScreenController.artist_.browseId}");
                    },
                    scrollOffset: 0,
                  ),
                  // Modern Artist Tabs
                  ModernArtistTabs(
                    tabs: [
                      "about".tr,
                      "songs".tr,
                      "videos".tr,
                      "albums".tr,
                      "singles".tr
                    ],
                    selectedIndex:
                        artistScreenController.navigationRailCurrentIndex.value,
                    onTabSelected: artistScreenController.onDestinationSelected,
                  ),
                  // Tab Content
                  Expanded(
                    child: _buildTabContent(
                        artistScreenController, separatedContent, tag),
                  ),
                ],
              )
            : const Center(child: LoadingIndicator()),
      ),
    );
  }

  Widget _buildTabContent(ArtistScreenController controller,
      Map<String, dynamic> separatedContent, String tag) {
    final tabIndex = controller.navigationRailCurrentIndex.value;

    if (tabIndex == 0) {
      // About tab
      return AboutArtist(
        artistScreenController: controller,
        padding:
            const EdgeInsets.only(top: 10, left: 15, right: 5, bottom: 200),
      );
    }

    // Other tabs: Songs, Videos, Albums, Singles
    final tabNames = ["Songs", "Videos", "Albums", "Singles"];
    final tabName = tabNames[tabIndex - 1];

    if (controller.isSeparatedArtistContentFetced.isFalse) {
      return const Center(child: LoadingIndicator());
    }

    return Padding(
      padding: const EdgeInsets.only(left: 15.0, right: 5),
      child: SeparateTabItemWidget(
        artistControllerTag: tag,
        hideTitle: true,
        isResultWidget: false,
        items: separatedContent.containsKey(tabName)
            ? separatedContent[tabName]['results']
            : [],
        title: tabName,
        scrollController: tabName == "Songs"
            ? controller.songScrollController
            : tabName == "Videos"
                ? controller.videoScrollController
                : tabName == "Albums"
                    ? controller.albumScrollController
                    : tabName == "Singles"
                        ? controller.singlesScrollController
                        : null,
      ),
    );
  }
}
