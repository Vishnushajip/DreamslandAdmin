import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

Stream<List<String>> searchLocations(String query) async* {
  try {
    print('Search initiated with query: $query');

    if (query.isEmpty) {
      print('Empty query, returning empty list');
      yield const [];
      return;
    }

    print('Fetching locations from property_location collection');

    final locationQuery =
        await FirebaseFirestore.instance.collection('property_location').get();

    if (locationQuery.docs.isEmpty) {
      print('No locations found');
      yield const [];
      return;
    }

    final List<String> locationList = locationQuery.docs
        .where((doc) => doc.data().containsKey('location'))
        .map((doc) => doc.data()['location'] as String)
        .toList();

    print('Fetched locations: $locationList');

    final filteredLocations = locationList
        .where((loc) => loc.toLowerCase().contains(query.toLowerCase()))
        .toList();

    print('Filtered locations: $filteredLocations');
    yield filteredLocations;
  } catch (e, stackTrace) {
    print('Error in searchLocations: $e');
    print('Stack trace: $stackTrace');
    yield const [];
  }
}

final locationSearchQueryProvider = StateProvider<String>((ref) => '');
final selectedLocationProvider = StateProvider<String?>((ref) => null);

class LocationDropdown extends ConsumerStatefulWidget {
  final String? initialValue;
  final ValueChanged<String> onSelected;

  const LocationDropdown({
    super.key,
    required this.onSelected,
    this.initialValue,
  });

  @override
  ConsumerState<LocationDropdown> createState() => _LocationDropdownState();
}

class _LocationDropdownState extends ConsumerState<LocationDropdown> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(locationSearchQueryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          cursorColor: Colors.black,
          controller: _controller,
          onChanged: (value) {
            ref.read(locationSearchQueryProvider.notifier).state = value;
          },
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1.0),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            hintText: "Search Location",
            suffixIcon: query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      ref.read(locationSearchQueryProvider.notifier).state = '';
                    },
                  )
                : null,
          ),
        ),
        const SizedBox(height: 10),
        if (query.isNotEmpty)
          StreamBuilder<List<String>>(
            stream: searchLocations(query),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Center(
                    child: LoadingAnimationWidget.progressiveDots(
                      color: const Color.fromARGB(255, 17, 70, 114),
                      size: 50,
                    ),
                  ),
                );
              }

              final results = snapshot.data ?? [];

              if (results.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text("No matching locations."),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final location = results[index];
                  return ListTile(
                    title: Text(location),
                    onTap: () {
                      _controller.text = location;
                      ref.read(locationSearchQueryProvider.notifier).state = '';
                      ref.read(selectedLocationProvider.notifier).state =
                          location;
                      widget.onSelected(location); // 🔁 update external state
                      FocusScope.of(context).unfocus(); // close keyboard
                    },
                  );
                },
              );
            },
          ),
      ],
    );
  }
}
