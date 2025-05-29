import 'package:cached_network_image/cached_network_image.dart';
import 'package:dladmin/Admin/DashBoard/Pages/View/Seach_results.dart';
import 'package:dladmin/Admin/DashBoard/Pages/admin_All_properties.dart';
import 'package:dladmin/Admin/Update/Pages/UpdateBasic_Details.dart';
import 'package:dladmin/Services/Cache.dart';
import 'package:dladmin/Services/Fetch_docs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class SearchResultList extends ConsumerStatefulWidget {
  final String query;

  const SearchResultList({super.key, required this.query});

  @override
  _SearchResultListState createState() => _SearchResultListState();
}

class _SearchResultListState extends ConsumerState<SearchResultList> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.query);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(adminSearchResultsProvider(widget.query));

    return Column(
      children: [
        Expanded(
          child: results.when(
            data: (list) {
              if (list.isEmpty) {
                return const Center(child: Text("No properties found"));
              }

              return ListView.separated(
                itemCount: list.length,
                separatorBuilder: (_, __) => const Divider(color: Colors.white),
                itemBuilder: (context, index) {
                  final suggestion = list[index];
                  final imageUrl =
                      (suggestion['images'] is List &&
                              suggestion['images'].isNotEmpty)
                          ? suggestion['images'][0]
                          : '';

                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading:
                          imageUrl.isNotEmpty
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  cacheManager: CustomCacheManager(),
                                  placeholder:
                                      (_, __) => Shimmer.fromColors(
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
                        suggestion['name'] ?? '',
                        style: GoogleFonts.poppins(fontSize: 15),
                      ),
                      subtitle: Text(
                        "Location: ${suggestion['location'] ?? ''}\nID: ${suggestion['propertyId'] ?? ''}",
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.mode_edit_outline_outlined,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              final property = AgentProperty.fromJson(
                                suggestion,
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => updatePropertyFormPage(
                                        property: property,
                                      ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => PropertyDetailsPage(
                                  propertyData: suggestion,
                                ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => SizedBox.shrink()
          ),
        ),
      ],
    );
  }
}