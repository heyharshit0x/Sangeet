import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '/ui/screens/Search/search_screen_controller.dart';

import '../../../navigator.dart';

class SearchItem extends StatelessWidget {
  final String queryString;
  final bool isHistoryString;
  const SearchItem(
      {super.key, required this.queryString, required this.isHistoryString});

  @override
  Widget build(BuildContext context) {
    final searchScreenController = Get.find<SearchScreenController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Get.toNamed(ScreenNavigationSetup.searchResultScreen,
                id: ScreenNavigationSetup.id, arguments: queryString);
            searchScreenController.addToHistryQueryList(queryString);
            // for Desktop searchbar
            if (GetPlatform.isDesktop) {
              searchScreenController.focusNode.unfocus();
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.03)
                  : Colors.black.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.05),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isHistoryString
                        ? const Color(0xFF06B6D4).withValues(alpha: 0.15)
                        : const Color(0xFFA855F7).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isHistoryString
                        ? PhosphorIconsRegular.clockCounterClockwise
                        : PhosphorIconsRegular.magnifyingGlass,
                    size: 18,
                    color: isHistoryString
                        ? const Color(0xFF06B6D4)
                        : const Color(0xFFA855F7),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    queryString,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                if (isHistoryString)
                  IconButton(
                    iconSize: 18,
                    splashRadius: 18,
                    visualDensity: const VisualDensity(horizontal: -2),
                    onPressed: () {
                      searchScreenController
                          .removeQueryFromHistory(queryString);
                    },
                    icon: Icon(
                      PhosphorIconsRegular.x,
                      color: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .color!
                          .withValues(alpha: 0.5),
                    ),
                  ),
                IconButton(
                  iconSize: 20,
                  splashRadius: 18,
                  visualDensity: const VisualDensity(horizontal: -2),
                  onPressed: () {
                    searchScreenController.suggestionInput(queryString);
                  },
                  icon: Icon(
                    PhosphorIconsRegular.arrowUpLeft,
                    color: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .color!
                        .withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
