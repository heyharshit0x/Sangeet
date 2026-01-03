import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'components/search_item.dart';
import '/ui/screens/Settings/settings_screen_controller.dart';
import '../../widgets/modified_text_field.dart';
import '/ui/navigator.dart';
import 'search_screen_controller.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final searchScreenController = Get.put(SearchScreenController());
    final settingsScreenController = Get.find<SettingsScreenController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPadding = context.isLandscape ? 50.0 : 80.0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Obx(
        () => Row(
          children: [
            settingsScreenController.isBottomNavBarEnabled.isFalse
                ? Container(
                    width: 60,
                    color:
                        Theme.of(context).navigationRailTheme.backgroundColor,
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: topPadding),
                          child: IconButton(
                            icon: Icon(
                              PhosphorIconsRegular.caretLeft,
                              color: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .color,
                            ),
                            onPressed: () {
                              Get.nestedKey(ScreenNavigationSetup.id)!
                                  .currentState!
                                  .pop();
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(
                    width: 15,
                  ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: topPadding, left: 5, right: 15),
                child: Column(
                  children: [
                    // Modern header with gradient
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.2),
                                Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withValues(alpha: 0.15),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.black.withValues(alpha: 0.05),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            PhosphorIconsBold.magnifyingGlass,
                            color: Theme.of(context).colorScheme.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "search".tr,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Glassmorphic search bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.black.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.black.withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                          child: ModifiedTextField(
                            textCapitalization: TextCapitalization.sentences,
                            controller:
                                searchScreenController.textInputController,
                            textInputAction: TextInputAction.search,
                            onChanged: searchScreenController.onChanged,
                            onSubmitted: (val) {
                              if (val.contains("https://")) {
                                searchScreenController
                                    .filterLinks(Uri.parse(val));
                                searchScreenController.reset();
                                return;
                              }
                              Get.toNamed(
                                  ScreenNavigationSetup.searchResultScreen,
                                  id: ScreenNavigationSetup.id,
                                  arguments: val);
                              searchScreenController.addToHistryQueryList(val);
                            },
                            autofocus: settingsScreenController
                                .isBottomNavBarEnabled.isFalse,
                            cursorColor: Theme.of(context).colorScheme.primary,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              hintText: "searchDes".tr,
                              hintStyle: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color
                                    ?.withValues(alpha: 0.5),
                              ),
                              prefixIcon: Icon(
                                PhosphorIconsRegular.magnifyingGlass,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              suffix: searchScreenController
                                      .textInputController.text.isNotEmpty
                                  ? IconButton(
                                      onPressed: searchScreenController.reset,
                                      icon: Icon(
                                        PhosphorIconsRegular.x,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color
                                            ?.withValues(alpha: 0.7),
                                      ),
                                      splashRadius: 20,
                                      iconSize: 20,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Results with gradient section header
                    Expanded(
                      child: Obx(() {
                        final isEmpty = searchScreenController
                                .suggestionList.isEmpty ||
                            searchScreenController.textInputController.text ==
                                "";
                        final list = isEmpty
                            ? searchScreenController.historyQuerylist.toList()
                            : searchScreenController.suggestionList.toList();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Section header with gradient
                            if (list.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isEmpty
                                        ? [
                                            const Color(0xFF06B6D4)
                                                .withValues(alpha: 0.15),
                                            const Color(0xFF3B82F6)
                                                .withValues(alpha: 0.1),
                                          ]
                                        : [
                                            const Color(0xFFA855F7)
                                                .withValues(alpha: 0.15),
                                            const Color(0xFFEC4899)
                                                .withValues(alpha: 0.1),
                                          ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isEmpty
                                          ? PhosphorIconsRegular
                                              .clockCounterClockwise
                                          : PhosphorIconsRegular.trendUp,
                                      size: 18,
                                      color: isEmpty
                                          ? const Color(0xFF06B6D4)
                                          : const Color(0xFFA855F7),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isEmpty
                                          ? "Recent Searches"
                                          : "Suggestions",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: isEmpty
                                                ? const Color(0xFF06B6D4)
                                                : const Color(0xFFA855F7),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 8),

                            // Results list
                            Expanded(
                              child: ListView(
                                padding:
                                    const EdgeInsets.only(top: 5, bottom: 400),
                                physics: const BouncingScrollPhysics(
                                    parent: AlwaysScrollableScrollPhysics()),
                                children: searchScreenController
                                        .urlPasted.isTrue
                                    ? [
                                        InkWell(
                                          onTap: () {
                                            searchScreenController.filterLinks(
                                                Uri.parse(searchScreenController
                                                    .textInputController.text));
                                            searchScreenController.reset();
                                          },
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 4),
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                      .withValues(alpha: 0.1),
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .secondary
                                                      .withValues(alpha: 0.05),
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: isDark
                                                    ? Colors.white
                                                        .withValues(alpha: 0.1)
                                                    : Colors.black.withValues(
                                                        alpha: 0.05),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  PhosphorIconsRegular.link,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    "urlSearchDes".tr,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                ),
                                                Icon(
                                                  PhosphorIconsRegular
                                                      .caretRight,
                                                  size: 16,
                                                  color: Theme.of(context)
                                                      .iconTheme
                                                      .color
                                                      ?.withValues(alpha: 0.5),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ]
                                    : list
                                        .map((item) => SearchItem(
                                            queryString: item,
                                            isHistoryString: isEmpty))
                                        .toList(),
                              ),
                            ),
                          ],
                        );
                      }),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
