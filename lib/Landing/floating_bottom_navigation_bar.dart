// ignore_for_file: unused_result

import 'package:dladmin/Admin/Add_Agent/pages/Agents.dart';
import 'package:dladmin/Landing/Activity_Log.dart';
import 'package:dladmin/Services/BackButton.dart';
import 'package:dladmin/Landing/Settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:google_fonts/google_fonts.dart';

final bottomNavIndexProvider = StateProvider<int>((ref) => 0);
final selectedIndexProvider = StateProvider<int>((ref) => 0);
final activityBottomSheetVisibleProvider = StateProvider<bool>((ref) => true);

class Navbar extends ConsumerWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedIndexProvider);
    final List<Widget> pages = [AgentsListPage(), ExpansionNavigationPage()];

    return WillPopScope(
      onWillPop: () async {
        final notifier = ref.read(backPressProvider.notifier);
        notifier.onBackPressed();

        if (notifier.shouldExitApp()) {
          return Future.value(true);
        } else {
          Fluttertoast.showToast(
            msg: "Press back again to exit",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          return Future.value(false);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [
            Consumer(
              builder: (context, ref, _) {
                final countAsync = ref.watch(
                  todayActivityCountProvider('activity_logs'),
                );

                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(
                        CupertinoIcons.bell,
                        color: Colors.black87,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ActivityLogList(),
                          ),
                        );
                      },
                    ),
                    countAsync.maybeWhen(
                      data:
                          (count) =>
                              count > 0
                                  ? Transform.translate(
                                    offset: const Offset(25, 5),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 3,
                                        vertical: 0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 5,
                                        minHeight: 5,
                                      ),
                                      child: Text(
                                        count.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  )
                                  : const SizedBox(),
                      orElse: () => const SizedBox(),
                    ),
                  ],
                );
              },
            ),
          ],

          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text("Admin Panel", style: GoogleFonts.nunito()),
        ),
        backgroundColor: Colors.white,
        body: pages[selectedIndex],
        bottomNavigationBar: SnakeNavigationBar.color(
          showSelectedLabels: true,
          showUnselectedLabels: true,
          behaviour: SnakeBarBehaviour.pinned,
          snakeShape: SnakeShape.circle,
          unselectedLabelStyle: GoogleFonts.nunito(fontSize: 10),
          selectedLabelStyle: GoogleFonts.nunito(),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          backgroundColor: Colors.grey[200]!,
          snakeViewColor: const Color(0xFF1C3A6B),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.black54,
          currentIndex: selectedIndex,

          onTap: (index) {
            ref.refresh(searchProvider);
            ref.read(selectedIndexProvider.notifier).state = index;
          },
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),

            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
        bottomSheet: Consumer(
          builder: (context, ref, _) {
            final isVisible = ref.watch(activityBottomSheetVisibleProvider);
            return isVisible
                ? const ActivityLogPreview()
                : GestureDetector(
                  onTap: () {
                    ref
                        .read(activityBottomSheetVisibleProvider.notifier)
                        .state = !isVisible;
                  },
                  child: Icon(Icons.visibility_outlined),
                );
          },
        ),
      ),
    );
  }
}
