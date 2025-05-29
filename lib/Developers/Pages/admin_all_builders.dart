import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../Services/Scaffold_Messanger.dart';
import '../Providers/Builders.dart';

class DevelopersPage extends ConsumerWidget {
  const DevelopersPage({super.key});

  static const desktopBreakpoint = 800;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devsAsyncValue = ref.watch(developersProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= desktopBreakpoint;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'Builders',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
        ),
      ),
      backgroundColor: Colors.white,
      body: devsAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (developers) {
          if (developers.isEmpty) {
            return const Center(child: Text('No developers found.'));
          }

          final children =
              developers
                  .map(
                    (dev) => DeveloperCard(
                      profile: dev,
                      width: isDesktop ? 250 : double.infinity,
                    ),
                  )
                  .toList();

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: children.length,
            itemBuilder:
                (_, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: children[index],
                ),
          );
        },
      ),
    );
  }
}

class DeveloperCard extends ConsumerWidget {
  final BuilderProfile profile;
  final double width;

  const DeveloperCard({super.key, required this.profile, required this.width});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deletionState = ref.watch(deletionNotifierProvider);
    final deleteNotifier = ref.read(deletionNotifierProvider.notifier);
    final isDeleting = deletionState.contains(profile.id);

    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade200, width: 2),
                ),
                child: ClipOval(
                  child:
                      profile.imageUrl.isNotEmpty
                          ? Image.network(
                            profile.imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.fill,
                          )
                          : Image.asset(
                            'assets/Logo.jpg',
                            width: 60,
                            height: 60,
                            fit: BoxFit.fill,
                          ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  profile.name,
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              icon:
                  isDeleting
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Icon(CupertinoIcons.trash, color: Colors.white),
              label: Text(
                isDeleting ? 'Deleting...' : 'Delete',
                style: GoogleFonts.nunito(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed:
                  isDeleting
                      ? null
                      : () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: Text(
                                  'Delete Developer',
                                  style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                content: Text(
                                  'Are you sure you want to delete this developer?',
                                  style: GoogleFonts.nunito(
                                    color: Colors.black,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(false),
                                    child: Text(
                                      'Cancel',
                                      style: GoogleFonts.nunito(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(true),
                                    child: Text(
                                      'Delete',
                                      style: GoogleFonts.nunito(
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                        );

                        if (confirm == true) {
                          await deleteNotifier.deleteDeveloper(
                            profile.id,
                            context,
                            profile.name,
                          );
                          CustomMessenger(
                            duration: Durations.extralong2,
                            backgroundColor: Colors.green,
                            textColor: Colors.white,
                            context: context,
                            message: 'Deleted ${profile.name}',
                          );
                        }
                      },
            ),
          ),
        ],
      ),
    );
  }
}
