import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shimmer/shimmer.dart';

final locationSearchQueryProvider = StateProvider<String>((ref) => '');
final selectedLocationsProvider = StateProvider<List<String>>((ref) => []);

Stream<List<Map<String, dynamic>>> searchLocations(String query) {
  if (query.isEmpty) return const Stream.empty();

  return FirebaseFirestore.instance
      .collection('property_location')
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs
                .map(
                  (doc) => {
                    'location': doc['location'].toString(),
                    'imageurl': doc['imageurl'] ?? '',
                  },
                )
                .where(
                  (loc) => loc['location'].toLowerCase().contains(
                    query.toLowerCase(),
                  ),
                )
                .toList(),
      );
}

class LocationDropdown extends ConsumerStatefulWidget {
  final List<String>? initialLocations;
  final ValueChanged<String> onSelected;
  final IconData? icon;

  const LocationDropdown({
    super.key,
    required this.onSelected,
    this.initialLocations,
    this.icon,
  });

  @override
  ConsumerState<LocationDropdown> createState() => _LocationDropdownState();
}

class _LocationDropdownState extends ConsumerState<LocationDropdown> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();

    if (widget.initialLocations != null &&
        widget.initialLocations!.isNotEmpty) {
      Future.microtask(() {
        ref.read(selectedLocationsProvider.notifier).state = List.from(
          widget.initialLocations!,
        );
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addLocation(String location) {
    final selected = ref.read(selectedLocationsProvider);
    if (!selected.contains(location)) {
      final updated = [...selected, location];
      ref.read(selectedLocationsProvider.notifier).state = updated;
      widget.onSelected(location);
    }
  }

  void _removeLocation(String location) {
    final updated = [...ref.read(selectedLocationsProvider)]..remove(location);
    ref.read(selectedLocationsProvider.notifier).state = updated;
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(locationSearchQueryProvider);
    final selectedLocations = ref.watch(selectedLocationsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          onChanged: (val) {
            ref.read(locationSearchQueryProvider.notifier).state = val;
          },
          decoration: InputDecoration(
            prefixIcon: widget.icon != null ? Icon(widget.icon) : null,
            hintText: 'Search Location',
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            suffixIcon:
                query.isNotEmpty
                    ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        ref.read(locationSearchQueryProvider.notifier).state =
                            '';
                      },
                    )
                    : null,
          ),
        ),
        const SizedBox(height: 10),
        if (selectedLocations.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children:
                selectedLocations
                    .map(
                      (loc) => Chip(
                        label: Text(loc),
                        deleteIcon: const Icon(Icons.close),
                        onDeleted: () => _removeLocation(loc),
                      ),
                    )
                    .toList(),
          ),
        const SizedBox(height: 10),
        if (query.isNotEmpty)
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: searchLocations(query),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: LoadingAnimationWidget.waveDots(
                    color: const Color.fromARGB(255, 17, 70, 114),
                    size: 40,
                  ),
                );
              }

              final results = snapshot.data ?? [];

              if (results.isEmpty) {
                return const Text("No matching locations found.");
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: results.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final item = results[index];
                  final location = item['location'] ?? '';
                  final imageUrl = item['imageurl'] ?? '';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.lightBlue.shade100),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade50,
                    ),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: CachedNetworkImage(
                          imageUrl:
                              imageUrl.isNotEmpty
                                  ? imageUrl
                                  : 'https://via.placeholder.com/60x60.png?text=📍',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  period: const Duration(milliseconds: 1500),
                                  child: Container(
                                    color: Colors.white,
                                    width: 50,
                                    height: 50,
                                  ),
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => const Icon(Icons.image),
                        ),
                      ),
                      title: Text(location),
                      onTap: () {
                        _addLocation(location);
                        _controller.clear();
                        ref.read(locationSearchQueryProvider.notifier).state =
                            '';
                        FocusScope.of(context).unfocus();
                      },
                    ),
                  );
                },
              );
            },
          ),
      ],
    );
  }
}
