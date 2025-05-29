import 'package:dladmin/Landing/floating_bottom_navigation_bar.dart';
import 'package:dladmin/Services/MacLikePageRoute.dart';
import 'package:dladmin/Services/Providers/activityLogsProvider.dart';
import 'package:firebase_cloud_firestore/firebase_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

final activityPreviewMinimizedProvider = StateProvider<bool>((ref) => false);

final todayActivityCountProvider = StreamProvider.family<int, String>((
  ref,
  collectionName,
) {
  final snapshots =
      FirebaseFirestore.instance.collection(collectionName).snapshots();

  return snapshots.map((querySnapshot) {
    final viewedDocs = querySnapshot.docs.where(
      (doc) => !doc.data().containsKey('viewed'),
    );
    return viewedDocs.length;
  });
});

class ActivityLogList extends ConsumerWidget {
  const ActivityLogList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncLogs = ref.watch(activityLogsProvider);
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Agent's Activity", style: GoogleFonts.numans()),
        centerTitle: true,
        backgroundColor: Color(0xFF1C3A6B),
        foregroundColor: Colors.white,
      ),
      body: asyncLogs.when(
        loading:
            () => const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            ),
        error: (e, _) => SizedBox.shrink(),
        data: (logs) {
          if (logs.isEmpty) {
            return const Center(child: Text('No activity logs found.'));
          }
          for (final log in logs.where((log) => true)) {
            FirebaseFirestore.instance
                .collection('activity_logs')
                .doc(log.id)
                .update({'viewed': true});
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 24),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              final isLeft = index % 2 == 0;

              return SizedBox(
                height: 150,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isLeft)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: _buildCard(
                            log,
                            isMobile,
                            Alignment.centerRight,
                          ),
                        ),
                      )
                    else
                      const Spacer(),

                    Column(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Color(0xFF1C3A6B),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                        if (index != logs.length - 1)
                          Container(
                            width: 2,
                            height: 120,
                            color: Color(0xFF1C3A6B),
                          ),
                      ],
                    ),

                    if (!isLeft)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: _buildCard(
                            log,
                            isMobile,
                            Alignment.centerLeft,
                          ),
                        ),
                      )
                    else
                      const Spacer(),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCard(ActivityLog log, bool isMobile, Alignment align) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: align,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              log.action,
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Agent: ${log.agentId}",
              style: GoogleFonts.nunito(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 2),
            Text(
              DateFormat.MMMd().add_jm().format(log.timestamp),
              style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class ActivityLogPreview extends ConsumerWidget {
  const ActivityLogPreview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(activityPreviewProvider);
    final isVisible = ref.watch(activityBottomSheetVisibleProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    return logsAsync.when(
      loading: () => const SizedBox(),
      error: (e, _) => const SizedBox(),
      data: (logs) {
        if (logs.isEmpty) return const SizedBox();

        final log = logs.first;

        return Container(
          width: screenWidth,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MacLikePageRoute(page: const ActivityLogList()),
              );
            },
            child: Row(
              children: [
                Lottie.asset(
                  'assets/icons8-notification.json',
                  width: 25,
                  height: 25,
                  fit: BoxFit.fill,
                  repeat: true,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: log.action,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: isVisible ? "Hide" : "Show",
                  icon: Icon(
                    isVisible ? Icons.visibility_off : Icons.visibility,
                    size: 18,
                    color: Colors.black54,
                  ),
                  onPressed: () {
                    ref
                        .read(activityBottomSheetVisibleProvider.notifier)
                        .state = !isVisible;
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

void navigateToActivityLog(BuildContext context) {
  Navigator.push(
    context,
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (_, __, ___) => const ActivityLogList(),
      transitionsBuilder: (_, animation, __, child) {
        // Scale from 0.9 to 1.0 and fade in
        return ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutExpo),
          ),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOut),
            ),
            child: child,
          ),
        );
      },
    ),
  );
}
