// ignore_for_file: unused_result
import 'package:dladmin/Admin/DashBoard/Pages/AdminSearch_Result.dart';
import 'package:dladmin/Admin/DashBoard/Pages/AllPropertiesList.dart';
import 'package:dladmin/Services/Providers/Search_suggetions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

final adminSearchTextProvider = StateProvider<String>((ref) => '');
final showSearchResultsProvider = StateProvider<bool>((ref) => false);

final adminSearchResultsProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, query) {
      return ref.watch(searchPropertyProvider(query).future);
    });

class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(adminSearchTextProvider);
    final showResults = ref.watch(showSearchResultsProvider);
    final isMobile = MediaQuery.of(context).size.width < 800;
    final isQueryEmpty = _controller.text.isEmpty;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text('Dashboard',style: GoogleFonts.nunito(fontWeight: FontWeight.w600),),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: isMobile ? double.infinity : 500,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.grey.shade400),
                  color: Colors.white,
                ),
                child: TextField(
                  onChanged: (value) {
                    ref.read(adminSearchTextProvider.notifier).state =
                        value.trim();
                    ref.read(showSearchResultsProvider.notifier).state = true;
                  },
                  controller: _controller,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    border: InputBorder.none,
                    hintText: 'Search by Location or Property ID',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: isMobile ? 12 : 14,
                      color: Colors.grey,
                    ),
                    suffixIcon:
                        isQueryEmpty
                            ? IconButton(
                              icon: Icon(
                                FontAwesomeIcons.search,
                                color: Colors.blue,
                              ),
                              onPressed: () {
                                ref
                                    .read(adminSearchTextProvider.notifier)
                                    .state = _controller.text.trim();
                                ref
                                    .read(showSearchResultsProvider.notifier)
                                    .state = true;
                              },
                            )
                            : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _controller.clear();
                                ref
                                    .read(adminSearchTextProvider.notifier)
                                    .state = '';
                                ref
                                    .read(showSearchResultsProvider.notifier)
                                    .state = false;
                              },
                            ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child:
                showResults && query.isNotEmpty
                    ? SearchResultList(query: query)
                    : const AllPropertiesList(),
          ),
        ],
      ),
    );
  }
}
