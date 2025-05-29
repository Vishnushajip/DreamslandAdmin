import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// Define the CallbackRequest model
class CallbackRequest {
  final String name;
  final String listingType;
  final String message;
  final String phone;
  final DateTime timestamp;

  CallbackRequest({
    required this.name,
    required this.listingType,
    required this.message,
    required this.phone,
    required this.timestamp,
  });

  factory CallbackRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CallbackRequest(
      name: data['name'] ?? '',
      listingType: data['listingType'] ?? '',
      message: data['message'] ?? '',
      phone: data['phone'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}

// Riverpod provider for pagination state
class PaginationState {
  final List<CallbackRequest> requests;
  final DocumentSnapshot? lastDocument;
  final bool hasMore;

  PaginationState({
    required this.requests,
    this.lastDocument,
    this.hasMore = true,
  });

  PaginationState copyWith({
    List<CallbackRequest>? requests,
    DocumentSnapshot? lastDocument,
    bool? hasMore,
  }) {
    return PaginationState(
      requests: requests ?? this.requests,
      lastDocument: lastDocument ?? this.lastDocument,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

final paginationProvider =
    StateNotifierProvider<PaginationNotifier, PaginationState>((ref) {
      return PaginationNotifier();
    });

class PaginationNotifier extends StateNotifier<PaginationState> {
  PaginationNotifier() : super(PaginationState(requests: [])) {
    fetchRequests();
  }

  final int _limit = 10;
  bool _isFetching = false;

  Future<void> fetchRequests({bool isLoadMore = false}) async {
    if (_isFetching || (!state.hasMore && isLoadMore)) return;
    _isFetching = true;

    Query query = FirebaseFirestore.instance
        .collection('contact_requests')
        .orderBy('timestamp', descending: true)
        .limit(_limit);

    if (isLoadMore && state.lastDocument != null) {
      query = query.startAfterDocument(state.lastDocument!);
    }

    final snapshot = await query.get();
    final newRequests =
        snapshot.docs.map((doc) => CallbackRequest.fromFirestore(doc)).toList();

    state = state.copyWith(
      requests: isLoadMore ? [...state.requests, ...newRequests] : newRequests,
      lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      hasMore: newRequests.length == _limit,
    );

    _isFetching = false;
  }
}

class CallbackRequestsScreen extends ConsumerWidget {
  const CallbackRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paginationState = ref.watch(paginationProvider);
    final paginationNotifier = ref.read(paginationProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Stack(
          children: [
            Center(
              child: Text(
                'Customer Callback Requests',
                style: GoogleFonts.nunito(
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          if (scrollInfo is ScrollEndNotification &&
              scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
              paginationState.hasMore) {
            paginationNotifier.fetchRequests(isLoadMore: true);
          }
          return false;
        },
        child: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount:
              paginationState.requests.length +
              (paginationState.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == paginationState.requests.length &&
                paginationState.hasMore) {
              return Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                  strokeWidth: 1,
                ),
              );
            }
            final request = paginationState.requests[index];
            return CallbackRequestCard(request: request);
          },
        ),
      ),
    );
  }
}

class CallbackRequestCard extends StatelessWidget {
  final CallbackRequest request;

  const CallbackRequestCard({super.key, required this.request});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Icon(
                      FontAwesomeIcons.user,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    request.name,
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),

              GestureDetector(
                onTap: () => _makePhoneCall(request.phone),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Icon(
                    FontAwesomeIcons.phone,
                    color: Colors.blue,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'LISTING TYPE',
            style: GoogleFonts.nunito(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            request.listingType,
            style: GoogleFonts.nunito(fontSize: 14, color: Colors.black87),
          ),
          SizedBox(height: 8),
          Text(
            'MESSAGE',
            style: GoogleFonts.nunito(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            request.message,
            style: GoogleFonts.nunito(fontSize: 14, color: Colors.black87),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PHONE',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    request.phone,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Date & Time',
            style: GoogleFonts.nunito(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '${request.timestamp.day.toString().padLeft(2, '0')}/${request.timestamp.month.toString().padLeft(2, '0')}/${(request.timestamp.year % 100).toString().padLeft(2, '0')} at ${_formatTime(request.timestamp)}',
            style: GoogleFonts.nunito(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour =
        time.hour > 12
            ? time.hour - 12
            : time.hour == 0
            ? 12
            : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
