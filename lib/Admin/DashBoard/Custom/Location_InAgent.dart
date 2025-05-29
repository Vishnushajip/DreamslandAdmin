import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

Stream<List<String>> searchLocations(String query) async* {
  try {
    print('Search initiated with query: $query');

    if (query.isEmpty) {
      print('Empty query, returning empty list');
      yield const [];
      return;
    }

    final agentQuery =
        await FirebaseFirestore.instance.collection('agents').get();

    final agentData = agentQuery.docs.first.data();
    print('Agent document data: $agentData');

    if (!agentData.containsKey('Allocatedlocations')) {
      print('Allocatedlocations field does not exist');
      yield const [];
      return;
    }

    final locations = agentData['Allocatedlocations'];
    print(
      'Raw Allocatedlocations value: $locations (Type: ${locations.runtimeType})',
    );

    List<String> locationList;
    if (locations is List<dynamic>) {
      locationList = locations.whereType<String>().toList();
    } else if (locations is String) {
      locationList = [locations];
    } else {
      print('Unexpected Allocatedlocations type: ${locations.runtimeType}');
      yield const [];
      return;
    }

    print('Processed locations list: $locationList');

    final filteredLocations =
        locationList
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

class LocationDropdownagent extends ConsumerStatefulWidget {
  final String? initialValue;
  final String? Suffixtext;
  final IconData? prefixIcon;
  final ValueChanged<String> onSelected;

  const LocationDropdownagent({
    super.key,
    required this.onSelected,
    this.initialValue,
    this.prefixIcon,
    this.Suffixtext,
  });

  @override
  ConsumerState<LocationDropdownagent> createState() =>
      _LocationDropdownState();
}

class _LocationDropdownState extends ConsumerState<LocationDropdownagent> {
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
            prefixIcon:
                widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
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
            hintText: "Select Location",
            suffixText: widget.Suffixtext,
            suffixStyle: GoogleFonts.poppins(fontSize: 13),
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
