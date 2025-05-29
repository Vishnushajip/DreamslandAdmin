import 'package:cached_network_image/cached_network_image.dart';
import 'package:dladmin/Admin/DashBoard/Pages/View/Seach_results.dart';
import 'package:dladmin/Admin/Update/Pages/UpdateBasic_Details.dart';
import 'package:dladmin/Services/Cache.dart';
import 'package:dladmin/Services/Fetch_docs.dart';
import 'package:dladmin/Services/Providers/Search_suggetions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

final adminsearchTextProvider = StateProvider<String>((ref) => '');
final adminSearchResultsProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, query) {
  return ref.watch(searchPropertyProvider(query).future);
});

class AdminSearchBarAllPage extends ConsumerStatefulWidget {
  const AdminSearchBarAllPage({super.key});

  @override
  ConsumerState<AdminSearchBarAllPage> createState() =>
      _AdminSearchBarAllPageState();
}

class _AdminSearchBarAllPageState extends ConsumerState<AdminSearchBarAllPage> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();

    _controller.addListener(() {
      ref.read(adminsearchTextProvider.notifier).state = _controller.text;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(adminsearchTextProvider);
    final results = ref.watch(adminSearchResultsProvider(query));
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Center(
            child: Container(
              width: isMobile ? double.infinity : 500,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade400),
                color: Colors.white,
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  border: InputBorder.none,
                  hintText: 'Search by Location or Property ID',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: isMobile ? 12 : 14,
                    color: Colors.grey,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () => _controller.clear(),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: results.when(
              data: (list) {
                if (query.isEmpty) return const SizedBox.shrink();
                if (list.isEmpty) {
                  return const Center(
                    child: Text("No properties found"),
                  );
                }
                return ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const Divider(
                    color: Colors.white,
                  ),
                  itemBuilder: (context, index) {
                    final suggestion = list[index];
                    final title = suggestion['name'] ?? '';
                    final location = suggestion['location'] ?? '';
                    final propertyId = suggestion['propertyId'] ?? '';
                    final imageUrl = (suggestion['images'] is List &&
                            suggestion['images'].isNotEmpty)
                        ? suggestion['images'][0]
                        : '';

                    return Container(
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.grey.shade400, width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        leading: imageUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  cacheManager: CustomCacheManager(),
                                  placeholder: (context, url) =>
                                      Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            : const Icon(Icons.image, size: 50),
                        title: Text(
                          title,
                          style: GoogleFonts.poppins(fontSize: 15),
                        ),
                        subtitle: Text(
                          "Location: $location\nID: $propertyId",
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.mode_edit_outline_outlined,
                                  color: Colors.blue),
                              onPressed: () {
                                final agentProperty =
                                    AgentProperty.fromJson(suggestion);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          updatePropertyFormPage(
                                              property: agentProperty),
                                    ));
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {},
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  PropertyDetailsPage(propertyData: suggestion),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text("Error: $e")),
            ),
          ),
        ],
      ),
    );
  }
}
