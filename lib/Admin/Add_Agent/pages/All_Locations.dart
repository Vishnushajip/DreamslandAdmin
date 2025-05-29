import 'package:dladmin/Admin/Add_Agent/pages/Location_add.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredLocationsProvider = StreamProvider.autoDispose<
  List<QueryDocumentSnapshot<Map<String, dynamic>>>
>((ref) async* {
  final query = ref.watch(searchQueryProvider).toLowerCase();

  final snapshots =
      FirebaseFirestore.instance.collection('property_location').snapshots();

  await for (final snapshot in snapshots) {
    final filteredDocs =
        snapshot.docs.where((doc) {
          final data = doc.data();
          final locationName =
              (data['location'] ?? '').toString().toLowerCase();
          return locationName.contains(query);
        }).toList();

    yield filteredDocs;
  }
});

class LocationListPage extends ConsumerWidget {
  const LocationListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationsStream = ref.watch(filteredLocationsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(
          "Location List",
          style: GoogleFonts.nunito(color: Colors.black),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.bottomToTop,
                    child: LocationUploadPage(),
                    duration: Duration(milliseconds: 400),
                  ),
                );
              },
              child: Text(
                'Add Location',
                style: GoogleFonts.nunito(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              width: 300,
              child: TextField(
                onChanged: (value) {
                  ref.read(searchQueryProvider.notifier).state = value;
                },
                decoration: InputDecoration(
                  suffixIcon: Icon(FontAwesomeIcons.searchengin),
                  hintText: 'Enter location name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: locationsStream.when(
                loading:
                    () => const Center(
                      child: CircularProgressIndicator(
                        color: Colors.blue,
                        strokeWidth: 1,
                      ),
                    ),
                error: (error, _) => Center(child: Text('Error: $error')),
                data: (locations) {
                  if (locations.isEmpty) {
                    return const Center(child: Text('No locations found.'));
                  }

                  return ListView.builder(
                    itemCount: locations.length,
                    itemBuilder: (context, index) {
                      final doc = locations[index];
                      final data = doc.data();
                      final imageUrl = data['imageurl'] ?? '';
                      final locationName = data['location'] ?? 'No Name';

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue.shade100),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: SizedBox(
                              width: 60,
                              height: 60,
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => const Icon(
                                      Icons.broken_image,
                                      size: 40,
                                    ),
                              ),
                            ),
                          ),
                          title: Text(locationName),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed:
                                () => _confirmDelete(context, doc.id, ref),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    String docId,
    WidgetRef ref,
  ) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Delete Location"),
            content: const Text(
              "Are you sure you want to delete this location?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  "Delete",
                  style: GoogleFonts.nunito(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (shouldDelete == true) {
      await FirebaseFirestore.instance
          .collection('property_location')
          .doc(docId)
          .delete();
      ref.invalidate(filteredLocationsProvider);
      Fluttertoast.showToast(
        msg: "Location deleted successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    }
  }
}
