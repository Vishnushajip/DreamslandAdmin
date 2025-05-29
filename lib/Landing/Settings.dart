import 'package:dladmin/Admin/AddProperty/Basic_Details.dart';
import 'package:dladmin/Admin/Add_Agent/pages/Agents.dart';
import 'package:dladmin/Admin/DashBoard/Verfied_Tabs/Verfied_req.dart';
import 'package:dladmin/Developers/Pages/Add_builder.dart';
import 'package:dladmin/Developers/Pages/admin_all_builders.dart';
import 'package:dladmin/Landing/Activity_Log.dart';
import 'package:dladmin/Landing/Leads/Contact_Req.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Admin/DashBoard/Pages/admin_All_properties.dart';

class PageListItem {
  final String title;
  final VoidCallback? onTap;
  final Widget destination;
  final IconData prefixIcon;
  final IconData suffixIcon;
  final Color suffixIconColor;

  PageListItem({
    required this.title,
    required this.destination,
    required this.prefixIcon,
    this.onTap,
    this.suffixIcon = CupertinoIcons.right_chevron,
    this.suffixIconColor = Colors.grey,
  });
}

class PageExpansionItem {
  final String title;
  final IconData icon;
  final List<PageListItem> children;

  PageExpansionItem({
    required this.title,
    required this.icon,
    required this.children,
  });
}

final expandedTilesProvider = StateProvider<Set<int>>((ref) => {});

class ExpansionNavigationPage extends ConsumerWidget {
  const ExpansionNavigationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<PageExpansionItem> items = [
      PageExpansionItem(
        title: 'Properties Section',
        icon: CupertinoIcons.list_bullet,
        children: [
          PageListItem(
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              prefs.remove("builder");
              prefs.remove('username');
            },
            title: 'Add Property',
            suffixIconColor: Colors.green,
            destination: PropertyFormPage(),
            prefixIcon: CupertinoIcons.add_circled,
          ),
          PageListItem(
            title: 'Property List',
            destination: AdminDashboardPage(),
            prefixIcon: Icons.inventory_outlined,
            suffixIconColor: Colors.green,
          ),
        ],
      ),

      PageExpansionItem(
        title: 'Builders Section',
        icon: Icons.business,
        children: [
          PageListItem(
            title: 'Add Builder',
            destination: BuilderProfileImage(),
            prefixIcon: Icons.assignment_add,
            suffixIconColor: Colors.blue,
          ),
          PageListItem(
            title: 'All Builders',
            destination: DevelopersPage(),
            prefixIcon: Icons.verified,
            suffixIconColor: Colors.blue,
          ),
          PageListItem(
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              prefs.setString("builder", "builder");
              prefs.remove('username');
            },
            title: 'Add Property',
            destination: PropertyFormPage(),
            prefixIcon: Icons.add_circle_outline_outlined,
            suffixIconColor: Colors.blue,
          ),
        ],
      ),
      PageExpansionItem(
        title: 'Requests Section',
        icon: Icons.plagiarism_outlined,
        children: [
          PageListItem(
            title: 'Property Requests',
            destination: VerifiedDocumentsScreen(status: "Verified"),
            prefixIcon: Icons.notifications_active_outlined,
            suffixIconColor: Colors.blueGrey,
          ),
          PageListItem(
            title: 'Rejected Property',
            destination: VerifiedDocumentsScreen(status: "Rejected by Admin"),
            prefixIcon: Icons.block_flipped,
            suffixIconColor: Colors.red,
          ),
          PageListItem(
            title: 'Verified Property',
            destination: VerifiedDocumentsScreen(status: "Verified by Admin"),
            prefixIcon: Icons.verified_outlined,
            suffixIconColor: Colors.blue,
          ),
          PageListItem(
            title: 'Contact Requests',
            destination: CallbackRequestsScreen(),
            prefixIcon: Icons.contact_mail_rounded,
            suffixIconColor: Colors.blue,
          ),
        ],
      ),
      PageExpansionItem(
        title: 'Agents Section',
        icon: FontAwesomeIcons.userTie,
        children: [
          PageListItem(
            title: 'Agent Activity',
            destination: ActivityLogList(),
            prefixIcon: CupertinoIcons.bell_circle_fill,
            suffixIconColor: Color.fromARGB(255, 1, 82, 148),
          ),
          PageListItem(
            title: 'All Agents',
            destination: AgentsListPage(),
            prefixIcon: Icons.group,
            suffixIconColor: const Color.fromARGB(255, 1, 82, 148),
          ),
        ],
      ),
    ];

    final expandedTiles = ref.watch(expandedTilesProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            for (int i = 0; i < items.length; i++) ...[
              Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18.0),
                  child: ExpansionTile(
                    trailing: Icon(Icons.arrow_drop_down_circle_outlined,
                        color: Colors.black),
                    initiallyExpanded: expandedTiles.contains(i),
                    onExpansionChanged: (expanded) {
                      final notifier = ref.read(expandedTilesProvider.notifier);
                      final currentSet = ref.read(expandedTilesProvider);

                      if (expanded) {
                        notifier.state = {...currentSet}..add(i);
                      } else {
                        notifier.state = {...currentSet}..remove(i);
                      }
                    },
                    leading: Icon(items[i].icon, color: Colors.black),
                    title: Text(
                      items[i].title,
                      style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
                    ),
                    childrenPadding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 8,
                    ),
                    children:
                        items[i].children.map((child) {
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              child.prefixIcon,
                              color: child.suffixIconColor,
                            ),
                            title: Text(
                              child.title,
                              style: GoogleFonts.nunito(),
                            ),
                            trailing: Icon(child.suffixIcon),
                            onTap: () async {
                              if (child.onTap != null) {
                                child.onTap!();
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => child.destination,
                                ),
                              );
                            },
                          );
                        }).toList(),
                  ),
                ),
              ),
              if (i != items.length - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.shade300,
                  indent: 16,
                  endIndent: 16,
                ),
            ],
          ],
        ),
      ),
    );
  }
}
