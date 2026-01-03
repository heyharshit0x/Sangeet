import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:sangeet/ui/screens/Home/home_screen_controller.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final homeScreenController = Get.find<HomeScreenController>();

    return Obx(
      () => NavigationBar(
        selectedIndex: homeScreenController.tabIndex.value,
        onDestinationSelected: homeScreenController.onSideBarTabSelected,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 65,
        backgroundColor: Theme.of(context).canvasColor,
        indicatorColor: Theme.of(context).colorScheme.secondaryContainer,
        surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
        destinations: [
          NavigationDestination(
            icon: Icon(PhosphorIconsRegular.house),
            selectedIcon: Icon(PhosphorIconsFill.house),
            label: "home".tr,
          ),
          NavigationDestination(
            icon: Icon(PhosphorIconsRegular.magnifyingGlass),
            selectedIcon: Icon(PhosphorIconsBold.magnifyingGlass),
            label: "search".tr,
          ),
          NavigationDestination(
            icon: Icon(PhosphorIconsRegular.musicNotes),
            selectedIcon: Icon(PhosphorIconsFill.musicNotes),
            label: "library".tr,
          ),
          NavigationDestination(
            icon: Icon(PhosphorIconsRegular.gear),
            selectedIcon: Icon(PhosphorIconsFill.gear),
            label: "settings".tr,
          ),
        ],
      ),
    );
  }
}
